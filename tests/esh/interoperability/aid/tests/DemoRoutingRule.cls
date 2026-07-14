Class esh.interoperability.aid.tests.DemoRoutingRule Extends Ens.Rule.Definition
{

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="esh.interoperability.aid.tests.DemoProduction">
  <ruleSet name="" effectiveBegin="" effectiveEnd="">
    <rule name="">
      <when condition="1" comment="">
        <send transform="esh.interoperability.aid.tests.DemoTransform" target="FHIR Operation"></send>
      </when>
    </rule>
  </ruleSet>
</ruleDefinition>
}

}
