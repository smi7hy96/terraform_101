variable "vpc_id" {
  description = "the ID of the main VPC"
}

variable "ami_id" {
  description = "the ID of the APP AMI"
}

variable "name" {
  description = "Naming Convention for naming resources"
}

variable "cidr_block_pub" {
  description = "CIDR Block for the public subnet"
}

variable "cidr_block_all" {
  description = "CIDR Block for all Traffic"
}

variable "internet_gw" {
  description = "ID for the internet gateway"
}

variable "db_private_ip" {
  description = "Private IP for the DB Instance"
}
