
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
The terraTrain is a minimal platform inspired by `mirantis/train` to create MKE/MCR/MSR Lab environment in AWS.
What do you need before using this?
    1. Docker engine
    2. Docker client 
    3. Internet Connection
    4. AWS account
# TLDR;
1. Pull the image with `docker pull cgroups/terratrain` 
2. Run the container with `docker run -it cgroups/terratrain`
3. Now copy your AWS env variable commands and paste your AWS credentials inside the container
4. Now edit the `config.tfvars` file according to your need
5.  Create your lab environment with `t deploy lab` command. The installation process will take a bit more time. To check the installation logs run `tail -f -n+1 /tmp/mke-installation.log`
6.  Check your installed components with `t show all` command.
7.  SSH to the desired node with `connect m1` or `connect w1` or `connect public-dns`
8.  To generate client bundle use `t gen cb` command.
9.  To remove all the components of the cluster use `t destroy lab` command.
10. For commandline reference run the command `t` or `t --help`

# Table of Contents
- [Welcome to terraTrain](#welcome-to-terratrain)
- [TLDR;](#tldr)
- [Table of Contents](#table-of-contents)
- [Configuring and Running terraTrain](#configuring-and-running-terratrain)
    - [Install the platform](#install-the-platform)
    - [Run your cluster](#run-your-cluster)
- [terratrain Command Line Tool reference](#terratrain-command-line-tool-reference)
- [connect Command Line Tool reference](#connect-command-line-tool-reference)
- [A few concepts](#a-few-concepts)
  - [Terratrain Workflow](#terratrain-workflow)
  - [Cluster vs Lab](#cluster-vs-lab)
    - [Cluster](#cluster)
    - [Lab](#lab)
    - [Use cases](#use-cases)
- [Lab related tasks](#lab-related-tasks)
    - [Create a lab](#create-a-lab)
    - [Destroy a lab](#destroy-a-lab)
    - [Login to the cloud instances](#login-to-the-cloud-instances)
  - [MKE Cluster Related task](#mke-cluster-related-task)
    - [Activating a client bundle](#activating-a-client-bundle)
    - [Check MKE related informations](#check-mke-related-informations)
    - [Enable various configurations](#enable-various-configurations)
    - [Generate workload on MKE](#generate-workload-on-mke)
    - [Querying from ETCD and Rethinkdb for MKE](#querying-from-etcd-and-rethinkdb-for-mke)
  - [MSR Cluster Related task](#msr-cluster-related-task)
    - [Generate workload on MSR](#generate-workload-on-msr)
    - [Login to MSR with docker cli](#login-to-msr-with-docker-cli)
    - [Querying from Rethinkdb for MSR](#querying-from-rethinkdb-for-msr)
  - [EC2 Related task](#ec2-related-task)
    - [Stop Instances](#stop-instances)
    - [Check status of Instances](#check-status-of-instances)
    - [Start Instances](#start-instances)
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

Pull the Image from the dockerhub
```
docker pull cgroups/terratrain:latest
```
Set the id of the case you are working on by creating a variable so that you can find and relate with the container 
```
CASEID=40705683
```
Run following command to get into the terraTrain container,
```
sudo docker run -it --hostname case-${CASEID} --name case_${CASEID} cgroups/terratrain:latest
```
Then you will be entered into the terraTrain environment, something like the following,
```
[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ 
```

### Run your cluster
Collect the following aws access information from your aws PowerUserAccess portal and just paste it to your terminal (inside the container)
```
[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ export AWS_ACCESS_KEY_ID="ASIAQUMWQ3ATTWQD4ZFV"

[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ export AWS_SECRET_ACCESS_KEY="kH+ClCBTRofpzollgeFiEMYw2qkyCatENBgEYdYL"

[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEDAaCWV1LXdlc3QtMiJGM"
```
Edit the `config.tfvars` according to your requirement. If you don't it will ask you to death or run it the default configurations. 
The file is pretty self explanatory. For any details see Table of Contents

You are good to go run your terraTrain. To run use following command,
```
t deploy lab
```
To see the cluster related informations,
```
t show all
```
To ssh into a node,
```
connect public-ip-address-of-the-node
```
To delete the lab,
```
t destroy lab
```
If you forget to delete the cluster and exit out of the container, then just run the container again and exec into it and purge the cluster.
```
docker container exec -it name-of-container bash 
```
# terratrain Command Line Tool reference 
`/bin/terratrain` or `/bin/t` is a command line tool created with simple bash to manupulate the resources of the terratrain platform.
This tool has been inspired from the `kubectl` tool so you might interpret it's use a bit easily. 
This command line tool interact with the cloud, cluster, nodes, with various scripted method. 
This tool gets all the information from the `/terraTrain/terraform.tfstate`, `config.tfvars` and `launchpad.yaml` file.

Following is the reference,
```
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
6) start: to stop the cloud instances
	t start managers			-> To start the manager nodes instances
	t start msrs			-> To start MSR nodes instances
	t start workeres			-> To start worker nodes instances
	t start windows			-> To start Windows worker nodes instances
7) gen : to generate different tailored requirements
	t gen client-bundle		-> To generate client bundle
	t gen swarm-service		-> To generate dockercoin app as swarm service 
	t gen k8s-service		-> To generate dockercoin app as k8s service
	t gen interlock-service		-> To generate a service exposed with interlock
	t gen msr-login			-> To perform docker login to existing MSR
	t gen msr-image			-> To populate MSR with random images
	t gen msr-org			-> To populate MSR with random organizations and teams
	t gen msr-populate		-> To populate MSR with random orgs,teams and images
	t gen launchpad-config		-> To populate launchpad.yaml based on config.tfvars
	t gen ldap-server		-> To install and configure ldap server
8) exec : to execute specific task on the cluster
	t exec rethinkcli msr		-> To request query from the rethinkdb of primary MSR replica
	t exec rethinkcli mke		-> To request query from the rethinkdb of MKE leader node
	t exec etcdctl m1			-> To request query from the etcd db of the MKE leader node
9) upload : to upload configurations
	t upload toml m1		-> To upload the toml file to manager node 1
10) download : to download configurations
	t download toml m1		-> To download the toml file to manager node 1
11) enable : to enable configurations
	t enable interlock		-> To enable Layer 7 ingress for swarm
	t enable interlock-hitless		-> To enable hitless for interlock

	
Actors:
1) managers: all the manager node of the MKE cluster.
		Nicknames: m, mgr, manager, man, woman
2) msrs: all the MSR nodes of the MKE cluster
		Nicknames: msrs, ms, msrs, dtr, dtrs, d
3) workers: all the linux worker nodes of the MKE cluster.
		Nicknames: w, wkr, wrk, work, worker, workers
4) windows: all the windows worker nodes of the MKE cluster.
		Nicknames: wi, win, windows, winworker, winworkers, thing-that-breaks
"
```
# connect Command Line Tool reference 
Following is the reference,
```
NAME
	connect - a wrapper for ssh

SYNOPSIS
	connect [lab-resources | public-dns] [command]
	connect m1 “docker ps --filter name=ucp”

DESCRIPTIONS

Lab Resources,
Managers: 	m1, m2, m3
Workeres: 	w1, w2, w3
Msrs:		d1, d2, d3
Windows:	win1, win2, win3
```
# A few concepts
## Terratrain Workflow
Terratrain is a very minimal platform consists of multiple tools.
We can divide the whole lab cration process in 3 steps.

1. Cloud instance creation:
In terraTrain, all the cloud resources gets created by terraform. 
Terraform colletcs all the lab related information from the `config.tfvars` file. 
So when you run `t deploy instance` or `t deploy lab` what happens is something like following,
```
terraform apply -var-file=/terraTrain/config.tfvars -auto-approve -compact-warnings 
```
If you have the provided the AWS access information and filled up `config.tfvars` properly, terraform will create necessary cloud resources (e.g., keypair, security group, ec2 etc.) according to the `config.tfvars` declaration. 

2. MKE cluster creation:
The second step is to create the MKE,MCR and MSR cluster which is mostly handled by the launchpad. 
So when you run `t deploy cluster` or `t deploy lab` what happens is the follwoing,
  1. A config generator script run to generate launchpad configuration (eg. instance username, keypair, mke version etc.) according to the declaration on `config.tfvars`
  2. Then launchpad command will run which will try to install MKE according to the configuration

3. Interaction with the lab:
All the interaction with lab is mostly done by the command line tool `terratrain` short for `t`.
`t` is a command line tool created with simple bash and inspired from the `kubectl` tool. 
This command line tool interact with the cloud, cluster, nodes, with various scripted method. 
This command line tool gets all the information from the `/terraTrain/terraform.tfstate`, `config.tfvars` and `launchpad.yaml` file.
To know more about this command line tool please follow the previous chapter or table of contents.
## Cluster vs Lab
### Cluster
In terratrain, a cluster means only the installation of the MKE, MCR, MSR cluster, not the cloud instances (eg. ec2, mv).
The cluster creation mostly done by Mirantis Launchpad tool.
There should be some cloud instances already before you run `t deploy cluster`.
The cluster creation steps also included in the `t deploy lab`

### Lab
In terratrain, a lab consists of two things. 
  1. Cloud Instances
  2. MKE Cluster 
The `t deploy lab` command creates the cloud resources first with terraform and then it creates the cluster with launchpad.
So if you try to `deploy` the lab, the `terratrain` will create both the cloud resources and MKE cluster for you.
Also, if you try to `destroy` the `lab` then the `terratrain` will delete the cloud resources which causes the removal of MKE cluster too.
### Use cases
1. When you want to re-use the cloud instances to install a different MKE version,
   1. Run `t destroy cluster` to remove the currently installed cluster
   2. Modify the MKE/MSR/MCR version on the `config.tfvars` file.
   3. Run `t deploy cluster` to install the new MKE version on the existing cloud resources
2. When you just need the cloud instances 
   1. Run `t deploy instances` just to create the cloud resrources 
   2. Run `t show all` to see the instance details and use `connect ec2-public-dns` to log into those machines
3. When you want to manage launchpad or the MKE installation by yourself
   1. Run `t deploy instances` just to create the cloud resrources 
   2. Run `t gen launchpad-config` to generate the launchpad configuration files 
   3. Edit the `launchpad.yaml` file according to your need.
   4. Run `/terraTrain/launchpad-linux-x64 apply --config /terraTrain/launchpad.yaml`

# Lab related tasks
### Create a lab
1. Create the platform
    ```
    docker run -it cgroups/terratrain
    ```
3. Edit config file
    ```
    vi config.tfvars
    ```
4. Paste AWS credentials
5. Deploy Lab
    ```
    t deploy lab
    ```
8. Check resources
    ```
    t show all
    ```
### Destroy a lab
1. Destroy the lab (or cloud resources)
    ```
    t destroy lab
    ```
2. Destory only MKE (only the installation)
    ```
    t destory cluster
    ```
### Login to the cloud instances
1. Login without dns/ip
    ```
    connect m1
    connect w1 "docker ps"
    connect win1
    ```
2. Loging with IP
    ```
    connect ec2....
    ```
3. RDP to Windows Instance
    ```
    t show creds windows
    #then use your RPD client
    ```
## MKE Cluster Related task
### Activating a client bundle
```
t gen client-bundle
```
Test with the following commands
```
docker node ls
kubectl -n kube-system get pods
```

### Check MKE related informations
```
t show managers
t creds managers
```
### Enable various configurations 
1. Enable Interlock
    ```
    t enable interlock
    ```
2. Enable Interlock Hitless
    ```
    t enable interlock-hitless
    ```
3. Generate LDAP server and Enable LDAP
    ```
    t gen ldap-server
    ```
4. Download MKE configuration file (`ucp-config.toml`)
    ```
    t download toml
    ```
5. Upload MKE confiiguration file (`ucp-config.toml`)
    ```
    t upload toml
    ```
### Generate workload on MKE
1. Generate swarm workload with dockercoin stack
    ```
    t gen swarm-service
    ```
2. Generate Kubernetes workload with dockercoin 
    ```
    t gen k8s-service
    ```
3. Generate Interlock service
    ```
    t gen interlock-service
    ```
### Querying from ETCD and Rethinkdb for MKE
1. Querying from etcd 
    ```
    t exec etcdctl m1
    member list
    ```
2. Querying form etcd (Recommended way)
    ```
    echo "cluster-health" | t exec et m1
    ```
3. Querying form rethinkdb 
    ```
    t exec rethinkcli mke
    r.dbList()
    ```
4. Querying from rethinkdb (Recommended way)
    ```
    echo "r.db('rethinkdb').tableList()" | t exec rethinkcli m1
    echo "r.db('rethinkdb').table('stats')" | t exec rt m1
    ```

## MSR Cluster Related task

### Generate workload on MSR
1. Generate random images and repositories
    ```
    t gen msr-image
    ```
2. Generate Orgs/namespace and push random images and repositories under those
    ```
    t gen msr-org
    ```
### Login to MSR with docker cli
```
t gen msr-login
```
### Querying from Rethinkdb for MSR
1. Querying form rethinkdb 
    ```
    t exec rethinkcli msr
    r.dbList()
    ```
2. Querying from rethinkdb (Recommended way)
    ```
    echo "r.db('dtr2').table(tags)" | t exec rethinkcli d1
    echo "r.db('dtr2').table('scanning_images).indexStatus()" | t exec rt m1
    ```
## EC2 Related task
### Stop Instances
1. Stop specific group
    ```
    t stop workers
    ```
2. Stop specific instance
    ```
    t stop m2
    ```
3. Stop all instances
    ```
    t stop all
    ```
### Check status of Instances
1. Status of specific group
    ```
    t status workers
    ```
2. Status of all instances
    ```
    t status all
    ```
### Start Instances

1. Start specific group
    ```
    t start managers
    ```
2. Start specific instance
    ```
    t start w1
    ```
3. Start all instances
    ```
    t start all
    ```
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

