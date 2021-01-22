module "vpc_module" {
  source = "../vpc"
}
resource "aws_security_group" "eq-sec-grp" {
  depends_on = [
    module.vpc_module.eq-vpc
  ]
  ingress {
    description = "Allow Jenkins"
    from_port = 8080
    protocol = "HTTP"
    to_port = 8080
    cidr_blocks = ['0.0.0.0/0']
  }

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "SSH"
    to_port = 22
    cidr_blocks = ['0.0.0.0/0']
  }

  ingress {
    description = "PING"
    from_port = -1
    protocol = "ICMP"
    to_port = -1
    cidr_blocks = ['0.0.0.0/0']
  }

  tags = {
    Name = "Jenkins Security "
  }
}

resource "aws_instance" "my-test-instance" {
  depends_on = [
    aws_vpc.eq-vpc,
    aws_subnet.eq-subnet-public-1,
    aws_subnet.eq-subnet-private-1,
    aws_security_group.eq-sec-grp
  ]
  ami             = var.ami
  instance_type   = var.instance_type
  vpc_security_group_ids  = aws_security_group.eq-sec-grp.id
  subnet_id	  = aws_subnet.eq-subnet-public-1.id
  key_name 	  = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
    type = "wikimedia-demo"
  }
}
