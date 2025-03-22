targetScope = 'resourceGroup'

param environment string
param dateTime string = utcNow()

var keyVaultReaderRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '21090545-7ca7-4776-b22c-e363652d74d2'
)

var keyVaultSecretsUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '4633458b-17de-408a-b874-0445c86b69e6'
)

var keyVaultAdministratorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '00482a5a-887f-4fb3-b363-3b7fe8e74483'
)

var location = resourceGroup().location
var tenantId = subscription().tenantId

// A unique string created based on the group's resource id.
// It is used to assign unique names to resources created within a resource group.
var namePostfix = '${environment}${uniqueString(resourceGroup().id)}'

// Used to create sas token with one month validity.
var nextMonthDateTime = dateTimeAdd(dateTime, 'P1M')

var containerNames = ['raw', 'curated', 'cleansed']


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

var storageSasToken = listAccountSAS(storageAccount.name, '2021-04-01', {
  signedProtocol: 'https'
  signedResourceTypes: 'sco'
  signedPermission: 'rl'
  signedServices: 'b'
  signedExpiry: nextMonthDateTime
}).accountSasToken

// Data Factory

var repoConfiguration = {
    accountName: 'UnleashData'
    repositoryName: 'adf-deployment'
    disablePublish: true
    collaborationBranch: 'main'
    rootFolder: '/adf'
    type: 'FactoryGitHubConfiguration'
  }

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf${namePostfix}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repoConfiguration: repoConfiguration
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

var storageSasConnectionString = '${storageAccount.properties.primaryEndpoints.blob}?${storageSasToken}'

resource storageSasSecret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'storage-sas'
  properties: {
    contentType: 'string'
    value: storageSasConnectionString
  }
  tags: {
    storage: storageAccount.name
  }
}

resource adfReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, dataFactory.id, keyVaultReaderRoleId)
  properties: {
    roleDefinitionId: keyVaultReaderRoleId
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource adfSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, dataFactory.id, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleId
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
