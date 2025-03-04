targetScope = 'subscription'

var environments = ['dev'] //['dev', 'tst', 'prd']

@description('markdown')
module resourceGroup 'resource_group.bicep' = [for environment in environments : {
  name: 'resource-group-${environment}'
  scope: subscription()
  params: {
    environment: environment
  }
}]

// output resources array = [for i in range(0, length(environments)) : resourceGroup[i].outputs.resources]
