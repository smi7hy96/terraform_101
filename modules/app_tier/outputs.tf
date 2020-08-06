output "sec_group_id" {
  description = "ID of the app security group"
  value = "${aws_security_group.webapp.id}"
}

output "subnet_id" {
  description = "ID of the subnet"
  value = "${aws_subnet.public.id}"
}
