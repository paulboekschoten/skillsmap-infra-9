variable "cert_email" {
  description = "email address used to obtain ssl certificate"
  type        = string
  default     = "paul.boekschoten@hashicorp.com"
}

variable "route53_zone" {
  description = "the domain to use for the url"
  type        = string
  default     = "tf-support.hashicorpdemo.com"
}

variable "route53_subdomain" {
  description = "the subdomain of the url"
  type        = string
  default     = "paulskillsmap9tf2"
}

variable "name_tag" {
  description = "global name for resource tags"
  type        = string
  default     = "paul-skillsmap-9-tf"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR of the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_private" {
  description = "private subnet cidr"
  type        = string
  default     = "10.1.0.0/24"
}

variable "subnet_public1" {
  description = "public1 subnet cidr"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_public2" {
  description = "public2 subnet cidr"
  type        = string
  default     = "10.1.2.0/24"
}

variable "ami" {
  description = "AMI id of the image"
  type        = string
  default     = "ami-0042da0ea9ad6dd83"
}

variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "http_port" {
  description = "http port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "https port"
  type        = number
  default     = 443
}

