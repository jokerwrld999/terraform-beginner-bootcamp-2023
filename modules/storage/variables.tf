variable "region" {
  description = "AWS Region"
  type        = string
}

variable "root_domain_name" {
  description = "Root Domain Name"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain Name"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare Api Token"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "AWS CloudFront Distribution ARN"
  type        = string
}