output "certificate-arn" {
  value = aws_acm_certificate_validation.validating.certificate_arn
}

output "zone-id" {
  value = data.aws_route53_zone.hosted-zone.zone_id
}