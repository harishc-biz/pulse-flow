# Infrastructure as Code: Azure Verified Foundation

This directory contains the Terraform configuration for the Pulse-Flow platform. The infrastructure is designed using the **Modular SRE approach**, prioritizing security, scalability, and automated resource linking.

## 🏗 Engineering Standards
* **Azure Verified Modules (AVM):** To ensure industry best practices, all primary resources (AKS, Key Vault, Service Bus) were created using [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/). This ensures the infrastructure adheres to Microsoft's Well-Architected Framework.
* **Environment Parity:** All common resource names, SKUs, and configurations are **variabilized**, allowing for seamless switching between `dev`, `test`, and `prod` environments.
* **Dynamic Resource Linking:** Resources are not just provisioned in isolation; they are dynamically linked at runtime (e.g., the AKS identity is retrieved and injected into Key Vault Access Policies and Service Bus RBAC).

## 🛠 Resource Deep Analysis
| Resource | Key Configuration & Logic |
| :--- | :--- |
| **AKS Cluster** | Managed Identity enabled. Automated integration with ACR and Key Vault Secret Store CSI. |
| **Azure Key Vault** | Configured with `purge_protection_enabled = false` (for cost/demo ease) and RBAC-based access control. |
| **Service Bus** | Standard Tier (to support Topics/Queues). Connection strings are dynamically generated and stored in Key Vault. |
| **Managed Identity** | **Deep Dive:** The AKS Kubelet Identity is dynamically granted the `Key Vault Secrets User` role via Terraform to allow the CSI driver to mount secrets without manual intervention. |

---

## 🚀 Bootstrap: NGINX Ingress Controller
To handle external traffic, NGINX is installed post-cluster creation:

```bash
# 1. Add/Update Repo
helm repo add ingress-nginx [https://kubernetes.github.io/ingress-nginx](https://kubernetes.github.io/ingress-nginx) && helm repo update

# 2. High-Availability Install
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.service.externalTrafficPolicy=Local
```
---

## 🤖 CI/CD Automation: Azure DevOps Pipeline Analysis

The project utilizes a multi-stage YAML pipeline (`azure-pipelines-infra.yml`) to ensure infrastructure stability and immutable deployments. It follows the **"Plan-Archive-Apply"** pattern, an SRE best practice that prevents "configuration drift" during deployment.

### 1. Trigger & Scope
* **Path Filtering:** The pipeline is strategically configured to trigger only on changes within the `pulse-infra/terraform/**` directory. This optimizes CI/CD costs and prevents unnecessary infrastructure runs when only application code is updated.
* **Branch Protection:** While the **Plan** stage can run on Pull Requests, the **Apply** stage is restricted to the `main` branch via branch-specific conditions.

### 2. Stage: Terraform Plan (The "Dry Run")
This stage focuses on risk mitigation and validation:
* **Initialization:** Connects to the remote Azure Storage Backend (`pulseterraformstate`) to ensure state locking and team consistency.
* **Validation:** Runs `terraform validate` to catch syntax and logic errors before any cloud resources are touched.
* **Immutable Plan:** Executes `terraform plan -out=tfplan.tfplan`. This binary file "freezes" the execution plan.
* **Artifact Archiving:** The plan file is published as a **Pipeline Artifact**. This ensures that the exact changes reviewed in this stage are the only ones executed in the next.

### 3. Stage: Terraform Apply (The "Execution")
This stage is responsible for the actual resource provisioning:
* **Dependency Gate:** This stage strictly `dependsOn` the successful completion of the Plan stage.
* **Environment Audit:** Uses an Azure DevOps `deployment` job targeting the `dev` environment. This provides a clear audit trail and deployment history in the Azure DevOps portal.
* **Plan Integrity:** Instead of a generic apply, the pipeline downloads the archived `tfplan` and executes it. This guarantees that **"What was planned is what is applied,"** even if the cloud environment changed slightly in the intervening minutes.

### 4. SRE Security Standards in Pipeline
* **Service Connections:** Uses `azure-svc-conn` to manage credentials. No SPN secrets or client IDs are hardcoded in the YAML.
* **Remote State:** State is maintained in a centralized Azure Storage container with encryption at rest.
---

## ⚠️ Architecture Trade-offs & Cost Optimization
Given the constraints of an **Azure Free Account** and the assessment timeline, the following "Enterprise-Standard" features were intentionally omitted to optimize for cost and deployment efficiency:

* **Azure Firewall / NVA:** Skipped in favor of standard **Network Security Groups (NSGs)** to avoid the high monthly costs of a managed firewall.
* **Private Endpoints:** Resources use Public Endpoints with **IP-restricted access** rather than Private Links/Private DNS Zones to reduce networking complexity and DNS costs.
* **Multi-Region Failover:** The architecture is currently pinned to a **Single-Region (Central India)** to stay within subscription limits.
* **WAF (Web Application Firewall):** The NGINX Ingress serves as the primary entry point without an upstream Azure Front Door or App Gateway WAF.

---



### Manually installed the Nginx ingress
**Installation Commands:**
```bash
# 1. Add and update the official NGINX repository
helm repo add ingress-nginx [https://kubernetes.github.io/ingress-nginx](https://kubernetes.github.io/ingress-nginx)
helm repo update

# 2. Install/Upgrade with High Availability (2 replicas)
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.service.externalTrafficPolicy=Local