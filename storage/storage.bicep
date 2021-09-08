
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'st${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  kind: 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }

  resource fileServices 'fileServices' = {
    name: 'default'

    resource share 'shares' = {
      name: 'logs'
      properties: {
        shareQuota: 1024
      }
    }
  }
}

output accountName string = base64(storageaccount.name)
output accountKey string = base64(storageaccount.listKeys().keys[0].value)
output shareName string = storageaccount::fileServices::share.name
