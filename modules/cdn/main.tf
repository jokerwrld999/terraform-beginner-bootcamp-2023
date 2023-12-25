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
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  value   = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value
  type    = "CNAME"
  proxied = false

  depends_on = [aws_acm_certificate.certificate]
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
  comment = var.bootcamp_bucket_id
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = "${var.subdomain_name}.${var.root_domain_name}"

    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
  }

  aliases             = ["${var.subdomain_name}.${var.root_domain_name}"]
  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.subdomain_name}.${var.root_domain_name}"

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
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "cloudflare_record" "cloudflare_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain_name
  value   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
  type    = "CNAME"
  proxied = true
}