resource "aws_security_group" "AzureSecGroup" {
  name= var.secgroupname
  //Allow ssh on port 22 , and  all outbound ports
  ingress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress { 
  cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }
  egress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  } 
  
  
}


resource "aws_instance" "AzureAgentServer" {
    ami= var.ami
    instance_type = var.itype
    tags = {
      "Name" = var.EC2name 
    }
    key_name = var.keyname
    associate_public_ip_address = var.publicip
    vpc_security_group_ids = [
        aws_security_group.AzureSecGroup.id
    ]
    
    depends_on = [ aws_security_group.AzureSecGroup ]
}



resource "null_resource" "Run_Ansible" {
  triggers = {
    sonar_instance_ip = aws_instance.AzureAgentServer.public_ip
  }

  provisioner "local-exec" {
    command = "sed -Ei '4 s/.*/${aws_instance.AzureAgentServer.public_ip}/' ../../Ansible/inventory.txt"
  }

  provisioner "local-exec" {
    command = "cd ../../Ansible; ansible-playbook AzureAgent.yml --inventory=inventory.txt --private-key=hamdy_key.pem"
  }
   
   depends_on =[aws_instance.AzureAgentServer]
}
