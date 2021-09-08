resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks'
        properties: {
          addressPrefix: '10.100.1.0/24'
        }
      }
      {
        name: 'agw'
        properties: {
          addressPrefix: '10.100.2.0/24'
        }
      }
    ]
  }
}

output aksSubnetId string = virtualNetwork.properties.subnets[0].id
output agwSubnetId string = virtualNetwork.properties.subnets[1].id
