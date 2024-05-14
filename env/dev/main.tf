# Resource S3
resource "aws_s3_bucket" "bucket" {
  count = length(var.bucket-s3)
  bucket = join("-", tolist(["bucket", var.environment, var.bucket-s3[count.index]]))
}