variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

provider "aws" {
  region = "us-east-1"
  access_key = var.access_key # terraform plan -var="access_key=your_access_key_here" -var="secret_key=your_secret_key_here"
  secret_key = var.secret_key
}



# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "web-server-instance" {
  ami               = "ami-085925f297f89fce1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"

  tags = {
    Name = "web-server"
  }
}


