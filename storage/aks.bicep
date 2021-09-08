param aksName string
param diskName string

resource disk 'Microsoft.Compute/disks@2020-12-01' existing = {
  name: diskName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: aksName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.19.13'
    dnsPrefix: aksName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

var virtualMachineContributorRoleId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(subscription().subscriptionId, subscription().tenantId, aksCluster.id, virtualMachineContributorRoleId)
  scope: disk
  properties: {
    principalId: aksCluster.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', virtualMachineContributorRoleId)
  }
}

output name string = aksCluster.name
