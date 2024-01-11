resource "aws_route53_zone" "chriswachira_com_zone" {
  name = "chriswachira.com"

  tags = {
    Environment = "Production"
  }
}

resource "aws_route53_record" "chriswachira_com_cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.chriswachira_com_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.chriswachira_com_zone.zone_id

}
