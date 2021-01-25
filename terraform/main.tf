module "create_vpc" {
  source = "./vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  availability_zone = var.availability_zone
  public_cidr_block = var.public_cidr_block
  public_subnet_name = var.public_subnet_name
  private_cidr_block = var.private_cidr_block
  private_subnet_name = var.private_subnet_name
  igw_name = var.igw_name
  public_rt_name = var.public_rt_name
  nat_gw_name = var.nat_gw_name
  private_rt_name = var.private_rt_name
}

module "create-jenkins-instance" {
  source = "./jenkins"
  instance_name = var.instance_name
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  type = var.type
  aws_access_key = var.aws_access_key
  aws_region = var.aws_region
  aws_secret_key = var.aws_secret_key
  vpc_name = var.vpc_name
  volume_name = var.volume_name
  availability_zone = var.availability_zone
  public_subnet_name = var.public_subnet_name
}

module "create-app-instance" {
  source = "./app"
  instance_name = var.app_instance_name
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  type = var.type
  aws_access_key = var.aws_access_key
  aws_region = var.aws_region
  aws_secret_key = var.aws_secret_key
  vpc_name = var.vpc_name
  volume_name = var.volume_name
  availability_zone = var.availability_zone
  private_subnet_name = var.private_subnet_name
  public_cidr_block = var.public_cidr_block
}
