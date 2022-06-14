# sg rules
# ingress public http
resource "aws_security_group_rule" "public-ingress-http" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["public"].id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ingress public https
resource "aws_security_group_rule" "public-ingress-https" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["public"].id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# ingress private sg
resource "aws_security_group_rule" "private-ingress-sg" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["private"].id

  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["public"].id
}

# egress public all
resource "aws_security_group_rule" "public-egress-all" {
  type              = "egress"
  security_group_id = aws_security_group.sg["public"].id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# egress private all
resource "aws_security_group_rule" "private-egress-all" {
  type              = "egress"
  security_group_id = aws_security_group.sg["private"].id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# sg rule ssh inbound
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["public"].id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "private-ingress-sg-ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.sg["private"].id

  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg["public"].id
}