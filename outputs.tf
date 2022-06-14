output "dns" {
  value = aws_route53_record.www.fqdn
}

output "user_pk" {
  value = nonsensitive(tls_private_key.rsa-4096.private_key_pem)
}