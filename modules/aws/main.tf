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
  tstmp = formatdate("DD-MMM-YYYY:hh-mm",timestamp())
}
######## SELECTING A DEFAULT SUBNET #########
data "aws_subnet" "selected" {
  filter {
    name   = "availability-zone"
    values = ["*a"]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

######## CREATING A SECURITY GROUP #########

resource "aws_security_group" "allow-all-security-group" {
  name        = "${var.name}-${random_pet.mke_username.id}-SecurityGroup"
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
    Name = "${var.name}-SecurityGroup"
    DateOfCreation = local.tstmp
    resourceType = "Security Group"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
  }
}
####### CREATING THE KEY PAIR  #######
resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-${random_pet.mke_username.id}-keypair"
  public_key = var.publicKey
   tags = {
    Name = "${var.name}-KeyPair"
    DateOfCreation = local.tstmp
    resourceType = "keyPair"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
  }
}

######## CREATING THE WORKER INSTANCE #######

resource "aws_instance" "workerNode" {
  count = "${var.worker_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.worker_instance_type
  key_name = "${var.name}-${random_pet.mke_username.id}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  tags = {
    Name = "${var.name}-${random_pet.mke_username.id}-workerNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    DateOfCreation = local.tstmp
    caseNumber = "${var.caseNo}"
    role = "worker"
  }
}

######## CREATING THE MANAGER INSTANCE #######

resource "aws_instance" "managerNode" {
  count = "${var.manager_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.manager_instance_type
  key_name = "${var.name}-${random_pet.mke_username.id}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  root_block_device {
    volume_size = "50"
    delete_on_termination = "true"
  }
  tags = {
    Name = "${var.name}-${random_pet.mke_username.id}-managerNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
    DateOfCreation = local.tstmp
    role = "manager"
  }
}
######## CREATING THE MSR INSTANCE #######

resource "aws_instance" "msrNode" {
  count = "${var.msr_count}"
  ami = "${ var.os_name == "ubuntu" ? data.aws_ami.ubuntu[0].image_id : (var.os_name == "redhat" ? data.aws_ami.redhat[0].image_id : (var.os_name == "centos" ? data.aws_ami.centos[0].image_id : data.aws_ami.suse[0].image_id ))}"
  instance_type = var.msr_instance_type
  key_name = "${var.name}-${random_pet.mke_username.id}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
#  user_data = data.template_cloudinit_config.replicas.rendered
  root_block_device {
    volume_size = "20"
    delete_on_termination = "true"
  }
  user_data              = <<EOF
#!/bin/bash
yum install -y nfs-utils || apt install -y nfs-common || zypper -n in nfs-client -y
EOF
  tags = {
    Name = "${var.name}-${random_pet.mke_username.id}-msrNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
    DateOfCreation = local.tstmp
    counter = "${format("%2d", count.index + 1)}"
    role = "msr"

  }
}
resource "aws_instance" "winNode" {
  count = var.win_worker_count
  instance_type                 = var.win_worker_instance_type # var.msr_instance_type
  ami                           = data.aws_ami.windows[0].image_id
  associate_public_ip_address   = true
  subnet_id                     = "${data.aws_subnet.selected.id}"
  security_groups               = ["${aws_security_group.allow-all-security-group.id}"]
  user_data              = <<EOF
<powershell>
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${random_string.mke_password.result}")
# Snippet to enable WinRM over HTTPS with a self-signed certificate
# from https://gist.github.com/TechIsCool/d65017b8427cfa49d579a6d7b6e03c93
Write-Output "Disabling WinRM over HTTP..."
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"
Get-ChildItem WSMan:\Localhost\listener | Remove-Item -Recurse
Write-Output "Configuring WinRM for HTTPS..."
Set-Item -Path WSMan:\LocalHost\MaxTimeoutms -Value '1800000'
Set-Item -Path WSMan:\LocalHost\Shell\MaxMemoryPerShellMB -Value '1024'
Set-Item -Path WSMan:\LocalHost\Service\AllowUnencrypted -Value 'false'
Set-Item -Path WSMan:\LocalHost\Service\Auth\Basic -Value 'true'
Set-Item -Path WSMan:\LocalHost\Service\Auth\CredSSP -Value 'true'
New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Domain,Private
New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP-PUBLIC" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Public
$Hostname = [System.Net.Dns]::GetHostByName((hostname)).HostName.ToUpper()
$pfx = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $Hostname
$certThumbprint = $pfx.Thumbprint
$certSubjectName = $pfx.SubjectName.Name.TrimStart("CN = ").Trim()
New-Item -Path WSMan:\LocalHost\Listener -Address * -Transport HTTPS -Hostname $certSubjectName -CertificateThumbPrint $certThumbprint -Port "5986" -force
Write-Output "Restarting WinRM Service..."
Stop-Service WinRM
Set-Service WinRM -StartupType "Automatic"
Start-Service WinRM
</powershell>
EOF


  lifecycle {
    ignore_changes = [ami]
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
  }

  connection {
    type = "winrm"
    user = "Administrator"
    password = random_string.mke_password.result
    timeout = "10m"
    https = "true"
    insecure = "true"
    port=5986
  }
  tags = {
    Name = "${var.name}-${random_pet.mke_username.id}-winNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
    counter = "${format("%2d", count.index + 1)}"
    role = "win-worker"
    DateOfCreation = local.tstmp
  }
}
resource "aws_instance" "nfsNode" {
  count = "${var.nfs_backend}"
  ami = data.aws_ami.nfsNodeImage[0].image_id 
  instance_type = "t2.nano"
  key_name = "${var.name}-${random_pet.mke_username.id}-deployer-key"
  associate_public_ip_address = true
  subnet_id = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.allow-all-security-group.id}"]
  user_data              = <<EOF
#!/bin/bash
apt update -y
apt install -y nfs-kernel-server nfs-common
mkdir /var/nfs/general -p
chown nobody:nogroup /var/nfs/general
chown -R nobody /var/nfs/general
chmod -R 755 /var/nfs/general
echo '/var/nfs/general    *(rw,sync,no_root_squash,no_subtree_check)' > /etc/exports
systemctl restart nfs-kernel-server
EOF
  tags = {
    Name = "${var.name}-${random_pet.mke_username.id}-nfsNode-${format("%02d", count.index + 1)}"
    resourceType = "instance"
    resourceOwner = "${var.name}"
    caseNumber = "${var.caseNo}"
    role = "nfs"
    DateOfCreation = local.tstmp
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
data "aws_ami" "windows" {
    owners = ["801119661308"]
    count  = "${var.win_worker_count == 0 ? 0 : 1}"
    most_recent = true
    filter {
        name = "name"
        values = ["*Windows_Server-2019-English-Full-ContainersLatest-*"]
    }
    filter {
        name = "description"
        values = ["Microsoft Windows Server 2019 with Containers Locale English AMI provided by Amazon"]
    }
}
data "aws_ami" "nfsNodeImage" {
    owners = ["099720109477"]
    count  = var.nfs_backend
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04*amd64*"]
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