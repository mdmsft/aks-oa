param publicIpAddress string
param dnsZoneName string
param name string

resource dns 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneName
}

resource a 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: name
  parent: dns
  properties: {
    ARecords: [
      {
        ipv4Address: publicIpAddress
      }
    ]
    TTL: 3600
  }
}
