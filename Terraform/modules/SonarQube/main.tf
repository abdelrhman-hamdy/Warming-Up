terraform {
  required_version = ">= 0.14.9"
}
resource "aws_security_group" "SonarQubeSecGroup" {
  name= var.secgroupname
  //Allow ssh on port 22 , jenkins server on 8080, and  all outbound ports
  ingress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress { 
  cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 9000
    protocol = "tcp"
    to_port = 9000
  }
  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
  
  
}


resource "aws_instance" "SonarQubeServer" {
    ami= var.ami
    instance_type = var.itype
    tags = {
      "Name" = var.EC2name 
    }
    key_name = var.keyname
    associate_public_ip_address = var.publicip
    vpc_security_group_ids = [
        aws_security_group.SonarQubeSecGroup.id
    ]
    
    depends_on = [ aws_security_group.SonarQubeSecGroup ]
}


resource "null_resource" "Run_Ansible" {
  triggers = {
    sonar_instance_ip = aws_instance.SonarQubeServer.public_ip
  }

  provisioner "local-exec" {
    command = "sed -Ei '2 s/.*/${aws_instance.SonarQubeServer.public_ip}/' ../../Ansible/inventory.txt"
  }

  provisioner "local-exec" {
    command = "cd ../../Ansible; ansible-playbook SonarQube.yml --inventory=inventory.txt --private-key=hamdy_key.pem"
  }
   
   depends_on =[aws_instance.SonarQubeServer]
}
