output "VPCID" {
  value = module.vpc.vpc_id
}

output "ec2_public_ip" {
  value = module.sculptsoft-webserver.instance.public_ip
}