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

# resource "aws_instance" "my-terraform-ec2" {
#     ami = "ami-0747bdcabd34c712a"
#     instance_type = "t2.micro"
#     tags = {
#         name = "ubuntu"
#     }
# }


# 1.create vpc
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "terraform-vpc"
  }
}

# 2.create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform-vpc.id
}


# 3.create custom route table
resource "aws_route_table" "terraform-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
  route {
      ipv6_cidr_block        = "::/0"
      gateway_id = aws_internet_gateway.gw.id
    }
  

  tags = {
    Name = "terraform-route-table"
  }
}

# 4.create a subnet

variable "subnet_prefix" {
  description = "cidr block for the subnet"
  # default = "10.0.1.0/24"
}

resource "aws_subnet" "terraform-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = var.subnet_prefix[0]
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "terraform-subnet"
  }
}

# 5. associate subnet with route table
resource "aws_route_table_association" "terraform-route-table-association" {
  subnet_id      = aws_subnet.terraform-subnet.id
  route_table_id = aws_route_table.terraform-route-table.id
}

# 6. create security group to allow port 22, 80, 443
resource "aws_security_group" "terraform_security_group" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ingress {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }


  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_web"
  }
}

# 7. create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "terraform-network-interface" {
  subnet_id       = aws_subnet.terraform-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.terraform_security_group.id]
}

# 8. assign an elastic ip to the network interface created in step 7
resource "aws_eip" "terraform-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.terraform-network-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
  
}

# print public ip on the console (can print other properties too)
output "server_public_ip" {
  value = aws_eip.terraform-eip.public_ip
  
}

# 9. create ubuntu server and install/enable apache2 

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

