param adlname string
param location string = resourceGroup().location

// variables
var containername = 'root'

// resource adl 'Microsoft.DataLakeStore/accounts@2016-11-01' = {
//   name: adlname
//   location: location
//   tags: {
//     mttcommunity: 'demo labs'
//   }
//   identity: {
//     type: 'SystemAssigned'
//   }

// }


resource adls 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: adlname
  location: location
  tags: {
    mttcommunity: 'demo labs'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: true
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${adls.name}/default/${containername}'
}


