variable "cidr_block" {
  description = "provide the cidr block for vpc"
}

variable "instance_tenancy" {
    description = "provide instance tenancy either 'Default' or 'Dedicated'"
  
}

variable "subnet1_cidr" {
    description = "provide the cidr block for subnet1"
  
}

variable "vpc_id" {
    type = string
}

variable "public_subnet_id" {
  type = string
  
}