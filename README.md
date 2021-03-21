# Welcome to terraTrain
```

           O         O    O             O         O   OO (OOO)
O O OO  O    OO O O OO OOO O O   OO OO OOOO  OOO OOOO O (O(OOO))
O OO O terraTrain  OO O OO O   O O (000 0 0000 000000)OO O OO)))
 O OO  OO O OO OO OO   O OOO OOO OOOO OOO OOOO OOO  OOOO((OOOOO))
       O          O          OO            OO        O O (OOO))
                                                          (OO)
                                                          |  |
   _______----------.   ___    _____    ___    _____      ___
--'       `| .----. |---------|     |---------|     |----'   `[3985]
          || |____| |                                           |__
          |---------     UNION PACIFIC  ____  _________________ |-'
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
## TLDR;
1. Clone the repo or download the zip file 
2. Unzip the file somehwere and cd into the terraTrain directory
3. Build the image with `sudo docker build -t terratrain .` (this is the most time consuming part)
4. Run the container wiht `sudo docker run -it terratrain`
5. Now copy your AWS env variable commands and paste your AWS credentials inside the container
6. Now edit the `config.tfvars` file according to your need
7. Create your cluster with `tt-run` command
8. Check your installed components with `tt-show` command.
9. SSH to the desired node with `connect node's-public-dns`
10. To generate client bundle use `tt-genClientBundle` command.
11. To remove all the components of the cluster use `tt-purge` command.


### Install the platform

Clone this repo or just download the folder and unzip it and change directory into it.

Build the container image,
```
sudo docker build -t terratrain:latest .
```
Set the id of the case you are working on by create a variable so that you can find and relate with the container 
```
CASEID=40705683
```
Run following command to get into the terraTrain container,
```
sudo docker run -it --hostname case-${CASEID} --name case_${CASEID} terratrain:latest
```
Then you will be entered into the terraTrain environment, something like the following,
```
[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ 
```

#### Run your cluster
Collect the following aws access information from your aws power user access portal and just paste it to your terminal (inside the container)
```
export AWS_ACCESS_KEY_ID="ASIAQUMWQ3ATTWQD4ZFV"
export AWS_SECRET_ACCESS_KEY="kH+ClCBTRofpzollgeFiEMYw2qkyCatENBgEYdYL"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEDAaCWV1LXdlc3QtMiJGM"
```

Edit the `config.tfvars` according to your requirement. If you don't it will ask you to death or run it the default configurations. The file also pretty self explanatory

You are good to go run your terraTrain. To run use following command,
```
tt-run
```
To see the cluster related infomrations,
```
tt-show
```
To see the leader node's details,
```
tt-show-ldr
```
To see the Manager node's details,
```
tt-show-mgr
```
To see the MSR node's details,
```
tt-show-msr
```
To see the worker node's details,
```
tt-show-wkr
```
To ssh into a node,
```
connect nodes-public-ip-address
```
To generate the client bundle
```
tt-genClientBundle
```

To delete the cluster,
```
tt-purge
```
If you forget to delete the cluster and exit out of the container, then just run the container again and exec into it and purge the cluster.

Enjoy your platform!! 

Following fetures will be available on the next release,
1. Load balancer for MKE
2. Windows as worker node
3. Creating a MKE cluster on Azure
4. Many more AMIs