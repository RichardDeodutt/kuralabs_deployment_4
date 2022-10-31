variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region"{
    default = "ap-northeast-1"
}
variable "main_vpc_cidr" {
    default = "10.0.0.0/24"
}
variable "public_subnets" {
    default = "10.0.0.128/26"
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region = var.region

}

resource "aws_instance" "web_server01" {
  ami = "ami-03f4fa076d2981b45"
  instance_type = "t2.micro"
  key_name = "Tokyo"
  vpc_security_group_ids = [aws_security_group.web_ssh.id]

  user_data = "${file("appdeployment.sh")}"

  tags = {
    "Name" : "Webserver001"
  }

}

output "instance_ip" {
  value = aws_instance.web_server01.public_ip
  
}