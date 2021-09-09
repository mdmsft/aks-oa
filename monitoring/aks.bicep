param name string
param logAnalyticsWorkspaceId string
param storageAccountId string

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
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}

var logCategories = [
  'kube-apiserver'
  'kube-audit'
  'kube-audit-admin'
  'kube-controller-manager'
  'kube-scheduler'
  'cluster-autoscaler'
  'guard'
]

var metricCategories = [
  'AllMetrics'
]

resource diagnosticSettings 'Microsoft.ContainerService/managedClusters/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${aksCluster.name}/Microsoft.Insights/default'
  properties: {
    logs: [for logCategory in logCategories: {
      category: logCategory
      enabled: true
      retentionPolicy: {
        days: 1
        enabled: true
      }
    }]
    metrics: [for metricCategory in metricCategories: {
      category: metricCategory
      enabled: true
      retentionPolicy: {
        days: 7
        enabled: true
      }
    }]
    storageAccountId: storageAccountId
  }
}

output name string = aksCluster.name
