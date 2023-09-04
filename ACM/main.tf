resource "aws_acm_certificate" "domain-cert" {
  domain_name                       = "api.ashata.online"
  validation_method                 = "DNS"
}

data "aws_route53_zone" "hosted-zone" {
  name                              = "ashata.online"
private_zone                        = false
}

resource "aws_route53_record" "validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.domain-cert.domain_validation_options : dvo.domain_name => {
    name                            = dvo.resource_record_name
    record                          = dvo.resource_record_value
    type                            = dvo.resource_record_type
    }
  }

  allow_overwrite = false
name                                = each.value.name
records                             = [each.value.record]
ttl                                 = 60
type                                = each.value.type
zone_id                             = data.aws_route53_zone.hosted-zone.zone_id
}

resource "aws_acm_certificate_validation" "validating" {
certificate_arn                     = aws_acm_certificate.domain-cert.arn
validation_record_fqdns             = [for record in aws_route53_record.validation-record : record.fqdn]
}
