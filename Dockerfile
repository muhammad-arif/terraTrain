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
    notary \
    tmux

ADD . /terraTrain
RUN chmod +x bootstrap.sh
RUN ./bootstrap.sh
ENV HOME /terraTrain
RUN terraform init -input=false
ENTRYPOINT ["/bin/bash"]
