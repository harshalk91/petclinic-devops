module "create_vpc" {
  source = "./vpc"
}

module "create-instance" {
  source = "./instance-creaation"
  instance_name = var.instance_name
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  type = var.type
  aws_access_key = var.aws_access_key
  aws_region = var.aws_region
  aws_secret_key = var.aws_secret_key
}
