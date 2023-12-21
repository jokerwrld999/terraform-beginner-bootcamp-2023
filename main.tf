# S3 static website bucket
resource "aws_s3_bucket" "bootcamp_bucket" {
  bucket = "${var.root_domain_name}"
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

  bucket = aws_s3_bucket.bootcamp_bucket.id
  key          = each.key
  content_type = each.value.content_type

  source       = each.value.source_path
  content = each.value.content
}

# Use the AWS Certificate Manager to create an SSL cert for our domain.
resource "aws_acm_certificate" "certificate" {
  domain_name       = "*.${var.root_domain_name}"
  validation_method = "DNS"

  subject_alternative_names = ["${var.root_domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create Validation Record on Cloudflare
resource "cloudflare_record" "cloudflare_validation_record" {
  zone_id = var.cloudflare_zone_id
  name    = "${tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name}"
  value   = "${tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value}"
  type    = "CNAME"
  proxied = false

  depends_on = [ aws_acm_certificate.certificate ]
}

# CloudFront
resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${aws_s3_bucket.bootcamp_bucket.id}"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.bootcamp_bucket.bucket_regional_domain_name
    origin_id   = "${var.sub_domain_name}"

    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  aliases = ["${var.sub_domain_name}"]
  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.sub_domain_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
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

  block_public_acls       = true
  block_public_policy     = true
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
                    "AWS:SourceArn": "${aws_cloudfront_distribution.cloudfront_distribution.arn}"
                }
            }
        }
    ]
}
POLICY
}

resource "cloudflare_record" "cloudflare_record" {
  zone_id = var.cloudflare_zone_id
  name    = "barista"
  value   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
  type    = "CNAME"
  proxied = true
}