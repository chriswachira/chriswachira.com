resource "aws_acm_certificate" "chriswachira_com_certificate" {
  domain_name       = "chriswachira.com"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"
  provider          = aws.us_east_1

  tags = {
    Environment = "Production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "chriswachira_com_cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.chriswachira_com_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.chriswachira_com_cert_validation_records : record.fqdn]

}
