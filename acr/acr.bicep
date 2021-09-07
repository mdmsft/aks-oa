resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: 'cr${uniqueString(resourceGroup().name)}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output name string = containerRegistry.name
