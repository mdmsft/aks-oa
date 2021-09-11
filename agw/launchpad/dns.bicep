param virtualNetworkId string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'

  resource link 'virtualNetworkLinks' = {
    name: '${privateDnsZone.name}-${last(split(virtualNetworkId, '/'))}'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetworkId
      }
    }
  }
}

output id string = privateDnsZone.id
