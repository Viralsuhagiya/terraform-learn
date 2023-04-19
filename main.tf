provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}

resource "aws_vpc" "sculptsoft-vpc" {
  cidr_block =var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
    vpc_env = var.env_prefix
  }
}

resource "aws_subnet" "sculptsoft-subnet-1" {
  vpc_id = aws_vpc.sculptsoft-vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
  availability_zone = var.avail_zone
}


output "dev-vpc-id" {
  value = aws_vpc.sculptsoft-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.sculptsoft-subnet-1
}