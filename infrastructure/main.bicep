param location string = resourceGroup().location
param environment string
param appName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'sharedVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'sharedSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
resource publicIp1 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'vm1-ip'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

resource publicIp2 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'vm2-ip'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'sharedNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module storage './modules/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    name: '${appName}stg${environment}'
    location: location
  }
}
module plan './modules/appservice.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    name: '${appName}plan${environment}'
    location: location
    sku: 'F1'
  }
}
module app './modules/app.bicep' = {
  name: 'webAppDeploy'
  params: {
    name: '${appName}-${environment}'
    location: location
    planId: plan.outputs.planId
    insightsInstrumentationKey: insights.outputs.instrumentationKey
  }
}
module insights './modules/insights.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    name: '${appName}-ai-${environment}'
    location: location
  }
}
module keyvault './modules/keyvault.bicep' = {
  name: 'kvDeployljg'
  params: {
    name: '${appName}-kv-${environment}'
    location: location
  }
}
module vm1 './modules/vm.bicep' = {
  name: 'vmdeploy1'
  params: {
    vmName: '<vmname>'
    adminUsername: '<username>'
    adminPassword: '<password>'
    location: location
    subnetId: vnet.properties.subnets[0].id
    publicIpId: publicIp1.id
    nsgId: nsg.id
  }
}

module vm2 './modules/vm.bicep' = {
  name: 'vmdeploy2'
  params: {
    vmName: '<vmname2>'
    adminUsername: '<username>'
    adminPassword: '<password>'
    location: location
    subnetId: vnet.properties.subnets[0].id
    publicIpId: publicIp2.id
    nsgId: nsg.id
  }
}

// az deployment group create \
//  --resource-group bicep.app \
//  --template-file main.bicep \
//  --parameters @parameters.dev.json

// If the above fails, use
// az deployment group create --resource-group bicep-app --template-file main.bicep --parameters @parameters.dev.json --no-wait
// az deployment group create --resource-group bicep-app --template-file main.bicep --parameters @parameters.prod.json --no-wait
