 
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

module "SonarQubeServer" {
  source = "../modules/SonarQube"
  ami= "ami-09cd747c78a9add63"
  itype = "t2.medium"
  publicip = true
  keyname = "hamdy_key"
  secgroupname = "SonarQubeSecGroup"
  EC2name=  "SonarQubeServer" 
}

output "SonarQubeServer" {
  value = module.SonarQubeServer.SonarQubeServer.public_ip
}



    