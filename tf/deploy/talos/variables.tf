variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url       = optional(string, "https://factory.talos.dev")
    schematic         = string
    version           = string
    arch              = optional(string, "amd64")
    platform          = optional(string, "nocloud")
    proxmox_datastore = optional(string, "local")
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name               = string
    endpoint           = string
    gateway            = optional(string)
    talos_version      = string
    kubernetes_version = string
    extra_manifests    = optional(list(string))
    proxmox_cluster    = string
  })
}


variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node    = string
    machine_type = string
    ip           = string
    mac_address  = string
    dns          = optional(list(string))
    vm_id        = number
    cpu_cores    = number
    ram          = number
    datastore_id = string
  }))
}


