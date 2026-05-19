resource "restapi_object" "proxmox-volume" {
  for_each = var.volumes

  path = "/api2/json/nodes/${each.value.node}/storage/${each.value.storage}/content"

  id_attribute = "data"

  debug = true

  data = jsonencode({
    vmid     = each.value.vmid
    filename = "vm-${each.value.vmid}-${each.key}.raw"
    size     = each.value.size
    format   = each.value.format
  })

  ignore_all_server_changes = true

  update_data = jsonencode({
    node = each.value.node
  })

  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_persistent_volume_v1" "pv" {
  for_each = var.volumes

  metadata {
    name = each.key
  }
  spec {
    capacity = {
      storage = each.value.size
    }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "proxmox-csi"
    mount_options      = ["noatime"]
    volume_mode        = "Filesystem"
    persistent_volume_source {
      csi {
        driver        = "csi.proxmox.sinextra.dev"
        fs_type       = "ext4"
        volume_handle = "${var.pve_cluster_name}/${each.value.node}/${each.value.storage}/${"vm-${each.value.vmid}-${each.key}.raw"}"
        volume_attributes = {
          cache   = "writethrough"
          ssd     = "true"
          storage = each.value.storage
        }
      }
    }
  }
}
