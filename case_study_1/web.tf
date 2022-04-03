locals{
    s3_origin_id = "${aws_s3_bucket.web.bucket}-origin"
    bucket_name = "${var.static_web_s3_bucket_name}"
}

resource "aws_s3_bucket" "web" {
  bucket = local.bucket_name

  # AWS Provider 4.0.0 don't use it
  // website {
  //   index_document = "index.html"
  //   error_document = "404.html"
  // }
}

# AWS Provider 4.0.0 use it to apply website settings
resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id

  policy = templatefile("./public_bucket_policy.tpl", {
    s3_bucket = aws_s3_bucket.web.arn
  })

}

resource "aws_cloudfront_distribution" "web" {
  origin {
    domain_name = replace(aws_s3_bucket.web.bucket_regional_domain_name, ".s3.", ".s3-website.")
    origin_id   = local.s3_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled = true

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }
}
