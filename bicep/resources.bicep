targetScope = 'resourceGroup'

param environment string

var storageBlobDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' >= {
//   // can be used to help make GUID unique
//   name: guid(deployer().objectId, readerRoleDefinitionId, resourceGroup().id)
//   properties: {
//     principalId: deployer().objectId // easily retrieve objectId
//     roleDefinitionId: readerRoleDefinitionId
//   }
//  }

// A unique string created based on the group's resource id.
// It is used to assign unique names to resources created within a resource group.
var namePostfix = '${environment}${uniqueString(resourceGroup().id)}'

var location = resourceGroup().location

// Data Factory

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf${namePostfix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

// Storage

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stg${namePostfix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, dataFactory.id, storageBlobDataContributorRoleId)
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


// jeden na raw drugi na transformed

// resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
//   name: '${storageAccount.name}/default/container-${environment}'
// }

output storage_name string = storageAccount.name
