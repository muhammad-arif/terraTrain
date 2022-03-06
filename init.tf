variable "region" {
  type        = string
  description = "This is where you have to mention region"
  default = "eu-central-1"
}
variable "aws_shared_credentials_file" {
  type = string
  default = "~/.aws/credentials"
}
variable "aws_profile" {
  type = string
  default = "PowerUserAccess-043802220583-SSO"
}
variable "name" {
  type        = string
  description = "Please Type your name so that You and Cloud admin can identify your resources."
}
variable "caseNo" {
  type        = string
  description = "This is the case number to track the issue."
}
variable "os_name" {
  type        = string
  description = "Please type os name like the following, \nubuntu\nredhat\ncentos\nsuse"
  default = "ubuntu"
}
variable "os_version" {
  type        = string
  description = "Please type os Version. For ubuntu 16.04,18,04 etc. For redhat 7.8, 7.1, 8.1 etc"
  default = "20.04"
}
variable "worker_count" {
  type        = string
  description = "Please type the total number of worker"
  default = 0
}
variable "manager_count" {
  type        = string
  description = "Please type the total number of manager"
  default = 1
}
variable "msr_count" {
  type        = string
  description = "Please type the total number of dtr"
  default = 0
}
variable "win_worker_count" {
  type        = string
  description = "Please type the total number of Windows worker"
  default = 0
}
variable "msr_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "t2.micro"
}
variable "manager_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "win_worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "publicKey" {
  type        = string
  description = "If you are using a customized key, please paste your public key here."
}
variable "image_repo" {
  type        = string
  default = "docker.io/mirantis"
}
variable "mcr_version" {
  type        = string
  description = "Please type your desired Mirantis Container Runtime version"
  default = "20.10.7"
}
variable "mke_version" {
  type        = string
  description = "Please type your desired Mirantis Kubernetes Engine version"
  default = "3.3.7"
}
variable "msr_version" {
  type        = string
  description = "Please type your desired Mirantis Secure Registry version"
}
variable "nfs_backend" {
  type        = string
  description = "Please type 1 or 0 for yes or no"
}