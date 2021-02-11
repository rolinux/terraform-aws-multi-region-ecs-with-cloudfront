/* Route 53 resources */
resource "aws_route53_record" "demo" {
  zone_id = data.aws_route53_zone.demo_domain.zone_id
  name    = var.demo_hostname
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.demo.domain_name
    zone_id                = aws_cloudfront_distribution.demo.hosted_zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_cloudfront_distribution.demo]
}
