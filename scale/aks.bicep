param name string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.19.13'
    dnsPrefix: name
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
      {
        name: 'user'
        count: 1
        minCount: 1
        maxCount: 3
        enableAutoScaling: true
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'User'
      }
    ]
  }
}

output name string = aksCluster.name
