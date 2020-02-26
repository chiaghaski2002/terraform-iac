#-----storage/outputs.tf-------

output "Bucket name" {
  value = "${aws_s3_bucket.my_bucket.id}"
}
