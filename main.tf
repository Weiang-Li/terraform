# """
# if want to just detroy one thing, ex: terraform  destroy -target aws_instance.terraform-web-server-instance
# if want to just apply one thing, ex: terraform apply -target aws_instance.terraform-web-server-instance

# to apply with variables(where the variable file has been created) ex: terraform apply -var-file main.tfvars
# """


provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZXT5EJO54A7BMHWT"
  secret_key = "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"
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

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "terraform-web-server"
  }
}

