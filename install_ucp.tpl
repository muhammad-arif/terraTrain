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
    OS=$(awk '{print $1}' /etc/redhat-release)
    VER=6
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi



if [ $(echo $OS | awk '{print $1}') == 'Red' ]; then
   echo "https://repos.mirantis.com/rhel" > /etc/yum/vars/dockerurl
   grep "VERSION_ID" /etc/os-release | sed -n 's/VERSION_ID="\(.*\)"$/\1/p' | awk -F '.' '{print $1}' | tee /etc/yum/vars/dockerosversion
   yum install -y yum-utils device-mapper-persistent-data lvm2
   yum-config-manager --enable rhel-7-server-extras-rpms
   yum-config-manager --enable rhui-REGION-rhel-server-extras
   yum-config-manager      --add-repo      "https://repos.mirantis.com/rhel/docker-ee.repo"
   yum install -y iptables-services
   yum install -y rh-amazon-rhui-client
   yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-3.el7.noarch.rpm
   yum install -y containerd.io 
   if [ $(echo ${dockerVERSION} | sed -n 's/\./\n/pg' | wc -l) == 3 ]; then SELECTOR="head -n 1" ; else SELECTOR="tail -n 1" ; fi
   yum -y install docker-ee-$(yum list docker-ee  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' | awk -F ':' '{print $2}'  | $SELECTOR) docker-ee-cli-$(yum list docker-ee-cli  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' |awk -F ':' '{print $2}'  | $SELECTOR)   
   systemctl enable docker
   systemctl start docker
   
#elif [ $(echo $OS | awk '{print $1}') = 'SLES' ]; then

elif [ $(echo $OS | awk '{print $1}') == 'CentOS' ]; then 
   echo "https://repos.mirantis.com/centos" > /etc/yum/vars/dockerurl
   VER="$(echo $VER | awk -F '.' '{print $1}')"
   echo "$VER" | tee /etc/yum/vars/dockerosversion
   yum install -y yum-utils device-mapper-persistent-data lvm2
   yum-config-manager --enable rhel-7-server-extras-rpms
   yum-config-manager --enable rhui-REGION-rhel-server-extras
   yum install -y rh-amazon-rhui-client
   yum-config-manager      --add-repo      "https://repos.mirantis.com/centos/docker-ee.repo"
   if [ $(echo ${dockerVERSION} | sed -n 's/\./\n/pg' | wc -l) == 3 ]; then SELECTOR="head -n 1" ; else SELECTOR="tail -n 1" ; fi
   yum -y install docker-ee-$(yum list docker-ee  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' | awk -F ':' '{print $2}'  | $SELECTOR) docker-ee-cli-$(yum list docker-ee-cli  --showduplicates | grep ${dockerVERSION} | sort -k3 |awk '{print $2}' |awk -F ':' '{print $2}'  | $SELECTOR)   
   systemctl enable docker
   systemctl start docker
   


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

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
SAN=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)
HOSTADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
UCP_HOSTADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
UCP_URL="https://$SAN/"

docker pull ${mkeREPOSITORY}:${ucpVERSION}
if [ $(echo $?) != 0 ] ; then
    MKEREPOSITORY="docker/ucp"
else 
    MKEREPOSITORY="mirantis/ucp"
fi
docker container run -i --rm --name ucp     \
    -v /var/run/docker.sock:/var/run/docker.sock    \
    $MKEREPOSITORY:${ucpVERSION} install           \
    --host-address $HOSTADDRESS \
    --san $SAN \
    --cloud-provider aws \
    --admin-username ${ucpAdminName} \
    --admin-password ${ucpAdminPass} 

while ! $(sudo docker node ls -q &>/dev/null) ; do echo "Swarm isn't ready yet";sleep 5 ; done

JOINCMD=$(sudo docker swarm join-token worker | grep 'docker.*' -o)
JOINCMD_MANAGER=$(sudo docker swarm join-token manager | grep 'docker.*' -o)

cp /home/"${amiUSERNAME}"/.ssh/key-pair ~/.ssh/key-pair

sleep 10
for ucpWorker in $(cat /tmp/ucp-worker-dns); do ssh -i ~/.ssh/key-pair -o StrictHostKeyChecking=false ${amiUSERNAME}@$ucpWorker "while ! $(which docker &>/dev/null) ; do echo 'Docker isnt ready yet';sleep 5 ; done; sudo $JOINCMD"; done
for ucpManager in $(cat /tmp/ucp-manager-dns); do ssh -i ~/.ssh/key-pair -o StrictHostKeyChecking=false ${amiUSERNAME}@$ucpManager "while ! $(which docker &>/dev/null) ; do echo 'Docker isnt ready yet';sleep 5 ; done; sudo $JOINCMD_MANAGER"; done
sleep 10

DTRHOSTNAME='$(cat /etc/hostname)'
for ucpDtr in $(head -n 1 /tmp/ucp-dtr-dns); do ssh -i ~/.ssh/key-pair -o StrictHostKeyChecking=false ${amiUSERNAME}@$ucpDtr "while ! $(curl -sSfk $UCP_URL/ca  &>/dev/null) ; do echo 'MKE (UCP) isnt ready yet';sleep 5 ; done; while ! $(which docker &>/dev/null) ; do echo 'Docker isnt ready yet';sleep 5 ; done;sudo $JOINCMD; sleep 10; sudo docker run -i --rm mirantis/dtr:${dtrVERSION} install --ucp-url  $UCP_URL --ucp-node $DTRHOSTNAME --ucp-insecure-tls --ucp-username ${ucpAdminName} --ucp-password ${ucpAdminPass} --dtr-external-url $ucpDtr --replica-id e6e1331b4888"; done
for ucpDtrReplica in $(tail -n +2 /tmp/ucp-dtr-dns); do ssh -i ~/.ssh/key-pair -o StrictHostKeyChecking=false ${amiUSERNAME}@$ucpDtrReplica "while ! $(which docker &>/dev/null) ; do echo 'Docker isnt ready yet';sleep 5 ; done; sudo $JOINCMD;  sleep 10; sudo docker run -i --rm mirantis/dtr:${dtrVERSION} join --ucp-url  $UCP_URL --ucp-node $DTRHOSTNAME --ucp-insecure-tls --ucp-username ${ucpAdminName} --ucp-password ${ucpAdminPass} --existing-replica-id e6e1331b4888"; done