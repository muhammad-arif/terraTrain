variable "region" {
  type        = string
  description = "This is where you have to mention region"
  default = "ap-northeast-1"
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
  description = "This is the Parent instance type name. \nFor 3 instance it would be like the following,\nIf the name is helios \n1. helios-ucp-leader\n2. helios_instance-0\n3. helios_instance-1"
}
variable "caseNo" {
  type        = string
  description = "This is the case number to track the issue."
}
variable "workerCount" {
  type        = string
  description = "Please type the total number of worker"
}
variable "managerCount" {
  type        = string
  description = "Please type the total number of manager"
}
variable "dtrCount" {
  type        = string
  description = "Please type the total number of dtr"
}
variable "ami" {
  type        = string
  description = "Please type which AMI you want. \n1. ami-02b658ac34935766f : Ubuntu Server 18.04 LTS (HVM) \n2. ami-0ce107ae7af2e92b5 : Amazon Linux 2 \n3. ami-07dd14faa8a17fb3e : Red Hat Enterprise Linux 8 (HVM)\n4. ami-0119d7d47f3b13adb : SUSE Linux Enterprise Server 15 SP2\n5. ami-09b86f9709b3c33d4 : Ubuntu Server 20.04 LTS (HVM)\n"
}
variable "amiUserName" {
  type        = string
  description = "This is the AMI username. For ubuntu it's ubuntu, for centos it's centos etc."
}
variable "ucpInstanceType" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
}
variable "dtrInstanceType" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
}
variable "workerInstanceType" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
}
variable "managerInstanceType" {
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
}
variable "publicKey" {
  type        = string
  description = "If you are using a customized key, please paste your public key here."
}

variable "docker_ee_url" {
  type        = string
  default = "https://repos.mirantis.com"
}
variable "mke_repo" {
  type        = string
  default = "mirantis/ucp"
}
variable "docker_ee_version" {
  type        = string
}
variable "docker_ucp_version" {
  type        = string
  description = "Please type your desired docker version"
}
variable "docker_dtr_version" {
  type        = string
  description = "Please type your desired DTR version"
}
variable "admin_username" {
  type        = string
  default = "admin"
}
variable "admin_password" {
  type        = string
  default = "dockeradmin"
}

#### WORKER INSTALLATION CONFIG ####
data "template_file" "worker_file" {
  template = file("install_docke-ee.tpl")
  vars = {
      dockerURL = "${var.docker_ee_url}"
      dockerVERSION = "${var.docker_ee_version}"
  }
}

data "template_cloudinit_config" "replicas" {
  gzip          = false
  base64_encode = false  #first part of local config file
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.worker_file.rendered
  }
}

#### UCP INSTALLATION CONFIG ####
data "template_file" "ucp_file" {
  template = file("install_ucp.tpl")
  vars = {
      dockerURL = "${var.docker_ee_url}"
      dockerVERSION = "${var.docker_ee_version}"
      ucpVERSION = "${var.docker_ucp_version}"
      ucpAdminName = "${var.admin_username}"
      ucpAdminPass = "${var.admin_password}"
      amiUSERNAME = "${var.amiUserName}"
      dtrVERSION = "${var.docker_dtr_version}"
      mkeREPOSITORY = "${var.mke_repo}"

  }
}
data "template_cloudinit_config" "ucp" {
  gzip          = false
  base64_encode = false  #first part of local config file
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.ucp_file.rendered
  }
}
