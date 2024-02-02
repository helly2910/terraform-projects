# create VPC

resource "aws_vpc" "Myvpc" {
  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"

  tags = {
    Name = "Myvpc"
  }
}

# subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.Myvpc.id
  cidr_block              = var.subnet1_CIDR
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.Myvpc.id
  cidr_block              = var.subnet2_CIDR
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# inernet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Myvpc.id
  tags = {
    Name = "myvpc_igw"
  }
}

# route table
resource "aws_route_table" "Myvpc_routes" {
  vpc_id = aws_vpc.Myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#subnet1 association
resource "aws_route_table_association" "subnet1_ass" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Myvpc_routes.id
}

#subnet2 association
resource "aws_route_table_association" "subnet2_ass" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.Myvpc_routes.id
}

#secaurity group
resource "aws_security_group" "sg1" {
  name   = "websg"
  vpc_id = aws_vpc.Myvpc.id

  ingress {
    description = "http"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#s3 bucket 
resource "aws_s3_bucket" "MyBucket" {
  bucket = "mybucketusingloadbalancer"
}

#create ec2 in subnet1
resource "aws_instance" "subnet1-instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  user_data              = base64encode(file("/home/helly-gtcsys/Documents/terraform/terraform project with load balance/userdata.sh"))
}

#create ec2 in subnet1
resource "aws_instance" "subnet2-instance" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  user_data              = base64encode(file("/home/helly-gtcsys/Documents/terraform/terraform project with load balance/userdata1.sh"))
}

# create load balancer
resource "aws_lb" "lb" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg1.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# create target group
resource "aws_lb_target_group" "lbtagertGP" {
  target_type      = "instance"
  name             = "myTG"
  protocol         = "HTTP"
  port             = 80
  ip_address_type  = "ipv4"
  vpc_id           = aws_vpc.Myvpc.id
  protocol_version = "HTTP1"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
}

# attach tragets
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.lbtagertGP.arn
  target_id        = aws_instance.subnet1-instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.lbtagertGP.arn
  target_id        = aws_instance.subnet2-instance.id
  port             = 80
}

#create listener
resource "aws_lb_listener" "lblistener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbtagertGP.arn
  }
}

output "loadbalancerDNS" {
  value = aws_lb.lb.dns_name
}



