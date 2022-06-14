output "dns" {
  value = aws_route53_record.www.fqdn
}