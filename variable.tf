provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAYT7BACL7O2K6PCGS"
  secret_key = "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"
}

# passing the variable



variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-done"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/17"
}

# passing the variable son subnet

variable "subnet_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-subnet"
}

variable "subnet_cidr" {
  description = "value of the subnet cidr"
  type        = string
  default     = "10.0.0.0/24"
}

# creating the vpc

resource "aws_vpc" "done" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}


# craeting the subnet

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.done.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = var.subnet_name
  }
}



# outputs


output "vpc_id" {
  value = aws_vpc.done.id
}
output "vpc_cidr" {
  value = aws_vpc.done.cidr_block
}
output "vpc_name" {
  value = aws_subnet.main.cidr_block
}