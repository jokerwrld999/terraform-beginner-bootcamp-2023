variable "region" {
  description = "AWS Region"
  type        = string
}

variable "root_domain_name" {
  description = "Root Domain Name"
  type        = string
  default = "jokerwrld.win"
}

variable "sub_domain_name" {
  description = "Sub-Domain Name"
  type        = string
  default = "barista.jokerwrld.win"
}

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare Api Token"
  type = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type = string
}