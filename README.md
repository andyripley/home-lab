# Overview
_work in progress_

This is my best attempt at migrating my home lab from a single-node, docker based environment over to a multi-node K8s cluster running Talos linux on Proxmox.  The goal here is to have all components in code and deployable without minimal manual intervention.  

# Components
## OpenTofu/Terraform Modules**
- `gcp-setup`: *Work in Progress* This is used for statefile storage and potentially for secrets provisioning.  
    - This might be moved to a different directory in the future to remove it from the Cluster provisioning.  
- `talos`: Builds the VMs in Proxmox and configures Talos Linux. 
- `storage/proxmox_csi`: Provisions the role and users for proxmox-csi and deploys the user details in a K8s secret. 
- `storage/proxmox_csi_vols`: Deploys the raw disk images in Proxmox for the CSI and creates the PVs for K8s.  
- `external-secrets`: *Work in Progress* Deployment of External Secrets in K8s along with the needed GCP resources.

# Todo

- **Tofu**
    - [ ] Complete the External Secrets deployment
- **K8s/Flux**
    - [ ] Traefik with Cert Manager using Gateway API
    - [ ] Migrate docker containers
    - [ ] Monitoring with Grafana and VictoriaMetrics
- **Dev**
    - [ ] Yamllint, yamlfmt, tflint, kubeconform, etc.
    - [ ] Github runner and actions setup