variable "aws_region" {
  description = "The AWS region to use for resources"
  type        = string
}

variable "aws_bucket_name" {
  description = "The name of the AWS S3 bucket to use for Terraform state"
  type        = string
}

variable "pve_endpoint" {
  description = "The API endpoint for Proxmox VE"
  type        = string
}
