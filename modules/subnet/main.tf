resource "aws_subnet" "my-app-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env-prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "my-app-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name : "${var.env-prefix}-igw"
  }
}

resource "aws_default_route_table" "my-app-main-rtb" {
  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-igw.id
  }
  tags = {
    Name : "${var.env-prefix}-main-rtb"
  }
}
