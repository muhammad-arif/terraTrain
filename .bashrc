# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=yes
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\n[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;202m\]\u\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;202m\]\h\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;202m\]\W\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;202m\]\A\[$(tput sgr0)\]-\[$(tput sgr0)\]\[\033[38;5;202m\]\d\[$(tput sgr0)\]]\n\\$ \[$(tput sgr0)\]'

else
    PS1='\n[\[$(tput bold)\]\u\[$(tput sgr0)\]]-[\[$(tput bold)\]\h\[$(tput sgr0)\]]-[\W]-[\A-\d]\n\\$ \[$(tput sgr0)\]'
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1='\n[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;202m\]\u\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;202m\]\h\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;202m\]\W\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;202m\]\A\[$(tput sgr0)\]-\[$(tput sgr0)\]\[\033[38;5;202m\]\d\[$(tput sgr0)\]]\n\\$ \[$(tput sgr0)\]'
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias h='http --verify=no'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
# adding some color variables
BLACK=$(tput setaf 0)           # ${BLACK}
RED=$(tput setaf 1)             # ${RED}
GREEN=$(tput setaf 2)           # ${GREEN}
YELLOW=$(tput setaf 3)          # ${YELLOW}
LIME_YELLOW=$(tput setaf 190)   # ${LIME_YELLOW}
POWDER_BLUE=$(tput setaf 153)   # ${POWDER_BLUE}
BLUE=$(tput setaf 4)            # ${BLUE}
MAGENTA=$(tput setaf 5)         # ${MAGENTA}
CYAN=$(tput setaf 6)            # ${CYAN}
WHITE=$(tput setaf 7)           # ${WHITE}
BRIGHT=$(tput bold)             # ${BRIGHT}
NORMAL=$(tput sgr0)             # ${NORMAL}
BLINK=$(tput blink)             # ${BLINK}
REVERSE=$(tput smso)            # ${REVERSE}
UNDERLINE=$(tput smul)          # ${UNDERLINE}

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################################################################################################################################
die () {
# Function for exiting with erorr
  ret=$?
  printf "\n$1\n"
  return "$ret"
}

source /terraTrain/config
complete -C /usr/bin/terraform terraform
alias d="docker"
alias k="kubectl"
alias h="helm"
alias ks="kubectl -n kube-system"
alias k-n-kubesystem="kubectl -n kube-system"
alias tt-genClientBundle="/bin/bash /terraTrain/client-bundle.sh"

# terraTrain-run function to create a cluster

tt-cleanup() {
  printf "\n${REVERSE}[Step-1]${YELLOW} Trying to uninstall the cluster...${NORMAL}\n"
  pkill launchpad
  /terraTrain/launchpad reset --force --config launchpad.yaml
  printf "\n${REVERSE}[Step-2]${YELLOW} Rebooting Machines...${NORMAL}\n"
  for i in $(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role!="nfs") | .attributes.public_dns')
    do 
    connect $i "sudo /sbin/shutdown -r now"
    sleep 5
  done 
  # rebooting nfs node
  connect  ubuntu@$(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="nfs") | .attributes.public_dns') "sudo /sbin/shutdown -r now" &>/dev/null

  printf "\n${BLINK}${YELLOW}[Step-2] Lets wait for 10 seconds for those machine to be available...\n${NORMAL}"
  sleep 20
  printf "\n${REVERSE}[Step-3]${YELLOW} Cleanig up Directories...\n${NORMAL}"
  for i in $(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role!="nfs") | .attributes.public_dns')
    do 
    connect $i "uptime; sudo rm -rf /var/lib/docker/* /etc/cni/* /etc/containerd/* /var/lib/containerd/* /var/lib/kubelet/* /var/lib/docker-engine/*; ls /var/lib/docker/* /etc/cni/* /etc/containerd/* /var/lib/containerd/* /var/lib/kubelet/* /var/lib/docker-engine/* "
  done
  # Clearing nfs node's NFS directory
  connect  ubuntu@$(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="nfs") | .attributes.public_dns') "sudo systemctl stop nfs-server;sudo rm -rf /var/nfs/general/*;sudo systemctl start nfs-server" &>/dev/null
  printf "\n${REVERSE}Done\n${YELLOW}Now change just the MKE,MCR,MSR version on config and run tt-reinstall ${NORMAL}\n"
}


tt-plan() {
    terraform plan -var-file=/terraTrain/config
}
tt-purge(){
terraform destroy -auto-approve -compact-warnings -var-file=/terraTrain/config
echo " " > /terraTrain/launchpad.yaml
}

tt-reinstall() {
  pkill launchpad
  /terraTrain/launchpad reset --force --config launchpad.yaml
  /terraTrain/configGenerator.sh
  nohup /terraTrain/launchpad apply --config launchpad.yaml &> /tmp/mke-installation.log &
  printf "\nMKE installation process is running.\nPlease check the MKE installation log buffer with the following command\ntail -f -n+1 /tmp/mke-installation.log\n"
}

tt-run() {
  var="aaaaaaaaaaaaallllllllllllllllllllllllllF"
  /usr/games/sl -e sl -${var:$(( RANDOM % ${#var} )):1} 
  printf "\n${REVERSE}[Step-1]${CYAN} Trying to spin up the instances on cloud...${NORMAL}\n"

  terraform apply -var-file=/terraTrain/config -auto-approve -compact-warnings || return 1 
  #Exporting AMI name for global reachability

  if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
  then
    amiUserName="ubuntu"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
  then
    export amiUserName="ec2-user"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
  then
    export amiUserName="centos"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
  then
    export amiUserName="ec2-user" 
  else
    echo "wrong Operating System Name" && return 1
  fi

  #echo "Do you want to see MKE installation logs?"
  #echo "Press y to see the logs and press any other key to ignore."
  #echo "You can always find the installation logs at /tmp/mke-installation.log"
  #
  #read input
  printf "\n${REVERSE}[Step-2]${MAGENTA} Generating configuration for Launchpad...${NORMAL}\n"

  /terraTrain/configGenerator.sh
  /terraTrain/launchpad register -name test --email test@mail.com --company "Mirantis Inc." -a yes
  nohup /terraTrain/launchpad apply --config launchpad.yaml &> /tmp/mke-installation.log &
  #
  #if (( "$input" == 'y' || "$input" == 'Y' )) ; then
  #  tail -f -n+1 /tmp/mke-installation.log | { sed '/Cluster is now configured/q'; pkill -PIPE -xg0 tail; } | tee output
  #  tt-show
  #else
  #    tt-show
  #fi
  tt-show
  printf "\n${BLINK}${REVERSE}[Step-3]${MAGENTA} MKE installation is running...${NORMAL}\n"

  printf "\nIf you want to check the installation process use following command for watching log buffer\n"
  
  printf "\n${BLINK}${MAGENTA}tail -f -n+1 /tmp/mke-installation.log\n${NORMAL}"
}


# terraTrain-show function to list the cluster details (more efficient than terraform binary) [time of execution: real	0m0.021s, user	0m0.019s, sys	0m0.005s ]
tt-show-clusterInfo() {
printf "\n MKE and MSR Information: \n"
echo "-------------------------------------------------------------------------------"
printf  '\e[1;34m%-6s\e[m' "MKE URL: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | ("https://" + .attributes.public_dns)' 2>/dev/null
printf  '\e[1;34m%-6s\e[m' "MSR URL: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="msrNode") | .instances[] | ("https://" + .attributes.public_dns)' 2>/dev/null
printf '\e[1;34m%-6s\e[m' "Username: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
printf  '\e[1;34m%-6s\e[m' "Password: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
}

tt-show-nodesInfo(){
printf "\n\n Manager Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n MSR Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="msrNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n Worker Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n Windows Worker Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="winNode") | .instances[] | { Name: .attributes.tags.Name, Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}

tt-show() {
tt-show-clusterInfo
tt-show-nodesInfo
}

tt-show-mke-creds() {
printf "\n\n MKE's Username and Password: \n"
echo "-------------------------------------------------------------------------------"
printf '\e[1;34m%-6s\e[m' "Username: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
printf '\e[1;34m%-6s\e[m' "Password: "
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
}



#tt-show-ldr() {
#printf "\n\n Leader Node: \n"
#echo "-------------------------------------------------------------------------------"
#cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="ucp-leader") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
#printf '\e[1;34m%-6s\e[m' "Username: "
#cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
#printf '\e[1;34m%-6s\e[m' "Password: "
#cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
#
#}
tt-show-mgr() {
printf "\n\n Manager Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}
tt-show-msr() {
printf "\n\n MSR Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="msrNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}
tt-show-wkr() {
printf "\n\n Worker Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}

tt-mke-toml-download() {
    UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
    uname=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    pass=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)
    AUTHTOKEN=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
    curl -k -H "Authorization: Bearer $AUTHTOKEN" https://${UCP_URL}/api/ucp/config-toml -o ucp-config.toml
}
tt-mke-toml-upload() {
    UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
    uname=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    pass=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)
    AUTHTOKEN=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
    curl -k -H "accept: application/toml" -H "Authorization: Bearer $AUTHTOKEN" --upload-file 'ucp-config.toml' https://${UCP_URL}/api/ucp/config-toml
}
tt-mke-swrm-svc-deploy() {
    if [[ -d /terraTrain/client-bundle ]] 
        then 
            docker stack deploy -c /terraTrain/dockercoin.yml dockercoin       
    else 
        echo "Please run tt-genClientBundle to generate client bundle first" 
    fi
}
tt-mke-k8s-svc-deploy() {
    if [[ -d /terraTrain/client-bundle ]] 
        then 
            kubectl apply -f /terraTrain/dockercoin.yaml
    else 
        echo "Please run tt-genClientBundle to generate client bundle first" 
    fi
}
tt-mke-rethinkcli() {
read echoedInput
UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
mke_private_ip=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.private_ip' 2>/dev/null)
connect-stripped $UCP_URL "echo \"$echoedInput\" | sudo docker run --rm -i -e DB_ADDRESS=$mke_private_ip -v ucp-auth-api-certs:/tls squizzi/rethinkcli-ucp non-interactive" | jq
}

tt-msr-rethinkcli() {
read echoedInput
msr=$(curl -k -H "Authorization: Bearer $auth" https://$ucpurl/api/ucp/config/dtr 2>/dev/null| jq -r ' .registries[] | .hostAddress')
connect-stripped $msr "echo \"$echoedInput\" | sudo docker run --rm -i --net dtr-ol -e DTR_REPLICA_ID=000000000001 -v dtr-ca-000000000001:/ca dockerhubenterprise/rethinkcli:v2.2.0-ni non-interactive " | jq
}

tt-mke-etcdctl() {
  read echoedInput
  UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
  connect-stripped $UCP_URL "docker exec -i -e ETCDCTL_API=2 ucp-kv etcdctl --endpoints https://127.0.0.1:2379 $echoedInput"
}



tt-msr-login() {
msr=$(curl -k -H "Authorization: Bearer $auth" https://$ucpurl/api/ucp/config/dtr 2>/dev/null| jq -r ' .registries[] | .hostAddress')
if [[ -d /terraTrain/client-bundle ]] 
    then 
    curl -k https://$msr/ca -o /usr/local/share/ca-certificates/$msr.crt 
    update-ca-certificates
    docker login $msr -u $uname -p $pass
else 
    echo "Please run tt-genClientBundle to generate client bundle first" 
fi
}

tt-msr-populate-img() {
    # Logging to MSR
    printf "\n YOU NEED TO ADD LICENSE TO MSR BEFORE RUNNING THIS COMMAND\n"
    sleep 1
    UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0)| .attributes.public_dns' 2>/dev/null)
    uname=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    pass=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)
    auth=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
    msr=$(curl -k -H "Authorization: Bearer $auth" https://$ucpurl/api/ucp/config/dtr 2>/dev/null| jq -r ' .registries[] | .hostAddress')
    curl -k https://$msr/ca -o /usr/local/share/ca-certificates/$msr.crt 
    update-ca-certificates
    docker login $msr -u $uname -p $pass
    printf "\nEnabling Create on push repository"
    curl -k -u $uname:$pass -X POST https://$msr/api/v0/meta/settings -H "accept: application/json" -H "content-type: application/json" -d "{ \"createRepositoryOnPush\": true}" &>/dev/null
    

    # Pulling and pushing images
    printf "\nStart Pulling and pushing\n"
    docker pull nginx:alpine &> /dev/null 
    docker tag nginx:alpine $msr/$uname/nginx:alpine || return 1
    docker pull nginx:latest &> /dev/null 
    docker tag nginx:alpine $msr/$uname/nginx:latest || return 1
    docker push $msr/$uname/nginx --all-tags || return 1

    docker pull alpine:3.13.4 &> /dev/null 
    docker tag alpine:3.13.4 $msr/$uname/alpine:3.13.4  || return 1
    docker pull alpine:latest &> /dev/null
    docker tag alpine:latest $msr/$uname/alpine:latest  || return 1
    docker push $msr/$uname/alpine --all-tags || return 1

    docker pull redis:alpine3.13 &> /dev/null
    docker tag redis:alpine3.13 $msr/$uname/redis:alpine3.13 || return 1
    docker pull redis:6.2.1-alpine3.13 &> /dev/null
    docker tag redis:6.2.1-alpine3.13 $msr/$uname/redis:6.2.1-alpine3.13 || return 1
    docker push $msr/$uname/redis --all-tags || return 1

    docker pull busybox:unstable-musl &> /dev/null
    docker tag busybox:unstable-musl $msr/$uname/busybox:unstable-musl || return 1
    docker pull busybox:uclibc &> /dev/null
    docker tag busybox:uclibc $msr/$uname/busybox:uclibc  || return 1
    docker push $msr/$uname/busybox --all-tags || return 1 

    docker pull hello-world:latest &> /dev/null
    docker tag hello-world:latest $msr/$uname/hello-world:latest || return 1
    docker pull hello-world:linux &> /dev/null
    docker tag hello-world:linux $msr/$uname/hello-world:linux || return 1
    docker push $msr/$uname/hello-world --all-tags || return 1
    
    docker pull haproxy:2.4-dev15-alpine &> /dev/null
    docker tag haproxy:2.4-dev15-alpine $msr/$uname/haproxy:2.4-dev15-alpine || return 1
    docker pull haproxy:2.2.13-alpine &> /dev/null
    docker tag  haproxy:2.2.13-alpine $msr/$uname/haproxy:2.2.13-alpine || return 1
    docker push $msr/$uname/haproxy --all-tags || return 1


    docker pull alpine/git:latest &> /dev/null
    docker tag alpine/git:latest $msr/$uname/git:latest || return 1
    docker pull alpine/git:v2.30.1 &> /dev/null
    docker tag alpine/git:v2.30.1 $msr/$uname/git:v2.30.1 || return 1
    docker push $msr/$uname/git --all-tags || return 1
}
tt-ec2-start() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | .attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-start-mgr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="manager") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-start-wkr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="worker") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-start-msr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="msr") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-start-win() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="win-worker") | .attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-stop() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | .attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-stop-wkr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="worker") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-stop-mgr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="manager") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-stop-msr() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="msr") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-stop-win() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="win-worker") |.attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
      printf "\nInstance Status: "
      aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
      printf "\n------\n"
  done
}
tt-ec2-status() {
  region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
  for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | .attributes.id ')
    do 
      printf "\nInstance Name: "
      cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name'
      printf "Instasnce Status: "
      aws ec2 describe-instances --instance-ids $i --region $region | jq '.Reservations[] | .Instances[] | .State.Name'
      printf "\n------\n"
  done
}
# Connect function to ssh into a machine
connect() {

  #validation check
  if [[ $# -eq 0 ]]
  then
  printf '
Usage:

Just to log in to a node. You can ssh into a node in following ways,

1. With Role:

For manager use m1, m2, m3 etc. 
    Example: connect m1
For workers use w1, w2, w3 etc. 
   Example: connect w2
For msr use d1, d2, d3 etc. 
    Example: connect d3
For windows use win1, win2, win3 etc. 
    Example: connect win3

2. With Hostname:
connect <nodes_public_dns/ip> 
    Example: connect ec2-18-156-117-231.eu-central-1.compute.amazonaws.com

To run a command inside a node connect <nodes_public_dns/ip/role> "<command-to-run-on-remote-machine>" 
E.g: connect m1 "docker ps | grep ucp-kv"
'
      return 0;
  fi

  if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
  then
    amiUserName="ubuntu"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
  then
    amiUserName="ec2-user"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
  then
    amiUserName="centos"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
  then
    amiUserName="ec2-user"
  else
    echo "wrong Operating System Name"
  fi



  count=$(echo $1 | grep -o . | wc -l)

  if [[ $count -eq 2 ]]
    then
      role=$(echo $1 | grep -o . | head -n 1)
      instanceNo=$(echo $1 | grep -o . | tail -n 1)
      index=`expr $instanceNo - 1`
      if [[ $role == 'm' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no manager $instanceNo\n" ; exit 1; }
      elif [[ $role == 'w' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no worker $instanceNo\n" ; exit 1; }
      elif [[ $role == 'd' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="msrNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="msrNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no MSR $instanceNo\n" ; exit 1; }
      else
          echo "wrong role"
          return 1
      fi
  elif [[ $1 =~ win[[:digit:]] ]]
    then
    instanceNo=$(echo $1 | grep -o . | tail -n 1)
    instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.name=="winNode") | .instances[] | select(.index_key==0) | .attributes.public_dns')
    mtype=win
  else
    instanceDNS=$1
    instanceName=$1
    mtype=linux
  fi

  if [[ $mtype == 'linux' ]]
    then
      printf "\n Logging into $instanceName...\n....\n"
      ssh -q -i /terraTrain/key-pair -o StrictHostKeyChecking=false -l $amiUserName $instanceDNS "$2"
  else
    if [[ $2 -eq 0 ]]
      then
      launchpad exec --interactive --target $instanceDNS
    else
      launchpad exec --target $instanceDNS $2
    fi
  fi
}
connect-stripped() {


  if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
  then
    amiUserName="ubuntu"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
  then
    amiUserName="ec2-user"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
  then
    amiUserName="centos"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
  then
    amiUserName="ec2-user"
  else
    echo "wrong Operating System Name"
  fi



  count=$(echo $1 | grep -o . | wc -l)

  if [[ $count -eq 2 ]]
    then
      role=$(echo $1 | grep -o . | head -n 1)
      instanceNo=$(echo $1 | grep -o . | tail -n 1)
      index=`expr $instanceNo - 1`
      if [[ $role == 'm' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no manager $instanceNo\n" ; exit 1; }
      elif [[ $role == 'w' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no worker $instanceNo\n" ; exit 1; }
      elif [[ $role == 'd' ]]
        then
          instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="msrNode") | .instances[] | select(.index_key==$i) | .attributes.public_dns')
          mtype=linux
          instanceName=$(cat /terraTrain/terraform.tfstate |  jq --argjson i $index -r '.resources[] | select(.name=="msrNode") | .instances[] | select(.index_key==$i) | .attributes.tags.Name')
          [[ -z "$instanceDNS" ]] && { printf "Don't test me B)\nThere is no MSR $instanceNo\n" ; exit 1; }
      else
          echo "wrong role"
          return 1
      fi
  elif [[ $1 =~ win[[:digit:]] ]]
    then
    instanceNo=$(echo $1 | grep -o . | tail -n 1)
    instanceDNS=$(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.name=="winNode") | .instances[] | select(.index_key==0) | .attributes.public_dns')
    mtype=win
  else
    instanceDNS=$1
    instanceName=$1
    mtype=linux
  fi

  if [[ $mtype == 'linux' ]]
    then
      ssh -q -i /terraTrain/key-pair -o StrictHostKeyChecking=false -l $amiUserName $instanceDNS "$2"
  else
    if [[ $2 -eq 0 ]]
      then
      launchpad exec --interactive --target $instanceDNS
    else
      launchpad exec --target $instanceDNS $2
    fi
  fi
}