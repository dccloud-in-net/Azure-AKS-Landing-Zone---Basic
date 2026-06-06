# Project Documentation: Azure AKS Landing Zone

This document serves as the comprehensive project guide and technical documentation for the modular Azure Kubernetes Service (AKS) Landing Zone Terraform codebase.

---

## 1. Executive Summary

This project provides an automated, production-ready, and highly secure infrastructure landing zone for deploying microservice applications in Azure Kubernetes Service (AKS). The codebase is designed around the Microsoft Cloud Adoption Framework (CAF) guidelines and implements a zero-trust network topology. 

Additionally, the project features a **Dual-Mode Architecture** that allows developers to toggle between a lightweight, cost-optimized "Student Subscription Mode" and a fully locked-down "Enterprise Landing Zone".

---

## 2. Core Design Pillars

1. **Zero-Trust Network Model**: All internal PaaS services (Key Vault, Storage, Container Registry) disable public internet access and are only reached privately via Private Endpoints.
2. **Entra ID Integrated Security**: RBAC roles and permissions are mapped using User Assigned Managed Identities and Microsoft Entra ID groups, eliminating the use of local Kubernetes admin certificates or static client credentials.
3. **Comprehensive Observability**: Logs, diagnostics, and metrics from all services (Kubernetes API server, audit logs, Key Vault operations, etc.) are centralized in a Log Analytics Workspace.
4. **Subscription Adaptability**: A single toggle variable (`azure_for_student`) dynamically adapts the deployment size, SKUs, and network configuration to match the resource quotas and credit limits of the Azure for Students subscription.

---

## 3. Directory Layout & Codebase Structure

```
AzureLandingzoneForAKS/
├── README.md                      # General overview & quick-start guide
├── architecture_design.md         # Technical architecture specifications
├── architecture_design.drawio     # Interactive Draw.io diagram
├── aks_landingzone_architecture.png# Visual PNG architecture diagram
├── project_document.md            # This project document
├── backend.tf                     # Remote state configuration block
├── providers.tf                   # Terraform version and providers definition
├── main.tf                        # Root orchestrator calling submodules
├── variables.tf                   # Global input variables definitions
├── outputs.tf                     # Unified output variables
├── locals.tf                      # Naming conventions, tags, and student-override logic
├── environments/                  # Environment-specific configuration values
│   ├── dev/
│   │   ├── backend.tfvars         # Dev remote storage backend variables
│   │   └── terraform.tfvars       # Dev environment parameters (toggled to Student Mode)
└── modules/                       # Reusable infrastructure submodules
    ├── networking/                # VNet, Subnets, Route Tables, NAT Gateway, Bastion, DNS
    ├── security/                  # Private Key Vault and Private Endpoints
    ├── monitoring/                # Log Analytics Workspace and diagnostics routing
    ├── identity/                  # User Assigned Managed Identities for control plane/kubelet
    ├── acr/                       # Container Registry (Basic SKU in Student Mode / Premium in Enterprise)
    ├── storage/                   # Storage Account (Blob Storage)
    └── aks/                       # AKS cluster and node pool configurations
```

---

## 4. Module Specifications

### 📁 Networking Module (`modules/networking`)
* Configures the Virtual Network (VNet) and divides it into dedicated subnets (`aks-subnet`, `pe-subnet`, `AzureBastionSubnet`, `gateway-subnet`).
* Manages outbound Internet access using a **NAT Gateway** (associated with a static Public IP).
* Deploys **Azure Bastion** for secure, private tunneling to virtual machines inside the VNet without exposing public SSH ports.
* Creates **Private DNS Zones** (`privatelink.azurecr.io`, `privatelink.vaultcore.azure.net`, etc.) for internal name resolution.
* *Note: NAT Gateway, Bastion, and Private DNS Zones are automatically disabled in Student Mode.*

### 📁 Monitoring Module (`modules/monitoring`)
* Deploys a central **Log Analytics Workspace**.
* Serves as the ingestion sink for diagnostic telemetry and Kubernetes control plane logs (API Server, Auditing, Autoscaler, etc.).

### 📁 Security Module (`modules/security`)
* Creates an **Azure Key Vault** using Azure RBAC authorization instead of legacy Access Policies.
* Integrates with the **Secrets Store CSI Driver** inside AKS to dynamically mount secrets as files inside pods.
* Configures **Private Endpoints** and network rules (block public traffic) in Enterprise Mode.

### 📁 Identity Module (`modules/identity`)
* Sets up distinct **User Assigned Managed Identities** for the AKS Control Plane and Kubelet (Agent Pools) to separate responsibilities and follow least-privilege principles.

### 📁 Container Registry Module (`modules/acr`)
* Provisions **Azure Container Registry (ACR)** to host application docker images.
* Switches dynamically between **Basic SKU** (Student Mode) to minimize cost and **Premium SKU** (Enterprise Mode) to support private endpoint networks.

### 📁 Storage Module (`modules/storage`)
* Provisions an Azure **Storage Account** for persistent storage (e.g., storage of backend assets or database backups).

### 📁 AKS Module (`modules/aks`)
* Orchestrates the **AKS Cluster** using Azure CNI Overlay networking for efficient IP utilization.
* Integrates Defender for Containers, Azure Policy engine, and Entra ID RBAC.
* *Note: Defender, Azure Policy, and Entra ID RBAC are bypassed in Student Mode to save credits and CPU/memory overhead on small nodes.*

---

## 5. Deployment Guide

### Prerequisites
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (`>= 1.5.0`)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* An active Azure Subscription

### Step 1: Login to Azure
```bash
az login
az account set --subscription "<your-subscription-id>"
```

### Step 2: Initialize Terraform Backend
Reconfigure the state backend pointing to your bootstrapped Storage Account container:
```bash
terraform init -reconfigure -backend-config=environments/dev/backend.tfvars
```

### Step 3: Run Plan
Generate and inspect the execution plan:
```bash
terraform plan -var-file=environments/dev/terraform.tfvars -out=tfplan
```

### Step 4: Apply Configuration
Apply the plan to build the infrastructure:
```bash
terraform apply tfplan
```

### Step 5: Accessing the Cluster
* **Student Mode**: Use your local CLI:
  ```bash
  az aks get-credentials --resource-group rg-contoso-dev-aks-lz --name aks-contoso-dev-cluster
  kubectl get nodes
  ```
* **Enterprise Mode**: Route your access through the Azure Bastion Tunnel:
  ```bash
  az network bastion tunnel --name "bas-contoso-dev" --resource-group "rg-contoso-dev-aks-lz" --target-resource-id "/subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.Compute/virtualMachines/<vm-name>" --port 5022 --remote-port 22
  az aks get-credentials --resource-group rg-contoso-dev-aks-lz --name aks-contoso-dev-cluster
  ```

---

## 6. Enterprise Best Practices & Cost Management

1. **Autoscaling**: In Enterprise Mode, enable the autoscaler on user node pools and set minimum limits to `1` (or `0` when idle) to reduce VM costs.
2. **Log Retention**: Limit log retention in your Log Analytics Workspace to `30 days` for non-prod environments to avoid high ingestion/storage fees.
3. **Spot VMs**: For QA or testing pools, leverage Spot instances to save up to 90% on VM pricing.
