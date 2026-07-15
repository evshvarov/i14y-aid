Class esh.interoperability.aid.tests.DemoService Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As esh.interoperability.aid.tests.DemoMessage, Output pOutput As esh.interoperability.aid.tests.DemoMessage) As %Status
{
    return $$$OK
}

}
