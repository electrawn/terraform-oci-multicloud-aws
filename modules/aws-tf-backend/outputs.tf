
output "backend" {
  description = "Helper object with bucket and table."
  value = {
    bucket = aws_s3_bucket.tfstate.bucket
    table  = aws_dynamodb_table.tf_locks.name
  }
}

