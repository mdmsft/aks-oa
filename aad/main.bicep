targetScope = 'subscription'

param adminGroupId string
param principalId string

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
    adminGroupId: adminGroupId
    principalId: principalId
  }
}

output azCliCommand string = 'az aks get-credentials -n ${aks.outputs.name} -g ${rg.name} --overwrite-existing'
