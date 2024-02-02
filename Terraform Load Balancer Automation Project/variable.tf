variable "VPC_CIDR" {
  default = "192.168.0.0/16"

}

variable "subnet1_CIDR" {
  default = "192.168.0.0/24"

}

variable "subnet2_CIDR" {
  default = "192.168.1.0/24"

}


## ec2 variables

variable "ami_id" {
  default = "ami-0c7217cdde317cfec"
}