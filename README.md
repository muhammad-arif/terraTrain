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


## Configuring and Running terraTrain
### Install the platform

Clone this repo or just download the folder and unzip it and change directory into it.

Build the container image,
```
sudo docker build -t terratrain:v1 .
```
Set the id of the case you are working on by create a variable so that you can find and relate with the container 
```
CASEID=40705683
```
Run following command to get into the terraTrain container,
```
docker run -it --volume ~/.aws:/terraTrain/.aws --hostname case-${CASEID} --name case_${CASEID} terratrain:<TAG>
```
Then you will be entered into the terraTrain environment, something like the following,
```
[root]-[6b012fcac34d]-[~]-[22:57-Sun Mar 21]
$ 
```

#### Before you begin
Collect the following aws access information from your aws power user access portal and just paste it to your terminal (inside the container)

Configure your AWS SSO login with following:
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

### Run your cluster
Edit the `config.tfvars` according to your requirement. If you don't it will ask you to death or run it the default configurations. The file also pretty self explanatory

You are good to go run your terraTrain. To run use following command,
```
tt-run
```
To check your aws sso login success.
```
tt-plan
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
After generating the client bundle you can run `k get nodes`, `kubectl get pods -A`, `docker node ls`, `d ps` etc. docker and kubectl client are installed in the container.

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


### Intermediate usages
#### Changing ssh key-pair

1. Change directory to the terraTrain folder
2. Remove previous key-pair and key-pair.pub files
3. Generate a new key-pair
    ```
    ssh-keygen -t rsa -b 4096 -f key-pair
    ```
4. Copy the public key 
    ```
    cat key-pair.pub
    ```
5. Update the following key value pair in `config.tfvars` with the newly created key-pair.pub
    ```
    publicKey="ssh-rsa AAAAB81tUJkq734us= arif@arif-mirantis-laptop"
    ```
6. Build your image again and you are ready to use it