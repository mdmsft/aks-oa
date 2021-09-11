param dnsZoneId string
param keyVaultSecretId string
param managedIdentity object
param virtualNetwork object

var dnsZoneComponents = split(dnsZoneId, '/')

module applicationGateway 'agw.bicep' = {
  name: '${deployment().name}-agw'
  params: {
    managedIdentityId: managedIdentity.id
    managedPrincipalId: managedIdentity.principalId
    keyVaultSecretId: keyVaultSecretId
    subnetId: virtualNetwork.applicationGatewaySubnetId
  }
}

module aks 'aks.bicep' = {
  name: '${deployment().name}-aks'
  params: {
    subnetId: virtualNetwork.kubernetesSubnetId
    applicationGatewayId: applicationGateway.outputs.id
  }
}

module rbac 'rbac.bicep' = {
  name: '${deployment().name}-rbac'
  params: {
    applicationGatewayId: applicationGateway.outputs.id
    clusterName: aks.outputs.name
    managedIdentityId: managedIdentity.id
    nodeResourceGroupName: aks.outputs.nodeResourceGroupName
  }
}

module dns 'dns.bicep' = {
  name: '${deployment().name}-dns'
  scope: resourceGroup(dnsZoneComponents[4])
  params: {
    dnsZoneName: last(dnsZoneComponents)
    publicIpAddress: applicationGateway.outputs.ip
    name: resourceGroup().name
  }
}

output sslCertificateName string = applicationGateway.outputs.sslCertificateName
output cliCommandText string = 'az aks get-credentials -n ${aks.outputs.name} -g ${resourceGroup().name}'
