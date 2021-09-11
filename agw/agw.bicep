param subnetId string
param keyVaultSecretId string
param managedIdentityId string
param managedPrincipalId string

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-${resourceGroup().name}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

var applicationGatewayName = 'agw-${resourceGroup().name}'
var backendHttpSettingName = 'default'
var backendAddressPoolName = 'default'
var frontendIpConfigurationName = 'default'
var frontendHttpPortName = 'default'
var httpListenerName = 'default'
var gatewayIpConfigurationName = 'default'
var sslCertificateName = split(substring(keyVaultSecretId, 8), '/')[2]
var requestRoutingRuleName = 'default'

resource agw 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: applicationGatewayName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    backendAddressPools: [
      {
        name: backendAddressPoolName
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingName
        properties: {
          pickHostNameFromBackendAddress: false
          protocol: 'Http'
          port: 80
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIpConfigurationName
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendHttpPortName
        properties: {
          port: 80
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          protocol: 'Http'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, frontendIpConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, frontendHttpPortName)
          }
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigurationName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: requestRoutingRuleName
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendAddressPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttpSettingName)
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerName)
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ]
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
  }
}

var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource contributor 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(subscription().subscriptionId, subscription().tenantId, managedPrincipalId, contributorRoleId)
  scope: agw
  properties: {
    principalId: managedPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
  }
}

var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource rbacReader 'Microsoft.Authorization/roleAssignments@2018-01-01-preview' = {
  name: guid(managedPrincipalId, readerRoleId)
  properties: {
    principalId: managedPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
  }
}

output id string = agw.id
output ip string = pip.properties.ipAddress
output sslCertificateName string = sslCertificateName
