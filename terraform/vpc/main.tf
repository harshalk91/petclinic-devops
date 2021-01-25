# Create VPC
resource "aws_vpc" "eq-vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Create Public Subnet
resource "aws_subnet" "eq-subnet-public-1" {
  depends_on = [
    aws_vpc.eq-vpc
  ]
  availability_zone = var.availability_zone
  cidr_block = var.public_cidr_block
  vpc_id = aws_vpc.eq-vpc.id
  tags = {
    Name = var.public_subnet_name
  }
}

# Create Private Subnet
resource "aws_subnet" "eq-subnet-private-1" {
  depends_on = [
    aws_vpc.eq-vpc
  ]
  availability_zone = var.availability_zone
  cidr_block = var.private_cidr_block
  vpc_id = aws_vpc.eq-vpc.id
  tags = {
    Name = var.private_subnet_name
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "eq-igw" {
  depends_on = [
    aws_vpc.eq-vpc,
    aws_subnet.eq-subnet-public-1
  ]
  vpc_id = aws_vpc.eq-vpc.id

  tags = {
    Name = var.igw_name
  }
}

# Create Public Route Table
resource "aws_route_table" "eq-public-rt" {
  depends_on = [
    aws_vpc.eq-vpc,
    aws_internet_gateway.eq-igw
  ]
  vpc_id = aws_vpc.eq-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eq-igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

# Associate Internet Gateway with subnet
resource "aws_route_table_association" "ig-association" {
  depends_on = [
    aws_vpc.eq-vpc,
    aws_subnet.eq-subnet-public-1,
    aws_internet_gateway.eq-igw,
    aws_route_table.eq-public-rt
  ]
  route_table_id = aws_route_table.eq-public-rt.id
  subnet_id = aws_subnet.eq-subnet-public-1.id
}

# Create Elastic IP for Nat Gateway
resource "aws_eip" "eq-eip" {
  depends_on = [
    aws_route_table_association.ig-association
  ]
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "eq-nat-gw" {
  allocation_id = aws_eip.eq-eip.id
  subnet_id = aws_subnet.eq-subnet-public-1.id
  tags = {
    Name = var.nat_gw_name
  }
}

# Create private Route Table
resource "aws_route_table" "eq-private-rt" {
  depends_on = [
    aws_nat_gateway.eq-nat-gw
  ]
  vpc_id = aws_vpc.eq-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eq-nat-gw.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

# Associate Private Route Table with subnet
resource "aws_route_table_association" "ng-association" {
  depends_on = [
    aws_vpc.eq-vpc,
    aws_subnet.eq-subnet-public-1,
    aws_internet_gateway.eq-igw,
    aws_route_table.eq-public-rt
  ]
  route_table_id = aws_route_table.eq-private-rt.id
  subnet_id = aws_subnet.eq-subnet-private-1.id
}
