#!/bin/bash
################## DETECTING OS #####################
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS=Red
    VER=
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi


if [ $(echo $OS | awk '{print $1}') == 'Red' ]; then
   setenforce 0
   echo "https://repos.mirantis.com/rhel" > /etc/yum/vars/dockerurl
   grep "VERSION_ID" /etc/os-release | sed -n 's/VERSION_ID="\(.*\)"$/\1/p' | tee /etc/yum/vars/dockerosversion
   yum install -y yum-utils device-mapper-persistent-data lvm2
   yum-config-manager --enable rhel-7-server-extras-rpms
   yum-config-manager --enable rhui-REGION-rhel-server-extras
   yum-config-manager      --add-repo      "https://repos.mirantis.com/rhel/docker-ee.repo"
   yum install -y rh-amazon-rhui-client
   yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-3.el7.noarch.rpm
   yum install -y containerd.io 
   if [ $(echo ${dockerVERSION} | sed -n 's/\./\n/pg' | wc -l) == 3 ]; then SELECTOR="head -n 1" ; else SELECTOR="tail -n 1" ; fi
   
   yum -y install docker-ee-$(yum list docker-ee  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' | awk -F ':' '{print $2}'  | $SELECTOR) docker-ee-cli-$(yum list docker-ee-cli  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' |awk -F ':' '{print $2}'  | $SELECTOR)   
   
   systemctl enable docker
   systemctl start docker


#elif [ $(echo $OS | awk '{print $1}') = 'SLES' ]; then

elif [ $(echo $OS | awk '{print $1}') == 'Centos' ]; then 
   sudo yum update -y
   sudo yum install -y yum-utils
   export DOCKERURL="${dockerURL}"
   export VER="$(echo $VER | awk -F '.' '{print $1}')"
   sudo -E sh -c 'echo "$VER" > /etc/yum/vars/dockerosversion'
   sudo -E sh -c 'echo "$DOCKERURL/centos" > /etc/yum/vars/dockerurl'
   sudo -E yum-config-manager --add-repo "${dockerURL}/centos/docker-ee.repo"
   sudo yum -y install docker-ee-${dockerVERSION} docker-ee-cli-${dockerVERSION} containerd.io
   sudo systemctl enable docker
   sudo systemctl start docker


elif [ $(echo $OS | awk '{print $1}') == 'Ubuntu' ] ; then
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    DOCKERMAJORVERSION=$(echo ${dockerVERSION} | awk -F "." '{print $1"."$2}')
    curl -fsSL "https://repos.mirantis.com/ubuntu/gpg" | sudo apt-key add - 
    sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] ${dockerURL}/ubuntu/ $(lsb_release -cs) stable-$DOCKERMAJORVERSION"
    if [ $(echo ${dockerVERSION} | sed -n 's/\./\n/pg' | wc -l) == 3 ]; then SELECTOR="tail -n 1" ; else SELECTOR="head -n 1" ; fi
    sudo apt-get update -y
    sudo apt-get install -y docker-ee=$(apt-cache madison docker-ee | grep ${dockerVERSION} | $SELECTOR | awk -F " " '{print $3}') docker-ee-cli=$(apt-cache madison docker-ee | grep ${dockerVERSION} | $SELECTOR | awk -F " " '{print $3}') containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker

else 
   echo "CANNOT DETECT THE OPERATING SYSTEM"
fi