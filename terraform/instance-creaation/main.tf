module "vpc" {
    source = "../vpc"
}
resource "aws_security_group" "eq-sec-grp" {

  ingress {
    description = "Allow Jenkins"
    from_port = 8080
    protocol = "HTTP"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    protocol = "SSH"
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

  tags = {
    Name = "Jenkins Security"
    type = var.type
  }
}

resource "aws_ebs_volume" "ebs-vol" {
  availability_zone = "ap-south-1a"
  size = 20
  tags = {
    Name = "jenkins-vol"
  }
}

data "aws_vpcs" "eq-vpc" {
  tags = {
    Name = "eq-vpc"
  }
  count = length(data.aws_vpcs.eq-vpc.ids)
  id = tolist(data.aws_vpcs.eq-vpc.ids)[count.index]
  #id = data.aws_vpcs.eq-vpc.ids
}
output "eq-vpc" {
  value = data.aws_vpcs.eq-vpc.ids
}


data "aws_subnet_ids" "private" {
  count = length(data.aws_vpcs.eq-vpc.ids)
  vpc_id = data.aws_vpcs.eq-vpc[count.index].id
  tags = {
    Name = "eq-subnet-private-1"
  }
}

resource "aws_instance" "my-test-instance" {

  ami             = var.ami
  instance_type   = var.instance_type
  vpc_security_group_ids  = aws_security_group.eq-sec-grp.id
  subnet_id	  = data.aws_subnet_ids.private.id
  associate_public_ip_address = true
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install java-1.8.0 -y | tee -a >> /tmp/install.log
              sudo yum remove java-1.7.0-openjdk | tee -a >> /tmp/install.log
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
              sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key | tee -a >> /tmp/install.log
              sudo yum install jenkins -y | tee -a >> /tmp/install.log
              sudo systemctl start jenkins | tee -a >> /tmp/install.log
              sudo systemctl enable jenkins | tee -a >> /tmp/install.log
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