# Provision Azure Container Registry (ACR)

> Azure Container Registry allows you to build, store, and manage container images and artifacts in a private registry for all types of container deployments.   

Registry Name: **acrdemosvc**

## What to Expect (Step-by-Step Flow)

This demo walks you through the complete workflow of creating an Azure Container Registry, pushing images to it, and integrating it with an AKS cluster using managed identities.  
You will perform the following steps:

1. **Create a resource group**  
2. **Create an Azure Container Registry (ACR)**  
3. **Understand ACR RBAC roles**  
4. **Login to ACR and retrieve the login server**  
5. **Tag and push a Docker image to ACR**  
6. **Inspect repositories and tags inside ACR**  
7. **Manage tags and delete repositories**  
8. **Review ACR SKU options**  
9. **Attach ACR to AKS using managed identities**  
10. **Understand AKS control-plane vs kubelet identities**

---

### 1. Create Resource Group

```bash
az group create \
  --name rg-acr-demo \
  --location eastus
```

### 2. Create Azure Container Registry
```bash
az acr create \
  --resource-group rg-acr-demo \
  --name acrdemosvc \
  --sku Standard \
  --location eastus
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

### 4. Lets your local Docker client authenticate to your registry so it can push images.
```bash
az acr login --name acrdemosvc
```



