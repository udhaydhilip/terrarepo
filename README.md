# Terraform AWS Infrastructure

This Terraform project provisions:

- A custom VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Public and private route tables
- Security groups for public and private access
- EC2 instances (Windows, Ubuntu, RHEL)

## Requirements

- Terraform >= 1.3
- AWS CLI with credentials configured

## How to Use

terraform init
terraform plan
terraform apply
