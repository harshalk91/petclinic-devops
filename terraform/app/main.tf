resource "aws_ebs_volume" "ebs-vol" {
  availability_zone = var.availability_zone
  size = 20
  tags = {
    Name = var.volume_name
  }
}

data "aws_vpc" "eq-vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "subnet" {
  #count = length(data.aws_vpcs.eq-vpc.ids)
  vpc_id = data.aws_vpc.eq-vpc.id
  filter {
    name = "tag:Name"
    values = [var.private_subnet_name]
  }
}

resource "aws_security_group" "eq-sec-grp" {
  vpc_id = data.aws_vpc.eq-vpc.id

  ingress {
    description = "Allow Jenkins to communicate with app"
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = [var.public_cidr_block]
  }

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.public_cidr_block]
  }

  ingress {
    description = "PING"
    from_port = -1
    protocol = "ICMP"
    to_port = -1
    cidr_blocks = [var.public_cidr_block]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App Security"
    type = var.type
  }
}
resource "aws_instance" "app-instance" {
  ami             = var.ami
  availability_zone = var.availability_zone
  instance_type   = var.instance_type
  vpc_security_group_ids  = [aws_security_group.eq-sec-grp.id]
  subnet_id	  = data.aws_subnet.subnet.id
  associate_public_ip_address = false
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install docker
              sudo service docker start
              sudo chkconfig --add docker
              sudo usermod -a -G docker ec2-user
              EOF
  tags = {
    Name = var.instance_name
    type = var.type
  }
}
resource "aws_volume_attachment" "ebs-vol-attach" {
  device_name = "/dev/sdb"
  instance_id = aws_instance.app-instance.id
  volume_id = aws_ebs_volume.ebs-vol.id
}