targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${uniqueString(subscription().id)}'
  location: deployment().location
  tags: {
    purpose: 'oa'
  }
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks-${deployment().name}'
  params: {
    name: 'aks-${rg.name}'
  }
}

output clusterName string = aks.outputs.name
output resourceGroupName string = rg.name
