output "cloudfront_distribution_arn" {
  value       = aws_cloudfront_distribution.cloudfront_distribution.arn
  description = "AWS CloudFront Distribution ARN"
}