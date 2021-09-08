targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${uniqueString(subscription().id, subscription().tenantId)}'
  location: deployment().location
  tags: {
    purpose: 'oa'
  }
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks-${deployment().name}'
  params: {
    aksName: 'aks-${rg.name}'
    diskName: disk.outputs.name
  }
}

module disk 'disk.bicep' = {
  scope: rg
  name: 'disk-${deployment().name}'
}

module storage 'storage.bicep' = {
  scope: rg
  name: 'storage-${deployment().name}'
}

output azCliCommand string = 'az aks get-credentials -n ${aks.outputs.name} -g ${rg.name} --overwrite-existing'
output disk object = {
  id: disk.outputs.id
  name: disk.outputs.name
}
output file object = {
  accountName: storage.outputs.accountName
  accountKey: storage.outputs.accountKey
  shareName: storage.outputs.shareName
}
