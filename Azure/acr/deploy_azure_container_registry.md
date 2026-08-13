# Provision & Push Local Containers to Azure Container Registry (ACR)

> Azure Container Registry allows you to build, store, and manage container images and artifacts in a private registry for all types of container deployments.   

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
4. **Login to ACR and retrieve the login server**  
5. **Tag and push a Docker image to ACR**  
6. **Inspect repositories and tags inside ACR**  
7. **Manage tags and delete repositories**  
8. **Review ACR SKU options**  
9. **Attach ACR to AKS using managed identities**  
10. **Understand AKS control-plane vs kubelet identities**


### Create Registry Name: **acrdemosvc**

##### **Pre-Requisites**
- If you do not already have a Docker container, click here to create one. Return to this section once your container is ready.
- Convert your container into a Docker image using the command below:
- tag: v1.0.0
```bash
docker commit <container-name> <image-name>:<tag>
```

example:
```bash
docker commit local_postgresql_acr_demo acr_demo_image:v1.0.0
```

##### Confirm that image is created
```bash
docker images
```

#### Login to azure portal from your terminal
```bash
az login
```

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
az acr show \
  --name acrdemosvc \
  --query loginServer \
  --output tsv
````

#### 4.2 Get all docker images
```bash
docker images
```

#### 5. Tag Local Image for ACR
 - This step prepares your local Docker image for upload by assigning it a tag that points to your Azure Container Registry. Tagging the image with the ACR login server ensures Docker knows exactly where the image should be pushed next.

- Before running the tagging command, record the following:
  - Docker Image Name:
  - ACR Login Server (endpoint):
  - Tag: v1.0.0
```bash
docker tag <image-name>:<tag> \
  <acr-endpoint>/<image-name>:<tag>
```

example:
```bash
docker tag acr_demo_image:v1.0.0 \
  acrdemosvc.azurecr.io/acr_demo_image:v1.0.0
```

verify the image is ready to push to acr
```bash
docker images
```

#### 6. Push Image to ACR
 - Uploads the tagged image to your Azure Container Registry.
```bash
docker push acrdemosvc.azurecr.io/acr_demo_image:v1.0.0
````

#### 6.1 Verify Image in ACR
 - This command lists all repositories stored in your Azure Container Registry, giving you a full inventory of every image collection inside acrdemosvc. Can get noisy and slow in large registries.
```bash
az acr repository list \
  --name acrdemosvc
```

#### 6.2 Returns detailed metadata for a single repository
```bash
az acr repository show \
  --name acrdemosvc \
  --repository acr_demo_image
```

#### 6.3 lists all tags associated with this repository
```bash
az acr repository show-tags \
  --name acrdemosvc \
  --repository acr_demo_image
```

#### 7 creates a new version tag
- Tagging lets you version your image — whether you changed the image or not — so you can reliably reference, push, and deploy specific builds using consistent tag names.
```bash
docker tag casacloud/nodejstemplate:v1.0.0 \
  acrdemosvc.azurecr.io/acr_demo_image:v1.0.1
```

#### 7.1 Push Your Latest Image Version to Azure Container Registry
- This command uploads the v1.0.1 image for acr_demo_image to your Azure Container Registry, making that version available for pulls, deployments, and CI/CD workflows.
```bash
docker push acrdemosvc.azurecr.io/acr_demo_image:v1.0.1
```

#### 8 Delete Entire Repository
- This command permanently deletes the entire acr_demo_image repository from your Azure Container Registry, including all tags, all image versions, and all digests stored under that repository. It’s a full repository removal, not a single‑tag delete.
- Deleting an ACR repository is irreversible, wipes all image versions and tags, can break any deployment that pulls acr_demo_image:*, offers no safety prompt in automation, and requires manually re‑tagging and re‑pushing images to restore it.
```bash
az acr repository delete \
  --name acrdemosvc \
  --repository acr_demo_image
```

#### Summarization
- Retrieve your login server, tag your image with a proper version, push it to ACR, verify repositories and tags, and delete only with extreme caution because removal is irreversible and breaks all dependent deployments.





