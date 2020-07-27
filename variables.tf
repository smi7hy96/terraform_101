variable "name" {
  default="Eng57.Ryan.S.tf"
}

variable "db_ami_id" {
  default="ami-008320af74136c628"
}

variable "app_ami_id" {
  default="ami-06ab65ef16db3ae5f"
}

variable "cidr_block" {
  default="96.0.0.0/16"
}
variable "cidr_block_pub" {
  default="96.0.1.0/24"
}
variable "cidr_block_priv" {
  default="96.0.2.0/24"
}
variable "cidr_block_all" {
  default="0.0.0.0/0"
}
