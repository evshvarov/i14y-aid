/// Discover and explain InterSystems IRIS interoperability productions in the current namespace.<br/>
/// Business logic class defined by OpenAPI in esh.interoperability.aid.api.spec<br/>
/// Updated Jul 15, 2026 08:05:19
Class esh.interoperability.aid.api.impl Extends %REST.Impl [ ProcedureBlock ]
{

Parameter ExposeServerExceptions = 1;

/// Get OpenAPI spec
ClassMethod GetSpec() As %DynamicObject
{
    set specname=$p(..%ClassName(1),".impl")
    Set spec = {}.%FromJSON(##class(%Dictionary.CompiledXData).%OpenId(specname_".spec||OpenAPI").Data)
    Set url = $Select(%request.Secure:"https",1:"http") _ "://"_$Get(%request.CgiEnvs("SERVER_NAME")) _ ":" _ $Get(%request.CgiEnvs("SERVER_PORT")) _ %request.Application
    Set spec.servers = [{"url" : (url)}]
    return spec
}

/// Get module health and capabilities
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

/// Get supported analysis capabilities
ClassMethod Capabilities() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).Capabilities()
}

/// Get module analysis settings
ClassMethod GetSettings() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).GetSettings()
}

/// Update module analysis settings<br/>
/// The method arguments hold values for:<br/>
///     settings<br/>
/// WARNING: This method's signature has changed.
ClassMethod UpdateSettings(settings As %DynamicObject) As %DynamicObject
{
    If '$IsObject(settings) {
        Set settings = ..ReadJsonBody()
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).UpdateSettings(settings)
    return ..HandleSettingsResult(result)
}

/// List interoperability productions in the current namespace
ClassMethod ListProductions() As %DynamicObject
{
    return ##class(esh.interoperability.aid.service.ProductionDiscovery).ListProductions()
}

/// Get production metadata<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProduction(productionName As %String) As %DynamicObject
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

/// List production components<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod ListComponents(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListComponents(productionName)
    return ..HandleProductionResult(result)
}

/// Get production component detail<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     componentName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetComponentDetail(productionName As %String, componentName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetComponentDetail(productionName, componentName)
    return ..HandleProductionResult(result)
}

/// Get static production analysis model<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionAnalysis(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionAnalysis(productionName)
    return ..HandleProductionResult(result)
}

/// Get deterministic production summary<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionSummary(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionSummary(productionName)
    return ..HandleProductionResult(result)
}

/// Get frontend-neutral production graph<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionGraph(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionGraph(productionName)
    return ..HandleProductionResult(result)
}

/// Get production runtime status<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionStatus(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionRuntimeStatus(productionName)
    return ..HandleProductionResult(result)
}

/// Start production<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
/// WARNING: This method's signature has changed.
ClassMethod StartProduction(productionName As %String) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).StartProduction(productionName)
    return ..HandleProductionActionResult(result)
}

/// Stop production<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     timeout<br/>
///     force<br/>
/// WARNING: This method's signature has changed.
ClassMethod StopProduction(productionName As %String, timeout As %Integer = 10, force As %Boolean = 0) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).StopProduction(productionName, timeout, force)
    return ..HandleProductionActionResult(result)
}

/// List recent interoperability message headers<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     limit<br/>
///     offset<br/>
///     sourceConfigName<br/>
///     targetConfigName<br/>
///     messageBodyClassName<br/>
///     sessionId<br/>
///     errorsOnly<br/>
/// WARNING: This method's signature has changed.
ClassMethod ListMessages(productionName As %String, limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %String, targetConfigName As %String, messageBodyClassName As %String, sessionId As %String, errorsOnly As %Boolean = 0) As %DynamicObject
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

/// List recent interoperability message headers for a production<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     limit<br/>
///     offset<br/>
///     sourceConfigName<br/>
///     targetConfigName<br/>
///     messageBodyClassName<br/>
///     sessionId<br/>
///     errorsOnly<br/>
/// WARNING: This method's signature has changed.
ClassMethod ListProductionMessages(productionName As %String, limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %String, targetConfigName As %String, messageBodyClassName As %String, sessionId As %String, errorsOnly As %Boolean = 0) As %DynamicObject
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

/// List recent message filter facets<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     limit<br/>
/// WARNING: This method's signature has changed.
ClassMethod ListMessageFacets(productionName As %String, limit As %Integer = 500) As %DynamicObject
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

/// List recent message filter facets for a production<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     limit<br/>
/// WARNING: This method's signature has changed.
ClassMethod ListProductionMessageFacets(productionName As %String, limit As %Integer = 500) As %DynamicObject
{
    If '$Data(limit) {
        Set limit = 500
    }
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ListMessageFacets(productionName, limit)
    return ..HandleRuntimeResult(result)
}

/// Get message header metadata<br/>
/// The method arguments hold values for:<br/>
///     messageId<br/>
ClassMethod GetMessage(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessage(messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped message header metadata<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionMessage(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessage(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Get safe payload metadata for a message<br/>
/// The method arguments hold values for:<br/>
///     messageId<br/>
ClassMethod GetMessagePayloadMetadata(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessagePayloadMetadata(messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped safe payload metadata for a message<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionMessagePayloadMetadata(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessagePayloadMetadata(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Get safe payload preview for a message<br/>
/// The method arguments hold values for:<br/>
///     messageId<br/>
ClassMethod GetMessagePayloadPreview(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessagePayloadPreview(messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped safe payload preview for a message<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
ClassMethod GetProductionMessagePayloadPreview(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessagePayloadPreview(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Get runtime trace for a message header<br/>
/// The method arguments hold values for:<br/>
///     messageId<br/>
ClassMethod GetMessageTrace(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessageTrace(messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped runtime trace for a message header<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionMessageTrace(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessageTrace(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped message session summary<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionMessageSessionSummary(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetProductionMessageSessionSummary(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Request production-scoped message resend<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod ResendProductionMessage(productionName As %String, messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).ResendProductionMessage(productionName, messageId)
    return ..HandleRuntimeResult(result)
}

/// Get deterministic explanation for a message trace<br/>
/// The method arguments hold values for:<br/>
///     messageId<br/>
ClassMethod GetMessageExplanation(messageId As %Integer) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.service.ProductionDiscovery).GetMessageExplanation(messageId)
    return ..HandleRuntimeResult(result)
}

/// Get production-scoped deterministic explanation for a message trace<br/>
/// The method arguments hold values for:<br/>
///     productionName<br/>
///     messageId<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetProductionMessageExplanation(productionName As %String, messageId As %Integer) As %DynamicObject
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
        If result.errorCode = "RESEND_FAILED" {
            return ..Error(500, "RESEND_FAILED", result.%Get("statusText"))
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
