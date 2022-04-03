variable "aws_region" {
  type = string
}

variable "namespace" {
  type    = string
}

variable "instance_type" {
  type    = string
}

variable "volume_size" {
  type = number
}

variable "ec2_ami" {
  type = string
}

variable "allow_traffic_cidrs" {
  type = list(string)
}

variable "availability_zone_1" {
  type = string
}

variable "availability_zone_2" {
  type = string
}

variable "key_name" {
  type = string
}

variable "deployer_key" {
  type = string
}

variable "vpc_cidr_prefix16" {
  type = string
}

variable "repository_name" {
  type = string
}