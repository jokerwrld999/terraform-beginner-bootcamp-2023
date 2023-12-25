output "bootcamp_bucket_id" {
  value       = aws_s3_bucket.bootcamp_bucket.id
  description = "AWS S3 Bucket ID"
}

output "bootcamp_bucket_bucket_regional_domain_name" {
  value       = aws_s3_bucket.bootcamp_bucket.bucket_regional_domain_name
  description = "AWS S3 Bucket Regional Domain Name"
}