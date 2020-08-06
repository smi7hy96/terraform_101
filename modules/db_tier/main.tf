# DB MACHINE SETUP

#CREATE private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr_block_priv}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}.sub.private"
  }
}
#CREATE Security Group for DB
resource "aws_security_group" "db" {
  name        = "db-security-group"
  description = "Allow Public Subnet In"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description = "Public Sub IN"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    # cidr_blocks = ["${var.cidr_block_pub}"]
    security_groups = ["${var.app_sec_group}"]
  }
  ingress {
    description = "HTTP IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block_all}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block_all}"]
  }

  tags = {
    Name = "${var.name}.SecG.DB"
  }
}
#CREATE NACL for Private Subnet
resource "aws_network_acl" "private" {
  vpc_id     = "${var.vpc_id}"
  subnet_ids = [aws_subnet.private.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block_pub}"
    from_port  = 27017
    to_port    = 27017
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.name}.Nacl.private"
  }
}
#CREATE Route Table for private subnet
resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "${var.cidr_block_all}"
    gateway_id = "${var.internet_gw}"
  }

  tags = {
    Name = "${var.name}.Route.private"
  }
}

#CREATE Route Table Association for private table
resource "aws_route_table_association" "routedb" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
#LOAD INIT SCRIPT TO BE USED FOR DB MACHINE
data "template_file" "initdb" {
  template = file("./scripts/db/init.sh.tpl")
}

#CREATE WEB MACHINE WITH DB AMI
resource "aws_instance" "Db" {
  ami                         = "${var.ami_id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  user_data                   = data.template_file.initdb.rendered
  tags = {
    Name = "${var.name}.tf.DB"
  }
}
