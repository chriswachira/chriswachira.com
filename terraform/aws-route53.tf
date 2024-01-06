resource "aws_route53_zone" "chriswachira_com_zone" {
  name = "chriswachira.com"

  tags = {
    Environment = "Production"
  }
}
