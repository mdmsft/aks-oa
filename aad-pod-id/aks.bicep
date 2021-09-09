param subnetId string
param identityId string
param nodeResourceGroupName string

var subnetSegments = split(subnetId, '/')
var identitySegments = split(identityId, '/')

var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'
var managedIdentityOperatorRoleId = 'f1a07417-d97a-45cb-824c-7a7467783830'


resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: subnetSegments[8]
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: last(subnetSegments)
  parent: vnet
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: last(identitySegments)
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'aks-${resourceGroup().name}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Paid'
  }
  properties: {
    kubernetesVersion: '1.19.13'
    dnsPrefix: resourceGroup().name
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnetId
        upgradeSettings: {
          maxSurge: '1'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
    }
    nodeResourceGroup: nodeResourceGroupName
  }
}

resource rbacNetworkContributor 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(subscription().subscriptionId, subscription().tenantId, aksCluster.id, networkContributorRoleId)
  scope: subnet
  properties: {
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
  }
}

resource rbacManagedIdentityOperator 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(subscription().subscriptionId, subscription().tenantId, aksCluster.id, managedIdentityOperatorRoleId)
  scope: id
  properties: {
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', managedIdentityOperatorRoleId)
  }
}

output name string = aksCluster.name
output kubeletPrincipalId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
