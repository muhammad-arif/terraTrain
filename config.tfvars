###### Configuration File #######

###### Test Information
name="terraTrain-case-"
caseNo=""

###### AWS Informations
region="eu-central-1"

###### AMI Informations
###### From AWS dashboard select your region. And from Services select EC2. and from the Left bar select AMIs
###### Then search your desired AMI's and change the following AMI ID. This only works for Frankfurt region
#ami= "ami-875042eb"			 # RedHat 7.2  
#ami="ami-dafdcfc7"			 # RedHat 7.7  
#ami="ami-06c0e8e713058d7be" 		 # RedHat 7.8  
#ami="ami-0e8286b71b81c3cc1"		 # Centos 7
#ami="ami-07fa74e425f2abf29"		 # Centos 6
#ami="ami-0f86cdae67e730b21"		 # Ubuntu 16.04 
ami="ami-0e1ce3e0deb8896d2"		 # Ubuntu 18.04 

## Common usernames, Ubuntu = ubuntu, RHEL = ec2-user, Centos = centos, SLES = ec2-user
amiUserName="ubuntu" 

#### If you want to change the public key, then create a new key pair and 
#### renamed your private key as "key-pair" first. Then change the following section
publicKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEcjgWhz5EFZXkQqGrdbJmdctxVh5BHKQ0t0EHY2jP5lQqgn7xpcecO/HGaUkKPPLJLE8KnCK4kndpD7PtivITRXy4/FP+HFQrr1cuh4rBC0AE/vFRIaYWuFl89avEMOjX/91Vi6dsljupBpWDyhI8b0FITkBYADB+UKfVFoeOdJsUJFA1rnJaKyN9LiaRSfUmdFWZgUirKaIiqJB87Ce4b5C9cCso3Paq9x9HyMRapC77SERAkALwWVyPm5u9o92wX/cEIWQQoVXZFR4m5EcIJSWf/UK2W8kVlys+PMAc41/HtiMlYayMPSSuRtXOlqi0HXr2sFMyr9U8iIZHnS9uQQyR5L8R7TSFI7o495ZFKmJFhL7RWIanCiBPPJTp/Vob8+K1/oc3yOjuiyFsa/uzgkTzXsHas66LeESAt/OxsokLQv7HdxnsTpRXgOH1kLh6Xjlt/UYGt/FTX8v0r+oIYsHdu33V+WBT4FkXqXHcDK+x/nlYoOf81tUJkq734us= arif@arif-mirantis-laptop"

###### UCP Informations
ucpInstanceType="c4.xlarge"

###### Managers Informations
managerCount="2"
managerInstanceType="c4.xlarge"

###### Workers Informations
workerCount="3"
workerInstanceType="t2.micro"

###### DTRs  Informations
dtrCount="1"
dtrInstanceType="c4.xlarge"



###### Docker EE  Informations
docker_ee_version="19.03" # E.g. 18.09.1, 19.03.11, 19.03 - will install the latest of 19.03 which is 14 at this moment
docker_ucp_version="3.3.4"
docker_dtr_version="2.8.2"
admin_username="admin"
admin_password="dockeradmin"