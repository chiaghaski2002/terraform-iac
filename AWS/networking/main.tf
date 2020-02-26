#------- Networking/mani.tf--------

data "aws_availability_zones" "available" {}

#----- Creatig vpc-----------------
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "dev_vpc"
  }
}

#----- Creating Internet Gateway--------------
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = "${aws_vpc.dev_vpc.id}"

  tags {
    Name = "dev_igw"
  }
}

#------- Creating public route table----------
resource "aws_route_table" "dev_public_rt" {
  vpc_id = "${aws_vpc.dev_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev_igw.id}"
  }

  tags {
    Name = "Public_RT"
  }
}

#--------- Creating public subnet--------------
resource "aws_subnet" "public_subnet" {
  count                   = 6
  vpc_id                  = "${aws_vpc.dev_vpc.id}"
  cidr_block              = "${var.public_cidrs[count.index]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "tf_public_${count.index + 1}"
  }
}

#----------- Creating private subnet--------------
resource "aws_subnet" "private_subnet" {
  count                   = 6
  vpc_id                  = "${aws_vpc.dev_vpc.id}"
  cidr_block              = "${var.private_cidrs[count.index]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "tf_private_${count.index + 1}"
  }
}

#------------ Creating elastic ip-----------------
resource "aws_eip" "nat_eip" {
  vpc = true
}

#----------- Creating nat gateway-----------------
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"

  tags {
    Name = "NAT_Gateway"
  }
}

#----------- Creating private route table---------------
resource "aws_default_route_table" "dev_private_rt" {
  default_route_table_id = "${aws_vpc.dev_vpc.default_route_table_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "Private_RT"
  }
}

#------------- Public subnets associations to public route table--------------
resource "aws_route_table_association" "public_assoc" {
  count          = "${aws_subnet.public_subnet.count}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.dev_public_rt.id}"
}

#-------------- Private subnet associatio to private route table---------------
resource "aws_route_table_association" "private_assoc" {
  count          = "${aws_subnet.private_subnet.count}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  route_table_id = "${aws_default_route_table.dev_private_rt.id}"
}

#-------------- Creating general security group---------------------------
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "used for accessing public instances"
  vpc_id      = "${aws_vpc.dev_vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
