import {
  to = google_storage_bucket.terraform_state
  id = var.bucket_name
}

resource "google_storage_bucket" "terraform_state" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_regional_secret" "pve_username" {
  secret_id = "pve-username"
  location  = var.location
  project   = data.google_project.current.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_regional_secret_version" "pve_username" {
  secret      = google_secret_manager_regional_secret.pve_username.id
  secret_data = var.pve_username
}

resource "google_secret_manager_regional_secret" "pve_password" {
  secret_id = "pve-password"
  location  = var.location
  project   = data.google_project.current.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_regional_secret_version" "pve_password" {
  secret      = google_secret_manager_regional_secret.pve_password.id
  secret_data = var.pve_password
}
