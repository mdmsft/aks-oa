targetScope = 'subscription'

var nodeResourceGroupName = '${rg.name}-k8s'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: uniqueString(subscription().subscriptionId)
  location: deployment().location
  tags: {
    purpose: 'oa'
  }
}

module id 'id.bicep' = {
  scope: rg
  name: 'id-${deployment().name}'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${deployment().name}'
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'kv-${deployment().name}'
  params: {
    managedIdentityId: id.outputs.principalId
  }
}

module aks 'aks.bicep' = {
  scope: rg
  name: 'aks-${deployment().name}'
  params: {
    subnetId: vnet.outputs.subnetId
    identityId: id.outputs.id
    nodeResourceGroupName: nodeResourceGroupName
  }
}

module rbac 'rbac.bicep' = {
  scope: resourceGroup(nodeResourceGroupName)
  name: 'rbac-${deployment().name}'
  params: {
    kubeletPrincipalId: aks.outputs.kubeletPrincipalId
  }
}

output azCliCommand string = 'az aks get-credentials -n ${aks.outputs.name} -g ${rg.name} --overwrite-existing'
output identity object = {
  id: id.outputs.id
  clientId: id.outputs.clientId
  name: id.outputs.name
}
output vaultUri string = kv.outputs.uri
