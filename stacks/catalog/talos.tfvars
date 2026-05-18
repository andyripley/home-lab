image = {
  version   = "1.13.0"
}

cluster = {
  name               = "home-lab"
  endpoint           = "10.13.37.25"
  gateway            = "10.13.37.1"
  talos_version      = "v1.13"
  proxmox_cluster    = "pve-cluster"
  kubernetes_version = "v1.36.0"
  extra_manifests = [
    #Traefik and Gateway API CRDs.  
    "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml",
    "https://raw.githubusercontent.com/traefik/traefik/v3.5/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml"
  ]
}

nodes = {
  "ctrl-1" = {
    host_node    = "pve1"
    machine_type = "controlplane"
    ip           = "10.13.37.25"
    mac_address  = "BC:24:11:00:00:25"
    dns          = ["10.13.37.10"]
    vm_id        = 301
    cpu_cores    = 2
    ram          = 4096
    datastore_id = "vm_data"
  }
  "ctrl-2" = {
    host_node    = "pve2"
    machine_type = "controlplane"
    ip           = "10.13.37.26"
    mac_address  = "BC:24:11:00:00:26"
    dns          = ["10.13.37.10"]
    vm_id        = 302
    cpu_cores    = 2
    ram          = 4096
    datastore_id = "vm_data"
  }
}
