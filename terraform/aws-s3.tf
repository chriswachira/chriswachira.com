resource "aws_s3_bucket" "chriswachira-site-bucket" {
  bucket = "chriswachira-com"

  tags = {
    Name        = "chriswachira-com"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_website_configuration" "chriswachira-site-bucket-conf" {
  bucket = aws_s3_bucket.chriswachira-site-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}
