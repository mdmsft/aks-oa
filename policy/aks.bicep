
var aksName = 'aks-${uniqueString(resourceGroup().name)}'

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
    addonProfiles: {
      azurePolicy: {
        enabled: true
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
    ]
    nodeResourceGroup: aksName
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'AKS pod security baseline standards for Linux-based workloads'
  scope: aksCluster
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
    parameters: {
      effect: {
        value: 'deny'
      }
    }
  }
}

output name string = aksCluster.name
