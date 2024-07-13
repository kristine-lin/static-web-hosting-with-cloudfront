data "aws_cloudfront_cache_policy" "example" {
  name = "Managed-CachingOptimized"
}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_web.arn}/*"]  #Get the arn of your bucket

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.s3_distribution.arn}/*"] #Get the ARN of your Cloudfront using Attribute
    }
  }
}

data "aws_acm_certificate" "name" {
  provider = aws.us-east-1 #Syntax: <provider>.<alias>
  domain   = "sctp-sandbox.com"
}

data "aws_route53_zone" "sctp_zone" {
  name = "sctp-sandbox.com"
}