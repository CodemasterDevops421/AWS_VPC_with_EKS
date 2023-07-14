provider "aws" {
  region = var.location
}


resource "aws_eip" "kubectl-eip" {
  count    = 1
  domain   = "vpc"
  instance = aws_instance.kubectl-server[count.index].id
}




resource "aws_instance" "kubectl-server" {
  count                       = 1
  ami                         = var.os_name
  key_name                    = var.key
  instance_type               = var.instance-type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.kubectl_subnet-1.id
  vpc_security_group_ids      = [aws_security_group.kubectl-vpc-sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum upgrade -y
  sudo yum install unzip java-11-openjdk-devel docker -y
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $(whoami)
  newgrp docker
  EOF

  tags = {
    Name = "kubectl-server-${count.index}"
  }
}




// Create VPC
resource "aws_vpc" "kubectl-vpc" {
  cidr_block = var.vpc-cidr
}

// Create Subnet
resource "aws_subnet" "kubectl_subnet-1" {
  vpc_id            = aws_vpc.kubectl-vpc.id
  cidr_block        = var.subnet1-cidr
  availability_zone = var.subent_az
  map_public_ip_on_launch = true

  tags = {
    Name = "kubectl_subnet1"
  }
}


resource "aws_subnet" "kubectl_subnet-2" {
  vpc_id            = aws_vpc.kubectl-vpc.id
  cidr_block        = var.subnet2-cidr
  availability_zone = var.subent-2_az
  map_public_ip_on_launch = true  

  tags = {
    Name = "kubectl_subnet2"
  }
}



// Create Internet Gateway

resource "aws_internet_gateway" "kubectl-igw" {
  vpc_id = aws_vpc.kubectl-vpc.id

  tags = {
    Name = "kubectl-igw"
  }
}


// Create Route table resource

resource "aws_route_table" "kubectl-rt" {
  vpc_id = aws_vpc.kubectl-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubectl-igw.id
  }
  tags = {
    Name = "kubectl-rt"
  }
}

// associate subnet with route table

resource "aws_route_table_association" "kubectl-rt_association-1" {
  subnet_id = aws_subnet.kubectl_subnet-1.id

  route_table_id = aws_route_table.kubectl-rt.id
}

resource "aws_route_table_association" "kubectl-rt_association-2" {
  subnet_id = aws_subnet.kubectl_subnet-2.id

  route_table_id = aws_route_table.kubectl-rt.id
}


// create a security group

resource "aws_security_group" "kubectl-vpc-sg" {
  name = "kubectl-vpc-sg"

  vpc_id = aws_vpc.kubectl-vpc.id

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}



module "sgs" {
  source = "./sg_eks"
  vpc_id = aws_vpc.kubectl-vpc.id
}

module "EKS" {
  source     = "./eks"
  sg_ids     = module.sgs.security_group_public
  vpc_id     = aws_vpc.kubectl-vpc.id
  subnet_ids = [aws_subnet.kubectl_subnet-1.id, aws_subnet.kubectl_subnet-2.id]
}
