```markdown
# Application Logic & Deployment Strategy

This directory contains the Go source code and the Kubernetes lifecycle management tools.

## 📦 Application Logic
* **API Handler:** Uses the `Azure/azure-sdk-for-go` to authenticate via Managed Identity and send messages.
* **Background Worker:** A long-running goroutine that prevents pod exit and provides continuous consumption of the `pulse-queue`.

## ☸️ Kubernetes Manifests (Helm)
Deployment is managed via a custom Helm chart in `./charts/pulse-flow`.

### Key Configurations:
* **SecretProviderClass:** Maps Key Vault secrets (Service Bus Connection Strings) into `/mnt/secrets-store`.
* **Ingress:** * `annotations: kubernetes.io/ingress.class: nginx`
    * `externalTrafficPolicy: Local` (Essential for preserving client source IP and avoiding asymmetric routing timeouts).
* **Probes:** Custom Liveness and Readiness probes verify application health before sending traffic.

## 🚀 CI/CD Pipeline
Managed via **Azure Pipelines** (`azure-pipelines.yml`).

1.  **Continuous Integration:** Triggered on main branch pushes.
    * Docker build using the provided multi-stage Dockerfile.
    * Push to Azure Container Registry (ACR).
2.  **Continuous Deployment:** * Updates Helm values with the new Image Tag.
    * Executes `helm upgrade --install` on the AKS cluster.

## 🛠 Troubleshooting Common Issues
* **400 Bad Request:** Occurs if the payload is a JSON object instead of the expected Raw String.
* **Timeout on Public IP:** Ensure the NSG allows traffic from your specific IP or `*` to the LoadBalancer.
* **Secrets Not Mounting:** Check `kubectl describe secretproviderclass` to ensure the ClientID and VaultName match Terraform outputs.