/* Data sources */
data "aws_route53_zone" "demo_domain" {
  name = "${var.demo_domain}."
}
