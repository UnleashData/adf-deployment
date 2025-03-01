targetScope = 'subscription'

param environment string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'adf-${environment}'
  location: deployment().location
}

// module storageAccount 'storage.bicep' = {
//   name: 'storage-${environment}'
//   scope: resourceGroup
//   params: {
//     environment: environment
//   }
// }

output resources object = {
  environment: environment
  // storage: storageAccount.outputs.storage_name
}

//dependsOn 
