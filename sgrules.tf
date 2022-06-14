# sg rules
# ingress public http
resource "aws_security_group_rule" "public-ingress-http" {
  type              = "ingress"
  security_group_id = aws_security_group.public.id

  from_port   = var.http_port
  to_port     = var.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]
}

# ingress public https
resource "aws_security_group_rule" "public-ingress-https" {
  type              = "ingress"
  security_group_id = aws_security_group.public.id

  from_port   = var.https_port
  to_port     = var.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]
}

# ingress private sg
resource "aws_security_group_rule" "private-ingress-sg" {
  type              = "ingress"
  security_group_id = aws_security_group.private.id

  from_port                = var.http_port
  to_port                  = var.http_port
  protocol                 = local.tcp_protocol
  source_security_group_id = aws_security_group.public.id
}

# egress public all
resource "aws_security_group_rule" "public-egress-all" {
  type              = "egress"
  security_group_id = aws_security_group.public.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = [local.all_ips]
}

# egress private all
resource "aws_security_group_rule" "private-egress-all" {
  type              = "egress"
  security_group_id = aws_security_group.private.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = [local.all_ips]
}