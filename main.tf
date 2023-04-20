provider "aws" {
  region = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}
variable ami {}

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

resource "aws_internet_gateway" "sculptsoft-igw" {
  vpc_id = aws_vpc.sculptsoft-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "sculptsoft-route-table" {
  vpc_id = aws_vpc.sculptsoft-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sculptsoft-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_route_table_association" "sculptsoft-rtb-subnet" {
  subnet_id = aws_subnet.sculptsoft-subnet-1.id
  route_table_id = aws_route_table.sculptsoft-route-table.id
}

resource "aws_security_group" "sculptsoft-gp" {
  name = "${var.env_prefix}-security-sg"
  vpc_id = aws_vpc.sculptsoft-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol="tcp"
    cidr_blocks = [var.my_ip]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol="-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

#Create Key-pair Must require ssh pub key generated locally
resource "aws_key_pair" "ssh-key" {
  key_name = "${var.env_prefix}-ssh-key"
  public_key =  file(var.public_key_location)
}

#Fetch Amazon Machine Image (AMI), Find AMI from aws, ami id will be different for every region
#if no subnet or vpc or security group specified it will by defalut take default
#key_name should be only name of key-pair which manually created from aws account
resource "aws_instance" "sculptsoft-server" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.sculptsoft-subnet-1.id
  vpc_security_group_ids = [aws_security_group.sculptsoft-gp.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  # user_data = file("entry_script.sh")

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file(var.private_key_location)
  }
  
  provisioner "file" {
    source = "enry_point.sh"
    destination = "/home/ubuntu/entry-script-on-ec2.sh"
  }

  provisioner "remote-exec" {
    script = file("entry-script-on-ec2.sh")
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  }
  
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.sculptsoft-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.sculptsoft-subnet-1
}


output "ec2_public_ip" {
  value = aws_instance.sculptsoft-server.public_ip
}