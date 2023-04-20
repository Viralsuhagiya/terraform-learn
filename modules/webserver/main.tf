
resource "aws_security_group" "sculptsoft-gp" {
  name = "${var.env_prefix}-security-sg"
  vpc_id = var.vpc_id

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
  ami = var.image_name
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sculptsoft-gp.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry_script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}
