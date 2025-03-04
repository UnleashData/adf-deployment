targetScope = 'subscription'

param environment string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-adf-${environment}'
  location: deployment().location
}

module resources 'resources.bicep'= {
  name: 'resources-${environment}'
  scope: resourceGroup
  params: {
    environment: environment
  }
}

// module keyVault 'key_vault.bicep' = {
//   name: 'key-vault-${environment}'
//   scope: resourceGroup
//   params: {
//     environment: environment
//   }
// }

// output resources object = {
//   environment: environment
//   storage: storageAccount.outputs.storage_name
//   key_vault: keyVault.outputs.key_vault_name
//   // dodać container name
//   data_factory: dataFactory.name
// }

//dependsOn 
