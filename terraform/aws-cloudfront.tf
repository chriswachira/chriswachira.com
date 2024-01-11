resource "aws_cloudfront_origin_access_identity" "chriswachira_cf_dist_origin_identity" {
  comment = "Access identity for the CloudFront distribution for chriswachira.com"
}

locals {
  cw_com_s3_origin_id = "chriswachira-com-s3-origin"
}

resource "aws_cloudfront_distribution" "chriswachira_cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.chriswachira-site-bucket.bucket_regional_domain_name
    origin_id   = local.cw_com_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.chriswachira_cf_dist_origin_identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for the chriswachira.com website"
  default_root_object = "index.html"
  http_version        = "http2and3"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 86400
    min_ttl                = 0
    max_ttl                = 31536000
    target_origin_id       = local.cw_com_s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
  }

  tags = {
    Environment = "Production"
  }

}
