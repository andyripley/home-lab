data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.image.version
  filters = {
    names = [
      "qemu-guest-agent",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
      }
      bootloader = "sd-boot"
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = var.image.version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = var.image.platform
  architecture  = var.image.arch
}

resource "proxmox_download_file" "this" {
  for_each = var.nodes

  node_name    = each.value.host_node
  content_type = "iso"
  datastore_id = var.image.proxmox_datastore

  file_name               = "talos-${each.key}-${var.image.version}-${var.image.arch}.img"
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  decompression_algorithm = "zst"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = var.nodes

  name            = each.key
  node_name       = each.value.host_node
  vm_id           = each.value.vm_id
  tags            = each.value.machine_type == "controlplane" ? ["k8s", "control-plane"] : ["k8s", "worker"]
  started         = true
  stop_on_destroy = true

  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"
  bios          = "ovmf"

  agent {
    enabled = true
  }

  startup {
    order = "3"
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.ram
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    firewall    = false
  }

  disk {
    datastore_id = each.value.datastore_id
    size         = 25
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    file_id      = proxmox_download_file.this[each.key].id
  }

  efi_disk {
    datastore_id = each.value.datastore_id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id

    dynamic "dns" {
      for_each = try(each.value.dns, null) != null ? { "enabled" = each.value.dns } : {}
      content {
        servers = each.value.dns
      }
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.cluster.gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "example" {
  for_each  = var.nodes

  node_name = proxmox_virtual_environment_vm.this[each.key].node_name
  vm_id     = proxmox_virtual_environment_vm.this[each.key].vm_id

  dhcp          = true
  enabled       = false
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "ACCEPT"
  output_policy = "ACCEPT"
  radv          = true
}
