FROM ubuntu:bionic-20200921

MAINTAINER Muhammad Ariful Islam (Arif): 'mchowdhury@mirantis.com'

WORKDIR /terraTrain

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y \
    iputils-ping \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    dnsutils \
    git \
    curl \
    vim \
    apt-utils \
    software-properties-common \
    gnupg2 \
    sl \
    jq \
    unzip \
    ldap-utils \
    notary \
    httpie \
    tmux

ADD . /terraTrain

# Installing teraform,kubctl,docker-cli,aws-cli,launchpad
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    cp kubectl /usr/local/bin/kubectl && \
    chmod 755 /usr/local/bin/kubectl && \
    cp /terraTrain/launchpad-linux-x64 /usr/local/bin/launchpad && \
    chmod 755 /terraTrain/launchpad-linux-x64 /usr/local/bin/launchpad && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    apt-get -y update && apt-get install -y terraform  docker-ce-cli &&\
    chmod +x t-commandline.bash && \
    cp t-commandline.bash /bin/t && \
    cp auger /bin/auger &&\
    cp t-commandline.bash /bin/terraTrain 
    
 
# Some housekeeping
RUN ssh-keygen -t rsa -b 4096 -f /terraTrain/key-pair -P "" && \
    cp .bashrc /root/.bashrc && \
    printf "\npublicKey=\"$(cat /terraTrain/key-pair.pub)\"" >> /terraTrain/config.tfvars

ENV HOME /terraTrain
RUN terraform init -input=false
ENTRYPOINT ["/bin/bash"]