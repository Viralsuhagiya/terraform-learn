output "dev-vpc-id" {
  value = aws_vpc.sculptsoft-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.sculptsoft-subnet-1
}


output "ec2_public_ip" {
  value = aws_instance.sculptsoft-server.public_ip
}