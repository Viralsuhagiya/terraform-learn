output "VPCID" {
  value = aws_vpc.sculptsoft-vpc.id
}

output "ec2_public_ip" {
  value = module.sculptsoft-webserver.instance.public_ip
}