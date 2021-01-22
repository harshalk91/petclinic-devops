# Create VPC
resource "aws_vpc" "eq-vpc" {
  cidr_block = "192.168.250.0/23"
  instance_tenancy = "default"
  enable_dns_hostnames = "True"
  tags = {
    Name = "eq-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "eq-subnet-public-1" {
  depends_on = [
    aws_vpc.eq-vpc
  ]
  cidr_block = "192.168.250.0/24"
  vpc_id = aws_vpc.eq-vpc.id
  tags = {
    Name = "eq-subnet-public-1"
  }
}

# Create Private Subnet
resource "aws_subnet" "eq-subnet-private-1" {
  depends_on = [
    aws_vpc.eq-vpc
  ]
  cidr_block = "192.168.251.0/24"
  vpc_id = aws_vpc.eq-vpc.id
  tags = {
    Name = "eq-subnet-private-1"
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
    Name = "eq-igw"
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
    Name = "eq-public-rt"
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
  subnet_id = aws_subnet.eq-subnet-public-1
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
  subnet_id = aws_subnet.eq-subnet-public-1
  tags = {
    Name = "eq-nat-gw"
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
    Name = "eq-private-rt"
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
  subnet_id = aws_subnet.eq-subnet-private-1
}