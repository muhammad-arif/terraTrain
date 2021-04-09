terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region  
  shared_credentials_file = var.aws_shared_credentials_file
  profile = var.aws_profile
}
# Creating two random password for MKE username and Password
resource "random_pet" "mke_username" {
  length  = 2
}
resource "random_string" "mke_password" {
  length  = 20
  special = false
}
# Creating a local variable for generating randomness
locals {
  tstmp = formatdate("hh-mm-ss",timestamp())
}
######## SELECTING A DEFAULT SUBNET #########
data "aws_subnet" "selected" {
  filter {
    name   = "availability-zone"
    values = ["*c"]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

######## CREATING A SECURITY GROUP #########

resource "aws_security_group" "allow-all-security-group" {
  //name        = "heliosAllowAllSG" # This line can be deleted 
  description = "Allow everything for an ephemeral cluster"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-AA-SG-${local.tstmp}"
    resourceType = "Security Group"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
  }
}
####### CREATING THE KEY PAIR  #######
resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-deployer-key"
  public_key = var.publicKey
}

######## CREATING THE WORKER INSTANCE #######

resource "aws_instance" "workerNode" {
  count = "${var.workerCount}"
  ami = var.ami
  instance_type = var.workerInstanceType
  key_name = "${var.name}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  tags = {
    Name = "${var.name}-workerNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
  }
}

######## CREATING THE MANAGER INSTANCE #######

resource "aws_instance" "managerNode" {
  count = "${var.managerCount}"
  ami = var.ami
  instance_type = var.managerInstanceType
  key_name = "${var.name}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  root_block_device {
    volume_size = "50"
    delete_on_termination = "true"
  }
  tags = {
    Name = "${var.name}-managerNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
  }
}
######## CREATING THE MSR INSTANCE #######

resource "aws_instance" "dtrNode" {
  count = "${var.dtrCount}"
  ami = var.ami
  instance_type = var.dtrInstanceType
  key_name = "${var.name}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  root_block_device {
    volume_size = "20"
    delete_on_termination = "true"
  }
  tags = {
    Name = "${var.name}-dtrNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
    counter = "${format("%2d", count.index + 1)}"

  }
}
