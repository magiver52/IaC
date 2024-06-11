resource "aws_s3_bucket" "bucket" {
  count  = length(var.s3_config) > 0 ? length(var.s3_config) : 0
  bucket = join("-", tolist([var.client, var.functionality, var.s3_config[count.index].account, var.s3_config[count.index].application, "s3", var.environment]))
  tags   = merge({ Name = "${join("-", tolist([var.client, var.functionality, "s3", var.s3_config[count.index].application, var.environment]))}" }, var.tags)
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = length(var.s3_config) > 0 ? length(var.s3_config) : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  versioning_configuration {
    status = var.s3_config[count.index].versioning
  }
}