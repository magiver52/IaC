# Resource S3
resource "aws_s3_bucket" "bucket" {
  count = length(var.bucket-s3)
  bucket = join("-", tolist(["bucket", var.environment, var.bucket-s3[count.index]]))
}

resource "aws_instance" "instance" {
  ami           = "ami-0bb84b8ffd87024d8"
  instance_type = "t3.micro"
  subnet_id = "subnet-06528b19f73591fac"
  vpc_security_group_ids = ["sg-09435d5db8702c30e"]
  tags = {
    Name = "ec2-lab-iac"
  }
}