

#CREATE public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr_block_pub}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}.sub.public"
  }
}
#CREATE Security Group for webapp
resource "aws_security_group" "webapp" {
  name        = "app-security-group"
  description = "Allow HTTP and HTTPS Traffic In"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description = "HTTPS IN"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block_all}"]
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
    Name = "${var.name}.SecG.Webapp"
  }
}
#CREATE NACL for Public Subnet
resource "aws_network_acl" "public" {
  vpc_id     = "${var.vpc_id}"
  subnet_ids = [aws_subnet.public.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 80
    to_port    = 80
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
    rule_no    = 120
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.name}.Nacl.public"
  }
}

#CREATE Route Table for public subnet
resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "${var.cidr_block_all}"
    gateway_id = "${var.internet_gw}"
  }

  tags = {
    Name = "${var.name}.Route.public"
  }
}

#CREATE Route Table Association for public route table
resource "aws_route_table_association" "routeapp" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#LOAD INIT SCRIPT TO BE USED
data "template_file" "initapp" {
  template = file("./scripts/app/init.sh.tpl")
  vars = {
      db_host = "mongodb://${var.db_private_ip}:27017/posts"
    }
}

#CREATE WEB MACHINE WITH APP AMI
resource "aws_instance" "Web" {
  ami                         = "${var.ami_id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.webapp.id]
  user_data                   = data.template_file.initapp.rendered
  tags = {
    Name = "${var.name}.tf.app"
  }
}
