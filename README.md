# Pulse-Flow: High-Availability SRE Messaging Pipeline


Pulse-Flow is a production-ready asynchronous event-processing engine. It demonstrates the **SRE "Gold Standard"** for decoupling services using Azure Service Bus, securing secrets via Key Vault CSI, and maintaining 99.9% availability through Kubernetes-native self-healing and multi environment deployment capabilities.

---

## Architecture Overview
The system implements a non-blocking **Producer-Consumer** pattern to ensure the API remains responsive even during heavy message processing.



1.  **API (Go/Web):** A high-performance ingress point that validates requests.
2.  **Service Bus Queue:** Acts as the persistent buffer (At-Least-Once delivery).
3.  **Background Worker:** A concurrent consumer that processes tasks from the queue.
4.  **Observability:** Integrated with **Application Insights** for distributed tracing.
5.  **Security:** Secrets are injected via **Azure Key Vault Secret Store CSI Driver** (Zero-trust).

---

## 📂 Repository Roadmap
* 📂 [**Infrastructure (Terraform)**](./pulse-infra/README.md) - Cloud resource definitions and RBAC.
* 📂 [**Application & Manifests**](./pulse-app/README.md) - Source code, Dockerfile, and Helm charts.

---

## 🌐 Quick Start & Testing

The application is live and managed by the **NGINX Ingress Controller**.

### 1. API Endpoints
| Action | Endpoint | Method | Expected Payload |
| :--- | :--- | :--- | :--- |
| **Health** | `/` | `GET` | 200 OK |
| **Process** | `/api/work` | `POST` | `"string"` |
| **Status** | `/api/work` | `GET` | List of items |

### 2. Integration Test (Curl)
```bash
curl -X POST "[http://20.235.200.43/api/work](http://20.235.200.43/api/work)" \
     -H "Content-Type: application/json" \
     -d "\"Final SRE Validation Test\""
```
Success Response: 202 Accepted

---

## 🛡Security & Reliability Features
**Zero-Hardcoding:** All connection strings are mounted as ephemeral volumes from Key Vault.

**Network Policy:**  Inbound traffic is strictly controlled via NSG Rule 500.

**Self-Healing:** Liveness and Readiness probes ensure traffic only hits healthy pods.

**Traffic Integrity:** externalTrafficPolicy: Local is enabled to preserve client source IPs for auditing.

---
## 📈 Future Roadmap
* **KEDA Integration:** Auto-scale worker pods based on Service Bus queue depth.

* **Istio Service Mesh:** Mutual TLS and advanced telemetry.

* **SSL/TLS:** Automate certificate renewal via Cert-Manager.
