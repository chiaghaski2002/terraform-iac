#-------networking/outputs.tf-----

output "public_subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnets" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "public_sg" {
  value = "${aws_security_group.public_sg.id}"
}

output "public_subnet_ips" {
  value = "${aws_subnet.public_subnet.*.cidr_block}"
}

output "private_subnet_ips" {
  value = "${aws_subnet.private_subnet.*.cidr_block}"
}
