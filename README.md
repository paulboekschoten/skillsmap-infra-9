# skillsmap-infra-9
Skillsmap cloud/infra tab, exercise line 9

# Task
on AWS. 
create VPC. 
create 2 subnets, one for public network, one for private network. 
create internet gw and connect to public network. 
create nat gateway, and connect to private network. 
create ec2 instance without public ip, only private subnet. 
create a LB on https (check Application Load Balancer or Network Load Balancer). 
publish a service over LB, ie nginx http or https. 

# Usage
Git clone
```
git clone https://github.com/paulboekschoten/skillsmap-infra-9.git
```

Change directory
```
cd skillsmap-infra-9
```

Check variables are correct in variables.tf  
(Especially the cert_email, route53_zone and route53_subdomain.)  

Terraform init
```
terraform init
```

Terraform apply
```
terraform apply
```


# TODO


# DONE
- [x] Change foreach to individual resources
