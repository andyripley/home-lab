variable "aws_region" {
  description = "The AWS region to use for resources"
  type        = string
}

variable "aws_bucket_name" {
  description = "The name of the AWS S3 bucket to use for Terraform state"
  type        = string
}

variable "gcp_bucket_name" {
  description = "The name of the GCP storage bucket to use for Terraform state"
  type        = string
}

variable "gcp_project" {
  description = "The GCP project to use for resources"
  type        = string
}

variable "gcp_location" {
  description = "The GCP region to use for resources"
  type        = string
}

variable "github_pat_token" {
  description = "The PAT Token used to bootstrapping FluxCD"
  type        = string
}

variable "pve_endpoint" {
  description = "The API endpoint for Proxmox VE"
  type        = string
}

variable "pve_username" {
  description = "The username for Proxmox VE"
  type        = string
  sensitive   = true
}

variable "pve_password" {
  description = "The password for Proxmox VE"
  type        = string
  sensitive   = true
}

variable "pve_api_token" {
  description = "The API token for Proxmox VE"
  type        = string
  sensitive   = true
}
