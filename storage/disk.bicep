resource disk 'Microsoft.Compute/disks@2020-12-01' = {
  name: 'disk-${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 4
  }
  sku: {
    name: 'StandardSSD_LRS'
  }
}

output id string = disk.id
output name string = disk.name
