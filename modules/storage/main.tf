# S3 static website bucket
resource "aws_s3_bucket" "bootcamp_bucket" {
  bucket = var.root_domain_name
}

resource "aws_s3_bucket_website_configuration" "bootcamp_bucket_website" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "bootcamp_bucket_versioning" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Upload website content
module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/static-website"
}

resource "aws_s3_object" "provision_source_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.bootcamp_bucket.id
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content
}

# S3 bucket ACL access
resource "aws_s3_bucket_ownership_controls" "bootcamp_bucket_ownership" {
  bucket = aws_s3_bucket.bootcamp_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bootcamp_bucket_access_block" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "bootcamp_bucket_policy" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bootcamp_bucket.bucket}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${var.cloudfront_distribution_arn}"
                }
            }
        }
    ]
}
POLICY
}