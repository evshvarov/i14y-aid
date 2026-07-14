Class esh.interoperability.aid.tests.DemoService Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    return $$$OK
}

}
