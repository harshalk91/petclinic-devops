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
  #count = length(data.aws_vpcs.eq-vpc.ids)
  #id    = tolist(data.aws_vpcs.eq-vpc.ids)[count.index]
}

data "aws_subnet" "subnet" {
  #count = length(data.aws_vpcs.eq-vpc.ids)
  vpc_id = data.aws_vpc.eq-vpc.id
  filter {
    name = "tag:Name"
    values = [var.public_subnet_name]
  }
  #tags = {
  #  Name = "eq-subnet-public-1"
  #}
}
resource "aws_security_group" "eq-sec-grp" {
  vpc_id = data.aws_vpc.eq-vpc.id

  ingress {
    description = "Allow Jenkins"
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PING"
    from_port = -1
    protocol = "ICMP"
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins Security"
    type = var.type
  }
}
resource "aws_instance" "my-test-instance" {
  ami             = var.ami
  availability_zone = var.availability_zone
  instance_type   = var.instance_type
  vpc_security_group_ids  = [aws_security_group.eq-sec-grp.id]
  subnet_id	  = data.aws_subnet.subnet.id
  associate_public_ip_address = true
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum remove java-1.7.0 -y | tee -a >> /tmp/install.log
              sudo yum install java-1.8.0 -y | tee -a >> /tmp/install.log
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key | tee -a >> /tmp/install.log
              sudo yum install jenkins -y | tee -a >> /tmp/install.log
              sudo service jenkins start | tee -a >> /tmp/install.log
              sudo chkconfig --add jenkins | tee -a >> /tmp/install.log
              sudo pip install ansible | tee -a >> /tmp/install.log
              EOF
  tags = {
    Name = var.instance_name
    type = var.type
  }
}
resource "aws_volume_attachment" "ebs-vol-attach" {
  device_name = "/dev/sdb"
  instance_id = aws_instance.my-test-instance.id
  volume_id = aws_ebs_volume.ebs-vol.id
}