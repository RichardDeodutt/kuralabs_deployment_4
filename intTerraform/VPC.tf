# Create the VPC
 resource "aws_vpc" "Main" {                # Creating VPC here
   cidr_block       = var.main_vpc_cidr     # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"

       tags = {
        "Name" : "Deployment-4 VPC"
    }
 }

 # Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.Main.id               # vpc_id will be generated after we create VPC
 }

 # Create a Public Subnets.
 resource "aws_subnet" "publicsubnets" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.public_subnets}"        # CIDR block of public subnets
 }

 # Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
 }
 
 # Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }