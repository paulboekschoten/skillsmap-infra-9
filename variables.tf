variable "name_tag" {
  description = "global name for resources"
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

variable "subnets" {
  description = "map of subnets"
  type        = map(any)
  default = {
    private = {
      cidr_block        = "10.1.1.0/24"
      availability_zone = "a"
    },
    public1 = {
      cidr_block        = "10.1.2.0/24"
      availability_zone = "a"
    },
    public2 = {
      cidr_block        = "10.1.3.0/24"
      availability_zone = "b"
    }
  }
}

variable "security_groups" {
  description = "map of security groups"
  type        = map(any)
  default = {
    private = {

    },
    public = {

    }
  }
}
