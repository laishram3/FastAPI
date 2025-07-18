terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_security_group" "fastapi_sg" {
  name        = "fastapi-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/////

resource "aws_iam_role" "ec2_role" {
  name = "fastapi_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "fastapi_ec2_profilee"
  role = aws_iam_role.ec2_role.name
}




resource "aws_instance" "fastapi_server" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.public_subnet.id 
  security_groups             = [aws_security_group.fastapi_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/../../user_data.sh")
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "FastAPI-Server"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "id_rsa"
   public_key = file("${path.module}/../../id_rsa.pub")
}

output "instance_public_ip" {
  value = aws_instance.fastapi_server.public_ip
}