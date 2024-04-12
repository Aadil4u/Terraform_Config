provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr_block" {
}


variable "subnet_cidr_block" {}

variable "availability_zone" {}

variable "env-prefix" {}
variable "my-ip" {}
variable "image-name" {}
variable "instance_type" {}
variable "public_key_location" {}





resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env-prefix}-vpc"
  }
}


resource "aws_subnet" "my-app-subnet-1" {
  vpc_id            = aws_vpc.my-app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env-prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my-app-igw" {
  vpc_id = aws_vpc.my-app-vpc.id
  tags = {
    Name : "${var.env-prefix}-igw"
  }
}

# Creating new route table, routes and subnet association
/*
resource "aws_route_table" "my-app-rtb" {
  vpc_id = aws_vpc.my-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-igw.id
  }
  tags = {
    Name : "${var.env-prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-assoc" {
  subnet_id      = aws_subnet.my-app-subnet-1.id
  route_table_id = aws_route_table.my-app-rtb.id
} */

# Using default existing route table and configuring new route

resource "aws_default_route_table" "my-app-main-rtb" {
  default_route_table_id = aws_vpc.my-app-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-igw.id
  }
  tags = {
    Name : "${var.env-prefix}-main-rtb"
  }
}

# Creating new sg and assigning inbound and outbount rules
/* resource "aws_security_group" "my-app-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.my-app-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my-ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name : "${var.env-prefix}-sg"
  }
} */

# using default sg and assigning inbound and outbount rules
resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = aws_vpc.my-app-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my-ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name : "${var.env-prefix}-default-sg"
  }
}


data "aws_ami" "amazon-linux" {
  owners = ["amazon"]

  most_recent = true

  filter {
    name   = "name"
    values = [var.image-name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "my-key-pair" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)

}

resource "aws_instance" "myapp-instance" {
  ami                         = data.aws_ami.amazon-linux.image_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.my-app-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.myapp-default-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.my-key-pair.key_name
  availability_zone           = var.availability_zone

  user_data                   = file("entryscript.sh")
  user_data_replace_on_change = true

  tags = {
    Name : "${var.env-prefix}-instance"
  }
}

output "public_ip" {
  value = aws_instance.myapp-instance.public_ip
}
