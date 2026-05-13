s3-backend = {
  bucket = "ripley-homelab-state"
  key    = "k8s-pve.tfstate"
  region = "us-east-1"
}

proxmox = {
  name         = "pve1"
  cluster_name = "pve-cluster"
  endpoint     = "https://pve1.ley.rip:8006"
  insecure     = false
  username     = "root"
}
