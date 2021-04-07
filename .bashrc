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
source /terraTrain/config.tfvars
complete -C /usr/bin/terraform terraform
alias d="docker"
alias k="kubectl"
alias k-n-kubesystem="kubectl -n kube-system"
alias tt-purge="terraform destroy --force -compact-warnings -var-file=/terraTrain/config.tfvars"
alias tt-genClientBundle="/bin/bash /terraTrain/client-bundle.sh"

# terraTrain-run function to create a cluster
tt-plan() {
    terraform plan -var-file=/terraTrain/config.tfvars
}
tt-run() {
var="aaaaaaaaaaaaallllllllllllllllllllllllllF"
/usr/games/sl -e sl -${var:$(( RANDOM % ${#var} )):1} 
terraform apply -var-file=/terraTrain/config.tfvars -auto-approve -compact-warnings
#echo "Yey! All of the instance were created by MKE installation is still in progress."
#echo "Do you want to see MKE installation logs?"
#echo "Press y to see the logs and press any other key to ignore"
#echo "You can close this log watching session with ctrl+c"

#read input
#if (( "$input" == 'y' || "$input" == 'Y' )) ; then
#    mke=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="ucp-leader") | .instances[] | .attributes.public_dns' 2>/dev/null)
#    mke_username=$(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n")
#
#    if (( $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") == 'ubuntu' )) ; then 
#    ssh -i key-pair -o StrictHostKeyChecking=false -l ${mke_username} ${mke} "sudo tail -f /var/log/cloud-init-output.log"   
#
#    elif (( $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") == 'ec2-user' )) ; then
#    # redhat 7 put all the cloud-init logs inside messages where redhat 8 uses cloud-init-output.log file
#    ssh -i key-pair -o StrictHostKeyChecking=false -l ${mke_username} ${mke} "if [ ! -f /var/log/cloud-init-output.log ] ; then sudo tail -f /var/log/messages | grep cloud-init; else sudo tail -f /var/log/cloud-init-output.log; fi"
#    
#    elif (( $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") == 'centos' )) ; then
#    mke=$(cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="ucp-leader") | .instances[] | .attributes.public_dns' 2>/dev/null)
#    ssh -i key-pair -o StrictHostKeyChecking=false -l ${mke_username} ${mke} "sudo tail -f /var/log/messages | grep cloud-init"   
#
#    else
#        echo "My bad. Can't detect the os"
#    fi
#else
#    exit 0
#fi
tt-show
}


# terraTrain-show function to list the cluster details (more efficient than terraform binary) [time of execution: real	0m0.021s, user	0m0.019s, sys	0m0.005s ]
tt-show() {
printf "\n\n MKE's Username and Password: \n"
echo "-------------------------------------------------------------------------------"
printf '\e[1;34m%-6s\e[m' "Username: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
printf  '\e[1;34m%-6s\e[m' "Password: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null

printf "\n\n Leader Node: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="ucp-leader") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n Manager Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n MSR Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="dtrNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf "\n\n Worker Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}
tt-show-mke-creds() {
printf "\n\n MKE's Username and Password: \n"
echo "-------------------------------------------------------------------------------"
printf '\e[1;34m%-6s\e[m' "Username: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
printf '\e[1;34m%-6s\e[m' "Password: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
}
tt-show-ldr() {
printf "\n\n Leader Node: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="ucp-leader") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
printf '\e[1;34m%-6s\e[m' "Username: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
printf '\e[1;34m%-6s\e[m' "Password: "
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null

}
tt-show-mgr() {
printf "\n\n Manager Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}
tt-show-msr() {
printf "\n\n MSR Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="dtrNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}
tt-show-wkr() {
printf "\n\n Worker Nodes: \n"
echo "-------------------------------------------------------------------------------"
cat terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, Hostname: .attributes.private_dns, PublicDNS: .attributes.public_dns, PublicIP: .attributes.public_ip }' 2>/dev/null
}

tt-mke-toml() {
    UCP_URL=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="ucp-leader") | .instances[] | .attributes.public_dns' 2>/dev/null)
    uname=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    pass=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)
    AUTHTOKEN=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
    curl -k -H "Authorization: Bearer $AUTHTOKEN" https://${UCP_URL}/api/ucp/config-toml -o ucp-config.toml
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
            kubectl apply -f https://k8s.io/examples/application/mysql/mysql-statefulset.yaml     
    else 
        echo "Please run tt-genClientBundle to generate client bundle first" 
    fi
}
tt-mke-rethinkcli() {
read echoedInput
UCP_URL=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="ucp-leader") | .instances[] | .attributes.public_dns' 2>/dev/null)
mke_private_ip=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="ucp-leader") | .instances[] | .attributes.private_ip' 2>/dev/null)
ssh -i ./key-pair -o StrictHostKeyChecking=false  -l $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") $UCP_URL "echo \"$echoedInput\" | sudo docker run --rm -i -e DB_ADDRESS=$mke_private_ip -v ucp-auth-api-certs:/tls squizzi/rethinkcli-ucp non-interactive" | jq
}

tt-msr-rethinkcli() {
read echoedInput
msr=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="dtrNode") | .instances[] | .attributes.public_dns' 2>/dev/null | head -n 1)
ssh -i ./key-pair -o StrictHostKeyChecking=false  -l $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") $msr "echo \"$echoedInput\" | sudo docker run --rm -i --net dtr-ol -e DTR_REPLICA_ID=e6e1331b4888 -v dtr-ca-e6e1331b4888:/ca dockerhubenterprise/rethinkcli:v2.3.0-ni non-interactive " | jq
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
    tt-msr-login

    # Enabling create repo on push
    msr=$(curl -k -H "Authorization: Bearer $auth" https://$ucpurl/api/ucp/config/dtr 2>/dev/null| jq -r ' .registries[] | .hostAddress')
    # Pulling and pushing images
    
    docker pull nginx:alpine
    docker tag nginx:alpine $msr/$uname/nginx:alpine
    docker pull nginx:latest
    docker tag nginx:alpine $msr/$uname/nginx:latest
    docker push $msr/$uname/nginx --all-tags

    docker pull alpine:3.13.4 
    docker tag alpine:3.13.4 $msr/$uname/alpine:3.13.4
    docker pull alpine:latest
    docker tag alpine:latest $msr/$uname/alpine:latest
    docker push $msr/$uname/alpine --all-tags

    docker pull redis:alpine3.13
    docker tag redis:alpine3.13 $msr/$uname/redis:alpine3.13
    docker pull redis:6.2.1-alpine3.13
    docker tag redis:6.2.1-alpine3.13 $msr/$uname/redis:6.2.1-alpine3.13
    docker push $msr/$uname/redis --all-tags

    docker pull busybox:unstable-musl
    docker tag busybox:unstable-musl $msr/$uname/busybox:unstable-musl
    docker pull busybox:uclibc    
    docker tag busybox:uclibc $msr/$uname/busybox:uclibc
    docker push $msr/$uname/busybox --all-tags

    docker pull hello-world:latest
    docker tag hello-world:latest $msr/$uname/hello-world:latest
    docker pull hello-world:linux
    docker tag hello-world:linux $msr/$uname/hello-world:linux
    docker push $msr/$uname/hello-world --all-tags

    docker pull haproxy:2.4-dev15-alpine
    docker tag haproxy:2.4-dev15-alpine $msr/$uname/haproxy:2.4-dev15-alpine
    docker pull haproxy:2.2.13-alpine
    docker tag  haproxy:2.2.13-alpine $msr/$uname/haproxy:2.2.13-alpine
    docker push $msr/$uname/haproxy --all-tags


    docker pull alpine/git:latest
    docker tag alpine/git:latest $msr/$uname/git:latest
    docker pull alpine/git:v2.30.1
    docker tag alpine/git:v2.30.1 $msr/$uname/git:v2.30.1
    docker push $msr/$uname/git --all-tags
}
tt-msr-populate-orgs() {
msr=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="dtrNode") | .instances[] | .attributes.public_dns' 2>/dev/null | head -n 1)

}

# Connect function to ssh into a machine
connect() {
ssh -i ./key-pair -o StrictHostKeyChecking=false  -l $(awk -F= -v key="amiUserName" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | tr -d "\n") $1 "$2"
}