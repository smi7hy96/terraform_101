output "db_private_ip" {
  description = "Private IP of the DB Instance"
  value = "${aws_instance.Db.private_ip}"
}
