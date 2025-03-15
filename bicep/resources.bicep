targetScope = 'resourceGroup'

param environment string

var containerNames = ['raw', 'curated', 'cleansed']

var storageBlobDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)
var keyVaultReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '21090545-7ca7-4776-b22c-e363652d74d2'
)

var keyVaultAdministratorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '00482a5a-887f-4fb3-b363-3b7fe8e74483'
)

// A unique string created based on the group's resource id.
// It is used to assign unique names to resources created within a resource group.
var namePostfix = '${environment}${uniqueString(resourceGroup().id)}'

var location = resourceGroup().location
var tenantId = subscription().tenantId

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

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for containerName in containerNames: {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}]

resource adfStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, dataFactory.id, storageBlobDataContributorRoleId)
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Key Vault

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: 'kv${namePostfix}'
  location: location
  properties: {
    enableSoftDelete: false
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    createMode: 'default'
    enableRbacAuthorization: true
  }
}

resource adfKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, dataFactory.id, keyVaultReaderRoleId)
  properties: {
    roleDefinitionId: keyVaultReaderRoleId
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deployerKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, deployer().objectId, keyVaultAdministratorRoleId)
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleId
    principalId: deployer().objectId
    principalType: 'User'
  }
}

// output storage_name string = storageAccount.name
