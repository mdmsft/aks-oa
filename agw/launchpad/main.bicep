param keyVaultAllowedIpList array
param principalId string

module id 'id.bicep' = {
  name: '${deployment().name}-id'
}

module vnet 'vnet.bicep' = {
  name: '${deployment().name}-vnet'
}

module dns 'dns.bicep' = {
  name: '${deployment().name}-dns'
  params: {
    virtualNetworkId: vnet.outputs.id
  }
}

module kv 'kv.bicep' = {
  name: '${deployment().name}-kv'
  params: {
    applicationGatewaySubnetId: vnet.outputs.applicationGatewaySubnetId
    managedIdentityId: id.outputs.principalId
    privateDnsZoneId: dns.outputs.id
    privateEndpointSubnetId: vnet.outputs.defaultSubnetId
    allowedIpList: keyVaultAllowedIpList
    principalId: principalId
  }
}

output managedIdentity object = {
  value: {
    id: id.outputs.id
    principalId: id.outputs.principalId
  }
}

output virtualNetwork object = {
  value: {
    applicationGatewaySubnetId: vnet.outputs.applicationGatewaySubnetId
    kubernetesSubnetId: vnet.outputs.kubernetesSubnetId
  }
}

output keyVaultName string = kv.outputs.name
