resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${resourceGroup().name}'
  location: resourceGroup().location
}

output id string = id.id
output principalId string = id.properties.principalId
output clientId string = id.properties.clientId
output name string = id.name
