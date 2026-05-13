# Pulse-Flow: SRE Asynchronous Messaging System

Pulse-Flow is a cloud-native asynchronous messaging pipeline built to demonstrate high-availability, secure secret management, and robust observability within a Kubernetes environment.

## 🏗 System Architecture

The project follows a producer-consumer pattern decoupled by a message broker:
1.  **API (Producer):** A service that receives HTTP POST requests and enqueues messages.
2.  **Azure Service Bus:** The reliable message broker for asynchronous communication.
3.  **Background Worker (Consumer):** A routine that pulls messages from the Service Bus and processes them.
4.  **Security:** Integration with **Azure Key Vault** via the **Secrets Store CSI Driver** to mount sensitive connection strings as volumes.

## 📂 Repository Structure

* [**Terraform Infrastructure**](./terraform/README.md): IaC for AKS, Service Bus, Key Vault, and Networking.
* [**Application & Helm**](./app/README.md): Go source code, Docker configuration, and Kubernetes manifests.

## 🌐 Connectivity & Access

The application is exposed via an **NGINX Ingress Controller** using a managed Azure Load Balancer.

**Public API Endpoint:** `http://20.235.200.43/api/work`

### Validating the Flow (Curl)
To send a message through the pipeline, use the following format:
```bash
curl -X POST "[http://20.235.200.43/api/work](http://20.235.200.43/api/work)" \
     -H "Content-Type: application/json" \
     -d "\"SRE Pipeline Stability Test\""



Future Enhancements
KEDA Implementation: Scale background workers to zero when the queue is empty and burst up based on message backlog.

Istio Service Mesh: Implement mTLS and advanced traffic shadowing for "Canary" deployments.

Automated TLS: Integrate cert-manager with Let's Encrypt for automatic HTTPS.
# pulse-flow

to send message 
curl -X POST "http://localhost:5195/api/work" -H "Content-Type: application/json" -d "\"Hello from Localhost\""


To fetch the message 
http://localhost:5195/api/work

install nginx ingress
# 1. Add the repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 2. Install/Upgrade with Static IP and Azure-specific annotations
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress --create-namespace \
  --set controller.replicaCount=2