FROM ubuntu:bionic-20210930

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
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    
RUN cp /terraTrain/bin/kubectl /usr/local/bin/kubectl && \
    chmod 755 /usr/local/bin/kubectl && \
    cp /terraTrain/bin/launchpad /usr/local/bin/launchpad && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    apt-get -y update && apt-get install -y  docker-ce-cli &&\
    cp /terraTrain/bin/terraform /bin/terraform && \
    cp /terraTrain/bin/helm /bin/helm && \
    cp /terraTrain/bin/t-commandline.bash /bin/t && \
    cp /terraTrain/bin/auger /bin/auger &&\
    cp /terraTrain/bin/t-commandline.bash /bin/terraTrain 
    
# Some housekeeping
RUN ssh-keygen -t rsa -b 4096 -f /terraTrain/key-pair -P "" && \
    cp .bashrc /root/.bashrc && \
    printf "\npublicKey=\"$(cat /terraTrain/key-pair.pub)\"" >> /terraTrain/config

ENV HOME /terraTrain
RUN /bin/terraform init -input=false
ENTRYPOINT ["/bin/bash"]