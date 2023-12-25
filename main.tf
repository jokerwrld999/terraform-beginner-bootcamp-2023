module "storage" {
  source = "./modules/storage"

  region               = var.region
  root_domain_name     = var.root_domain_name
  subdomain_name       = var.subdomain_name
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn
}

module "cdn" {
  source = "./modules/cdn"

  region                      = var.region
  root_domain_name            = var.root_domain_name
  subdomain_name              = var.subdomain_name
  cloudflare_api_token        = var.cloudflare_api_token
  cloudflare_zone_id          = var.cloudflare_zone_id
  bootcamp_bucket_id          = module.storage.bootcamp_bucket_id
  bucket_regional_domain_name = module.storage.bootcamp_bucket_bucket_regional_domain_name
}