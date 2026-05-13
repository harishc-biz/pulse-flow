```markdown
# Terraform Infrastructure (IaC)

This directory manages the lifecycle of the Azure cloud resources using Terraform.

## 🛠 Resource Stack
* **AKS Cluster:** Standard Tier with System-Assigned Managed Identity.
* **Azure Service Bus:** Namespace and Queue for message decoupling.
* **Azure Key Vault:** Centralized secret store for the Service Bus primary connection string.
* **Networking:** * Virtual Network (VNet) & Subnets.
    * Network Security Group (NSG) with rules to allow inbound traffic on port 80/443.
* **Application Insights:** Monitoring and distributed tracing.

## 🔐 Security Highlights
* **RBAC Assignment:** The AKS identity is granted `Key Vault Secrets User` permissions automatically via Terraform.
* **Managed Identity:** No static credentials are used; the cluster authenticates to Azure services using its identity.

## 🚀 Deployment
```bash
terraform init
terraform plan
terraform apply