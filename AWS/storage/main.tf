#-------storage/main.tf--------------------

#-------Creating a random id---------------

resource "random_id" "tf_bucket_id" {
  byte_length = 2
}

#-------Creating the bucket-------------------
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "${var.project_name}-${random_id.tf_bucket_id.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "my_bucket"
  }
}
