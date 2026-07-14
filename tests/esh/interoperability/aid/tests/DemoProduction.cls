Class esh.interoperability.aid.tests.DemoProduction Extends Ens.Production
{

XData ProductionDefinition [ XMLNamespace = "http://www.intersystems.com/production" ]
{
<Production Name="esh.interoperability.aid.tests.DemoProduction" TestingEnabled="true">
  <Item Name="CSV Patient Service" Category="Demo" ClassName="esh.interoperability.aid.tests.DemoService" PoolSize="1" Enabled="true" Comment="Receives simplified patient events">
    <Setting Target="Host" Name="FilePath">/tmp/i14y-aid/in</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Patient Router</Setting>
  </Item>
  <Item Name="Patient Router" Category="Demo" ClassName="esh.interoperability.aid.tests.DemoProcess" PoolSize="1" Enabled="true" Comment="Routes patient events">
    <Setting Target="Host" Name="BusinessRuleName">esh.interoperability.aid.tests.DemoRoutingRule</Setting>
    <Setting Target="Host" Name="TargetConfigNames">FHIR Operation, Notification Operation</Setting>
  </Item>
  <Item Name="FHIR Operation" Category="Demo" ClassName="esh.interoperability.aid.tests.DemoOperation" PoolSize="1" Enabled="true" Comment="Sends admissions and updates to FHIR">
    <Setting Target="Host" Name="FilePath">/tmp/i14y-aid/out</Setting>
  </Item>
  <Item Name="Notification Operation" Category="Demo" ClassName="esh.interoperability.aid.tests.DemoOperation" PoolSize="1" Enabled="false" Comment="Sends discharge notifications">
  </Item>
</Production>
}

}
