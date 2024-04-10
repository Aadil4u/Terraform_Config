provider "aws" {
}

variable "aws_vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "vpc_name"
  default     = "Dev-Vpc"
}

variable "subnet_name" {
  description = "subnet_name"
  default     = "Dev-Vpc-1"
}

variable "aws_subnet_cidr_block" {
  description = "subnet cidr block"
  type        = string
  default     = "10.0.10.0/24"
}

variable "availability_zone" {
  default = "ap-south-1a"
}

resource "aws_vpc" "terr_main" {
  cidr_block = var.aws_vpc_cidr_block
  tags = {
    Name : var.vpc_name
  }
}


resource "aws_subnet" "demo_subnet_1" {
  vpc_id            = aws_vpc.terr_main.id
  cidr_block        = var.aws_subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : var.subnet_name
  }
}


data "aws_vpc" "default_vpc" {
  default = true
}

output "vpc_id" {
  value = data.aws_vpc.default_vpc.id
}

output "dev_vpc_id" {
  value = aws_vpc.terr_main.id
}

output "dev_subnet_id" {
  value = aws_subnet.demo_subnet_1.id
}
