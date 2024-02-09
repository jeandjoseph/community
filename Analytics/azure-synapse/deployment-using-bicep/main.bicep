targetScope = 'subscription'

var suffix  = substring(uniqueString(subscription().id),1,7)

var AzResourceGroup  = 'rg-dp203-${suffix}'
var synapsews        = 'synapse-dp203-${suffix}'
var Location         = 'eastus2'
// storage account
var adlsaccountname  = 'adlsdp203${suffix}'
var adlscontainername= 'root'
// sql pool
var sqlpoolname      = 'sqlpool01'
var AzSqlServerName  = 'SQLPool01'
var sql_admin_user   = 'az_sql_admin_user'
var sql_admin_pw     = 'P@s!W0rD1'
// spark pool
var sparkpool001     = 'sparkpool001'
// ip address
var startIp = '0.0.0.0'
var endIp = '0.0.0.0'
//


resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
 name: AzResourceGroup
 location: Location
 tags: {
   mttcommunity: 'demo labs'
 }
}


module adls2 'create_adls.bicep' = {
  scope:rg
  name: 'adls2'
  params: {
    adlname: adlsaccountname
    location: Location
  }
}



module sqlpool 'create_synapse_ws.bicep' = {
  scope:rg
  name: AzSqlServerName
  params: {
    synapseName: synapsews
    location: Location
    sqlpoolname: sqlpoolname
    administratorUsername: sql_admin_user
    administratorPassword: sql_admin_pw
    adlsaccountname: adlsaccountname
    adlscontainername: adlscontainername
    sparkpool001: sparkpool001
  }
}

