data "aws_secretsmanager_secret" "proxmox" {
  name = "proxmox"
}

data "aws_secretsmanager_secret_version" "proxmox" {
  secret_id = data.aws_secretsmanager_secret.proxmox.id
}

data "aws_secretsmanager_secret" "github" {
  name = "github"
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = data.aws_secretsmanager_secret.github.id
}

locals {
  pve_username     = jsondecode(data.aws_secretsmanager_secret_version.proxmox.secret_string)["username"]
  pve_password     = jsondecode(data.aws_secretsmanager_secret_version.proxmox.secret_string)["password"]
  pve_api_token    = jsondecode(data.aws_secretsmanager_secret_version.proxmox.secret_string)["api_token"]
  github_pat_token = jsondecode(data.aws_secretsmanager_secret_version.github.secret_string)["pat_token"]
}
