# Provision & Push Local Containers to Azure Container Registry (ACR)

> Azure Container Registry allows you to build, store, distribution, and manage container images and artifacts in a private registry for all types of container deployments.   

ACR knows how to:
 - store container images, OCI artifacts, and Helm charts
 - version, tag, and manage repositories
 - run cloud builds using ACR Tasks (az acr build)
 - serve images to Azure services (AKS, ACI, ACA, App Service, Functions)


### ACR SKU Comparison
| Feature | Basic | Standard | Premium |
| --- | --- | --- | --- |
| Webhooks | ✅ | ✅ | ✅ |
| Geo-replication | ❌ | ❌ | ✅ |
| Private Link | ❌ | ❌ | ✅ |
| Content Trust | ❌ | ❌ | ✅ |
| CMK Support | ❌ | ❌ | ✅ |
| Throughput | Low | Medium | High |
| Storage | 10 GB | 100 GB | 500 GB |

### SKU Guidance
| SKU | Description | Best For |
| --- | --- | --- |
| Basic | Low-cost, limited throughput | Dev/test |
| Standard | Balanced performance | Production |
| Premium | Enterprise features | Geo-distributed workloads |


### Azure Container Registry — Core Terms (Concise Definitions)
 - **registry**: A private, Azure‑hosted container registry that stores and manages your container images and artifacts.
 - **repository**: A logical collection inside the registry that groups related images (usually by application or service name).
 - **tag**: A version label applied to an image within a repository, used to identify and pull specific builds.
 - **digest**: A unique, immutable SHA‑256 hash that identifies the exact image contents; guarantees you’re pulling the precise image.
 - **artifact**: Any OCI‑compliant object stored in ACR, including container images, Helm charts, SBOMs, signatures, and other supply‑chain assets.
 - **manifest**: Metadata describing an image or artifact — layers, configuration, and references — used by ACR and runtimes to fetch the correct content.
 - **loginServer**: The fully qualified registry endpoint (e.g., `acrdemosvc.azurecr.io`) used for tagging, pushing, and pulling images.
 - **scope map**: A permission set defining what actions tokens can perform on specific repositories (push, pull, delete, etc.).
 - **token**: A lightweight credential tied to a scope map, used for fine‑grained access control without exposing full registry permissions.
 - **import**: An operation that copies an image or artifact into your registry from another registry without pulling it locally.
 - **retention policy**: Rules that automatically clean up old or untagged images to reduce storage usage and keep the registry tidy.
 - **webhooks**: Notifications triggered by registry events (push, delete, etc.) that integrate with CI/CD or automation workflows.


# Live Demo Scripts

### What to Expect (Step-by-Step Flow)

This demo walks you through the complete workflow of creating an Azure Container Registry, pushing images to it, and integrating it with an AKS cluster using managed identities.  
You will perform the following steps:

1. **Create a resource group**  
2. **Create an Azure Container Registry (ACR)**  
3. **Understand ACR RBAC roles**  
4. **Prepare your Dockerfile and source context**  
5. **Build the container image using az acr build (cloud build)**  
6. **Inspect repositories and tags inside ACR**  
7. **Manage tags and delete repositories**  
8. **Review ACR SKU options**  
9. **Attach ACR to AKS using managed identities**


### Create Registry Name: **acrdemosvc**

##### **Pre-Requisites**
- [Click here to download the local Docker container bundle, then return to this section](https://github.com/jeandjoseph/llm-agent-demos/tree/main/postgresql/local_ai_postgres_rag_demo/container).
- Run this script to enable this resource provider: `az provider register --namespace Microsoft.ContainerRegistry`

#### Login to azure portal from your terminal
```bash
az login
```

---

### 1. Create Resource Group

```bash
az group create ^
  --name rg-acr-demo ^
  --location eastus
```

### 2. Create Azure Container Registry
```bash
az acr create ^
  --resource-group rg-acr-demo ^
  --name acrdemosvc ^
  --sku Standard ^
  --location eastus
```

#### check if its created successfully
```bash
az acr list -o table 
```

### 3. Understanding ACR RBAC roles / permissions (Microsoft Learn‑aligned)

| **Role** | **Login** | **Push** | **Pull** |
| --- | --- | --- | --- |
| **AcrPull** | Yes | No | Yes |
| **AcrPush** | Yes | Yes | Yes |
| **AcrDelete** | Yes | No | No |
| **Contributor / Owner** | Yes | Yes | Yes |

### 3.1 Choosing the Right ACR Role for Each Workflow
| **Scenario** | **Recommended Role** | **Pros / Cons** |
|-------------|----------------------|------------------|
| CI/CD pipelines | AcrPush | **Pro:** Supports push+pull for builds. **Con:** Too permissive for runtime-only workloads. |
| AKS / App Services pulling images | AcrPull | **Pro:** Least-privilege for production. **Con:** Cannot push images. |
| Admin operations | Contributor | **Pro:** Full registry management. **Con:** Broad access; not ideal for automation. |

### 4. Login to ACR
 - Lets your local Docker client authenticate to your registry so it can push images.
```bash
az acr login --name acrdemosvc
```

#### 4.1 Get ACR Login Server
 - This command retrieves the registry’s login server URL details so you can reference it when tagging and pushing images.
```bash
az acr show ^
  --name acrdemosvc ^
  --query loginServer ^
  --output tsv
````

#### 5 Build the Container Image Using ACR Tasks
Ensure you are in the correct folder context before running the build. For example:
```bash
cd C:^CommunityDemos^local-postgresql-old^container
```

Build the Container Image Using ACR Tasks
```bash
az acr build ^
    --registry acrdemosvc ^
    --image acr_psql_demo_img:v1.0.0 ^
    .
```

#### 6 Verify the image in the registry
```bash
az acr repository list --name acrdemosvc --output table
```

#### 6.2 List Image Tags in Your ACR Repository
```bash
az acr repository show-tags ^
   --name acrdemosvc ^
   --repository acr_psql_demo_img ^
   --output table
```

#### 6.3 Show Manifest Metadata
```bash
az acr manifest list-metadata ^
   --registry acrdemosvc ^
   --name acr_psql_demo_img ^
   --output table
```
