targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${uniqueString(subscription().id)}'
  location: deployment().location
  tags: {
    purpose: 'oa'
  }
}

module log 'log.bicep' = {
  scope: rg
  name: 'log-${deployment().name}'
}

module storage 'storage.bicep' = {
  scope: rg
  name: 'storage-${deployment().name}'
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks-${deployment().name}'
  params: {
    name: 'aks-${rg.name}'
    logAnalyticsWorkspaceId: log.outputs.id
    storageAccountId: storage.outputs.id
  }
}

output azCliCommand string = 'az aks get-credentials -n ${aks.outputs.name} -g ${rg.name} --overwrite-existing'
