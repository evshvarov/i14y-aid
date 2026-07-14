Class esh.interoperability.aid.api.impl Extends %REST.Impl [ ProcedureBlock ]
{

Parameter ExposeServerExceptions = 1;

/// /_spec
/// Get OpenAPI spec
ClassMethod GetSpec() As %DynamicObject
{
    set specname=$p(..%ClassName(1),".impl")
    Set spec = {}.%FromJSON(##class(%Dictionary.CompiledXData).%OpenId(specname_".spec||OpenAPI").Data)
    Set url = $Select(%request.Secure:"https",1:"http") _ "://"_$Get(%request.CgiEnvs("SERVER_NAME")) _ ":" _ $Get(%request.CgiEnvs("SERVER_PORT")) _ %request.Application
    Set spec.servers = [{"url" : (url)}]
    return spec
}

ClassMethod Health() As %DynamicObject
{
    Set result = {}
    Set result.status = "ok"
    Set result.module = "esh-i14y-aid"
    Set result.version = "0.1.0"
    Set result.namespace = $Namespace
    Set result.capabilities = ##class(esh.interoperability.aid.service.ProductionDiscovery).Capabilities()
    return result
}

ClassMethod ListProductions() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).ListProductions()
}

ClassMethod GetProduction(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProduction(productionName)
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_PRODUCTION_NAME" {
            return ..Error(400, "INVALID_PRODUCTION_NAME", "Invalid productionName.")
        }
        If result.errorCode = "PRODUCTION_NOT_FOUND" {
            return ..Error(404, "PRODUCTION_NOT_FOUND", "The requested interoperability production was not found.")
        }
    }
    return result
}

ClassMethod ListComponents(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListComponents(productionName)
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_PRODUCTION_NAME" {
            return ..Error(400, "INVALID_PRODUCTION_NAME", "Invalid productionName.")
        }
        If result.errorCode = "PRODUCTION_NOT_FOUND" {
            return ..Error(404, "PRODUCTION_NOT_FOUND", "The requested interoperability production was not found.")
        }
    }
    return result
}

ClassMethod GetProductionStatus(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionRuntimeStatus(productionName)
    return ..HandleProductionResult(result)
}

ClassMethod StartProduction(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).StartProduction(productionName)
    return ..HandleProductionActionResult(result)
}

ClassMethod StopProduction(productionName As %VarString, timeout As %Integer = 10, force As %Boolean = 0) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).StopProduction(productionName, timeout, force)
    return ..HandleProductionActionResult(result)
}

ClassMethod HandleProductionResult(result As %DynamicObject) As %DynamicObject [ Private ]
{
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_PRODUCTION_NAME" {
            return ..Error(400, "INVALID_PRODUCTION_NAME", "Invalid productionName.")
        }
        If result.errorCode = "PRODUCTION_NOT_FOUND" {
            return ..Error(404, "PRODUCTION_NOT_FOUND", "The requested interoperability production was not found.")
        }
    }
    return result
}

ClassMethod HandleProductionActionResult(result As %DynamicObject) As %DynamicObject [ Private ]
{
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_PRODUCTION_NAME" {
            return ..Error(400, "INVALID_PRODUCTION_NAME", "Invalid productionName.")
        }
        If result.errorCode = "PRODUCTION_NOT_FOUND" {
            return ..Error(404, "PRODUCTION_NOT_FOUND", "The requested interoperability production was not found.")
        }
        If result.errorCode = "PRODUCTION_ALREADY_RUNNING" {
            return ..Error(409, "PRODUCTION_ALREADY_RUNNING", "Another interoperability production is already running.")
        }
        If result.errorCode = "PRODUCTION_NOT_ACTIVE" {
            return ..Error(409, "PRODUCTION_NOT_ACTIVE", "The requested production is not the active running production.")
        }
        If result.errorCode = "START_FAILED" {
            return ..Error(500, "START_FAILED", result.%Get("statusText"))
        }
        If result.errorCode = "STOP_FAILED" {
            return ..Error(500, "STOP_FAILED", result.%Get("statusText"))
        }
    }
    return result
}

ClassMethod Error(status As %Integer, code As %VarString, message As %VarString) As %DynamicObject [ Private ]
{
    Do ..%SetStatusCode(status)
    Do ..%SetHeader("X-Error", message)
    Set result = {}
    Set error = {}
    Set error.code = code
    Set error.message = message
    Set error.details = {}
    Set error.requestId = $Job_"-"_$ZTimestamp
    Do result.%Set("error", error)
    return result
}

}
