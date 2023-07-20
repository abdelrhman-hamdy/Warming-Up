 
terraform {
    required_providers {
      aws = {
	      source = "hashicorp/aws"

      }
    }

}

provider "aws" {
    profile = "default"
}

data "aws_ami" "ubuntu" {
most_recent = true 
filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230207"]
  }
filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
   }

#module "SonarQubeServer" {
#  source = "../modules/SonarQube"
#  ami= data.aws_ami.ubuntu.id
#  #"ami-09cd747c78a9add63"
#  itype = "t2.medium"
#  publicip = true
#  keyname = "hamdy_key"
#  secgroupname = "SonarQubeSecGroup"
#  EC2name=  "SonarQubeServer" 
#}


module "AzureAgent" {
  source = "../modules/AzureAgent"
  ami= data.aws_ami.ubuntu.id
  itype = "t2.micro"
  publicip = true
  keyname = "hamdy_key"
  secgroupname = "AzureSecGroup"
  EC2name=  "AzureAgentServer" 
}

/*
output "SonarQubeServer" {
  value = module.SonarQubeServer.SonarQubeServer.public_ip
}
*/
output "AzureAgent" {
  value = module.AzureAgent.AzureAgentServer.public_ip
}




    