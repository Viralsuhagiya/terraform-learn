provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "sculptsoft-vpc" {
  cidr_block =var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
    vpc_env = var.env_prefix
  }
}

module "sculptsoft-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block=var.subnet_cidr_block
  avail_zone=var.avail_zone
  env_prefix=var.env_prefix
  vpc_id=aws_vpc.sculptsoft-vpc.id
  default_route_table_id=aws_vpc.sculptsoft-vpc.default_route_table_id
}

module "sculptsoft-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.sculptsoft-vpc.id
  my_ip = var.my_ip
  public_key_location = var.public_key_location
  image_name = var.image_name
  instance_type = var.instance_type
  subnet_id = module.sculptsoft-subnet.subnet.id
  avail_zone = var.avail_zone
}