targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: uniqueString(subscription().id)
  location: deployment().location
  tags: {
    purpose: 'oa'
  }
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${deployment().name}'
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks-${deployment().name}'
  params: {
    subnetId: vnet.outputs.subnetId
  }
}

output azCliCommand string = 'az aks get-credentials -n ${aks.outputs.name} -g ${rg.name} --overwrite-existing'
