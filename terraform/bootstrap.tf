resource "aws_s3_bucket" "terraform" {
  bucket = "adborden-terraform"
  acl    = "private"

  versioning {
    enabled = true
  }
}
