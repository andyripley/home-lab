module "talos" {
  source = "./talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version   = "1.13.0"
    schematic = file("${path.module}/talos/configs/talos-schematic.yaml")
  }

  cilium = {
    install = file("${path.module}/talos/manifests/cilium-install.yaml")
    values  = file("${path.module}/../../k8s/cilium/values.yaml")
  }


  cluster = {
    name            = "lab"
    endpoint        = "10.13.37.25"
    gateway         = "10.13.37.1"
    talos_version   = "v1.13"
    proxmox_cluster = "pve-cluster"
  }

  nodes = {
    "ctrl-1" = {
      host_node    = "pve1"
      machine_type = "controlplane"
      ip           = "10.13.37.25"
      vm_id        = 301
      cpu_cores    = 2
      ram          = 4096
      datastore_id = "vm_data"
    }
    "ctrl-2" = {
      host_node    = "pve2"
      machine_type = "controlplane"
      ip           = "10.13.37.26"
      vm_id        = 302
      cpu_cores    = 2
      ram          = 4099
      datastore_id = "vm_data2"
    }
  }
}

resource "local_file" "machine_configs" {
  for_each        = module.talos.machine_config
  content         = each.value.machine_configuration
  filename        = "../../output/talos-machine-config-${each.key}.yaml"
  file_permission = "0600"
}

resource "local_file" "talos_config" {
  content         = module.talos.client_configuration.talos_config
  filename        = "../../output/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = module.talos.kube_config
  filename        = "../../output/kube-config.yaml"
  file_permission = "0600"
}

