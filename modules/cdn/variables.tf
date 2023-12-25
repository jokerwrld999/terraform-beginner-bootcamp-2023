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

variable "bootcamp_bucket_id" {
  description = "AWS S3 Bucket ID"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "AWS S3 Bucket Regional Domain Name"
  type        = string
}