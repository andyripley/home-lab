# Overview
_work in progress_

This is my best attempt at migrating my home lab from a single-node, docker based environment over to a multi-node K8s cluster running Talos linux on Proxmox.  The goal here is to have all components in code and deployable without minimal manual intervention.  

# Components
## OpenTofu/Terraform Modules**
- `gcp-setup`: *Work in Progress* This is used for statefile storage and some secret management.
  - Will be migrated to AWS as I'm able to provision the access needed easier with Terraform.  
- `talos`: Builds the VMs in Proxmox and configures Talos Linux. 
- `storage/proxmox_csi`: Provisions the role and users for proxmox-csi and deploys the user details in a K8s secret. 
- `storage/proxmox_csi_vols`: Deploys the raw disk images in Proxmox for the CSI and creates the PVs for K8s.  
- `external-secrets`: Deployment of External Secrets in K8s along with the needed AWS resources.

# Todo

- **Tofu**
    - [x] Complete the External Secrets deployment
- **K8s/Flux**
    - [x] External Secrets deployment of Cluster Secret Store
    - [ ] Traefik with Cert Manager using Gateway API
    - [ ] Migrate docker containers
    - [ ] Monitoring with Grafana and VictoriaMetrics
- **Dev**
    - [ ] Yamllint, yamlfmt, tflint, kubeconform, etc.
    - [ ] Github runner and actions setup
