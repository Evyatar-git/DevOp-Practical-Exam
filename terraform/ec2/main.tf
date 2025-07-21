provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "builder_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.builder_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key-evya"
  public_key = tls_private_key.builder_key.public_key_openssh
}

resource "aws_security_group" "builder_sg" {
  name        = "builder-sg-evya"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "builder-sg-evya"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "builder" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.builder_key.key_name
  vpc_security_group_ids = [aws_security_group.builder_sg.id]
  subnet_id              = var.public_subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "builder"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.builder_key.private_key_pem
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo usermod -aG docker ubuntu",
      "docker --version",
      "docker compose version"
    ]
  }
}