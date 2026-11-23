resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

# Optional: enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}
