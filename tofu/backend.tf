terraform {
  backend "s3" {
    bucket = var.s3-backend.bucket
    endpoints = {
      s3 = var.s3-backend.endpoint
    }
    key = "talos-pve.tfstate"

    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
  }
}
