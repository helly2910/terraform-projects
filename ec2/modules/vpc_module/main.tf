provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "example_vpc" {
    cidr_block = var.cidr_block
    instance_tenancy = var.instance_tenancy
    tags = {
      "name" = "myvpc" 
    }
}

resource "aws_subnet" "example_subnet1" {
    vpc_id = aws_vpc.example_vpc.id
    availability_zone_id = "use1-az1"
    cidr_block = var.subnet1_cidr
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.example_vpc.id
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.example_vpc.id

    route {
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.example_subnet1.id
    route_table_id = aws_route_table.RT.id
}





