variable "pve_cluster_name" {
  description = "The name of the Proxmox VE cluster"
  type        = string
}

variable "volumes" {
  type = map(
    object({
      node    = string
      size    = string
      vmid    = optional(number, 9999)
      storage = optional(string, "vm_data")
      format  = optional(string, "raw")
    })
  )
}
