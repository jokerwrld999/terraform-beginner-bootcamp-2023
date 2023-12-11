terraform {
  cloud {
    organization = "jokerwrld"

    workspaces {
      name = "terraform-bootcamp"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

# AWS provider block

provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# S3 static website bucket

resource "aws_s3_bucket" "bootcamp_bucket" {
  bucket = "terraform-bootcamp-jokerwrld"
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

# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "bootcamp_bucket_ownership" {
  bucket = aws_s3_bucket.bootcamp_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bootcamp_bucket_access_block" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bootcamp_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bootcamp_bucket_ownership,
    aws_s3_bucket_public_access_block.bootcamp_bucket_access_block,
  ]

  bucket = aws_s3_bucket.bootcamp_bucket.id
  acl    = "public-read"
}

# S3 bucket policy

resource "aws_s3_bucket_policy" "bootcamp_bucket_policy" {
  bucket = aws_s3_bucket.bootcamp_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bootcamp_bucket.bucket}/*"
        }
    ]
}
POLICY
}

# Upload website content

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/static-website"
}

resource "aws_s3_object" "provision_source_files" {
  for_each = module.template_files.files

  bucket = aws_s3_bucket.bootcamp_bucket.id
  key          = each.key
  content_type = each.value.content_type

  source       = each.value.source_path
  content = each.value.content
}

output "website_url" {
  value = "http://${aws_s3_bucket.bootcamp_bucket.bucket}.s3-website.${var.region}.amazonaws.com"
}