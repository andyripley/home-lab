proxmox = {
  name         = "pve1"
  cluster_name = "pve-cluster"
  endpoint     = "https://pve1.local:8006"
  insecure     = false
  username     = "root"
}

s3-backend = {
  bucket = "statefiles"
  endpoint = "https://s3.endpoint.com"
}
