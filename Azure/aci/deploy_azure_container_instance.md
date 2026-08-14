# Azure Container Instance
 - CI is designed as a runtime, not a build or storage service.
 - It only knows how to:
   - read your YAML/Compose file
   - extract the image: field
   - pull that image from a registry
   - start the container
 - If the image is not in a registry, ACI cannot run it.
