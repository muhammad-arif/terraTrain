
# Welcome to terraTrain
```

           O         O    O             O         O   OO (OOO)
O O OO  O    OO O O OO OOO O O   OO OO OOOO  OOO OOOO O (O(OOO))
O OO O terraTrain  OO O OO O   O O (mke 0 msr0 000000)OO O OO)))
 O OO  OO O OO OO OO   O OOO OOO OOOO OOO OOOO OOO  OOOO((OOOOO))
       O          O          OO            OO        O O (OOO))
                                                          (OO)
                                                          |  |
   _______----------.   ___    _____    ___    _____      ___
--'       `| .----. |---------| aws |---------| azr |----'   `[3985]
          || |____| |                                           |__
          |---------       TERRATRAIN   ____  _________________ |-'
          | | 3985    /----------------(____)/,---------------_||__
          | |========/ /  \ / _\_/_<|==(____)  \ / _\_/__<|==[__]_\\_
---._---_./=|,-._,-\   o---{o}=======\>=[__]o---{o}=======\>=[__]----\=
___(O)_(O)___(O)_(O)___\__/_\__/_\__/_______\__/_\__/_\__/____(O)_(O)_\_
___
```
This repo contains some terraform configuration to build an MKE Cluster with MSR inspired by mirantis/train and build with terraform

What do you need before using this?
    1. Docker engine
    2. Docker client 
    3. Internet Connection
    4. AWS account
# TLDR;
1. Clone the repo or download the zip file 
2. Unzip the file somehwere and cd into the terraTrain directory
3. Build the image with `sudo docker build -t terratrain .` (this is the most time consuming part)
4. Run the container wiht `sudo docker run -it terratrain`
5. Now copy your AWS env variable commands and paste your AWS credentials inside the container
6. Now edit the `config.tfvars` file according to your need
7. Create your cluster with `tt-run` command
8. Check your installed components with `tt-show` command.
9. SSH to the desired node with `connect m1` or `connect w1` or `connect public-dns`
10. To generate client bundle use `tt-genClientBundle` command.
11. To remove all the components of the cluster use `tt-purge` command.

# Table of Contents
- [Welcome to terraTrain](#welcome-to-terratrain)
- [TLDR;](#tldr)
- [Table of Contents](#table-of-contents)
- [Configuring and Running terraTrain](#configuring-and-running-terratrain)
    - [Install the platform](#install-the-platform)
    - [Run your cluster](#run-your-cluster)
- [tt(terraTrain) Command References](#ttterratrain-command-references)
  - [Instance Creation Commands](#instance-creation-commands)
    - [tt-run](#tt-run)
    - [tt-purge](#tt-purge)
    - [connect](#connect)
  - [Cluster Related Commands](#cluster-related-commands)
    - [tt-cleanup](#tt-cleanup)
    - [tt-reinstall](#tt-reinstall)
    - [tt-genClientBundle](#tt-genclientbundle)
    - [tt-show](#tt-show)
      - [tt-show-mke-cred](#tt-show-mke-cred)
      - [tt-show-msr](#tt-show-msr)
      - [tt-show-mgr](#tt-show-mgr)
      - [tt-show-wkr](#tt-show-wkr)
  - [MKE Related Commands](#mke-related-commands)
    - [tt-mke-swrm-svc-deploy](#tt-mke-swrm-svc-deploy)
    - [tt-mke-k8s-svc-deploy](#tt-mke-k8s-svc-deploy)
    - [tt-mke-toml-download](#tt-mke-toml-download)
    - [tt-mke-toml-upload](#tt-mke-toml-upload)
    - [tt-mke-rethinkcli](#tt-mke-rethinkcli)
    - [tt-mke-etcdctl](#tt-mke-etcdctl)
  - [MSR Related Commands](#msr-related-commands)
    - [tt-msr-login](#tt-msr-login)
    - [tt-msr-populate-img](#tt-msr-populate-img)
    - [tt-msr-rethinkcli](#tt-msr-rethinkcli)
  - [EC2 Related Commands](#ec2-related-commands)
    - [tt-ec2-status](#tt-ec2-status)
    - [tt-ec2-start](#tt-ec2-start)
    - [tt-ec2-start-mgr](#tt-ec2-start-mgr)
    - [tt-ec2-start-wkr](#tt-ec2-start-wkr)
    - [tt-ec2-start-msr](#tt-ec2-start-msr)
    - [tt-ec2-start-win](#tt-ec2-start-win)
    - [tt-ec2-stop](#tt-ec2-stop)
    - [tt-ec2-stop-wkr](#tt-ec2-stop-wkr)
    - [tt-ec2-stop-mgr](#tt-ec2-stop-mgr)
    - [tt-ec2-stop-msr](#tt-ec2-stop-msr)
    - [tt-ec2-stop-win](#tt-ec2-stop-win)
- [config.tfvars Configurtion file reference](#configtfvars-configurtion-file-reference)
  - [AWS Instance related configurations](#aws-instance-related-configurations)
    - [region=""](#region)
    - [name=""](#name)
    - [caseNo=""](#caseno)
    - [os_name=""](#os_name)
    - [os_version=""](#os_version)
    - [manager_count=""](#manager_count)
    - [manager_instance_type=""](#manager_instance_type)
    - [worker_count=""](#worker_count)
    - [worker_instance_type=""](#worker_instance_type)
    - [msr_count=""](#msr_count)
    - [msr_instance_type="c4.xlarge"](#msr_instance_typec4xlarge)
  - [Cluster Related informations](#cluster-related-informations)
    - [mcr_version="19.03.12"](#mcr_version190312)
    - [mke_version="3.2.8"](#mke_version328)
    - [msr_version="2.7.6"](#msr_version276)
    - [image_repo=""](#image_repo)
- [Intermediate usages](#intermediate-usages)
  - [Enabling AWS Single Sign On](#enabling-aws-single-sign-on)


# Configuring and Running terraTrain
### Install the platform

Clone this repo or just download the folder and unzip it and change directory into it.
```
git clone https://github.com/muhammad-arif/terraTrain.git  && cd terraTrain
```
At this point you can do a first edit on the file config.tfvars and put your region , e.g eu-central-1 
so that the image to be build on next step will already have your AWS region

Build the container image,
```
sudo docker build -t terratrain:v1 .
```
Set the id of the case you are working on by creating a variable so that you can find and relate with the container 
```
CASEID=40705683
```
Run following command to get into the terraTrain container,
```
sudo docker run -it --hostname case-${CASEID} --name case_${CASEID} terratrain:v1
```
Then you will be entered into the terraTrain environment, something like the following,
```
[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ 
```

### Run your cluster
Collect the following aws access information from your aws PowerUserAccess portal and just paste it to your terminal (inside the container)
```
export AWS_ACCESS_KEY_ID="ASIAQUMWQ3ATTWQD4ZFV"
export AWS_SECRET_ACCESS_KEY="kH+ClCBTRofpzollgeFiEMYw2qkyCatENBgEYdYL"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEDAaCWV1LXdlc3QtMiJGM"
```

Edit the `config.tfvars` according to your requirement. If you don't it will ask you to death or run it the default configurations. The file is pretty self explanatory

You are good to go run your terraTrain. To run use following command,
```
tt-run
```
To see the cluster related informations,
```
tt-show
```
To ssh into a node,
```
connect nodes-public-ip-address
```
To delete the cluster,
```
tt-purge
```
If you forget to delete the cluster and exit out of the container, then just run the container again and exec into it and purge the cluster.
```
docker container exec name-of-container bash 
```
Enjoy your platform!! 

# tt(terraTrain) Command References 

## Instance Creation Commands
### tt-run
Usage:
`tt-run` 

**Background:**
This command will Perform 3 actions,  
   1. Create instances
      - At first it will create the necessarary instances and components related to cluster based on the `config.tfvars` file. 
   2. Generate configurations
      - Then Based on the `config.tfvars` and instances information (whcih just created at step 1), it will generate a configuration file for the launchpad named `launchpad.yaml`.
   3. Run launchpad
      - Then it will run the launchpad with the `launchpad.yaml` file
      - You can check the logs in following places,
        1. `/tmp/mke-installation.log`
        2. `/terraTrain/.mirantis-launchpad/cluster/launchpad-mke/apply.log`
Example:
```
[root]-[case-4323089]-[~]-[14:08-Tue Apr 13]
$ tt-run 
random_pet.mke_username: Creating...
random_string.mke_password: Creating...
random_pet.mke_username: Creation complete after 0s [id=evident-flea]
random_string.mke_password: Creation complete after 0s [id=6SCic29CnXlX5T9xyb3A]
aws_key_pair.deployer: Creating...
aws_security_group.allow-all-security-group: Creating...
aws_key_pair.deployer: Creation complete after 1s [id=helios-pd1-deployer-key]
aws_security_group.allow-all-security-group: Creation complete after 7s [id=sg-03c98815d5c06753f]
aws_instance.workerNode[0]: Creating...
aws_instance.managerNode[0]: Creating...
aws_instance.managerNode[0]: Still creating... [10s elapsed]
aws_instance.workerNode[0]: Still creating... [10s elapsed]
aws_instance.managerNode[0]: Creation complete after 18s [id=i-067f8fbc366564550]
aws_instance.workerNode[0]: Still creating... [20s elapsed]
aws_instance.workerNode[0]: Creation complete after 29s [id=i-07a31534543122a67]

 MKE and MSR Information: 
-------------------------------------------------------------------------------
MKR URL: "https://ec2-18-156-117-231.eu-central-1.compute.amazonaws.com"
MKR URL: Username: "evident-flea"
Password: "6SCic29CnXlX5T9xyb3A"


 Manager Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-pd1-managerNode-01",
  "URL": "https://ec2-18-156-117-231.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-8-23.eu-central-1.compute.internal",
  "PublicDNS": "ec2-18-156-117-231.eu-central-1.compute.amazonaws.com",
  "PublicIP": "18.156.117.231"
}

 MSR Nodes: 
-------------------------------------------------------------------------------
 Worker Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-pd1-workerNode-01",
  "Hostname": "ip-172-31-3-16.eu-central-1.compute.internal",
  "PublicDNS": "ec2-18-159-195-118.eu-central-1.compute.amazonaws.com",
  "PublicIP": "18.159.195.118"
}
MKE installation process is running

Please check the MKE installation log buffer with the following command
tail -f /tmp/mke-installation.log

```
### tt-purge
Usage:
`tt-purge`

**Background:**
This command will remove all the cloud instances that has been created by the `tt-run` command
Example,
```
$ tt-purge 
random_pet.mke_username: Destroying... [id=evident-flea]
random_string.mke_password: Destroying... [id=6SCic29CnXlX5T9xyb3A]
random_pet.mke_username: Destruction complete after 0s
random_string.mke_password: Destruction complete after 0s
aws_key_pair.deployer: Destroying... [id=helios-pd1-deployer-key]
aws_instance.workerNode[0]: Destroying... [id=i-07a31534543122a67]
aws_instance.managerNode[0]: Destroying... [id=i-067f8fbc366564550]
aws_key_pair.deployer: Destruction complete after 1s
aws_instance.workerNode[0]: Still destroying... [id=i-07a31534543122a67, 10s elapsed]
aws_instance.managerNode[0]: Still destroying... [id=i-067f8fbc366564550, 10s elapsed]
aws_instance.workerNode[0]: Still destroying... [id=i-07a31534543122a67, 20s elapsed]
aws_instance.managerNode[0]: Still destroying... [id=i-067f8fbc366564550, 20s elapsed]
aws_instance.workerNode[0]: Still destroying... [id=i-07a31534543122a67, 30s elapsed]
aws_instance.managerNode[0]: Still destroying... [id=i-067f8fbc366564550, 30s elapsed]
aws_instance.workerNode[0]: Still destroying... [id=i-07a31534543122a67, 40s elapsed]
aws_instance.managerNode[0]: Still destroying... [id=i-067f8fbc366564550, 40s elapsed]
aws_instance.managerNode[0]: Destruction complete after 44s
aws_instance.workerNode[0]: Still destroying... [id=i-07a31534543122a67, 50s elapsed]
aws_instance.workerNode[0]: Destruction complete after 55s
aws_security_group.allow-all-security-group: Destroying... [id=sg-03c98815d5c06753f]
aws_security_group.allow-all-security-group: Destruction complete after 2s

Warnings:

- Interpolation-only expressions are deprecated
  on main.tf line 63 (and 24 more)

To see the full warning notes, run Terraform without -compact-warnings.


Destroy complete! Resources: 6 destroyed.
```
### connect 
Usage:
1. Just to log in to a node. You can ssh into a node in following ways,
   
   a. With Role
      1. For manager use `m1`, `m2`, `m3` etc.
          `connect m1`
      2. For workers use `w1`, `w2`, `w3` etc.
          `connect w2`
      3. For msr use `d1`, `d2`, `d3` etc.
          `connect d3`
      4. For windows use `win1`, `win2`, `win3` etc.
          `connect win3`

   b. With Hostname
    `connect <node's_public_dns/ip>`
    E.g: `connect ec2-18-156-117-231.eu-central-1.compute.amazonaws.com`
2. To run a command inside a node
    `connect <node's_public_dns/ip/role> "<command-to-run-on-remote-machine>"`
    E.g: `connect m1 "docker ps | grep ucp-kv`


**Background:**
This command is an implementation of ssh. The ssh command has been aliased to this command.
The equivelent ssh command is the following,
`ssh -i /terraTrain/key-pair -o StrictHostKeyChecking=false  username@hostname "command"`
When to use this command,
   1. When you need to login to a instance
   2. When you need to run a command to a instance without logging to that instance
## Cluster Related Commands
### tt-cleanup
Usage:
`tt-cleanup`

**Background:**
This command will help you to re-use your instances. If you just need a different MKE version with the same ammount of nodes then you don't have to re-create the instances every time with `tt-run`. 
Running this command will try to cleanup the MKE,MCR and MSR packages on your nodes.
This command 
When to use this command,
   1. When your MKE installation get failed for some reason in the `tt-run` command. To try to cleanup the MKE installation run this command
   2. When you need to un-install MKE 
### tt-reinstall
Usage:
1. Change the following 3 cluster information from the `config.tfvars` according to your need
   - `mcr_version=`
   - `mke_version=`
   - `msr_version=`
2. Then run the `tt-reinstall` command. 

**Background:**
This command will cleanup the installed MKE,MCR,MSR and re-install the MKE,MCR and MSR based on the `config.tfvars` file. 

When to use this command,
   1. When your MKE installation get failed for some reason in the `tt-run` command. To try to cleanup the MKE installation run this command
   2. When you need to un-install MKE 
   3. When you need to re-use the instances for creating a new cluster with different version.

### tt-genClientBundle
Usage:
`tt-genClientBundle`

**Background:**
This command will generate a client bundle for the cluster. Almost 90% of the time you should run this after the installation. Because lots of other commands are depends on this.
After a sucessful genearation you can use, `docker` and `kubectl` commands to communicate further with your cluster.
For example you can run the following commands,
```
k get pods -A
d node ls
kubectl get nodes -n kube-system
```
When to use this command,
   1. When you need to utlize all the terraTrain (`tt`) commands. 
   2. When you need to communicate with the MKE 

Example,
```
[root]-[case-4266390]-[~]-[09:32-Tue Apr 13]
$ tt-genClientBundle

~~~~~~ Removing Old Client Bundle if there is any~~~~~~ 

~~~~~~ Downloading the client bundle ~~~~~~~
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16931  100 16931    0     0  16680      0  0:00:01  0:00:01 --:--:-- 16680
Archive:  bundle.zip
 extracting: client-bundle/ca.pem    
 extracting: client-bundle/cert.pem  
 extracting: client-bundle/key.pem   
 extracting: client-bundle/cert.pub  
 extracting: client-bundle/env.ps1   
 extracting: client-bundle/env.cmd   
 extracting: client-bundle/kube.yml  
 extracting: client-bundle/env.sh    
 extracting: client-bundle/meta.json  
 extracting: client-bundle/tls/docker/ca.pem  
 extracting: client-bundle/tls/docker/cert.pem  
 extracting: client-bundle/tls/docker/key.pem  
 extracting: client-bundle/tls/kubernetes/ca.pem  
 extracting: client-bundle/tls/kubernetes/cert.pem  
 extracting: client-bundle/tls/kubernetes/key.pem  

~~~~~~ Activating the client bundle ~~~~~~~
Cluster "ucp_ec2-3-123-127-9.eu-central-1.compute.amazonaws.com:6443_driving-swine" set.
User "ucp_ec2-3-123-127-9.eu-central-1.compute.amazonaws.com:6443_driving-swine" set.
Context "ucp_ec2-3-123-127-9.eu-central-1.compute.amazonaws.com:6443_driving-swine" modified.

~~~~~~ Testing client bundle with kubectl~~~~~~ 
NAME               STATUS   ROLES    AGE   VERSION
ip-172-31-12-153   Ready    master   27m   v1.14.8-docker-1
ip-172-31-8-201    Ready    <none>   26m   v1.14.8-docker-1

~~~~~~ Testing client bundle with docker-cli~~~~~~ 
ID                            HOSTNAME           STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
bjqde4pbvvuwcll85uomfbuvw     ip-172-31-8-201    Ready     Active                          19.03.12
qba56dch1cuzj52ifox1bm7fd *   ip-172-31-12-153   Ready     Active         Leader           19.03.12

~~~~~~ Yeeeeup, working !! ~~~~~~ 
```
### tt-show
Usage:
`tt-show`

**Background:**
This command will show you the cluster wide information
Example,
```

 MKE and MSR Information: 
-------------------------------------------------------------------------------
MKR URL: "https://ec2-3-123-127-9.eu-central-1.compute.amazonaws.com"
MKR URL: "https://ec2-18-197-141-99.eu-central-1.compute.amazonaws.com"
Username: "driving-swine"
Password: "KXyVIrP8ngqXW23BOLLq"


 Manager Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-426390-managerNode-01",
  "URL": "https://ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-12-153.eu-central-1.compute.internal",
  "PublicDNS": "ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "PublicIP": "3.123.127.9"
}


 MSR Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-426390-dtrNode-01",
  "URL": "https://ec2-18-197-141-99.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-8-201.eu-central-1.compute.internal",
  "PublicDNS": "ec2-18-197-141-99.eu-central-1.compute.amazonaws.com",
  "PublicIP": "18.197.141.99"
}


 Worker Nodes: 
-------------------------------------------------------------------------------
```
#### tt-show-mke-cred
Usage:
`tt-show-mke-cred`

**Background:**
This command will show you the MKE credentials 
Example,
```
$ tt-show-mke-creds 
 MKE's Username and Password: 
-------------------------------------------------------------------------------
Username: "driving-swine"
Password: "KXyVIrP8ngqXW23BOLLq"
```
#### tt-show-msr
Usage:
`tt-show-msr`

**Background:**
This command will show you the MSR Node informations
Example,
```
$ tt-show-msr 


 MSR Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-426390-dtrNode-01",
  "URL": "https://ec2-18-197-141-99.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-8-201.eu-central-1.compute.internal",
  "PublicDNS": "ec2-18-197-141-99.eu-central-1.compute.amazonaws.com",
  "PublicIP": "18.197.141.99"
}
```
#### tt-show-mgr
Usage:
`tt-show-mgr`

**Background:**
This command will show you the Manager Node informations
Example,
```
$ tt-show-mgr 
 Manager Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-426390-managerNode-01",
  "URL": "https://ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-12-153.eu-central-1.compute.internal",
  "PublicDNS": "ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "PublicIP": "3.123.127.9"
}
```
#### tt-show-wkr
Usage:
`tt-show-wkr`

**Background:**
This command will show you the Worker Node informations
Example,
```
$ tt-show-wkr 
 Worker Nodes: 
-------------------------------------------------------------------------------
{
  "Name": "helios-426390-workerNode-01",
  "URL": "https://ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "Hostname": "ip-172-31-12-153.eu-central-1.compute.internal",
  "PublicDNS": "ec2-3-123-127-9.eu-central-1.compute.amazonaws.com",
  "PublicIP": "3.123.127.9"
}
```
## MKE Related Commands
### tt-mke-swrm-svc-deploy
Usage:
`tt-mke-swrm-svc-deploy`

**Background:**
This command will create a test swarm service based on the `dockercoin.yml` file.
When to use this command,
   1. When you need to test swarm's service functionality by deploying a test application

### tt-mke-k8s-svc-deploy
Usage:
`tt-mke-k8s-svc-deploy`

**Background:**
This command will create a test swarm service based on the `dockercoin.yaml` file.
When to use this command,
   1. When you need to test k8s functionality by deploying a test application
### tt-mke-toml-download
Usage:
`tt-mke-toml-download`

**Background:**
This will download the MKE's configuration file in the current directory as `ucp-config.toml`
This option requires an activated client bundle.
When to use this command,
   1. When you need to change some parameter on the MKE's configuration file

### tt-mke-toml-upload
Usage:
`tt-mke-toml-upload`

**Background:**
This will upload the MKE's configuration file named as `ucp-config.toml` in the current directory.
This option requires an activated client bundle.
When to use this command,
   1. When you need to change some parameter on the MKE's configuration file
   
### tt-mke-rethinkcli
Usage:
This command can be run in two way,
1. Run the `tt-mke-rethinkcli` command and then paste the rethinkdb query `r.dbList()`
2. echoed the rethinkquery and pipe it with the `tt-mke-rethinkcli` command.

**Background:**
This command will connect with the first manager and will create an non-interective rethink session.
You can use this commands to explore the rethinkdb tables of the MKE

Example,
1 way,
```
$ tt-mke-rethinkcli 
r.dbList()
[
  "enzi",
  "rethinkdb",
  "ucp"
]
```
2nd way,
```
$ echo "r.db('rethinkdb').table('table_status').filter({'db': 'ucp'}).pluck('id')" | tt-mke-rethinkcli 
[
  {
    "id": "8dc559e7-8327-4d4f-a36d-1160c3dbd703"
  },
  {
    "id": "bd81266e-39ef-412a-82d9-56f3c1b2dcf8"
  },
  {
    "id": "ecb8756a-d793-4229-b41d-9eb4cddf3313"
  }
]
```
### tt-mke-etcdctl
Usage:
This command can be run in two way,
1. Run the `tt-mke-etcdctl` command and then paste the etcd commands like `get`,`ls`, `member list` etc.
2. echoed the etcd commands and pipe it with the `tt-mke-etcdctl` command.

**Background:**
This command will connect with the first manager and will create an non-interective etcdctl session.
You can use this commands to explore the etcd contnets of the `ucp-kv` container.
Example,
Direct way,
```
$ tt-mke-etcdctl 
ls /docker/nodes/qba56dch1cuzj52ifox1bm7fd
/docker/nodes/qba56dch1cuzj52ifox1bm7fd

$ tt-mke-etcdctl 
get /docker/nodes/qba56dch1cuzj52ifox1bm7fd
172.31.12.153:12376
```
Piped way,
```
$ echo "member list" | tt-mke-etcdctl 
5e8614be80ff9740: name=orca-kv-172.31.12.153 peerURLs=https://172.31.12.153:12380 clientURLs=https://172.31.12.153:12379 isLeader=true
```
## MSR Related Commands
### tt-msr-login
Usage:
`tt-msr-login`

**Background:**
This command will log in to your existing MSR cluster so that you can push/pull images to the repostiory
### tt-msr-populate-img
Usage:
`tt-msr-populate-img`

**Background:**
This command will populate your MSR cluster with few test repositoires and tags.
But you **need to have a license** before running this command.
### tt-msr-rethinkcli
Usage:
This command can be run in two way,
1. Run the `tt-msr-rethinkcli` command and then paste the rethinkdb query `r.dbList()`
2. echoed the rethinkquery and pipe it with the `tt-msr-rethinkcli` command.

**Background:**
This command will connect with the first MSR replica and will create an non-interective rethink session.
You can use this commands to explore the rethinkdb tables of the MSR

Example,
Direct way,
```
$ tt-msr-rethinkcli 
r.dbList()
[
  "dtr2",
  "jobrunner",
  "notaryserver",
  "notarysigner",
  "rethinkdb"
]
```
Piped way
```
$ echo "r.db('dtr2').table('tags').filter({'repository': 'driving-swine/redis'}).pluck('name')" | tt-msr-rethinkcli 
[
  {
    "name": "alpine3.13"
  },
  {
    "name": "6.2.1-alpine3.13"
  }
]

```
## EC2 Related Commands

### tt-ec2-status
Usage:
`tt-ec2-status`
Will show the status of all of the ec2 instance

### tt-ec2-start
Usage:
`tt-ec2-start`
Will start all the ec2 instance

### tt-ec2-start-mgr
Usage:
`tt-ec2-start-mgr`
Will start only the manager instances

### tt-ec2-start-wkr
Usage:
`tt-ec2-start-wkr`
Will start only the worker instances

### tt-ec2-start-msr
Usage:
`tt-ec2-start-msr`
Will start only the msr instances

### tt-ec2-start-win
Usage:
`tt-ec2-start-win`
Will start only the windows instances

### tt-ec2-stop
Usage:
`tt-ec2-stop`
Will stop all of the instances

### tt-ec2-stop-wkr
Usage:
`tt-ec2-stop-wkr`
Will stop only the worker instances

### tt-ec2-stop-mgr
Usage:
`tt-ec2-stop-mgr`
Will stop only the manager instances

### tt-ec2-stop-msr
Usage:
`tt-ec2-stop-msr`
Will stop only the msr instances

### tt-ec2-stop-win
Usage:
`tt-ec2-stop-win`
Will stop only the windows instances

# config.tfvars Configurtion file reference
## AWS Instance related configurations
### region=""
choose your region. This is where you should write the region name.
E.g., `eu-central-1`, `us-east-1`, `ap-southeast-1` etc.

### name=""
The standard is something like "yourname-caseno". Eg. arif-bosch-4799686
The instance name would like, `arif-bosch-4799686-managerNode-01`, `arif-bosch-4799686-dtrNode-01`

### caseNo=""
You can specify your case no here. This is just a tag to find your resources. 
### os_name=""
use "ubuntu" or  "redhat" or "centos" or "suse"
At this moment ubuntu, redhat and centos are tested.
Please use exact keywords like the following,
`ubuntu`
`redhat`
`centos` 
### os_version=""
For `ubuntu following is the patters,
`16.04`, .... `18.04`, ....., `20.04`
For `redhat` following is the patters,
`7.1`, `7.2`, ...... `7.9`, `8.1`, `8.3`
For `centos` following is the patters,
`7.1`, `7.2`, ...... `7.9`

For good result use known OS versions.
### manager_count=""
How many manager you want. You should have at least one manager.
### manager_instance_type=""
You can configre the manager instance type. Following are few example,
`c4.xlarge`, `m4.xlarge` etc.
### worker_count=""
The number of worker node you want. 
### worker_instance_type=""
You can configre the worker instance type. Following are few example,
`t2.micro`, `c4.xlarge`, `m4.xlarge` etc.
### msr_count=""
The number of MSR replica you want. 
### msr_instance_type="c4.xlarge"
You can configre the MSR replica instance type. Following are few example,
`c4.xlarge`, `m4.xlarge` etc.

## Cluster Related informations
Please change only the following informations if you want to use `tt-reinstall`.
### mcr_version="19.03.12"
This is the version of Mirantis Container Runtime. **Please use full version**
### mke_version="3.2.8"
This is the version of Mirantis Kubernetes Engine. **Please use full version**
### msr_version="2.7.6"
This is the version of Mirantis Secure Registry. **Please use full version**

### image_repo=""
For older version use `docker.io/docker`, from MKE 3.2.8 and forward use `docker.io/mirantis`

# Intermediate usages

## Enabling AWS Single Sign On 
Configure your AWS SSO login with following (Host Machine):
```
aws configure sso --profile PowerUserAccess-043802220583-SSO
```

Output of the command:

```
SSO start URL [None]:https://mirantis.awsapps.com/start
SSO Region [None]: eu-west-2
The only AWS account available to you is: 043802220583
Using the account ID 043802220583
There are 3 roles available to you.
Using the role name "PowerUserAccess"
CLI default client Region [None]:eu-central-1
CLI default output format [None]:json

To use this profile, specify the profile name using --profile, as shown:

aws s3 ls --profile PowerUserAccess-043802220583-SSO
```

Sample of the AWS SSO Login.
```
aws sso login --profile PowerUserAccess-043802220583-SSO
```
Command Output:
```
SSO start URL [None]: https://mirantis.awsapps.com/start#/
SSO Region [None]:  eu-west-2
Attempting to automatically open the SSO authorization page in your default browser.
If the browser does not open or you wish to use a different device to authorize this request, open the following URL:
https://device.sso.eu-west-2.amazonaws.com/

Then enter the code:
<REDACTED>
Successully logged into Start URL:
https://mirantis.awsapps.com/start
```
Run following command to get into the terraTrain container,
```
docker run -it --volume ~/.aws:/terraTrain/.aws --hostname case-${CASEID} --name case_${CASEID} terratrain:<TAG>
```
Check if the credential is working or not
```
tt-plan
```

