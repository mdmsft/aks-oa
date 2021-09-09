param managedIdentityId string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-${uniqueString(subscription().subscriptionId)}'
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }

  resource secret 'secrets' = {
    name: 'secret'
    properties: {
      value: subscription().displayName
    }
  }
}

var secretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource rbac 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid(subscription().subscriptionId, managedIdentityId, kv.id, secretsUserRoleId)
  scope: kv
  properties: {
    principalId: managedIdentityId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsUserRoleId)
  }
}

output uri string = 'https://${kv.name}${environment().suffixes.keyvaultDns}'
