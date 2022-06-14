terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.8.0"
    }
  }
}

provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = var.name_tag
  }
}

# subnets
resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = "${var.region}${each.value.availability_zone}"

  tags = {
    Name = "${var.name_tag}-${each.key}"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name_tag
  }
}

# elastic ip for NAT gateway
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = var.name_tag
  }
}

# NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main["public1"].id

  tags = {
    Name = var.name_tag
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# security groups
resource "aws_security_group" "sg" {
  for_each = var.security_groups
  vpc_id   = aws_vpc.main.id
  name     = "${var.name_tag}-${each.key}"
  tags = {
    Name = "${var.name_tag}-${each.key}"
  }
}

# security group rules, see sgrules.tf

# route tables
# default add internet gateway
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = local.all_ips[0]
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.name_tag
  }
}

# rtb for nat
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = local.all_ips[0]
    nat_gateway_id = aws_nat_gateway.nat.id
  }



  tags = {
    Name = var.name_tag
  }
}
# associate nat rtb with subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main["private"].id
  route_table_id = aws_route_table.example.id
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key pair
resource "aws_key_pair" "paul-tf" {
  key_name   = var.name_tag
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# EC2 instance
resource "aws_instance" "web" {
  ami                         = "ami-0042da0ea9ad6dd83"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.paul-tf.key_name
  vpc_security_group_ids      = [aws_security_group.sg["private"].id]
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.main["private"].id

  tags = {
    Name = var.name_tag
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get install -y nginx
    sudo service nginx restart
    EOF

}


## route53 fqdn
# fetch zone
data "aws_route53_zone" "selected" {
  name         = "tf-support.hashicorpdemo.com"
  private_zone = false
}
# create record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "paulskillsmap9tf.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = true
  }
}

## certficate let's encrypt
# create auth key
resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

# register
resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.cert_private_key.private_key_pem
  email_address   = "paul.boekschoten@hashicorp.com"
}
# get certificate
resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = aws_route53_record.www.name

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.selected.zone_id
    }
  }
}

# store cert
resource "aws_acm_certificate" "cert" {
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_body  = acme_certificate.certificate.certificate_pem
  certificate_chain = acme_certificate.certificate.issuer_pem
}

# target group
resource "aws_lb_target_group" "test" {
  name     = "${var.name_tag}-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
# register instance to target group
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# load balancer
resource "aws_lb" "test" {
  name               = var.name_tag
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg["public"].id]
  subnets            = [aws_subnet.main["public1"].id, aws_subnet.main["public2"].id]

  tags = {
    Environment = var.name_tag
  }
}

# listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

## load balancer ssh
#resource "aws_lb" "ssh" {
#  name               = var.name_tag
#  internal           = false
#  load_balancer_type = "network"
#  subnets            = [aws_subnet.main["public1"].id, aws_subnet.main["public2"].id]
#
#  tags = {
#    Environment = var.name_tag
#  }
#}
#
#resource "aws_lb_target_group" "ssh" {
#  name     = "${var.name_tag}-ssh"
#  port     = 22
#  protocol = "TCP"
#  vpc_id   = aws_vpc.main.id
#}
#
#resource "aws_lb_listener" "ssh" {
#  load_balancer_arn = aws_lb.ssh.arn
#  port              = "22"
#  protocol          = "TCP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.ssh.arn
#  }
#}
#
#resource "aws_lb_target_group_attachment" "ssh" {
#  target_group_arn = aws_lb_target_group.ssh.arn
#  target_id        = aws_instance.web.id
#  port             = 22
#}