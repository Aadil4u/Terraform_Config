resource "aws_default_security_group" "myapp-default-sg" {
  vpc_id = var.vpc_id

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
  subnet_id                   = var.subnet_id
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
