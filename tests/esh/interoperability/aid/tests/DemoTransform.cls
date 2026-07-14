Class esh.interoperability.aid.tests.DemoTransform Extends %RegisteredObject
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass="esh.interoperability.aid.tests.DemoMessage" targetClass="esh.interoperability.aid.tests.DemoMessage" create="new" language="objectscript">
  <assign value="source.EventType" property="target.EventType" action="set"/>
  <assign value="source.PatientId" property="target.PatientId" action="set"/>
</transform>
}

}
