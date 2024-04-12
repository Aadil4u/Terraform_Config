provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env-prefix}-vpc"
  }
}

module "myapp-subnet" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  availability_zone      = var.availability_zone
  env-prefix             = var.env-prefix
  vpc_id                 = aws_vpc.my-app-vpc.id
  default_route_table_id = aws_vpc.my-app-vpc.default_route_table_id
}


module "myapp-webserver" {
  source              = "./modules/webserver"
  availability_zone   = var.availability_zone
  env-prefix          = var.env-prefix
  vpc_id              = aws_vpc.my-app-vpc.id
  my-ip               = var.my-ip
  image-name          = var.image-name
  public_key_location = var.public_key_location
  instance_type       = var.instance_type
  subnet_id           = module.myapp-subnet.subnet.id
}



