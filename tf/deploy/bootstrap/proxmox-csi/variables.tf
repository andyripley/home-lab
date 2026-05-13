variable "proxmox" {
  type = object({
    cluster_name = string
    endpoint     = string
    insecure     = optional(bool, false)
  })
}
