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
  count = "${var.worker_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.worker_instance_type
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
  count = "${var.manager_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.manager_instance_type
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
  count = "${var.msr_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.msr_instance_type
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

######### AMI SEARCH #########
data "aws_ami" "ubuntu" {
    owners = ["099720109477"]
    count  = "${ var.os_name == "ubuntu" ? 1 : 0}"
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.os_version}*amd64*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    
    filter {
        name = "description"
        values = ["Canonical, Ubuntu, *"]
    }
}
data "aws_ami" "redhat" {
    count  = "${ var.os_name == "redhat" ? 1 : 0}"
    owners = ["309956199498"]
    most_recent = true

    filter {
        name = "name"
        values = ["RHEL-${var.os_version}*-x86_64*"]
   }
   filter {
        name = "architecture"
        values = ["x86_64"]
    }
    
    filter {
        name = "description"
        values = ["Provided by Red Hat, Inc."]
    }
}
data "aws_ami" "centos" {
    count  = "${var.os_name == "centos" ? 1 : 0}"
    owners = ["125523088429"]
    most_recent = true
    filter {
        name = "name"
        values = ["CentOS*${var.os_version}*x86_64"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    
    filter {
        name = "description"
        values = ["CentOS*"]
    }
}
data "aws_ami" "suse" {
    count  = "${var.os_name == "suse" ? 1 : 0}"
    owners = ["amazon"]
    most_recent = true
    filter {
        name = "name"
        values = ["suse-sles-${var.os_version}-sp*-v????????-hvm-ssd-x86_64"]
    }
    #filter {
    #    name = "virtualization_type"
    #    values = ["hvm"]
    #}
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    
    filter {
        name = "description"
        values = ["SUSE Linux Enterprise Server*"]
    }
}    