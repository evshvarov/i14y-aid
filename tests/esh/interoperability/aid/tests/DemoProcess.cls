Class esh.interoperability.aid.tests.DemoProcess Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As %Persistent, Output pResponse As %Persistent) As %Status
{
    return $$$OK
}

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process request="esh.interoperability.aid.tests.DemoMessage" response="esh.interoperability.aid.tests.DemoMessage" height="2000" width="2000">
  <sequence xend="200" yend="400">
    <assign property="context.EventType" value="request.EventType" action="set" />
    <call name="SendToFHIR" target="FHIR Operation" async="0" xpos="200" ypos="200">
      <request type="esh.interoperability.aid.tests.DemoMessage">
        <assign property="callrequest.EventType" value="request.EventType" action="set" />
      </request>
      <response type="esh.interoperability.aid.tests.DemoMessage" />
    </call>
    <sync calls="SendToFHIR" type="all" />
    <reply />
  </sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
