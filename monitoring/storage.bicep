
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'st${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output id string = storageaccount.id
