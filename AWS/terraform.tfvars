aws_region   = "us-east-1"
project_name = "dev"
vpc_cidr     = "30.0.0.0/16"
public_cidrs = [
  "30.0.0.0/24",
  "30.0.1.0/24",
  "30.0.2.0/24",
  "30.0.3.0/24",
  "30.0.4.0/24",
  "30.0.5.0/24"
]
private_cidrs = [
  "30.0.6.0/24",
  "30.0.7.0/24",
  "30.0.8.0/24",
  "30.0.9.0/24",
  "30.0.10.0/24",
  "30.0.11.0/24"
]
accessip    = "0.0.0.0/0"

key_name = "tf_key"
public_key_path = "~/.ssh/dev.pub"
server_instance_type = "t2.micro"
instance_count = 2
