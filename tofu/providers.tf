provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure
  ssh {
    agent    = true
    username = var.proxmox.username
  }
}
