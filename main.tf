# """
# if want to just detroy one thing, ex: terraform  destroy -target aws_instance.terraform-web-server-instance
# if want to just apply one thing, ex: terraform apply -target aws_instance.terraform-web-server-instance

# to apply with variables(where the variable file has been created) ex: terraform apply -var-file main.tfvars
# """


provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "terraform-web-server-instance" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "my_working_ec2"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.terraform-network-interface.id
  }

  tags = {
    Name = "terraform-web-server"
  }
}

