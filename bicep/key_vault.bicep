targetScope = 'resourceGroup'

param environment string

var namePostfix = uniqueString(resourceGroup().id)
var keyVaultName = 'kvadf${environment}${namePostfix}'
var tenantId = subscription().tenantId



// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' >= {
//   // can be used to help make GUID unique
//   name: guid(deployer().objectId, readerRoleDefinitionId, resourceGroup().id)
//   properties: {
//     principalId: deployer().objectId // easily retrieve objectId
//     roleDefinitionId: readerRoleDefinitionId
//   }
//  }


resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    
    
    enableSoftDelete: false
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }

    accessPolicies: [
      {
        objectId: '275a64a9-eaf1-436c-89bf-3fd0d3a27632'
        tenantId: tenantId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
      // dodać ADF
    ]
    createMode: 'default'
    publicNetworkAccess: 'disabled'

    // enablePurgeProtection: bool
    // enableRbacAuthorization: bool
    // enabledForTemplateDeployment
    // networkAcls: {
    //   bypass: 'string'
    //   defaultAction: 'string'
    //   ipRules: [
    //     {
    //       value: 'string'
    //     }
    //   ]
    //   virtualNetworkRules: [
    //     {
    //       id: 'string'
    //       ignoreMissingVnetServiceEndpoint: bool
    //     }
    //   ]
    // }
    // provisioningState: 'string'
    
    
    // softDeleteRetentionInDays: int

    // vaultUri: 'string'
  }
}

output key_vault_name string = keyVault.name
