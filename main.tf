terraform {
   required_version = ">= 0.12"
   backend "s3" {
    bucket = "viral-dev-terraform-storage"
    key = "viral-dev-terraform-storage/state.tfstate"
    region = "us-east-1"
   }
}

provider "aws" {
  region = "us-east-1"
}

#Copy from https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sculptsoft-existing-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name:"${var.env_prefix}-subnet-1"}

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

#Find VPC ID from #https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=outputs
module "sculptsoft-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  vpc_id = module.vpc.vpc_id
  my_ip = var.my_ip
  public_key_location = var.public_key_location
  image_name = var.image_name
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  avail_zone = var.avail_zone
}