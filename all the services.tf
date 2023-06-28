# Provider

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAWCOUOBMY7NOUWB76"
  secret_key = "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"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "mynew133bucket"
}

# creating the vpc
resource "aws_vpc" "rudra" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "somavpc"
  }
}

#creating the subnet

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.rudra.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "soma_subnet"
  }
}


# craeting the second subnet

resource "aws_subnet" "subnetone" {
  vpc_id     = aws_vpc.rudra.id
  cidr_block = "10.0.0.0/24"
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "soma_subnet"
  }
}

# # creating the internetgateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.rudra.id

  tags = {#
    Name = "soma_ig"
  }
}

# # creating the route table

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.rudra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "soma_rt"
  }
}

# associating the subnet to the routetable

resource "aws_route_table_association" "assocaite" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}


# creating the security group

resource "aws_security_group" "security" {
  name        = "soma_security"
  description = "demo security group"
  vpc_id      = aws_vpc.rudra.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "soma_security"
  }
}

# creating the keypair 

resource "aws_key_pair" "deployer" {
  key_name   = "keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}



# creating the ec2 instances

resource "aws_instance" "instances" {
  ami                     = "ami-03b31136fc503b84a"
  instance_type           = "t2.micro"
  key_name                = "keypair"
  availability_zone       = "ap-south-1a"
  security_groups         = [aws_security_group.security.id]
  subnet_id               = aws_subnet.subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "soma_instances"
  }
}


# creating the  EBS volume

resource "aws_ebs_volume" "ebs" {
  availability_zone = "ap-south-1a"
  size              = 5

  tags = {
    Name = "soma_ebs"
  }
}


# craeting the s3 bucket

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


# Enabling the bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# to upload the object in the s3 bucket

resource "aws_s3_bucket_object" "object" {
  bucket = "mynew133bucket"
  key    = "doduts"                                       
  source = "C:/Users/somas/OneDrive/Desktop/doduts.txt"
  # etag   = filemd5("C:/Users/somas/OneDrive/Desktop/doduts.txt")
}


# craeeting the target groups for the load balancer

resource "aws_lb_target_group" "lb" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rudra.id
  target_type = "instance"
}

# craeting the load balancer for the instances
resource "aws_lb" "example" {
  name               = "my-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security.id]
  subnets            = [aws_subnet.subnet.id, aws_subnet.subnetone.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}


# attaching the load balancer to the instanvces and traget group
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.lb.arn
  target_id        = aws_instance.instances.id
  port             = 80
}

