provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "websg" {
  name   = "websg"
  vpc_id = var.websg_vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }

}

resource "aws_key_pair" "keyexample" {
  key_name   = "terraform-demo-key"
  public_key = file(var.public_key)

}


resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.keyexample.key_name
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = var.subnet_id

  connection {
    type        = var.ssh_connection.type
    user        = var.ssh_connection.user
    private_key = file(var.ssh_connection.private_key)
    host        = self.public_ip
    timeout     = var.ssh_connection.timeout
  }
  provisioner "remote-exec" {
    inline = [file(var.remote_exec_file_path)]

  }
}


