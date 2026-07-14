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

Method FindConnection(items As %DynamicArray, fromName As %VarString, toName As %VarString, kind As %VarString = "") As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If (item.%Get("from") = fromName) && (item.%Get("to") = toName) {
                If (kind = "") || (item.kind = kind) {
                    Set found = item
                    Quit
                }
            }
        }
    }
    return found
}

Method FindGraphNode(items As %DynamicArray, nodeId As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.id = nodeId {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindGraphEdge(items As %DynamicArray, sourceName As %VarString, targetName As %VarString, kind As %VarString = "") As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If (item.source = sourceName) && (item.target = targetName) {
                If (kind = "") || (item.kind = kind) {
                    Set found = item
                    Quit
                }
            }
        }
    }
    return found
}

Method FindArtifact(items As %DynamicArray, kind As %VarString, name As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If (item.kind = kind) && (item.name = name) {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindRule(items As %DynamicArray, ruleName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = ruleName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindMessageType(items As %DynamicArray, componentName As %VarString, methodName As %VarString, parameterName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If (item.component = componentName) && (item.method = methodName) && (item.parameter = parameterName) {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindParameter(items As %DynamicArray, parameterName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = parameterName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindTransformation(items As %DynamicArray, transformName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = transformName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindBusinessProcess(items As %DynamicArray, processName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = processName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindComponentExplanation(items As %DynamicArray, componentName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.component = componentName {
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
    Do $$$AssertTrue(spec.paths.%IsDefined("/capabilities"), "Spec must expose capabilities endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/settings"), "Spec must expose settings endpoint")
    Do $$$AssertTrue(spec.paths.%Get("/settings").%IsDefined("put"), "Spec must expose settings update endpoint")
    Do $$$AssertEquals(spec.paths.%Get("/settings").put.operationId, "UpdateSettings", "Settings update operationId mismatch")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions"), "Spec must expose /productions")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}"), "Spec must expose production detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/components"), "Spec must expose component endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/components/{componentName}"), "Spec must expose component detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/analysis"), "Spec must expose production analysis endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/summary"), "Spec must expose production summary endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/graph"), "Spec must expose production graph endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/status"), "Spec must expose production status endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/start"), "Spec must expose production start endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/stop"), "Spec must expose production stop endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages"), "Spec must expose production messages endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/facets"), "Spec must expose production message facets endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}"), "Spec must expose production-scoped message detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/payload"), "Spec must expose production-scoped message payload endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/trace"), "Spec must expose production-scoped message trace endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/explanation"), "Spec must expose production-scoped message explanation endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages"), "Spec must expose message header endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/facets"), "Spec must expose message facets endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}"), "Spec must expose message detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/payload"), "Spec must expose message payload metadata endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/trace"), "Spec must expose message trace endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/explanation"), "Spec must expose message explanation endpoint")
    Set messageParameters = spec.paths.%Get("/messages").get.parameters
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "sourceConfigName")), "Spec must expose sourceConfigName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "targetConfigName")), "Spec must expose targetConfigName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "messageBodyClassName")), "Spec must expose messageBodyClassName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "sessionId")), "Spec must expose sessionId filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "errorsOnly")), "Spec must expose errorsOnly filter")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageDetailResponse"), "Spec must define MessageDetailResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessagePayloadMetadataResponse"), "Spec must define MessagePayloadMetadataResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("PayloadMetadata"), "Spec must define PayloadMetadata")
    Do $$$AssertTrue(spec.definitions.MessageDetailResponse.properties.%IsDefined("payloadMetadata"), "Message detail response must expose payloadMetadata")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageFacetResponse"), "Spec must define MessageFacetResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageExplanationResponse"), "Spec must define MessageExplanationResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ComponentDetailResponse"), "Spec must define ComponentDetailResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("CapabilitiesResponse"), "Spec must define CapabilitiesResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionGraphResponse"), "Spec must define ProductionGraphResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("GraphNode"), "Spec must define GraphNode")
    Do $$$AssertTrue(spec.definitions.%IsDefined("GraphEdge"), "Spec must define GraphEdge")
    Do $$$AssertTrue(spec.definitions.%IsDefined("AnalysisSettings"), "Spec must define AnalysisSettings")
    Do $$$AssertTrue(spec.definitions.%IsDefined("SettingsResponse"), "Spec must define SettingsResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("SettingsUpdateResponse"), "Spec must define SettingsUpdateResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("TraceOverview"), "Spec must define TraceOverview")
    Do $$$AssertTrue(spec.definitions.MessageTraceResponse.properties.%IsDefined("traceOverview"), "Trace response must expose traceOverview")
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
    Do $$$AssertEquals(result.capabilities.productionControl, 1, "Production control capability mismatch")
    Do $$$AssertTrue(result.capabilities.%IsDefined("runtimeTraceAnalysis"), "Capabilities must include runtime trace flag")
}

Method TestCapabilities()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).Capabilities()
    Do $$$AssertTrue($IsObject(result), "Capabilities response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Capabilities namespace mismatch")
    Do $$$AssertEquals(result.openapiVersion, "2.0", "Capabilities OpenAPI version mismatch")
    Do $$$AssertTrue(result.%IsDefined("interoperabilityAvailable"), "Capabilities must include interoperabilityAvailable")
    Do $$$AssertTrue(result.%IsDefined("productionDiscovery"), "Capabilities must include productionDiscovery")
    Do $$$AssertTrue(result.%IsDefined("runtimeTraceAnalysis"), "Capabilities must include runtimeTraceAnalysis")
    Do $$$AssertEquals(result.payloadInspection, 0, "Payload inspection capability mismatch")
}

Method TestGetSettings()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetSettings()
    Do $$$AssertTrue($IsObject(result), "Settings response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Settings namespace mismatch")
    Do $$$AssertTrue($IsObject(result.settings), "Settings payload must be an object")
    Do $$$AssertEquals(result.settings.runtimeMessageAnalysisEnabled, 1, "Runtime message analysis default mismatch")
    Do $$$AssertEquals(result.settings.payloadInspectionEnabled, 0, "Payload inspection default mismatch")
    Do $$$AssertEquals(result.settings.maxMessagesReturned, 100, "Max messages default mismatch")
    Do $$$AssertEquals(result.settings.maxTraceDepth, 50, "Max trace depth default mismatch")
    Do $$$AssertTrue($IsObject(result.evidence), "Settings response must include evidence")
}

Method TestUpdateSettings()
{
    Do ..InitRequestResponse()
    Set payload = {"maxTraceDepth":25,"explanationVerbosity":"brief"}
    Set result = ##class(esh.interoperability.aid.api.impl).UpdateSettings(payload)
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Do $$$AssertTrue($IsObject(result), "Settings update response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Settings update namespace mismatch")
    Do $$$AssertEquals(result.changed, 1, "Settings update should report changed")
    Do $$$AssertEquals(result.settings.maxTraceDepth, 25, "Settings maxTraceDepth update mismatch")
    Do $$$AssertEquals(result.settings.explanationVerbosity, "brief", "Settings explanation verbosity update mismatch")
    Do $$$AssertTrue($IsObject(result.warnings), "Settings update must include warnings")
    Do $$$AssertTrue($IsObject(result.evidence), "Settings update must include evidence")
    Do $$$AssertEquals(restored.settings.maxTraceDepth, 50, "Settings restore maxTraceDepth mismatch")
    Do $$$AssertEquals(restored.settings.explanationVerbosity, "normal", "Settings restore explanation verbosity mismatch")
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
    Do $$$AssertTrue($IsObject(production.runtime), "Production summary must include runtime status")
    Do $$$AssertTrue(production.runtime.%IsDefined("stateLabel"), "Production summary runtime status must include state label")
}

Method TestGetProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProduction("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Production response must be an object")
    Do $$$AssertEquals(result.name, "esh.interoperability.aid.tests.DemoProduction", "Production name mismatch")
    Do $$$AssertEquals(result.namespace, $Namespace, "Namespace mismatch")
    Do $$$AssertEquals(result.componentCount, 4, "Component count mismatch")
    Do $$$AssertTrue($IsObject(result.runtime), "Production detail must include runtime status")
    Do $$$AssertTrue(result.runtime.%IsDefined("isRunning"), "Production detail runtime status must include isRunning")
    Do $$$AssertTrue($IsObject(result.evidence), "Evidence must be an array")
}

Method TestGetProductionStatus()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionStatus("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Runtime status response must be an object")
    Do $$$AssertEquals(result.name, "esh.interoperability.aid.tests.DemoProduction", "Runtime status production name mismatch")
    Do $$$AssertTrue($IsObject(result.runtime), "Runtime status must include runtime object")
    Do $$$AssertTrue(result.runtime.%IsDefined("state"), "Runtime status must include raw state")
    Do $$$AssertTrue(result.runtime.%IsDefined("stateLabel"), "Runtime status must include state label")
}

Method TestListMessages()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListMessages("", 5, 0)
    Do $$$AssertTrue($IsObject(result), "Message list response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Message list namespace mismatch")
    Do $$$AssertTrue($IsObject(result.items), "Message list items must be an array")
    Do $$$AssertEquals(result.limit, 5, "Message list limit mismatch")
    Do $$$AssertEquals(result.offset, 0, "Message list offset mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Message list must not return payloads")
    Do $$$AssertEquals(result.runtimeMessageAnalysisEnabled, 1, "Message list must include runtime analysis flag")
    Do $$$AssertEquals(result.maxMessagesReturned, 100, "Message list must include configured max")
    Do $$$AssertTrue(result.%IsDefined("hasMore"), "Message list must include hasMore")
    Set capped = ##class(esh.interoperability.aid.api.impl).ListMessages("", 500, 0)
    Do $$$AssertEquals(capped.limit, 100, "Message list limit should be capped by settings")
    Set filtered = ##class(esh.interoperability.aid.api.impl).ListMessages("", 5, 0, "Source", "Target", "Body.Class", "123", 1)
    Do $$$AssertEquals(filtered.sourceConfigName, "Source", "Message source filter mismatch")
    Do $$$AssertEquals(filtered.targetConfigName, "Target", "Message target filter mismatch")
    Do $$$AssertEquals(filtered.messageBodyClassName, "Body.Class", "Message body class filter mismatch")
    Do $$$AssertEquals(filtered.sessionId, "123", "Message session filter mismatch")
    Do $$$AssertEquals(filtered.errorsOnly, 1, "Message errorsOnly filter mismatch")
}

Method TestListMessagesForProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListMessages("esh.interoperability.aid.tests.DemoProduction", 5, 0)
    Do $$$AssertTrue($IsObject(result), "Production message list response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production message list name mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Production message list must not return payloads")
}

Method TestListProductionMessages()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductionMessages("esh.interoperability.aid.tests.DemoProduction", 5, 0)
    Do $$$AssertTrue($IsObject(result), "Production-scoped message list response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production-scoped message list name mismatch")
    Do $$$AssertEquals(result.limit, 5, "Production-scoped message list limit mismatch")
    Do $$$AssertEquals(result.offset, 0, "Production-scoped message list offset mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Production-scoped message list must not return payloads")
}

Method TestListMessageFacets()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListMessageFacets("esh.interoperability.aid.tests.DemoProduction", 25)
    Do $$$AssertTrue($IsObject(result), "Message facets response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Message facets production mismatch")
    Do $$$AssertEquals(result.limit, 25, "Message facets limit mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Message facets must not return payloads")
    Do $$$AssertEquals(result.runtimeMessageAnalysisEnabled, 1, "Message facets must include runtime analysis flag")
    Do $$$AssertEquals(result.maxMessagesReturned, 100, "Message facets must include configured max")
    Do $$$AssertTrue($IsObject(result.sourceConfigNames), "Message facets must include source names")
    Do $$$AssertTrue($IsObject(result.targetConfigNames), "Message facets must include target names")
    Do $$$AssertTrue($IsObject(result.messageBodyClassNames), "Message facets must include body classes")
    Do $$$AssertTrue($IsObject(result.sessionIds), "Message facets must include session ids")
    Do $$$AssertTrue($IsObject(result.componentNames), "Message facets must include component names")
}

Method TestListProductionMessageFacets()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductionMessageFacets("esh.interoperability.aid.tests.DemoProduction", 25)
    Do $$$AssertTrue($IsObject(result), "Production-scoped message facets response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production-scoped message facets production mismatch")
    Do $$$AssertEquals(result.limit, 25, "Production-scoped message facets limit mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Production-scoped message facets must not return payloads")
    Do $$$AssertTrue($IsObject(result.sourceConfigNames), "Production-scoped message facets must include source names")
    Do $$$AssertTrue($IsObject(result.targetConfigNames), "Production-scoped message facets must include target names")
    Do $$$AssertTrue($IsObject(result.messageBodyClassNames), "Production-scoped message facets must include body classes")
    Do $$$AssertTrue($IsObject(result.sessionIds), "Production-scoped message facets must include session ids")
    Do $$$AssertTrue($IsObject(result.componentNames), "Production-scoped message facets must include component names")
}

Method TestGetMessageTraceInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessageTrace(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message trace response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message id error code mismatch")
}

Method TestGetMessageExplanationInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessageExplanation(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message explanation response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message explanation id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message explanation error code mismatch")
}

Method TestGetMessagePayloadMetadataInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessagePayloadMetadata(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message payload metadata response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message payload metadata id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message payload metadata error code mismatch")
}

Method TestGetMessageInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessage(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message id error code mismatch")
}

Method TestGetProductionMessageInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessage("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message id error code mismatch")
}

Method TestGetProductionMessagePayloadMetadataInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessagePayloadMetadata("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message payload response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message payload id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message payload id error code mismatch")
}

Method TestGetProductionMessageTraceInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageTrace("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message trace response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message trace id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message trace id error code mismatch")
}

Method TestGetProductionMessageExplanationInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageExplanation("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message explanation response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message explanation id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message explanation id error code mismatch")
}

Method TestGetProductionAnalysis()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionAnalysis("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Analysis response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Analysis production name mismatch")
    Do $$$AssertTrue($IsObject(result.production), "Analysis must include production detail")
    Do $$$AssertEquals(result.components.%Size(), 4, "Analysis component count mismatch")
    Do $$$AssertEquals(result.connections.%Size(), 5, "Analysis connection count mismatch")
    Do $$$AssertTrue($IsObject(..FindConnection(result.connections, "CSV Patient Service", "Patient Router")), "Service to router connection should be present")
    Do $$$AssertTrue($IsObject(..FindConnection(result.connections, "Patient Router", "FHIR Operation")), "Router to FHIR connection should be present")
    Do $$$AssertTrue($IsObject(..FindConnection(result.connections, "Patient Router", "Notification Operation")), "Router to notification connection should be present")
    Set ruleConnection = ..FindConnection(result.connections, "Patient Router", "FHIR Operation", "routing-rule")
    Do $$$AssertTrue($IsObject(ruleConnection), "Routing rule connection should be present")
    Do $$$AssertEquals(ruleConnection.ruleName, "esh.interoperability.aid.tests.DemoRoutingRule", "Routing rule connection rule name mismatch")
    Set bplConnection = ..FindConnection(result.connections, "Patient Router", "FHIR Operation", "bpl-call")
    Do $$$AssertTrue($IsObject(bplConnection), "BPL call connection should be present")
    If $IsObject(bplConnection) {
        Do $$$AssertEquals(bplConnection.processClass, "esh.interoperability.aid.tests.DemoProcess", "BPL call connection process class mismatch")
    }
    Do $$$AssertEquals(result.externalSystems.%Size(), 2, "Analysis external endpoint count mismatch")
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "routing-rule", "esh.interoperability.aid.tests.DemoRoutingRule")), "Routing rule artifact should be present")
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "rule-transformation", "esh.interoperability.aid.tests.DemoTransform")), "Rule transform artifact should be present")
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "bpl-process", "esh.interoperability.aid.tests.DemoProcess")), "BPL artifact should be present")
    Do $$$AssertEquals(result.componentExplanations.%Size(), 4, "Analysis component explanation count mismatch")
    Set serviceExplanation = ..FindComponentExplanation(result.componentExplanations, "CSV Patient Service")
    Do $$$AssertTrue($IsObject(serviceExplanation), "Service explanation should be present")
    If $IsObject(serviceExplanation) {
        Do $$$AssertTrue(serviceExplanation.text["business service", "Service explanation should mention type")
        Do $$$AssertTrue(serviceExplanation.text["Patient Router", "Service explanation should mention target")
    }
    Set routerExplanation = ..FindComponentExplanation(result.componentExplanations, "Patient Router")
    Do $$$AssertTrue($IsObject(routerExplanation), "Router explanation should be present")
    If $IsObject(routerExplanation) {
        Do $$$AssertTrue(routerExplanation.text["esh.interoperability.aid.tests.DemoRoutingRule", "Router explanation should mention routing rule")
        Do $$$AssertTrue(routerExplanation.text["esh.interoperability.aid.tests.DemoTransform", "Router explanation should mention transformation")
        Do $$$AssertTrue(routerExplanation.text["esh.interoperability.aid.tests.DemoProcess", "Router explanation should mention BPL process")
    }
    Do $$$AssertEquals(result.rules.%Size(), 1, "Analysis rule count mismatch")
    Set rule = ..FindRule(result.rules, "esh.interoperability.aid.tests.DemoRoutingRule")
    Do $$$AssertTrue($IsObject(rule), "Rule detail should be present")
    Do $$$AssertEquals(rule.component, "Patient Router", "Rule component mismatch")
    Do $$$AssertEquals(rule.conditions.%Size(), 1, "Rule condition count mismatch")
    Set condition = rule.conditions.%Get(0)
    Do $$$AssertEquals(condition.condition, "1", "Rule condition mismatch")
    Do $$$AssertEquals(condition.sends.%Size(), 1, "Rule condition send count mismatch")
    Set send = condition.sends.%Get(0)
    Do $$$AssertEquals(send.target, "FHIR Operation", "Rule send target mismatch")
    Do $$$AssertEquals(send.transform, "esh.interoperability.aid.tests.DemoTransform", "Rule send transform mismatch")
    Do $$$AssertEquals(result.transformations.%Size(), 1, "Analysis transformation count mismatch")
    Set transformation = ..FindTransformation(result.transformations, "esh.interoperability.aid.tests.DemoTransform")
    Do $$$AssertTrue($IsObject(transformation), "Transformation detail should be present")
    If $IsObject(transformation) {
        Do $$$AssertEquals(transformation.component, "Patient Router", "Transformation component mismatch")
        Do $$$AssertEquals(transformation.sourceClass, "esh.interoperability.aid.tests.DemoMessage", "Transformation source class mismatch")
        Do $$$AssertEquals(transformation.targetClass, "esh.interoperability.aid.tests.DemoMessage", "Transformation target class mismatch")
        Do $$$AssertEquals(transformation.actions.assign, 2, "Transformation assignment count mismatch")
        Do $$$AssertEquals(transformation.assignments.%Size(), 2, "Transformation assignments size mismatch")
        Set assignment = transformation.assignments.%Get(0)
        Do $$$AssertEquals(assignment.property, "target.EventType", "Transformation first assignment target mismatch")
        Do $$$AssertEquals(assignment.value, "source.EventType", "Transformation first assignment value mismatch")
    }
    Do $$$AssertEquals(result.businessProcesses.%Size(), 1, "Analysis BPL process count mismatch")
    Set bplProcess = ..FindBusinessProcess(result.businessProcesses, "esh.interoperability.aid.tests.DemoProcess")
    Do $$$AssertTrue($IsObject(bplProcess), "BPL process detail should be present")
    If $IsObject(bplProcess) {
        Do $$$AssertEquals(bplProcess.component, "Patient Router", "BPL process component mismatch")
        Do $$$AssertEquals(bplProcess.requestClass, "esh.interoperability.aid.tests.DemoMessage", "BPL request class mismatch")
        Do $$$AssertEquals(bplProcess.responseClass, "esh.interoperability.aid.tests.DemoMessage", "BPL response class mismatch")
        Do $$$AssertEquals(bplProcess.actions.call, 1, "BPL call count mismatch")
        Do $$$AssertEquals(bplProcess.actions.sync, 1, "BPL sync count mismatch")
        Do $$$AssertEquals(bplProcess.actions.assign, 2, "BPL assign count mismatch")
        Do $$$AssertEquals(bplProcess.calls.%Size(), 1, "BPL call detail count mismatch")
        Set call = bplProcess.calls.%Get(0)
        Do $$$AssertEquals(call.name, "SendToFHIR", "BPL call name mismatch")
        Do $$$AssertEquals(call.target, "FHIR Operation", "BPL call target mismatch")
    }
    Do $$$AssertTrue(result.messageTypes.%Size() > 0, "Analysis message types should be present")
    Set serviceInput = ..FindMessageType(result.messageTypes, "CSV Patient Service", "OnProcessInput", "pInput")
    Do $$$AssertTrue($IsObject(serviceInput), "Service input message type should be present")
    If $IsObject(serviceInput) {
        Do $$$AssertEquals(serviceInput.direction, "input", "Service input message direction mismatch")
        Do $$$AssertEquals(serviceInput.messageClass, "%RegisteredObject", "Service input message class mismatch")
    }
    Set processResponse = ..FindMessageType(result.messageTypes, "Patient Router", "OnRequest", "pResponse")
    Do $$$AssertTrue($IsObject(processResponse), "Process response message type should be present")
    If $IsObject(processResponse) {
        Do $$$AssertEquals(processResponse.direction, "output", "Process response message direction mismatch")
        Do $$$AssertEquals(processResponse.messageClass, "%Persistent", "Process response message class mismatch")
    }
    Set operationInput = ..FindMessageType(result.messageTypes, "FHIR Operation", "OnMessage", "pRequest")
    Do $$$AssertTrue($IsObject(operationInput), "Operation input message type should be present")
    If $IsObject(operationInput) {
        Do $$$AssertEquals(operationInput.direction, "input", "Operation input message direction mismatch")
    }
    Set hasServiceText = result.summary["business service"
    Do $$$AssertTrue(hasServiceText, "Analysis summary should describe services")
    Set hasMessageText = result.summary["message signature"
    Do $$$AssertTrue(hasMessageText, "Analysis summary should describe message signatures")
    Set hasTransformText = result.summary["transformation definition"
    Do $$$AssertTrue(hasTransformText, "Analysis summary should describe transformations")
    Set hasBPLText = result.summary["BPL process definition"
    Do $$$AssertTrue(hasBPLText, "Analysis summary should describe BPL processes")
}

Method TestGetProductionSummary()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionSummary("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Summary response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Summary production name mismatch")
    Set hasConnectionText = result.summary["target connection"
    Do $$$AssertTrue(hasConnectionText, "Summary should mention target connections")
    Do $$$AssertEquals(result.confidence, "confirmed", "Summary confidence mismatch")
}

Method TestGetProductionGraph()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionGraph("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Graph response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Graph production name mismatch")
    Do $$$AssertEquals(result.nodes.%Size(), 4, "Graph node count mismatch")
    Do $$$AssertEquals(result.edges.%Size(), 5, "Graph edge count mismatch")
    Set node = ..FindGraphNode(result.nodes, "Patient Router")
    Do $$$AssertTrue($IsObject(node), "Graph should include Patient Router node")
    If $IsObject(node) {
        Do $$$AssertEquals(node.type, "business-process", "Graph node type mismatch")
        Do $$$AssertEquals(node.label, "Patient Router", "Graph node label mismatch")
    }
    Set edge = ..FindGraphEdge(result.edges, "Patient Router", "FHIR Operation", "routing-rule")
    Do $$$AssertTrue($IsObject(edge), "Graph should include routing-rule edge")
    If $IsObject(edge) {
        Do $$$AssertEquals(edge.relationship, "sends", "Graph edge relationship mismatch")
        Do $$$AssertEquals(edge.ruleName, "esh.interoperability.aid.tests.DemoRoutingRule", "Graph edge rule mismatch")
        Do $$$AssertTrue($IsObject(edge.messageTypes), "Graph edge should include messageTypes")
    }
    Do $$$AssertEquals(result.confidence, "confirmed", "Graph confidence mismatch")
}

Method TestStartProductionInvalidName()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).StartProduction("bad production name")
    Do $$$AssertTrue($IsObject(result), "Start error response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid start name should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_PRODUCTION_NAME", "Invalid start error code mismatch")
}

Method TestStopProductionMissingProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).StopProduction("esh.interoperability.aid.tests.DoesNotExist")
    Do $$$AssertTrue($IsObject(result), "Stop error response must be an object")
    Do $$$AssertEquals(%response.Status, 404, "Missing stop production should set 404")
    Do $$$AssertEquals(result.error.code, "PRODUCTION_NOT_FOUND", "Missing stop production error code mismatch")
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

Method TestGetComponentDetail()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetComponentDetail("esh.interoperability.aid.tests.DemoProduction", "Patient Router")
    Do $$$AssertTrue($IsObject(result), "Component detail response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Component detail production mismatch")
    Do $$$AssertEquals(result.componentName, "Patient Router", "Component detail name mismatch")
    Do $$$AssertTrue($IsObject(result.component), "Component detail must include component")
    Do $$$AssertEquals(result.component.type, "business-process", "Component detail type mismatch")
    Do $$$AssertTrue($IsObject(result.explanation), "Component detail must include explanation")
    Do $$$AssertTrue(result.explanation.text["esh.interoperability.aid.tests.DemoRoutingRule", "Component detail explanation should mention rule")
    Do $$$AssertTrue(result.connections.%Size() > 0, "Component detail should include related connections")
    Do $$$AssertEquals(result.rules.%Size(), 1, "Component detail rule count mismatch")
    Do $$$AssertEquals(result.transformations.%Size(), 1, "Component detail transformation count mismatch")
    Do $$$AssertEquals(result.businessProcesses.%Size(), 1, "Component detail BPL count mismatch")
    Do $$$AssertTrue(result.messageTypes.%Size() > 0, "Component detail should include message signatures")
    Do $$$AssertTrue($IsObject(result.evidence), "Component detail must include evidence")
}

Method TestGetComponentDetailMissingComponent()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetComponentDetail("esh.interoperability.aid.tests.DemoProduction", "Missing Component")
    Do $$$AssertTrue($IsObject(result), "Missing component response must be an object")
    Do $$$AssertEquals(%response.Status, 404, "Missing component should set 404")
    Do $$$AssertEquals(result.error.code, "COMPONENT_NOT_FOUND", "Missing component error code mismatch")
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
