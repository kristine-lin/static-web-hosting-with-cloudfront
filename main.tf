locals {
  origin_id = "s3origin"
}

resource "aws_s3_bucket" "static_web" {
  bucket        = "kristinestaticwebsite123" #Name of your bucket
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.static_web.id #Get the name of your bucket using Attribute (id)
  policy = data.aws_iam_policy_document.default.json #Get the value of your bucket policy using attribute (json)
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name    = aws_s3_bucket.static_web.bucket_regional_domain_name #Attribute: bucket_regional_domain_name from your s3 bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id
  }

  enabled             = true
  comment             = "Kristine's static website using Cloudfront" #Description
  default_root_object = "index.html"

  aliases = ["kristinestaticwebsite123.sctp-sandbox.com"] #Cloudfront alternate domain name (Same as Route53 record)

  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.example.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "allow-all"
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.name.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "kristine-cloudfront-oac"    #e.g. <yourname>-cloudfront-oac
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.sctp_zone.zone_id #Zone ID of hosted zone: sctp-sandbox.com
  name    = "kristinestaticwebsite123"  #Your domain prefix. <this-value>.sctp-sandbox.com
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name  #Cloudfront attribute:domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id # Hosted zone of the Cloudfront, Attribute: hosted_zone_id
    evaluate_target_health = true
  }
}  