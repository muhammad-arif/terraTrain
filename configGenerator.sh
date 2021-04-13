#!/bin/bash

# Sourcing config.tfvars
. /terraTrain/config.tfvars
if [[ $os_name == "ubuntu" ]] 
then
  amiUserName="ubuntu"
elif [[ $os_name == "redhat" ]] 
then
  amiUserName="ec2-user"
elif [[ $os_name == "centos" ]] 
then
  amiUserName="centos"
elif [[ $os_name == "suse" ]] 
then
  amiUserName="ec2-user"
else
  echo "wrong Operating System Name"
fi

if [[ $msr_count != 0 ]]
  then
    ####### Generating Launchpad Metadata Configuration
    cat > launchpad.yaml << EOL
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke+msr
metadata:
  name: launchpad-mke
spec:
  hosts:
EOL
    ####### Generating Manager Node Configuration
    if [[ $manager_count != 0 ]]
      then
        for count in $(seq $manager_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                mgr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
                cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
        done
    else
    ### For minimum 1 Manager 
      manager_count=1
      for count in $(seq $manager_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                mgr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
                cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
    done
    fi

    ####### Generating Worker Node Configuration
    if [[ $worker_count != 0 ]]
        then
            for count in $(seq $worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                wkr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
                cat >> launchpad.yaml << EOL
  - role: worker
    ssh:
      address: $wkr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
EOL
            done
    fi
    ####### Generating MSR Node Configuration
    
    for count in $(seq $msr_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                msr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="dtrNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
                cat >> launchpad.yaml << EOL
  - role: msr
    ssh:
      address: $msr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
EOL
    done

    ####### Generating MKE Configuration
    mkeadminUsername=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    mkeadminPassword=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)                
    cat >> launchpad.yaml << EOL
  mke:
    version: $mke_version
    imageRepo: "docker.io/mirantis"
    adminUsername: $mkeadminUsername
    adminPassword: $mkeadminPassword
EOL

    ####### Generating MSR Configuration
    msr_address=$(cat /terraTrain/terraform.tfstate |  jq -r '.resources[] | select(.name=="dtrNode") | .instances[] | select(.index_key==0) | .attributes.public_dns')
    cat >> launchpad.yaml << EOL
  msr:
    version: $msr_version
    imageRepo: "docker.io/mirantis"
    installFlags:
    - --dtr-external-url $msr_address
    - --ucp-insecure-tls
    replicaIDs: sequential
EOL

    ####### Generating MCR Configuration
    cat >> launchpad.yaml << EOL
  mcr:
    version: $mcr_version
    channel: stable
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
  cluster:
    prune: true
EOL

else
    ####### Generating Launchpad Metadata Configuration
    cat > launchpad.yaml << EOL
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke
metadata:
  name: launchpad-mke
spec:
  hosts:
EOL
    ####### Generating Manager Node Configuration
    for count in $(seq $manager_count)
        do 
            index=`expr $count - 1` #because index_key starts with 0
            mgr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
            cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
    done


    ####### Generating Worker Node Configuration
    if [[ $worker_count != 0 ]]
        then
            for count in $(seq $worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                wkr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
                cat >> launchpad.yaml << EOL
  - role: worker
    ssh:
      address: $wkr_address
      user: $amiUserName
      port: 22
      keyPath: /terraTrain/key-pair
EOL
            done
    fi

    ####### Generating MKE Configuration
    mkeadminUsername=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    mkeadminPassword=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)                
    cat >> launchpad.yaml << EOL
  mke:
    version: $mke_version
    imageRepo: "docker.io/mirantis"
    adminUsername: $mkeadminUsername
    adminPassword: $mkeadminPassword
EOL

    ####### Generating MCR Configuration
    cat >> launchpad.yaml << EOL
  mcr:
    version: $mcr_version
    channel: stable
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
  cluster:
    prune: true
EOL

fi