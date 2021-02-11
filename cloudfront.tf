/* CloudFront resources */
resource "aws_cloudfront_distribution" "demo" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.demo_hostname}.${var.demo_domain} CloudFront"
  default_root_object = "index.html"
  aliases             = ["${var.demo_hostname}.${var.demo_domain}"]

  origin_group {
    origin_id = "demo"

    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }

    member {
      origin_id = "primaryECS"
    }

    member {
      origin_id = "failoverECS"
    }
  }

  origin {
    domain_name = module.us-east-1.lb_dns_name
    origin_id   = "primaryECS"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  origin {
    domain_name = module.eu-west-1.lb_dns_name
    origin_id   = "failoverECS"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  default_cache_behavior {
    # allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "demo"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name  = "demo"
    Owner = "Radu"
  }

  depends_on = [module.us-east-1, module.eu-west-1]
}
