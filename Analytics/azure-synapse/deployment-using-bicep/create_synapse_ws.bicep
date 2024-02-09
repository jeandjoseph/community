// az deployment sub create --location eastus --template-file .\main.bicep

// This template is used to create a Synapse workspace.
//targetScope = 'resourceGroup'

// Parameters
param location string
param synapseName string
// adls parameters
param adlsaccountname string
param adlscontainername string
// sql pool parameters
param sqlpoolname string
param administratorUsername string
param administratorPassword string
param enableSqlPool bool = true
// spark pool parameters
param sparkpool001 string

//param tags string = '{MTTDeployment': 'Demo Labs}'
//param subnetId string = 'b635aca8-b9cc-4989-ab6e-23d330614423'


// Variables
var startIp = '0.0.0.0'
var endIp = '255.255.255.255'

// Resources

// Provision Azure Synapse workspace
resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${adlsaccountname}.dfs.core.windows.net/'
      filesystem: adlscontainername
    }
    managedResourceGroupName: synapseName
    sqlAdministratorLogin: administratorUsername
    sqlAdministratorLoginPassword: administratorPassword
  }
}

// Set firewall rules for Azure Synapse workspace
// resource synapsefirewall 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
//   name: 'synapsefw'
//   parent: synapse
//   properties: {
//     endIpAddress: startIp
//     startIpAddress: endIp
//   }
// }

// Provision Azure Synapse Dedicated SQL pool
resource synapseSqlPool001 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = if(enableSqlPool) {
  parent: synapse
  name: sqlpoolname
  location: location
  sku: {
    name: 'DW100c'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    storageAccountType: 'LRS'
  }
}


resource synapseBigDataPool001 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapse
  name: sparkpool001
  location: location
  properties: {
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 4
    }
    customLibraries: []
    defaultSparkLogFolder: 'logs/'
    nodeSize: 'Small'
    nodeSizeFamily: 'MemoryOptimized'
    sessionLevelPackagesEnabled: true
    sparkEventsFolder: 'events/'
    sparkVersion: '3.3'
  }
}
