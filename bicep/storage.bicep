targetScope = 'resourceGroup'

param environment string

var namePostfix = uniqueString(resourceGroup().id)
var storageAccountName = 'adf${environment}${namePostfix}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

output storage_name string = storageAccount.name
