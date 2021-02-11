/* Outputs */
output "primary_lb_dns_name" {
  value = module.us-east-1.lb_dns_name
}

output "secondary_lb_dns_name" {
  value = module.eu-west-1.lb_dns_name
}
