targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'biceptest'
  location: deployment().location
}

module storage 'storage.bicep' = {
  scope: rg
  name: '${deployment().name}-storage'
}

output blobContianerNames array = storage.outputs.blobContainerNames
