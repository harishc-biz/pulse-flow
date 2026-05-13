# Application, Containerization & Orchestration

This directory contains the source code, container configuration, and Kubernetes manifests for the Pulse-Flow application suite. The project is built with a focus on high concurrency, asynchronous processing, and the "Separation of Concerns" principle.

## 📦 Application Components

### 1. API Service (The Producer)
* **Language:** Go (Golang) / High-performance Web Framework.
* **Function:** Receives HTTP requests, performs schema validation, and hands off the payload to Azure Service Bus.
* **Endpoint Logic:** * `POST /api/work`: Accepts a raw JSON string and returns a `202 Accepted` status, signifying the start of an async workflow.
    * `GET /api/work`: Retrieves a list of processed items (demonstrating state persistence/retrieval).

### 2. Background Worker (The Consumer)
* **Function:** A dedicated worker routine that maintains a persistent connection to the Azure Service Bus Queue.
* **Reliability:** Implements manual message acknowledgement (Peek-Lock pattern) to ensure no data loss during processing failures.

---

## 🛠 Kubernetes Orchestration (Helm)

The application is deployed using **Helm v3** to ensure consistent, repeatable deployments across environments.

### 🛡 Security: Secrets Store CSI Driver
The application follows a **Zero-Trust** security model. No connection strings are stored in environment variables or Kubernetes Secrets.
* **Integration:** Uses the `SecretProviderClass` to pull the Service Bus Connection String directly from **Azure Key Vault**.
* **Mount Path:** Secrets are mounted as ephemeral volumes at `/mnt/secrets-store`, which the application reads at startup.

### 🚦 Traffic Management & Reliability
* **Ingress:** Managed via NGINX with `externalTrafficPolicy: Local`. This was a strategic decision to solve asymmetric routing issues and preserve the Client Source IP for logging and security auditing.
* **Health Probes:**
    * **Liveness Probe:** Monitors the process state to trigger automatic container restarts if the app hangs.
    * **Readiness Probe:** Ensures the container only receives traffic once the connection to Azure Service Bus is verified.

---

## 🚢 CI/CD Pipeline (Azure DevOps)

The deployment is fully automated via `azure-pipelines.yml`, emphasizing a **Build-Once-Deploy-Many** strategy.

### Stage 1: Build & Package
1. **Linting:** Scans Go code for formatting and syntax errors.
2. **Multi-Stage Docker Build:** * *Builder Image:* Compiles the Go binary with all dependencies.
    * *Runtime Image:* Uses a minimal `distroless` or `alpine` base to reduce attack surface and image size (~20MB).
3. **Registry:** Tags and pushes the image to **Azure Container Registry (ACR)** using the Build ID for versioning.

### Stage 2: Deploy (CD)
1. **Ui Releases:** Configured the UI release for the app so that developers can take care of app deployments for all enviroments
2. **Atomic Upgrades:** Uses `helm upgrade --install` to ensure that Deploys the latest vesrion if its first time a new installation taken place for deployment.