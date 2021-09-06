var containers = [
  'one'
  'two'
]

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'st${uniqueString(resourceGroup().name)}'
  location: resourceGroup().location

  sku: {
    name: 'Premium_LRS'
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' = {
    name: 'default'
  
    resource blobContainer 'containers' = [for (containerName, index) in containers: {
      name: containerName
    }]
  }
}

output blobContainerNames array = [
  storage::blobService::blobContainer[0].name
  storage::blobService::blobContainer[1].name
]
