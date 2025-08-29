param location string = resourceGroup().location
param environment string
param appName string
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
module vm './modules/vm.bicep' = {
  name: 'vmdeployljg'
  params: {
    adminUsername: 'ljg'
    adminPassword: 'Minoandruby42!!!'
    location: location
    vmName: 'ljvm'
  }
}

// az deployment group create \
//  --resource-group bicep.app \
//  --template-file main.bicep \
//  --parameters @parameters.dev.json

// If the above fails, use
// az deployment group create --resource-group bicep-app --template-file main.bicep --parameters @parameters.dev.json --no-wait
// az deployment group create --resource-group bicep-app --template-file main.bicep --parameters @parameters.prod.json --no-wait
