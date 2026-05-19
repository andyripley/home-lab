variable "pve_cluster_name" {
  description = "Proxmox VE cluster name"
  type        = string
}

variable "pve_endpoint" {
  description = "Proxmox VE API endpoint"
  type        = string
}

variable "insecure" {
  description = "Whether to skip TLS verification for Proxmox API"
  type        = bool
  default     = false
}
