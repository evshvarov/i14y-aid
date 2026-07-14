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

ClassMethod Capabilities() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).Capabilities()
}

ClassMethod GetSettings() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).GetSettings()
}

ClassMethod UpdateSettings(settings As %DynamicObject = "") As %DynamicObject
{
    If '$IsObject(settings) {
        Set settings = ..ReadJsonBody()
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).UpdateSettings(settings)
    return ..HandleSettingsResult(result)
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
    return ..HandleProductionResult(result)
}

ClassMethod GetComponentDetail(productionName As %VarString, componentName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetComponentDetail(productionName, componentName)
    return ..HandleProductionResult(result)
}

ClassMethod GetProductionAnalysis(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionAnalysis(productionName)
    return ..HandleProductionResult(result)
}

ClassMethod GetProductionSummary(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionSummary(productionName)
    return ..HandleProductionResult(result)
}

ClassMethod GetProductionGraph(productionName As %VarString) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionGraph(productionName)
    return ..HandleProductionResult(result)
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

ClassMethod ListMessages(productionName As %VarString = "", limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0) As %DynamicObject
{
    If '$Data(productionName) {
        Set productionName = ""
    }
    If '$Data(limit) {
        Set limit = 50
    }
    If '$Data(offset) {
        Set offset = 0
    }
    If '$Data(sourceConfigName) {
        Set sourceConfigName = ""
    }
    If '$Data(targetConfigName) {
        Set targetConfigName = ""
    }
    If '$Data(messageBodyClassName) {
        Set messageBodyClassName = ""
    }
    If '$Data(sessionId) {
        Set sessionId = ""
    }
    If '$Data(errorsOnly) {
        Set errorsOnly = 0
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListMessages(productionName, limit, offset, sourceConfigName, targetConfigName, messageBodyClassName, sessionId, errorsOnly)
    return ..HandleRuntimeResult(result)
}

ClassMethod ListProductionMessages(productionName As %VarString, limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0) As %DynamicObject
{
    If '$Data(limit) {
        Set limit = 50
    }
    If '$Data(offset) {
        Set offset = 0
    }
    If '$Data(sourceConfigName) {
        Set sourceConfigName = ""
    }
    If '$Data(targetConfigName) {
        Set targetConfigName = ""
    }
    If '$Data(messageBodyClassName) {
        Set messageBodyClassName = ""
    }
    If '$Data(sessionId) {
        Set sessionId = ""
    }
    If '$Data(errorsOnly) {
        Set errorsOnly = 0
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListMessages(productionName, limit, offset, sourceConfigName, targetConfigName, messageBodyClassName, sessionId, errorsOnly)
    return ..HandleRuntimeResult(result)
}

ClassMethod ListMessageFacets(productionName As %VarString = "", limit As %Integer = 500) As %DynamicObject
{
    If '$Data(productionName) {
        Set productionName = ""
    }
    If '$Data(limit) {
        Set limit = 500
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListMessageFacets(productionName, limit)
    return ..HandleRuntimeResult(result)
}

ClassMethod ListProductionMessageFacets(productionName As %VarString, limit As %Integer = 500) As %DynamicObject
{
    If '$Data(limit) {
        Set limit = 500
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListMessageFacets(productionName, limit)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetMessage(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessage(messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetProductionMessage(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessage(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetMessagePayloadMetadata(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessagePayloadMetadata(messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetProductionMessagePayloadMetadata(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessagePayloadMetadata(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetMessageTrace(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessageTrace(messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetProductionMessageTrace(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessageTrace(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetMessageExplanation(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessageExplanation(messageId)
    return ..HandleRuntimeResult(result)
}

ClassMethod GetProductionMessageExplanation(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessageExplanation(productionName, messageId)
    return ..HandleRuntimeResult(result)
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
        If result.errorCode = "INVALID_COMPONENT_NAME" {
            return ..Error(400, "INVALID_COMPONENT_NAME", "Invalid componentName.")
        }
        If result.errorCode = "COMPONENT_NOT_FOUND" {
            return ..Error(404, "COMPONENT_NOT_FOUND", "The requested production component was not found.")
        }
    }
    return result
}

ClassMethod HandleRuntimeResult(result As %DynamicObject) As %DynamicObject [ Private ]
{
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_PRODUCTION_NAME" {
            return ..Error(400, "INVALID_PRODUCTION_NAME", "Invalid productionName.")
        }
        If result.errorCode = "PRODUCTION_NOT_FOUND" {
            return ..Error(404, "PRODUCTION_NOT_FOUND", "The requested interoperability production was not found.")
        }
        If result.errorCode = "INVALID_MESSAGE_ID" {
            return ..Error(400, "INVALID_MESSAGE_ID", "Invalid messageId.")
        }
        If result.errorCode = "MESSAGE_NOT_FOUND" {
            return ..Error(404, "MESSAGE_NOT_FOUND", "The requested interoperability message header was not found.")
        }
        If result.errorCode = "MESSAGE_NOT_IN_PRODUCTION" {
            return ..Error(404, "MESSAGE_NOT_IN_PRODUCTION", "The requested interoperability message header does not belong to the requested production.")
        }
        If result.errorCode = "MESSAGE_HEADER_NOT_AVAILABLE" {
            return ..Error(404, "MESSAGE_HEADER_NOT_AVAILABLE", "Ens.MessageHeader is not available in this namespace.")
        }
        If result.errorCode = "RUNTIME_MESSAGE_ANALYSIS_DISABLED" {
            return ..Error(403, "RUNTIME_MESSAGE_ANALYSIS_DISABLED", "Runtime message analysis is disabled by module settings.")
        }
        If result.errorCode = "STATUS_ERROR" {
            return ..Error(500, "STATUS_ERROR", "Runtime message query failed.")
        }
    }
    return result
}

ClassMethod HandleSettingsResult(result As %DynamicObject) As %DynamicObject [ Private ]
{
    If result.%IsDefined("errorCode") {
        If result.errorCode = "INVALID_SETTINGS_PAYLOAD" {
            return ..Error(400, "INVALID_SETTINGS_PAYLOAD", "Settings update requires a JSON object body.")
        }
        If result.errorCode = "SETTINGS_OPEN_FAILED" {
            return ..Error(500, "SETTINGS_OPEN_FAILED", "Module settings could not be opened for update.")
        }
        If result.errorCode = "STATUS_ERROR" {
            return ..Error(500, "STATUS_ERROR", result.%Get("statusText"))
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

ClassMethod ReadJsonBody() As %DynamicObject [ Private ]
{
    Set payload = ""
    Try {
        If $IsObject(%request) && $IsObject(%request.Content) {
            Do %request.Content.Rewind()
            Set json = ""
            While '%request.Content.AtEnd {
                Set json = json _ %request.Content.Read(32000)
            }
            If json '= "" {
                Set payload = {}.%FromJSON(json)
            }
        }
    } Catch ex {
        Set payload = ""
    }
    return payload
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
