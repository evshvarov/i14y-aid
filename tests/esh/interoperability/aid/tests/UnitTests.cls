Class esh.interoperability.aid.tests.UnitTests Extends %UnitTest.TestCase
{

Method InitRequestResponse() [ Private ]
{
    Set %response = ##class(%CSP.Response).%New()
    Set %request = ##class(%CSP.Request).%New()
    Set %request.CgiEnvs("SERVER_NAME") = "localhost"
    Set %request.CgiEnvs("SERVER_PORT") = "52773"
}

Method FindProduction(items As %DynamicArray, productionName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = productionName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindComponent(items As %DynamicArray, componentName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = componentName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method TestGetSpec()
{
    Do ..InitRequestResponse()
    Set spec = ##class(esh.interoperability.aid.api.impl).GetSpec()
    Do $$$AssertTrue($IsObject(spec), "Spec response must be an object")
    Do $$$AssertEquals(spec.swagger, "2.0", "Unexpected swagger version")
    Do $$$AssertEquals(spec.basePath, "/i14y-aid/api", "Unexpected base path")
    Do $$$AssertTrue(spec.paths.%IsDefined("/_spec"), "Spec must expose /_spec")
    Do $$$AssertTrue(spec.paths.%IsDefined("/health"), "Spec must expose /health")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions"), "Spec must expose /productions")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}"), "Spec must expose production detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/components"), "Spec must expose component endpoint")
}

Method TestHealth()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).Health()
    Do $$$AssertTrue($IsObject(result), "Health response must be an object")
    Do $$$AssertEquals(result.status, "ok", "Health status mismatch")
    Do $$$AssertEquals(result.module, "esh-i14y-aid", "Module name mismatch")
    Do $$$AssertEquals(result.namespace, $Namespace, "Namespace mismatch")
    Do $$$AssertTrue($IsObject(result.capabilities), "Capabilities must be an object")
    Do $$$AssertEquals(result.capabilities.openapiVersion, "2.0", "OpenAPI version mismatch")
}

Method TestListProductions()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductions()
    Do $$$AssertTrue($IsObject(result), "List response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Namespace mismatch")
    Do $$$AssertTrue($IsObject(result.items), "Items must be a dynamic array")

    Set production = ..FindProduction(result.items, "esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(production), "Demo production should be listed")
    Do $$$AssertEquals(production.componentCount, 4, "Demo production component count mismatch")
}

Method TestGetProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProduction("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Production response must be an object")
    Do $$$AssertEquals(result.name, "esh.interoperability.aid.tests.DemoProduction", "Production name mismatch")
    Do $$$AssertEquals(result.namespace, $Namespace, "Namespace mismatch")
    Do $$$AssertEquals(result.componentCount, 4, "Component count mismatch")
    Do $$$AssertTrue($IsObject(result.evidence), "Evidence must be an array")
}

Method TestListComponents()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListComponents("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Component response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production name mismatch")
    Do $$$AssertEquals(result.count, 4, "Component count mismatch")

    Set service = ..FindComponent(result.items, "CSV Patient Service")
    Do $$$AssertTrue($IsObject(service), "Service component should be present")
    Do $$$AssertEquals(service.type, "business-service", "Service type mismatch")
    Do $$$AssertEquals(service.enabled, 1, "Service enabled flag mismatch")
    Do $$$AssertEquals(service.targets.%Get(0), "Patient Router", "Service target mismatch")

    Set process = ..FindComponent(result.items, "Patient Router")
    Do $$$AssertTrue($IsObject(process), "Process component should be present")
    Do $$$AssertEquals(process.type, "business-process", "Process type mismatch")
    Do $$$AssertEquals(process.targets.%Size(), 2, "Process target count mismatch")

    Set disabledOperation = ..FindComponent(result.items, "Notification Operation")
    Do $$$AssertTrue($IsObject(disabledOperation), "Disabled operation should be present")
    Do $$$AssertEquals(disabledOperation.type, "business-operation", "Operation type mismatch")
    Do $$$AssertEquals(disabledOperation.enabled, 0, "Disabled operation enabled flag mismatch")
}

Method TestInvalidProductionName()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProduction("bad production name")
    Do $$$AssertTrue($IsObject(result), "Error response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid name should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_PRODUCTION_NAME", "Invalid name error code mismatch")
}

Method TestMissingProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProduction("esh.interoperability.aid.tests.DoesNotExist")
    Do $$$AssertTrue($IsObject(result), "Error response must be an object")
    Do $$$AssertEquals(%response.Status, 404, "Missing production should set 404")
    Do $$$AssertEquals(result.error.code, "PRODUCTION_NOT_FOUND", "Missing production error code mismatch")
}

}
