variable "websg_vpc_id" {
    description = "vpc-id for secaurity group"
  
}

variable "ami" {
    description = "ami-id for create ec2"
  
}

variable "instance_type" {
    description = "instance-type"
  
}

variable "subnet_id" {
    description = "subnet-id for ec2"
  
}

variable "ingress_rules" {
    type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
    description = "provide inbound rules. it should contain : description,from_port, to_port, protocol, cidr_blocks "
}

variable "public_key" {
   type = string
   description = "path of public key file"
}
variable "ssh_connection" {
  type = object({
    type        = string
    user        = string
    private_key = string
    timeout     = string
  })
}

variable "remote_exec_file_path"{
    type = string
    description = "provide file path for remote_exec_file_path"

}
