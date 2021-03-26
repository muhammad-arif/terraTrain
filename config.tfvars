###### Configuration File #######
# JUST UNCOMMENT WHAT YOU NEED and COMMENT WHAT YOU DON'T

###### Test Information
name="YOURNAME-caseNo"
caseNo=""

###### AWS Informations
###### Please beware that if you change the region you need to change the ami-id too.
###### Let's keep it like this until the next release 
region="eu-central-1"


###### AMI Informations ---------------------------------------------------------------------------------------------------
###### From AWS dashboard select your region. And from Services select EC2. and from the Left bar select AMIs
###### Then search your desired AMI's and change the following AMI ID. Followings only work for eu-central-1 region 
###### At this moment only the following AMIs are supported. Change/add them at your own risk
#ami="ami-06c0e8e713058d7be" 		 # RedHat 7.8  
#ami="ami-0f86cdae67e730b21"		 # Ubuntu 16.04 
ami="ami-0e1ce3e0deb8896d2"		 # Ubuntu 18.04 

###### For Ubuntu ami username should be ubuntu,
###### For RHEL or SLES ami username should be ec2-user, 
###### For Centos ami username should be centos. Uncomment only what you need
amiUserName="ubuntu" 
#amiUserName="ec2-user" 
#amiUserName="centos" 

#### If you want to change the public key, then create a new key pair and 
#### renamed your private key as "key-pair" first. Then change the following section
publicKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEcjgWhz5EFZXkQqGrdbJmdctxVh5BHKQ0t0EHY2jP5lQqgn7xpcecO/HGaUkKPPLJLE8KnCK4kndpD7PtivITRXy4/FP+HFQrr1cuh4rBC0AE/vFRIaYWuFl89avEMOjX/91Vi6dsljupBpWDyhI8b0FITkBYADB+UKfVFoeOdJsUJFA1rnJaKyN9LiaRSfUmdFWZgUirKaIiqJB87Ce4b5C9cCso3Paq9x9HyMRapC77SERAkALwWVyPm5u9o92wX/cEIWQQoVXZFR4m5EcIJSWf/UK2W8kVlys+PMAc41/HtiMlYayMPSSuRtXOlqi0HXr2sFMyr9U8iIZHnS9uQQyR5L8R7TSFI7o495ZFKmJFhL7RWIanCiBPPJTp/Vob8+K1/oc3yOjuiyFsa/uzgkTzXsHas66LeESAt/OxsokLQv7HdxnsTpRXgOH1kLh6Xjlt/UYGt/FTX8v0r+oIYsHdu33V+WBT4FkXqXHcDK+x/nlYoOf81tUJkq734us= arif@arif-mirantis-laptop"

#---------------------------------------------------------------------------------------------------------------------------

###### UCP Informations ----------------------------------------------------------------------------------------------------
ucpInstanceType="c4.xlarge"

###### Managers Informations
###### There would be 1 leader always. So if you type 2 in managerCount there would be 3 manager in total
managerCount="2"
managerInstanceType="c4.xlarge"

###### Workers Informations
workerCount="3"
workerInstanceType="t2.micro"

###### MSR  Informations
dtrCount="1"
dtrInstanceType="c4.xlarge"
# --------------------------------------------------------------------------------------------------------------------------


###### MKE Information ----------------------------------------------------------------------------------------------------- 
docker_ee_version="19.03" # E.g. 18.09.1, 19.03.11, 19.03 - will install the latest of 19.03 which is 14 at this moment
docker_ucp_version="3.3.4"
docker_dtr_version="2.8.2"
admin_username="admin"
admin_password="dockeradmin"

#---------------------------------------------------------------------------------------------------------------------------
# Check Again Please
