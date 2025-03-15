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

// output
