provider "aws" {
  region     = "eu-west-1"
  #access_key = ""
  #secret_key = ""
}
#CREATE WEB MACHINE WITH APP AMI
resource "aws_instance" "Web" {
  ami                         = "${app_ami_id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.webapp.id]
  user_data                   = data.template_file.initapp.rendered
  tags = {
    Name = "${name}.app"
  }
}
#CREATE WEB MACHINE WITH APP AMI
resource "aws_instance" "Db" {
  ami                         = "${db_ami_id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  user_data                   = data.template_file.initdb.rendered
  tags = {
    Name = "${name}.DB"
  }
}
#CREATE BASTION MACHINE
# resource "aws_instance" "Bastion" {
#   ami                         = "ami-06ab65ef16db3ae5f"
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   tags = {
#     Name = "Eng57.Ryan.S.tf.bastion"
#   }
# }
#CREATE VPC
#CREATE VPC
resource "aws_vpc" "main" {
  cidr_block       = "${cidr_block}"
  tags = {
    Name = "${name}.VPC.Main"
  }
}

#CREATE Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${name}.igw.main"
  }
}

#CREATE public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${cidr_block_pub}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${name}.sub.public"
  }
}
#CREATE Security Group for webapp
resource "aws_security_group" "webapp" {
  name        = "${name}.SG.app"
  description = "Allow HTTP and HTTPS Traffic In"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS IN"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${cidr_block_all}"]
  }
  ingress {
    description = "HTTP IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${cidr_block_all}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${cidr_block_all}"]
  }

  tags = {
    Name = "${name}.SecG.Webapp"
  }
}
#CREATE NACL for Public Subnet
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${name}.Nacl.public"
  }
}

#CREATE Route Table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "${cidr_block_all}"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${name}.Route.public"
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
      db_host = "mongodb://${aws_instance.Db.private_ip}:27017/posts"
    }
}

# DB MACHINE SETUP

#CREATE private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${cidr_block_priv}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${name}.sub.private"
  }
}
#CREATE Security Group for DB
resource "aws_security_group" "db" {
  name        = "${name}.SG.Db"
  description = "Allow Public Subnet In"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Public Sub IN"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${cidr_block_pub}"]
  }
  ingress {
    description = "HTTP IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${cidr_block_all}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${cidr_block_all}"]
  }

  tags = {
    Name = "${name}.SecG.DB"
  }
}
#CREATE NACL for Private Subnet
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${cidr_block_pub}"
    from_port  = 27017
    to_port    = 27017
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "${cidr_block_all}"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${name}.Nacl.private"
  }
}
#CREATE Route Table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "${cidr_block_all}"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${name}.Route.private"
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
