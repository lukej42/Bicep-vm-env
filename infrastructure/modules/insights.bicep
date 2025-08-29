param name string
param location string
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
output instrumentationKey string = appInsights.properties.InstrumentationKey
