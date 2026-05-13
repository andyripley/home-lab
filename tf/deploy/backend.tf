terraform {
  backend "s3" {
    bucket = var.s3-backend.bucket
    key    = var.s3-backend.key
    region = var.s3-backend.region
  }
}
