terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "sangue-doce-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "sangue-doce-subnet-public"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "sangue-doce-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "sangue-doce-route-table"
  }
}

resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "s3-nest-upload"
  tags = {
    Name        = "s3-nest-upload"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "disable_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  depends_on              = [aws_s3_bucket.my_bucket]
}


resource "aws_s3_bucket_policy" "allow_read" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.disable_block]
}

resource "aws_s3_object" "static_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  content_type = "text/html"
  source       = "${path.module}/index.html"
  etag         = filemd5("${path.module}/index.html")
  depends_on   = [aws_s3_bucket_policy.allow_read]
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
}

resource "aws_key_pair" "my_kp" {
  key_name   = "sangue-doce-keypair"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "my_sg" {
  name        = "mysqcuritygroup"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH on port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App on port 3388"
    from_port   = 3388
    to_port     = 3388
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

resource "aws_instance" "my_server" {
  ami                    = "ami-05ffe3c48a9991133"
  instance_type          = "t2.nano"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  user_data              = file("${path.module}/user_data.sh")
  key_name               = aws_key_pair.my_kp.key_name

  tags = {
    Name        = "sangue-doce-server"
    Environment = "Production"
  }
  depends_on = [aws_security_group.my_sg, aws_subnet.my_subnet, aws_internet_gateway.my_igw]
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.my_bucket.id
}

output "ec2_instance_public_ip" {
  description = "Endereço IP público da instância EC2"
  value       = aws_instance.my_server.public_ip
}

output "s3_website_endpoint" {
  description = "Endpoint do website S3"
  value       = aws_s3_bucket.my_bucket.bucket_regional_domain_name
}

output "vpc_id" {
  description = "ID do VPC criado"
  value       = aws_vpc.my_vpc.id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.my_subnet.id
}
