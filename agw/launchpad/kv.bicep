param privateEndpointSubnetId string
param applicationGatewaySubnetId string
param privateDnsZoneId string
param managedIdentityId string
param principalId string
param allowedIpList array

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-${resourceGroup().name}'
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: applicationGatewaySubnetId
        }
      ]
      ipRules: [for ip in allowedIpList: {
        value: ip
      }]
    }
  }
}

var secretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var keyVaultAdministratorRoleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

resource rbacSecretsUser 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(subscription().subscriptionId, managedIdentityId, keyVault.id, secretsUserRoleId)
  scope: keyVault
  properties: {
    principalId: managedIdentityId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsUserRoleId)
  }
}

resource rbacKeyVaultAdministrator 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(subscription().subscriptionId, principalId, keyVault.id, keyVaultAdministratorRoleId)
  scope: keyVault
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdministratorRoleId)
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-kv-${resourceGroup().name}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-kv-${resourceGroup().name}'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }

  resource privateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'kv-${resourceGroup().name}'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'default'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
}

output name string = keyVault.name
