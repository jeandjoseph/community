

```bash
az webapp create \
    --resource-group rg-acr-demos \
    --plan appsvc-linux-b1-plan \
    --name docprocessor-webapp \
    --container-image-name acrdemosvc.azurecr.io/docprocessor:v1
```
