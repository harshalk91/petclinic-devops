# AWS Config

variable "instance_name" {
  default = "Jenkins"
}
variable "aws_access_key" {
  default = "AKIA23LO2KZKEBDZXTUG"
}

variable "aws_secret_key" {
  default = "MRyPK6ql7GesQAV8kFTUTJmSlGfgL7OAUhDziX/2"
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "ami" {
  default = "ami-02e60be79e78fef21"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "jenkins-test"
}
variable "type" {
  default = "jenkins"
}