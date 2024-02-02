provider "aws" {
    region = "us-east-1"
  
}

module "vpc" {
    source = "./modules/vpc_module"
    cidr_block = "10.0.0.0/16"
    subnet1_cidr = "10.0.0.0/24"
    instance_tenancy = "default"
    vpc_id = module.vpc.vpc_id
    public_subnet_id = module.vpc.public_subnet_id
  
}
 module "ec2" {
    source = "./modules/ec2_module"
    websg_vpc_id = module.vpc.vpc_id
    ami = "ami-0c7217cdde317cfec"
    instance_type = "t2.micro"
    subnet_id = module.vpc.public_subnet_id
    public_key = "/home/helly-gtcsys/.ssh/id_rsa.pub"
    ingress_rules = [{
      description = "HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Custom port"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },]
    ssh_connection = {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "/home/helly-gtcsys/.ssh/id_rsa"
    timeout     = "15m"
  }
   remote_exec_file_path = "/home/helly-gtcsys/Music/devops/terraform/ec2/remote-exec.sh"
 }
