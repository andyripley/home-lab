variable "proxmox" {
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool
    username     = string
  })
  sensitive = true
}

variable "s3-backend" {
  type = object({
    bucket   = string
    endpoint = string
  })
}
