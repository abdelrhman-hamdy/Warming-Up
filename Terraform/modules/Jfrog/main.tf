terraform {
  required_version = ">= 0.14.9"
}
resource "aws_security_group" "JfrogSecGroup" {
  name= var.secgroupname

  ingress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress { 
  cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 8081
    protocol = "tcp"
    to_port = 8081
  }
    ingress { 
  cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 8082
    protocol = "tcp"
    to_port = 8082
  }

  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
  
  
}


resource "aws_instance" "JfrogServer" {
    ami= var.ami
    instance_type = var.itype
    tags = {
      "Name" = var.EC2name 
    }
    key_name = var.keyname
    associate_public_ip_address = var.publicip
    vpc_security_group_ids = [
        aws_security_group.JfrogSecGroup.id
    ]
    
    depends_on = [ aws_security_group.JfrogSecGroup ]
}


resource "null_resource" "Run_Ansible" {
  triggers = {
    jfrog_instance_ip = aws_instance.JfrogServer.public_ip
  }

  provisioner "local-exec" {
    command = "sed -Ei '6 s/.*/${aws_instance.JfrogServer.public_ip}/' ../../Ansible/inventory.txt"
  }

  provisioner "local-exec" {
    command = "cd ../../Ansible; ansible-playbook Jfrog.yml --inventory=inventory.txt --private-key=hamdy_key.pem"
  }
   
   depends_on =[aws_instance.SonarQubeServer]
}
