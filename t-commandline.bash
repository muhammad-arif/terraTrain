#!/bin/bash
#Enabling exteded globbing
shopt -s extglob
### Color functionality
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
### t deploy lab|cluster|instances  
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

  if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
  then
    amiUserName="ubuntu"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
  then
    amiUserName="ec2-user"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
  then
    amiUserName="centos"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
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
      ssh -i /terraTrain/key-pair -o StrictHostKeyChecking=false -l $amiUserName $instanceDNS "$2"
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
  if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
  then
    amiUserName="ubuntu"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
  then
    amiUserName="ec2-user"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
  then
    amiUserName="centos"
  elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
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
      ssh -i /terraTrain/key-pair -o StrictHostKeyChecking=false -l $amiUserName $instanceDNS "$2"
  else
    if [[ $2 -eq 0 ]]
      then
      launchpad exec --interactive --target $instanceDNS
    else
      launchpad exec --target $instanceDNS $2
    fi
  fi
}
t-deploy() {
  case "$1" in
    "lab") t-deploy-lab 
	       exit;;
	"cluster") t-deploy-cluster
	       exit;;
	"instances") t-deploy-instances
	       exit;;
	*) echo "t deploy lab|cluster|instances"
	   exit ;;
  esac
}
t-deploy-lab() { 
	var="aaaaaaaaaaaaallllllllllllllllllllllllllF"
	/usr/games/sl -e sl -${var:$(( RANDOM % ${#var} )):1} 
	printf "\n${REVERSE}[Step-1]${CYAN} Trying to spin up the instances on cloud...${NORMAL}\n"
	terraform apply -var-file=/terraTrain/config.tfvars -auto-approve -compact-warnings || return 1 
	#Exporting AMI name for global reachability
	if [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "ubuntu" ]] 
	then
	  amiUserName="ubuntu"
	elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "redhat" ]] 
	then
	  export amiUserName="ec2-user"
	elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "centos" ]] 
	then
	  export amiUserName="centos"
	elif [[ $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n") == "suse" ]] 
	then
	  export amiUserName="ec2-user" 
	else
	  echo "wrong Operating System Name" && return 1
	fi

	printf "\n${REVERSE}[Step-2]${MAGENTA} Generating configuration for Launchpad...${NORMAL}\n"
	/terraTrain/configGenerator.sh
	/terraTrain/launchpad-linux-x64 register -name test --email test@mail.com --company "Mirantis Inc." -a yes
	nohup /terraTrain/launchpad-linux-x64 apply --config launchpad.yaml &> /tmp/mke-installation.log &

	t-show-all
	printf "\n${BLINK}${REVERSE}[Step-3]${MAGENTA} MKE installation is running...${NORMAL}\n"
	printf "\nIf you want to check the installation process use following command for watching log buffer\n"

	printf "\n${BLINK}${MAGENTA}tail -f -n+1 /tmp/mke-installation.log\n${NORMAL}"
}	
t-deploy-cluster() { 
	printf "\n${REVERSE}[Step-1]${YELLOW} Trying to clean up any previous resedue...${NORMAL}\n"
	pkill launchpad
	/terraTrain/launchpad-linux-x64 reset --force --config launchpad.yaml &>/dev/null
	
	printf "\n${REVERSE}[Step-2]${YELLOW} Generating Launchpad Configuration...${NORMAL}\n"
	/terraTrain/configGenerator.sh
	
	printf "\n${REVERSE}[Step-3]${YELLOW} Executing Launchpad...${NORMAL}\n"
	nohup /terraTrain/launchpad-linux-x64 apply --config launchpad.yaml &> /tmp/mke-installation.log &
	
	printf "\n${BLINK}${REVERSE}[Step-3]${MAGENTA} MKE installation is running...${NORMAL}\n"
	printf "\nIf you want to check the installation process use following command for watching log buffer\n"
	printf "\n${BLINK}${MAGENTA}tail -f -n+1 /tmp/mke-installation.log\n${NORMAL}"
}
t-deploy-instances() { 
	var="aaaaaaaaaaaaallllllllllllllllllllllllllF"
	/usr/games/sl -e sl -${var:$(( RANDOM % ${#var} )):1} 
	printf "\n${REVERSE}[Step-1]${CYAN} Trying to spin up the instances on cloud...${NORMAL}\n"
	terraform apply -var-file=/terraTrain/config.tfvars -auto-approve -compact-warnings || return 1 
}
### t destroy lab|cluster  DONE 
t-destroy() {
  case "$1" in
    "lab") t-destroy-lab 
	       exit;;
	"cluster") t-destroy-cluster
	       exit;;
	"instances") t-destroy-lab 
	      exit;;
    *) echo "t destroy lab|cluster"
	   exit;;
  esac
}
t-destroy-lab() {
	printf "\n This will destroy all of the cloud instances. \n you have about 5 sec to press ctrl+c :D"
	sleep 5
	printf "\n${REVERSE}[Step 1]${RED} Destroying Cloud Instances ${NORMAL}\n"
	terraform destroy -auto-approve -compact-warnings -var-file=/terraTrain/config.tfvars
	echo " " > /terraTrain/launchpad.yaml
}
t-destroy-cluster() { 
	echo "t-destroy-cluster was called "
	printf "\nThis will cleanup the MKE,MCR and MSR from the Cloud instances. \nYou have about 3 sec to press ctrl+c :D"
	sleep 3
	printf "\n${REVERSE}[Step-1]${YELLOW} Trying to uninstall the cluster...${NORMAL}\n"
	pkill launchpad
	/terraTrain/launchpad-linux-x64 reset --force --config /terraTrain/launchpad.yaml
	
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
	printf "\n${REVERSE}Done\n${YELLOW}Now change just the MKE,MCR,MSR version on config.tfvars and run tt-reinstall ${NORMAL}\n"
}  
# what about t-destroy-instances ?? Will we implement such thing? 
### t stop managers|msrs|workers|windows   DONE 
### Have not implemented the : t stop manager1 (t stop manager 1)
t-stop() {
  case "$1" in
    m|manager|managers|man) t-stop-managers
			exit;;
	ms|msr|msrs|dtrs|dtr|d)  t-stop-msrs
			exit;;
	w|wkr|wrk|work|worker|workers) t-stop-workers
			exit;;
	wi|win|windows|winworker|winworkers) t-stop-windows
			exit;;
	a|al|all) 	t-stop-windows ; t-stop-workers ; t-stop-msrs ; t-stop-managers
			exit;;
	*) echo "t stop managers|msrs|workers|windows"
	   exit ;;
  esac
}
t-stop-managers() { 
	echo "t-stop-managers was called"
	printf "\n${REVERSE}[Step-1]${YELLOW} Stopping the Manager instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="manager") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-stop-msrs() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Stopping the MSR instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="msr") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-stop-workers() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Stopping the Worker instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="worker") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-stop-windows() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Stopping the Windows Worker instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="win-worker") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 stop-instances --instance-ids $i --region $region | jq '.StoppingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
# t start managers|msrs|workers|windows DONE
t-start() {
  case "$1" in
    m|manager|managers|man) t-start-managers
			exit;;
	ms|msr|msrs|dtrs|dtr|d)  t-start-msrs
			exit;;
	w|wkr|wrk|work|worker|workers) t-start-workers
			exit;;
	wi|win|windows|winworker|winworkers) t-start-windows
			exit;;
	a|al|all) 	t-start-windows ; t-start-workers ; t-start-msrs ; t-start-managers
			exit;;
	*) echo "t stop managers|msrs|workers|windows"
	   exit ;;
  esac
}
t-start-managers() { 
	echo "t-stop-managers was called"
	printf "\n${REVERSE}[Step-1]${YELLOW} Starting the Manager instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="manager") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-start-msrs() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Starting the MSR instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="msr") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-start-workers() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Starting the Worker instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="worker") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
t-start-windows() { 
    printf "\n${REVERSE}[Step-1]${YELLOW} Starting the Windows Worker instances...${NORMAL}\n"
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="win-worker") |.attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name' 
		printf "\nInstance Status: "
		aws ec2 start-instances --instance-ids $i --region $region | jq '.StartingInstances[] | .CurrentState.Name'
		printf "\n------\n"
	done
}
### t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images
t-gen-client_bundle() {
	/bin/bash /terraTrain/client-bundle.sh
}
t-gen-msr_login() {
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
t-gen-swarm_service() {
	if [[ -d /terraTrain/client-bundle ]] 
	        then 
	            docker stack deploy -c /terraTrain/dockercoin.yml dockercoin       
	    else 
	        echo "Please run tt-genClientBundle to generate client bundle first" 
	    fi
}
t-gen-k8s_service() {
	if [[ -d /terraTrain/client-bundle ]] 
	        then 
	            kubectl apply -f /terraTrain/dockercoin.yaml
	    else 
	        echo "Please run tt-genClientBundle to generate client bundle first" 
	    fi
}
t-gen-msr_images() {
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
t-gen-msr_orgs() {
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
    curl -k -u $uname:$pass -X POST https://$msr/api/v0/meta/settings -H "accept: application/json" -H "content-type: application/json" -d "{ \"createRepositoryOnPush\": true}" &>/dev/null
    printf "\nCreating an Organization"
	curl -k -u $uname:$pass -XPOST https://$msr/enzi/v0/accounts -H 'content-type: application/json'  -d '{"isOrg" : true, "name" : "mirantis" }'
	curl -k -u $uname:$pass -XPOST https://$msr/enzi/v0/accounts -H 'content-type: application/json'  -d '{"isOrg" : true, "name" : "docker" }'

    # Pulling and pushing images
    printf "\nStart Pulling and pushing\n"
    docker pull nginx:alpine &> /dev/null 
    docker tag nginx:alpine $msr/mirantis/nginx:alpine || return 1
	docker tag nginx:alpine $msr/mirantis/nginx:alpine || return 1
    docker pull nginx:latest &> /dev/null 
    docker tag nginx:alpine $msr/mirantis/nginx:latest || return 1
    docker push $msr/mirantis/nginx --all-tags || return 1

    docker pull alpine:3.13.4 &> /dev/null 
    docker tag alpine:3.13.4 $msr/mirantis/alpine:3.13.4  || return 1
    docker pull alpine:latest &> /dev/null
    docker tag alpine:latest $msr/mirantis/alpine:latest  || return 1
    docker push $msr/mirantis/alpine --all-tags || return 1

    docker pull redis:alpine3.13 &> /dev/null
    docker tag redis:alpine3.13 $msr/docker/redis:alpine3.13 || return 1
    docker pull redis:6.2.1-alpine3.13 &> /dev/null
    docker tag redis:6.2.1-alpine3.13 $msr/docker/redis:6.2.1-alpine3.13 || return 1
    docker push $msr/docker/redis --all-tags || return 1

    docker pull busybox:unstable-musl &> /dev/null
    docker tag busybox:unstable-musl $msr/docker/busybox:unstable-musl || return 1
    docker pull busybox:uclibc &> /dev/null
    docker tag busybox:uclibc $msr/docker/busybox:uclibc  || return 1
    docker push $msr/docker/busybox --all-tags || return 1 

    docker pull hello-world:latest &> /dev/null
    docker tag hello-world:latest $msr/mirantis/hello-world:latest || return 1
    docker pull hello-world:linux &> /dev/null
    docker tag hello-world:linux $msr/mirantis/hello-world:linux || return 1
    docker push $msr/mirantis/hello-world --all-tags || return 1
    
    docker pull haproxy:2.4-dev15-alpine &> /dev/null
    docker tag haproxy:2.4-dev15-alpine $msr/docker/haproxy:2.4-dev15-alpine || return 1
    docker pull haproxy:2.2.13-alpine &> /dev/null
    docker tag  haproxy:2.2.13-alpine $msr/docker/haproxy:2.2.13-alpine || return 1
    docker push $msr/docker/haproxy --all-tags || return 1


    docker pull alpine/git:latest &> /dev/null
    docker tag alpine/git:latest $msr/mirantis/git:latest || return 1
    docker pull alpine/git:v2.30.1 &> /dev/null
    docker tag alpine/git:v2.30.1 $msr/mirantis/git:v2.30.1 || return 1
    docker push $msr/$mirantis/git --all-tags || return 1
}
#### t show ip managers|msrs|workers|windows|all 
t-show-ip() {
  case "$1" in
    m|manager|managers|man) t-show-ip-managers
			exit;;
	ms|msr|msrs|dtrs|dtr|d) t-show-ip-msrs
			exit;;
	w|wkr|wrk|work|worker|workers) t-show-ip-workers
			exit;;
	wi|win|windows|winworker|winworkers) t-show-ip-windows
			exit;;
	a|al|all) t-show-ip-all
	       exit;;
	*) echo "t show ip managers|msrs|workers|windows|all"
	   exit;;
  esac
}
t-show-ip-managers() { 
	printf "\n\n Manager Nodes IP: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, PublicIP: .attributes.public_ip }' 2>/dev/null
	}
t-show-ip-msrs() { 
	printf "\n\n MSR Nodes IP: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="msrNode") | .instances[] | { Name: .attributes.tags.Name, PublicIP: .attributes.public_ip }' 2>/dev/null
}
t-show-ip-workers() { 
	printf "\n\n Worker Nodes IP: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, PublicIP: .attributes.public_ip }' 2>/dev/null
}
t-show-ip-windows() { 
	printf "\n\n Windows Nodes IP: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="winNode") | .instances[] | { Name: .attributes.tags.Name, PublicIP: .attributes.public_ip }' 2>/dev/null
}
t-show-ip-all() {
  t-show-ip-managers
  t-show-ip-msrs
  t-show-ip-workers
  # t-show-ip-windows   # if windows VMs exist 
}
#### t show dns managers|msrs|workers|windows|all   
t-show-dns() {
  case "$1" in
    m|manager|managers|man) t-show-dns-managers
			exit;;
	ms|msr|msrs|dtrs|dtr|d)    t-show-dns-msrs
			exit;;
	w|wkr|wrk|work|worker|workers) t-show-dns-workers
			exit;;
	wi|win|windows|winworker|winworkers) t-show-dns-windows
			exit;;
	a|al|all) t-show-dns-all
	      exit;;
	*) echo "t show dns managers|msrs|workers|windows|all"
	   exit ;;
  esac
}
t-show-dns-managers() { 
	printf "\n\n Manager Nodes: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="managerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), PublicDNS: .attributes.public_dns}' 2>/dev/null
	}
t-show-dns-workers() { 
	printf "\n\n MSR Nodes: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="workerNode") | .instances[] | { Name: .attributes.tags.Name, URL: ("https://" + .attributes.public_dns), PublicDNS: .attributes.public_dns}' 2>/dev/null
	}
t-show-dns-msrs() { 
	printf "\n\n Workers Nodes: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="msrNode") | .instances[] | { Name: .attributes.tags.Name, PublicDNS: .attributes.public_dns}' 2>/dev/null
	}
t-show-dns-windows() { 
	printf "\n\n Windows Nodes: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="winNode") | .instances[] | { Name: .attributes.tags.Name, PublicDNS: .attributes.public_dns}' 2>/dev/null
	}
t-show-dns-all() {
  t-show-dns-managers
  t-show-dns-msrs
  t-show-dns-workers
  # t-show-dns-windows   # if windows VMs exist 
}
#### t show hostname managers|msrs|workers|windows  
t-show-hostname() {
  case "$1" in
    m|manager|managers|man) t-show-hostname-managers
			exit;;
	ms|msr|msrs|dtrs|dtr|d)    t-show-hostname-msrs
			exit;;
	w|wkr|wrk|work|worker|workers) t-show-hostname-workers
			exit;;
	wi|win|windows|winworker|winworkers) t-show-hostname-windows
			exit;;
	*) echo "t show dns managers|msrs|workers|windows|all"
	   exit ;;
  esac
}
t-show-hostname-managers() { 
  echo "t show hostname managers was typed"
}
t-show-hostname-msrs() { 
  echo "t show hostname msrs was typed"
}
t-show-hostname-workers() { 
  echo "t show hostname workers was typed"
}
t-show-hostname-windows() { 
  echo "t show hostname windows was typed"
}
#### t show creds mke|msr      
t-show-creds() {
  case "$1" in
    mke|manager|leader|login|msrs|msr|ms|dtr|dtrs|d) t-show-creds-mke
			exit;;
	linux|worker|node) t-show-creds-linux
			exit;;
	wi|win|windows|winworker|winworkers) t-show-creds-windows
			exit;;
	*) printf "Usage\nt show creds mke\nt show creds msrs\nt show creds linux\nt show creds windows\n"
	   exit ;;
  esac
}                     
t-show-creds-mke() { 
	printf "\n\n MKE's Username and Password: \n"
	echo "-------------------------------------------------------------------------------"
	printf '\e[1;34m%-6s\e[m' "Username: "
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
	printf '\e[1;34m%-6s\e[m' "Password: "
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
}
t-show-creds-msr() { 
	printf "\n\n MSR's Username and Password: \n"
	echo "-------------------------------------------------------------------------------"	
	printf '\e[1;34m%-6s\e[m' "Username: "
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null
	printf '\e[1;34m%-6s\e[m' "Password: "
	cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null
}
t-show-creds-linux() { 
	cat /terraTrain/key-pair
	printf "\nYou also can find the private key here:\n/terraTrain/key-pair"
	printf "\nUsage: ssh -i /terraTrain/key-pair ....\n"
}
t-show-creds-windows() { 
	printf "\nYou can use the following information for accessing windows Nodes\n"
	printf "\nUsername: Administrator\n"
	printf "\nPassword: $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)\n"
}
### t show access​-ke​y-linux|access​-ke​y-windows
t-show-access​_ke​y_linux() { 
	cat /terraTrain/key-pair
	printf "\nYou also can find the private key here:\n/terraTrain/key-pair"
	printf "\nUsage: ssh -i /terraTrain/key-pair ....\n"
}
t-show-access​_ke​y_windows() { 
	printf "\nYou can use the following information for accessing windows Nodes\n"
	printf "\nUsername: Administrator\n"
	printf "\nPassword: $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)\n"
}
#### t show status managers|msrs|workers|windows|all  
t-status() {
  case "$1" in 
  m|manager|managers|man) t-status-managers
              exit;;
  ms|msr|msrs|dtrs|dtr|d) t-status-msrs
          exit;;
  w|wkr|wrk|work|worker|workers) t-status-workers 
            exit;;
  wi|win|windows|winworker|winworkers) t-status-windows 
            exit;;
  a|al|all) t-status-all
        exit;;
  *) printf "\nUsage: \nt status managers\nt status msrs\nt status workers\nt status windows\t status all"
  esac 
}
t-status-managers() { 
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | .attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name'
		printf "Instasnce Status: "
		aws ec2 describe-instances --instance-ids $i --region $region | jq '.Reservations[] | .Instances[] | .State.Name'
		printf "\n------\n"
	done
}
t-status-msrs() { 
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="msrNode") | .instances[] | .attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name'
		printf "Instasnce Status: "
		aws ec2 describe-instances --instance-ids $i --region $region | jq '.Reservations[] | .Instances[] | .State.Name'
		printf "\n------\n"
	done
}
t-status-workers() { 
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="workerNode") | .instances[] | .attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name'
		printf "Instasnce Status: "
		aws ec2 describe-instances --instance-ids $i --region $region | jq '.Reservations[] | .Instances[] | .State.Name'
		printf "\n------\n"
	done
}
t-status-windows() { 	
	region=$(awk -F= -v key="region" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
	for i in $(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="winNode") | .instances[] | .attributes.id ')
		do 
		printf "\nInstance Name: "
		cat /terraTrain/terraform.tfstate 2>/dev/null | jq --arg instanceId $i '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.id==$instanceId) | .attributes.tags.Name'
		printf "Instasnce Status: "
		aws ec2 describe-instances --instance-ids $i --region $region | jq '.Reservations[] | .Instances[] | .State.Name'
		printf "\n------\n"
	done
}
t-status-all() {
  t-status-managers 
  t-status-msrs
  t-status-workers
  t-status-windows
}
### t show versions 
t-show-versions() {
	printf "OS  :${CYAN}   $(awk -F= -v key="os_name" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")-$(awk -F= -v key="os_version" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d \"\n\")${NORMAL}\n"
	printf "MCR :${CYAN}   $(awk -F= -v key="mcr_version" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d \"\n\")${NORMAL}\n"
	printf "MKE :${CYAN}   $(awk -F= -v key="mke_version" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d \"\n\")${NORMAL}\n"
	printf "MSR :${CYAN}   $(awk -F= -v key="msr_version" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d \"\n\")${NORMAL}\n"
}
### t show all 
t-show-all() { 
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
	printf "\n\n MSR Storage NFS Node: \n"
	echo "-------------------------------------------------------------------------------"
	cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.type=="aws_instance") | .instances[] | select(.attributes.tags.role=="nfs") | { Name: .attributes.tags.Name, PublicDNS: .attributes.public_dns, }' 2>/dev/null
}
### t exec etcdctl
t-exec-etcdctl() {
	read echoedInput
	UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
	connect-stripped $UCP_URL "docker exec -i -e ETCDCTL_API=2 ucp-kv etcdctl --endpoints https://127.0.0.1:2379 $echoedInput"
}
#### t exec rethinkcli mke|msr
t-exec-rethinkcli() {
  case "$1" in
    "mke") t-exec-rethinkcli-mke
	      exit;;
	"msr") t-exec-rethinkcli-msr 
	      exit;;
	*) printf "\nUsage: \necho \"r.db('enzi').tableList()\" | t exec rethinkcli mke\necho \"r.db('dtr2').tableList()\" | t exec rethinkcli msr\n"
	  exit;;
  esac
}	
t-exec-rethinkcli-mke() {	
	read echoedInput	
	UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.public_dns' 2>/dev/null)
	mke_private_ip=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0) | .attributes.private_ip' 2>/dev/null)
	connect-stripped $UCP_URL "echo \"$echoedInput\" | sudo docker run --rm -i -e DB_ADDRESS=$mke_private_ip -v ucp-auth-api-certs:/tls squizzi/rethinkcli-ucp non-interactive" | jq .
	}
t-exec-rethinkcli-msr() {
	read echoedInput
	msr=$(curl -k -H "Authorization: Bearer $auth" https://$ucpurl/api/ucp/config/dtr 2>/dev/null| jq -r ' .registries[] | .hostAddress')
	connect-stripped $msr "echo \"$echoedInput\" | sudo docker run --rm -i --net dtr-ol -e DTR_REPLICA_ID=000000000001 -v dtr-ca-000000000001:/ca dockerhubenterprise/rethinkcli:v2.2.0-ni non-interactive " | jq .
}
##### 1st level usage function : 
usage1() {
#  echo "t deploy lab|cluster|instances "
#  echo "  After you have a running cluster, you have the following available commands:"
#  echo "t show versions|status|all "
#  echo "t show ip|dns|creds ...."
#  echo "t show status|hostname managers|workers|msrs|windows "
#  echo "t exec etcdctl "
#  echo "t exec rethinkcli ..."
#  echo "  When you finish your work:"
#  echo "t stop managers|workers|msrs|windows|manager1 "
#  echo "t destroy lab|cluster "
  printf "
NAME
	t - Command line tool for the terraTrain platform 

SYNOPSIS
	t [verbs] [adjective] [Actors]
	t show dns managers

DESCRIPTIONS
Verbs:
  1) deploy : to deploy resoruces. (cloud instances | MKE cluster)
	t deploy lab			-> To deploy the Lab (cloud instances + MKE cluster)
	t deploy cluster		-> To deploy the MKE cluster (an existing cloud instances should be present)
	t deploy instances		-> To deploy the Cloud instances
  2) destroy: to destroy resources (cloud instances | MKE cluster)
	t destroy lab			-> To destroy the Lab (cloud instances + MKE cluster)
	t destroy cluster		-> To destroy the MKE cluster (the cloud instances would not be destoryed)
  3) show : to show the metadata of resources
	t show all			-> To show all information about the cluster
	t show versions 		-> To show the versions of the resources
	t show ip managers		-> To show the IP address of the managers
	t show dns workers		-> To show the DNS of the workers
	t show creds windows		-> To show the private to to get ssh access MKE nodes
	t show creds linux 		-> To show the Credentials for getting RDP access to Windows Nodes
	t show creds mke		-> To show the MKE Login credentials
	t show creds msr		-> To show the MSR Login Credentials
  4) status: to check the cloud instance status 
	t status managers		-> To check the status of manager nodes instances
	t status msrs			-> To check the status of MSR nodes instances
	t status workeres		-> To check the status of worker nodes instances
	t status windows		-> To check the status of Windows worker nodes instances
  5) stop: to stop the cloud instances
	t stop managers			-> To stop the manager nodes instances
	t stop msrs			-> To stop MSR nodes instances
	t stop workeres			-> To stop worker nodes instances
	t stop windows			-> To stop Windows worker nodes instances
  6) gen : to generate different tailored requirements
	t gen client-bundle		-> To generate client bundle
	t gen swarm-service		-> To generate dockercoin app as swarm service 
	t gen k8s-service		-> To generate dockercoin app as k8s service
	t gen msr-login			-> To perform docker login to existing MSR
	t gen msr-image			-> To populate MSR with random images
	t gen msr-org			-> To populate MSR with random organizations and teams
	t gen msr-populate		-> To populate MSR with random orgs,teams and images
  7) exec : to execute specific task on the cluster
	t exec rethinkcli msr		-> To get into the rethinkdb of primary MSR replica
	t exec rethinkcli mke		-> To get into the rethinkdb of MKE leader node
	t exec etcdctl			-> To get into the etcd db of the MKE leader node
\nActors:
  1) managers: all the manager node of the MKE cluster.
  		Nicknames: m, mgr, manager, man, woman
  2) msrs: all the MSR nodes of the MKE cluster
  		Nicknames: msrs, ms, msrs, dtr, dtrs, d
  3) workers: all the linux worker nodes of the MKE cluster.
  		Nicknames: w, wkr, wrk, work, worker, workers
  4) windows: all the windows worker nodes of the MKE cluster.
  		Nicknames: wi, win, windows, winworker, winworkers, thing-that-breaks
"
}

######### Parsing starts here, t is $0 , and we can have $1 $2 , or $1 $2 $3 ########
if [ $# -eq 2 ]; then 
  case "$1" in 
  deploy|dp|dep) t-deploy "$2"    # t deploy lab|cluster|instances
          exit ;;
  ds|des|destroy) t-destroy "$2"  # t destroy lab|cluster
           exit ;;
  stop|stp)  t-stop "$2"       # t stop managers|msrs|workers|windows
         exit;;
  start|star|strt|str)  t-start "$2"       # t stop managers|msrs|workers|windows
         exit;;	
  status|stat|stt|s)  t-status "$2"       # t stop managers|msrs|workers|windows
         exit;;			 	
  show|sh) case "$2" in 
		    versions|ver|v) t-show-versions
			             exit ;;
		    a|al|all) t-show-all 
			        exit ;;
			akl|access​-ke​y-linux) t-show-access​_ke​y_linux
			        exit;;
			akw|access​-ke​y-windows) t-show-access​_ke​y_windows
			        exit;;
			 *) printf "\nUsages :\nt show versions |all|access-key-linux|access-key-windows "
				exit;;
		  esac 
         exit;;
  gen)  # t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images
         case "$2" in 
		 client-bundle|cb) t-gen-client_bundle 
		                 exit;;
		 msr-login|ml) t-gen-msr_login 
		              exit;;
		 swarm-service|ss) t-gen-swarm_service
		                 exit;;
		 k8s-service|k8s) t-gen-k8s_service
		                exit;;
		 msr-images|mi) t-gen-msr_images
		               exit;;
		msr-orgs|mo) t-gen-msr_orgs
		               exit;;
		  *) echo "t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images"
		 esac
        exit;;  
   exec) # t exec etcdctl
          case "$2" in 
		  "etcdctl") t-exec-etcdctl  
		             exit ;; 
		   *) echo "t exec etcdctl|rethinkcli "
		      exit ;;
          esac		   
          exit;;
   *) usage1
     exit ;;
  esac 
elif [ $# -eq 3 ]; then 
  case "$1" in 
  show|sh) # t show ip|dns|hostname|creds|status ...
         case "$2" in 
		 "ip") t-show-ip "$3"
				exit;;
		 "dns") t-show-dns "$3"
				exit;;
		 "hostname") t-show-hostname "$3"
		        exit;;
		 creds|credentials|cred|login|c)  t-show-creds "$3"
				exit;;
#		 "status") t-show-status "$3"
#		        exit;;
		  *) echo " t show ip|dns|hostname|creds|status ... "
		     exit;;
		 esac 
	    exit;;
  "exec") case "$2" in 
          rethinkcli|rthink|rt) t-exec-rethinkcli "$3"
		  exit;;
		  *) printf "\nUsage: \necho \"r.db('enzi').tableList()\" | t exec rethinkcli mke\necho \"r.db('dtr2').tableList()\"t exec rethinkcli msr\n"
		  exit;;
		  esac 
         exit;;
   *) usage1
      exit;;
  esac
else 
  usage1 
fi