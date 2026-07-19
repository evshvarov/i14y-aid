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

Method FindConnectionExplanation(items As %DynamicArray, fromName As %VarString, toName As %VarString, kind As %VarString = "") As %DynamicObject [ Private ]
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

Method FindMessageTypeExplanation(items As %DynamicArray, componentName As %VarString, methodName As %VarString, parameterName As %VarString) As %DynamicObject [ Private ]
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

Method FindExternalSystemExplanation(items As %DynamicArray, componentName As %VarString, kind As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If (item.component = componentName) && (item.kind = kind) {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindTransformationExplanation(items As %DynamicArray, transformName As %VarString) As %DynamicObject [ Private ]
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

Method FindArtifactExplanation(items As %DynamicArray, kind As %VarString, name As %VarString) As %DynamicObject [ Private ]
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

Method FindRuleExplanation(items As %DynamicArray, ruleName As %VarString) As %DynamicObject [ Private ]
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

Method FindPayloadPreviewField(items As %DynamicArray, fieldName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.name = fieldName {
                Set found = item
                Quit
            }
        }
    }
    return found
}

Method FindWarning(items As %DynamicArray, warningCode As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        If $IsObject(item) {
            If item.code = warningCode {
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

Method FindBusinessProcessExplanation(items As %DynamicArray, processName As %VarString) As %DynamicObject [ Private ]
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

Method CreatePayloadPreviewMessage() As %DynamicObject [ Private ]
{
    return ..CreateRuntimeMessage("CSV Patient Service", "Patient Router")
}

Method CreateRuntimeMessage(sourceConfigName As %VarString, targetConfigName As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set body = ##class(esh.interoperability.aid.tests.DemoMessage).%New()
    Set body.EventType = "ADT"
    Set body.PatientId = "MRN123"
    Set sc = body.%Save()
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "BODY_SAVE_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }

    Set header = ##class(Ens.MessageHeader).%New()
    Set header.SessionId = $Random(1000000)+1000000
    Set header.SourceConfigName = sourceConfigName
    Set header.TargetConfigName = targetConfigName
    Set header.MessageBodyClassName = "esh.interoperability.aid.tests.DemoMessage"
    Set header.MessageBodyId = body.%Id()
    Set header.Status = 1
    Set header.Type = 1
    Set header.Invocation = 1
    Set header.TimeCreated = $ZDATETIME($HOROLOG, 3)
    Set header.TimeProcessed = $ZDATETIME($HOROLOG, 3)
    Set sc = header.%Save()
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "HEADER_SAVE_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }

    Set result.messageId = header.%Id()
    Set result.bodyId = body.%Id()
    return result
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
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionListMetrics"), "Spec must define ProductionListMetrics")
    Do $$$AssertTrue(spec.definitions.ProductionListResponse.properties.%IsDefined("metrics"), "Production list response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionListMetrics.properties.%IsDefined("runningProductionCount"), "ProductionListMetrics must expose runningProductionCount")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}"), "Spec must expose production detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/components"), "Spec must expose component endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/components/{componentName}"), "Spec must expose component detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/analysis"), "Spec must expose production analysis endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/summary"), "Spec must expose production summary endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/graph"), "Spec must expose production graph endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/status"), "Spec must expose production status endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/start"), "Spec must expose production start endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/stop"), "Spec must expose production stop endpoint")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionRuntimeMetrics"), "Spec must define ProductionRuntimeMetrics")
    Do $$$AssertTrue(spec.definitions.ProductionRuntimeResponse.properties.%IsDefined("metrics"), "Production runtime response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionActionResponse.properties.%IsDefined("metrics"), "Production action response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionSummary.properties.%IsDefined("runtimeMetrics"), "Production summary must expose runtimeMetrics")
    Do $$$AssertTrue(spec.definitions.ProductionDetailResponse.properties.%IsDefined("runtimeMetrics"), "Production detail must expose runtimeMetrics")
    Do $$$AssertTrue(spec.definitions.ProductionRuntimeMetrics.properties.%IsDefined("hasActiveProduction"), "ProductionRuntimeMetrics must expose hasActiveProduction")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages"), "Spec must expose production messages endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/facets"), "Spec must expose production message facets endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/logs"), "Spec must expose production logs endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/logs"), "Spec must expose production-scoped logs endpoint")
    Do $$$AssertEquals(spec.paths.%Get("/productions/{productionName}/logs").get.operationId, "ListProductionLogs", "Production logs operationId mismatch")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionLogListResponse"), "Spec must define ProductionLogListResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionLogEntry"), "Spec must define ProductionLogEntry")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionLogMetrics"), "Spec must define ProductionLogMetrics")
    Do $$$AssertTrue(spec.definitions.ProductionLogListResponse.properties.%IsDefined("metrics"), "Production log list response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionLogMetrics.properties.%IsDefined("typeFacetCount"), "ProductionLogMetrics must expose typeFacetCount")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}"), "Spec must expose production-scoped message detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/payload"), "Spec must expose production-scoped message payload endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/payload/preview"), "Spec must expose production-scoped message payload preview endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/trace"), "Spec must expose production-scoped message trace endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/session"), "Spec must expose production-scoped message session summary endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/resend"), "Spec must expose production-scoped message resend endpoint")
    Do $$$AssertEquals(spec.paths.%Get("/productions/{productionName}/messages/{messageId}/resend").post.operationId, "ResendProductionMessage", "Message resend operationId mismatch")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/messages/{messageId}/explanation"), "Spec must expose production-scoped message explanation endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages"), "Spec must expose message header endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/facets"), "Spec must expose message facets endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}"), "Spec must expose message detail endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/payload"), "Spec must expose message payload metadata endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/payload/preview"), "Spec must expose message payload preview endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/trace"), "Spec must expose message trace endpoint")
    Do $$$AssertTrue(spec.paths.%IsDefined("/messages/{messageId}/explanation"), "Spec must expose message explanation endpoint")
    Set messageParameters = spec.paths.%Get("/messages").get.parameters
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "sourceConfigName")), "Spec must expose sourceConfigName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "targetConfigName")), "Spec must expose targetConfigName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "messageBodyClassName")), "Spec must expose messageBodyClassName filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "sessionId")), "Spec must expose sessionId filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "errorsOnly")), "Spec must expose errorsOnly filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "startDate")), "Spec must expose message startDate filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageParameters, "endDate")), "Spec must expose message endDate filter")
    Set messageFacetParameters = spec.paths.%Get("/messages/facets").get.parameters
    Do $$$AssertTrue($IsObject(..FindParameter(messageFacetParameters, "startDate")), "Spec must expose message facets startDate filter")
    Do $$$AssertTrue($IsObject(..FindParameter(messageFacetParameters, "endDate")), "Spec must expose message facets endDate filter")
    Set logParameters = spec.paths.%Get("/logs").get.parameters
    Do $$$AssertTrue($IsObject(..FindParameter(logParameters, "startDate")), "Spec must expose logs startDate filter")
    Do $$$AssertTrue($IsObject(..FindParameter(logParameters, "endDate")), "Spec must expose logs endDate filter")
    Set productionLogParameters = spec.paths.%Get("/productions/{productionName}/logs").get.parameters
    Do $$$AssertTrue($IsObject(..FindParameter(productionLogParameters, "startDate")), "Spec must expose production logs startDate filter")
    Do $$$AssertTrue($IsObject(..FindParameter(productionLogParameters, "endDate")), "Spec must expose production logs endDate filter")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageDetailResponse"), "Spec must define MessageDetailResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessagePayloadMetadataResponse"), "Spec must define MessagePayloadMetadataResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessagePayloadPreviewResponse"), "Spec must define MessagePayloadPreviewResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("PayloadPreviewField"), "Spec must define PayloadPreviewField")
    Do $$$AssertTrue(spec.definitions.%IsDefined("PayloadMetadata"), "Spec must define PayloadMetadata")
    Do $$$AssertTrue(spec.definitions.%IsDefined("PayloadMetrics"), "Spec must define PayloadMetrics")
    Do $$$AssertTrue(spec.definitions.MessagePayloadMetadataResponse.properties.%IsDefined("metrics"), "Payload metadata response must expose metrics")
    Do $$$AssertTrue(spec.definitions.MessagePayloadPreviewResponse.properties.%IsDefined("metrics"), "Payload preview response must expose metrics")
    Do $$$AssertTrue(spec.definitions.PayloadMetadata.properties.%IsDefined("metrics"), "PayloadMetadata must expose metrics")
    Do $$$AssertTrue(spec.definitions.MessageDetailResponse.properties.%IsDefined("payloadMetadata"), "Message detail response must expose payloadMetadata")
    Do $$$AssertTrue(spec.definitions.MessageDetailResponse.properties.%IsDefined("metrics"), "Message detail response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageDetailMetrics"), "Spec must define MessageDetailMetrics")
    Do $$$AssertTrue(spec.definitions.MessageDetailMetrics.properties.%IsDefined("payloadEvidenceCount"), "MessageDetailMetrics must expose payloadEvidenceCount")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageFacetResponse"), "Spec must define MessageFacetResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageListMetrics"), "Spec must define MessageListMetrics")
    Do $$$AssertTrue(spec.definitions.MessageHeaderListResponse.properties.%IsDefined("metrics"), "Message list response must expose metrics")
    Do $$$AssertTrue(spec.definitions.MessageFacetResponse.properties.%IsDefined("metrics"), "Message facets response must expose metrics")
    Do $$$AssertTrue(spec.definitions.MessageListMetrics.properties.%IsDefined("errorCount"), "MessageListMetrics must expose errorCount")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageSessionSummaryResponse"), "Spec must define MessageSessionSummaryResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageResendResponse"), "Spec must define MessageResendResponse")
    Do $$$AssertTrue(spec.definitions.MessageResendResponse.properties.%IsDefined("statusText"), "Message resend response must expose statusText")
    Do $$$AssertTrue(spec.definitions.MessageResendResponse.properties.%IsDefined("metrics"), "Message resend response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("RuntimeActionMetrics"), "Spec must define RuntimeActionMetrics")
    Do $$$AssertTrue(spec.definitions.RuntimeActionMetrics.properties.%IsDefined("evidenceCount"), "RuntimeActionMetrics must expose evidenceCount")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageExplanationResponse"), "Spec must define MessageExplanationResponse")
    Do $$$AssertTrue(spec.definitions.MessageExplanationResponse.properties.%IsDefined("metrics"), "Message explanation response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ComponentDetailResponse"), "Spec must define ComponentDetailResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ComponentListMetrics"), "Spec must define ComponentListMetrics")
    Do $$$AssertTrue(spec.definitions.ComponentListResponse.properties.%IsDefined("metrics"), "Component list response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ComponentListMetrics.properties.%IsDefined("disabledComponentCount"), "ComponentListMetrics must expose disabledComponentCount")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("summaryBullets"), "Component detail must expose summary bullets")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("metrics"), "Component detail must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ComponentMetrics"), "Spec must define ComponentMetrics")
    Do $$$AssertTrue(spec.definitions.ComponentMetrics.properties.%IsDefined("evidenceCount"), "ComponentMetrics must expose evidenceCount")
    Do $$$AssertTrue(spec.definitions.ComponentMetrics.properties.%IsDefined("confirmedEvidenceCount"), "ComponentMetrics must expose confirmedEvidenceCount")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("connectionExplanations"), "Component detail must expose connection explanations")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("artifactExplanations"), "Component detail must expose artifact explanations")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("ruleExplanations"), "Component detail must expose rule explanations")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("messageTypeExplanations"), "Component detail must expose message type explanations")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("transformationExplanations"), "Component detail must expose transformation explanations")
    Do $$$AssertTrue(spec.definitions.ComponentDetailResponse.properties.%IsDefined("businessProcessExplanations"), "Component detail must expose business process explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("CapabilitiesResponse"), "Spec must define CapabilitiesResponse")
    Do $$$AssertTrue(spec.definitions.CapabilitiesResponse.properties.%IsDefined("productionLogs"), "Capabilities must expose productionLogs")
    Do $$$AssertEquals(spec.definitions.HealthResponse.properties.capabilities.%Get("$ref"), "#/definitions/CapabilitiesResponse", "Health capabilities must reference CapabilitiesResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ArtifactExplanation"), "Spec must define ArtifactExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("summaryBullets"), "Analysis response must expose summary bullets")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("metrics"), "Analysis response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionMetrics"), "Spec must define ProductionMetrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("AnalysisCoverage"), "Spec must define AnalysisCoverage")
    Do $$$AssertTrue(spec.definitions.AnalysisCoverage.properties.%IsDefined("routingRuleAnalysisAvailable"), "AnalysisCoverage must expose routingRuleAnalysisAvailable")
    Do $$$AssertTrue(spec.definitions.AnalysisCoverage.properties.%IsDefined("evidenceCount"), "AnalysisCoverage must expose evidenceCount")
    Do $$$AssertTrue(spec.definitions.AnalysisCoverage.properties.%IsDefined("confirmedEvidenceCount"), "AnalysisCoverage must expose confirmedEvidenceCount")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("analysisCoverage"), "Analysis response must expose analysis coverage")
    Do $$$AssertTrue(spec.definitions.ProductionDetailResponse.properties.%IsDefined("summary"), "Production detail must expose summary")
    Do $$$AssertTrue(spec.definitions.ProductionDetailResponse.properties.%IsDefined("summaryBullets"), "Production detail must expose summary bullets")
    Do $$$AssertTrue(spec.definitions.ProductionDetailResponse.properties.%IsDefined("metrics"), "Production detail must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionSummaryResponse.properties.%IsDefined("summaryBullets"), "Summary response must expose summary bullets")
    Do $$$AssertTrue(spec.definitions.ProductionSummaryResponse.properties.%IsDefined("metrics"), "Summary response must expose metrics")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("artifactExplanations"), "Analysis response must expose artifact explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ConnectionExplanation"), "Spec must define ConnectionExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("connectionExplanations"), "Analysis response must expose connection explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("RuleExplanation"), "Spec must define RuleExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("ruleExplanations"), "Analysis response must expose rule explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("MessageTypeExplanation"), "Spec must define MessageTypeExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("messageTypeExplanations"), "Analysis response must expose message type explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ExternalSystemExplanation"), "Spec must define ExternalSystemExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("externalSystemExplanations"), "Analysis response must expose external system explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("TransformationExplanation"), "Spec must define TransformationExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("transformationExplanations"), "Analysis response must expose transformation explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("BusinessProcessExplanation"), "Spec must define BusinessProcessExplanation")
    Do $$$AssertTrue(spec.definitions.ProductionAnalysisResponse.properties.%IsDefined("businessProcessExplanations"), "Analysis response must expose business process explanations")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionGraphResponse"), "Spec must define ProductionGraphResponse")
    Do $$$AssertTrue(spec.definitions.ProductionGraphResponse.properties.%IsDefined("summaryBullets"), "Graph response must expose summary bullets")
    Do $$$AssertTrue(spec.definitions.ProductionGraphResponse.properties.%IsDefined("metrics"), "Graph response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("GraphMetrics"), "Spec must define GraphMetrics")
    Do $$$AssertTrue(spec.definitions.GraphMetrics.properties.%IsDefined("evidenceCount"), "GraphMetrics must expose evidenceCount")
    Do $$$AssertTrue(spec.definitions.GraphMetrics.properties.%IsDefined("confirmedEvidenceCount"), "GraphMetrics must expose confirmedEvidenceCount")
    Do $$$AssertTrue(spec.definitions.%IsDefined("GraphNode"), "Spec must define GraphNode")
    Do $$$AssertTrue(spec.definitions.GraphNode.properties.%IsDefined("text"), "Graph node must expose explanation text")
    Do $$$AssertTrue(spec.definitions.%IsDefined("GraphEdge"), "Spec must define GraphEdge")
    Do $$$AssertTrue(spec.definitions.GraphEdge.properties.%IsDefined("text"), "Graph edge must expose explanation text")
    Do $$$AssertTrue(spec.paths.%IsDefined("/productions/{productionName}/ai/summary"), "Spec must expose AI summary endpoint")
    Do $$$AssertEquals(spec.paths.%Get("/productions/{productionName}/ai/summary").post.operationId, "GetProductionAISummary", "AI summary operationId mismatch")
    Do $$$AssertTrue(spec.definitions.%IsDefined("ProductionAISummaryResponse"), "Spec must define ProductionAISummaryResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("AnalysisSettings"), "Spec must define AnalysisSettings")
    Do $$$AssertTrue(spec.definitions.AnalysisSettings.properties.%IsDefined("messageResendEnabled"), "Spec settings must expose messageResendEnabled")
    Do $$$AssertTrue(spec.definitions.AnalysisSettings.properties.%IsDefined("aiSummaryEnabled"), "Spec settings must expose aiSummaryEnabled")
    Do $$$AssertTrue(spec.definitions.AnalysisSettings.properties.%IsDefined("aiApiKeyConfigured"), "Spec settings must expose AI key status")
    Do $$$AssertTrue(spec.definitions.AnalysisSettings.properties.%IsDefined("openAIApiKey"), "Spec settings must accept write-only OpenAI key")
    Do $$$AssertTrue(spec.definitions.%IsDefined("SettingsResponse"), "Spec must define SettingsResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("SettingsUpdateResponse"), "Spec must define SettingsUpdateResponse")
    Do $$$AssertTrue(spec.definitions.%IsDefined("SettingsMetrics"), "Spec must define SettingsMetrics")
    Do $$$AssertTrue(spec.definitions.SettingsResponse.properties.%IsDefined("metrics"), "Settings response must expose metrics")
    Do $$$AssertTrue(spec.definitions.SettingsUpdateResponse.properties.%IsDefined("metrics"), "Settings update response must expose metrics")
    Do $$$AssertTrue(spec.definitions.SettingsMetrics.properties.%IsDefined("enabledFeatureFlagCount"), "SettingsMetrics must expose enabledFeatureFlagCount")
    Do $$$AssertTrue(spec.definitions.%IsDefined("TraceOverview"), "Spec must define TraceOverview")
    Do $$$AssertTrue(spec.definitions.%IsDefined("TraceStaticContext"), "Spec must define TraceStaticContext")
    Do $$$AssertTrue(spec.definitions.MessageTraceResponse.properties.%IsDefined("traceOverview"), "Trace response must expose traceOverview")
    Do $$$AssertTrue(spec.definitions.MessageTraceResponse.properties.%IsDefined("metrics"), "Trace response must expose metrics")
    Do $$$AssertTrue(spec.definitions.%IsDefined("TraceMetrics"), "Spec must define TraceMetrics")
    Do $$$AssertTrue(spec.definitions.TraceMetrics.properties.%IsDefined("evidenceCount"), "TraceMetrics must expose evidenceCount")
    Do $$$AssertTrue(spec.definitions.MessageTraceResponse.properties.%IsDefined("productionStepCount"), "Trace response must expose productionStepCount")
    Do $$$AssertTrue(spec.definitions.MessageSessionSummaryResponse.properties.%IsDefined("staticContext"), "Session summary must expose static context")
    Do $$$AssertTrue(spec.definitions.MessageSessionSummaryResponse.properties.%IsDefined("metrics"), "Session summary must expose metrics")
    Do $$$AssertTrue(spec.definitions.TraceExplanation.properties.%IsDefined("productionName"), "Trace explanation must expose production name")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("inProduction"), "Trace steps must expose production membership")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("sourceInProduction"), "Trace steps must expose source production membership")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("targetInProduction"), "Trace steps must expose target production membership")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("staticConnectionKind"), "Trace steps must expose static connection kind")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("staticConnectionConfidence"), "Trace steps must expose static connection confidence")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("staticRuleName"), "Trace steps must expose static rule name")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("staticTransformNames"), "Trace steps must expose static transform names")
    Do $$$AssertTrue(spec.definitions.TraceStep.properties.%IsDefined("staticProcessClass"), "Trace steps must expose static process class")
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
    Do $$$AssertTrue(result.capabilities.%IsDefined("payloadPreview"), "Capabilities must include payload preview flag")
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
    Do $$$AssertTrue(result.%IsDefined("productionLogs"), "Capabilities must include productionLogs")
    Do $$$AssertTrue(result.%IsDefined("aiProvider"), "Capabilities must include aiProvider")
    Do $$$AssertTrue(result.%IsDefined("aiSummary"), "Capabilities must include aiSummary")
    Do $$$AssertEquals(result.payloadInspection, result.runtimeTraceAnalysis, "Payload inspection capability mismatch")
    Do $$$AssertEquals(result.payloadPreview, result.runtimeTraceAnalysis, "Payload preview capability mismatch")
}

Method TestGetSettings()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetSettings()
    Do $$$AssertTrue($IsObject(result), "Settings response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Settings namespace mismatch")
    Do $$$AssertTrue($IsObject(result.settings), "Settings payload must be an object")
    Do $$$AssertEquals(result.settings.runtimeMessageAnalysisEnabled, 1, "Runtime message analysis default mismatch")
    Do $$$AssertEquals(result.settings.payloadInspectionEnabled, 0, "Payload inspection default mismatch")
    Do $$$AssertEquals(result.settings.messageResendEnabled, 0, "Message resend default mismatch")
    Do $$$AssertEquals(result.settings.maxMessagesReturned, 100, "Max messages default mismatch")
    Do $$$AssertEquals(result.settings.maxTraceDepth, 50, "Max trace depth default mismatch")
    Do $$$AssertEquals(result.settings.aiProviderEnabled, 0, "AI provider default mismatch")
    Do $$$AssertEquals(result.settings.aiSummaryEnabled, 0, "AI summary default mismatch")
    Do $$$AssertEquals(result.settings.aiProvider, "openai", "AI provider name mismatch")
    Do $$$AssertEquals(result.settings.aiModel, "gpt-4o-mini", "AI model default mismatch")
    Do $$$AssertTrue(result.settings.%IsDefined("aiApiKeyConfigured"), "Settings must expose AI key status")
    Do $$$AssertEquals(result.settings.%IsDefined("openAIApiKey"), 0, "Settings must not return OpenAI API key")
    Do $$$AssertTrue($IsObject(result.evidence), "Settings response must include evidence")
    Do $$$AssertTrue($IsObject(result.metrics), "Settings response must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.featureFlagCount, 6, "Settings metrics feature flag count mismatch")
        Do $$$AssertEquals(result.metrics.enabledFeatureFlagCount, 1, "Settings metrics enabled feature flag count mismatch")
        Do $$$AssertEquals(result.metrics.limitSettingCount, 3, "Settings metrics limit count mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, 0, "Settings metrics warning count mismatch")
        Do $$$AssertEquals(result.metrics.evidenceCount, 1, "Settings metrics evidence count mismatch")
        Do $$$AssertEquals(result.metrics.confirmedEvidenceCount, 1, "Settings metrics confirmed evidence count mismatch")
    }
}

Method TestUpdateSettings()
{
    Do ..InitRequestResponse()
    Set payload = {"messageResendEnabled":1,"maxTraceDepth":25,"explanationVerbosity":"brief"}
    Set result = ##class(esh.interoperability.aid.api.impl).UpdateSettings(payload)
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Do $$$AssertTrue($IsObject(result), "Settings update response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Settings update namespace mismatch")
    Do $$$AssertEquals(result.changed, 1, "Settings update should report changed")
    Do $$$AssertEquals(result.settings.messageResendEnabled, 1, "Settings messageResendEnabled update mismatch")
    Do $$$AssertEquals(result.settings.maxTraceDepth, 25, "Settings maxTraceDepth update mismatch")
    Do $$$AssertEquals(result.settings.explanationVerbosity, "brief", "Settings explanation verbosity update mismatch")
    Do $$$AssertEquals(result.settings.%IsDefined("openAIApiKey"), 0, "Settings update must not return OpenAI API key")
    Do $$$AssertTrue($IsObject(result.warnings), "Settings update must include warnings")
    Do $$$AssertEquals(result.warnings.%Size(), 0, "Enabling implemented resend should not emit warnings")
    Do $$$AssertTrue($IsObject(result.evidence), "Settings update must include evidence")
    Do $$$AssertTrue($IsObject(result.metrics), "Settings update must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.featureFlagCount, 6, "Settings update metrics feature flag count mismatch")
        Do $$$AssertEquals(result.metrics.enabledFeatureFlagCount, 2, "Settings update metrics enabled feature flag count mismatch")
        Do $$$AssertEquals(result.metrics.limitSettingCount, 3, "Settings update metrics limit count mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, 0, "Settings update metrics warning count mismatch")
        Do $$$AssertEquals(result.metrics.evidenceCount, 1, "Settings update metrics evidence count mismatch")
        Do $$$AssertEquals(result.metrics.confirmedEvidenceCount, 1, "Settings update metrics confirmed evidence count mismatch")
    }
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
    Do $$$AssertTrue($IsObject(result.metrics), "Production list response must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.productionCount, result.count, "Production list metrics production count mismatch")
        Do $$$AssertTrue(result.metrics.productionCount >= 1, "Production list metrics should report at least one production")
        Do $$$AssertTrue(result.metrics.componentCount >= 4, "Production list metrics component count should include demo production")
        Do $$$AssertTrue(result.metrics.serviceCount >= 1, "Production list metrics service count should include demo production")
        Do $$$AssertTrue(result.metrics.processCount >= 1, "Production list metrics process count should include demo production")
        Do $$$AssertTrue(result.metrics.operationCount >= 2, "Production list metrics operation count should include demo production")
        Do $$$AssertTrue(result.metrics.disabledComponentCount >= 1, "Production list metrics disabled count should include demo production")
        Do $$$AssertEquals(result.metrics.warningCount, result.warnings.%Size(), "Production list metrics warning count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount >= result.metrics.productionCount, "Production list metrics evidence count should cover productions")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Production list metrics evidence confidence total mismatch")
    }

    Set production = ..FindProduction(result.items, "esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(production), "Demo production should be listed")
    Do $$$AssertEquals(production.componentCount, 4, "Demo production component count mismatch")
    Do $$$AssertEquals(production.serviceCount, 1, "Demo production service count mismatch")
    Do $$$AssertEquals(production.processCount, 1, "Demo production process count mismatch")
    Do $$$AssertEquals(production.operationCount, 2, "Demo production operation count mismatch")
    Do $$$AssertEquals(production.disabledComponentCount, 1, "Demo production disabled component count mismatch")
    Do $$$AssertTrue($IsObject(production.runtime), "Production summary must include runtime status")
    Do $$$AssertTrue(production.runtime.%IsDefined("stateLabel"), "Production summary runtime status must include state label")
    Do $$$AssertTrue($IsObject(production.runtimeMetrics), "Production summary must include runtime metrics")
    If $IsObject(production.runtimeMetrics) {
        Do $$$AssertEquals(production.runtimeMetrics.state, production.runtime.state, "Production summary runtime metrics state mismatch")
        Do $$$AssertEquals(production.runtimeMetrics.isRunning, production.runtime.isRunning, "Production summary runtime metrics running state mismatch")
    }
}

Method TestGetProduction()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProduction("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Production response must be an object")
    Do $$$AssertEquals(result.name, "esh.interoperability.aid.tests.DemoProduction", "Production name mismatch")
    Do $$$AssertEquals(result.namespace, $Namespace, "Namespace mismatch")
    Do $$$AssertEquals(result.componentCount, 4, "Component count mismatch")
    Do $$$AssertEquals(result.serviceCount, 1, "Production detail service count mismatch")
    Do $$$AssertEquals(result.processCount, 1, "Production detail process count mismatch")
    Do $$$AssertEquals(result.operationCount, 2, "Production detail operation count mismatch")
    Do $$$AssertEquals(result.disabledComponentCount, 1, "Production detail disabled component count mismatch")
    Do $$$AssertTrue(result.summary["1 business service", "Production detail summary must describe service count")
    Do $$$AssertTrue($IsObject(result.summaryBullets), "Production detail summary bullets must be an array")
    Do $$$AssertTrue(result.summaryBullets.%Size() >= 3, "Production detail should include summary bullets")
    Do $$$AssertTrue(result.summaryBullets.%Get(0)["configured component", "Production detail summary bullets must describe components")
    Do $$$AssertTrue($IsObject(result.metrics), "Production detail should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.componentCount, 4, "Production detail metrics component count mismatch")
        Do $$$AssertEquals(result.metrics.serviceCount, 1, "Production detail metrics service count mismatch")
        Do $$$AssertEquals(result.metrics.processCount, 1, "Production detail metrics process count mismatch")
        Do $$$AssertEquals(result.metrics.operationCount, 2, "Production detail metrics operation count mismatch")
        Do $$$AssertEquals(result.metrics.disabledComponentCount, 1, "Production detail metrics disabled component count mismatch")
    }
    Do $$$AssertTrue($IsObject(result.runtime), "Production detail must include runtime status")
    Do $$$AssertTrue(result.runtime.%IsDefined("isRunning"), "Production detail runtime status must include isRunning")
    Do $$$AssertTrue($IsObject(result.runtimeMetrics), "Production detail must include runtime metrics")
    If $IsObject(result.runtimeMetrics) {
        Do $$$AssertEquals(result.runtimeMetrics.state, result.runtime.state, "Production detail runtime metrics state mismatch")
        Do $$$AssertEquals(result.runtimeMetrics.isRunning, result.runtime.isRunning, "Production detail runtime metrics running state mismatch")
    }
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
    Do $$$AssertTrue($IsObject(result.metrics), "Runtime status must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.state, result.runtime.state, "Runtime metrics state mismatch")
        Do $$$AssertEquals(result.metrics.isRunning, result.runtime.isRunning, "Runtime metrics running state mismatch")
        Do $$$AssertEquals(result.metrics.isCurrent, result.runtime.isCurrent, "Runtime metrics current state mismatch")
        Do $$$AssertEquals(result.metrics.hasError, 0, "Runtime metrics error state mismatch")
    }
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
    Do $$$AssertTrue($IsObject(result.metrics), "Message list must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.itemCount, result.count, "Message list metrics item count mismatch")
        Do $$$AssertEquals(result.metrics.totalCount, result.count, "Message list metrics total count mismatch")
        Do $$$AssertEquals(result.metrics.hasMore, result.hasMore, "Message list metrics hasMore mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, result.warnings.%Size(), "Message list metrics warning count mismatch")
    }
    Set capped = ##class(esh.interoperability.aid.api.impl).ListMessages("", 500, 0)
    Do $$$AssertEquals(capped.limit, 100, "Message list limit should be capped by settings")
    Set filtered = ##class(esh.interoperability.aid.api.impl).ListMessages("", 5, 0, "Source", "Target", "Body.Class", "123", 1)
    Do $$$AssertEquals(filtered.sourceConfigName, "Source", "Message source filter mismatch")
    Do $$$AssertEquals(filtered.targetConfigName, "Target", "Message target filter mismatch")
    Do $$$AssertEquals(filtered.messageBodyClassName, "Body.Class", "Message body class filter mismatch")
    Do $$$AssertEquals(filtered.sessionId, "123", "Message session filter mismatch")
    Do $$$AssertEquals(filtered.errorsOnly, 1, "Message errorsOnly filter mismatch")
    Set dateFiltered = ##class(esh.interoperability.aid.api.impl).ListMessages("", 5, 0, "", "", "", "", 0, "2026-07-18T00:00:00Z", "2026-07-19")
    Do $$$AssertEquals(dateFiltered.startDate, "2026-07-18 00:00:00", "Message startDate filter mismatch")
    Do $$$AssertEquals(dateFiltered.endDate, "2026-07-19 23:59:59", "Message endDate filter mismatch")
    Do ..InitRequestResponse()
    Set invalid = ##class(esh.interoperability.aid.api.impl).ListMessages("", 5, 0, "", "", "", "", 0, "2026-07-20", "2026-07-19")
    Do $$$AssertTrue($IsObject(invalid), "Invalid date filter response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid date range should set 400")
    Do $$$AssertEquals(invalid.error.code, "INVALID_DATE_FILTER", "Invalid date filter error code mismatch")
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
    Do $$$AssertTrue($IsObject(result.metrics), "Message facets must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.totalCount, result.totalCount, "Message facets metrics total count mismatch")
        Do $$$AssertEquals(result.metrics.errorCount, result.errorCount, "Message facets metrics error count mismatch")
        Do $$$AssertEquals(result.metrics.hasMore, result.hasMore, "Message facets metrics hasMore mismatch")
        Do $$$AssertEquals(result.metrics.sourceFacetCount, result.sourceConfigNames.%Size(), "Message facets metrics source facet count mismatch")
        Do $$$AssertEquals(result.metrics.targetFacetCount, result.targetConfigNames.%Size(), "Message facets metrics target facet count mismatch")
        Do $$$AssertEquals(result.metrics.messageBodyClassFacetCount, result.messageBodyClassNames.%Size(), "Message facets metrics body class facet count mismatch")
        Do $$$AssertEquals(result.metrics.sessionFacetCount, result.sessionIds.%Size(), "Message facets metrics session facet count mismatch")
        Do $$$AssertEquals(result.metrics.componentFacetCount, result.componentNames.%Size(), "Message facets metrics component facet count mismatch")
    }
    Do $$$AssertTrue($IsObject(result.sourceConfigNames), "Message facets must include source names")
    Do $$$AssertTrue($IsObject(result.targetConfigNames), "Message facets must include target names")
    Do $$$AssertTrue($IsObject(result.messageBodyClassNames), "Message facets must include body classes")
    Do $$$AssertTrue($IsObject(result.sessionIds), "Message facets must include session ids")
    Do $$$AssertTrue($IsObject(result.componentNames), "Message facets must include component names")
    Set dateFiltered = ##class(esh.interoperability.aid.api.impl).ListMessageFacets("esh.interoperability.aid.tests.DemoProduction", 25, "2026-07-18T00:00:00", "2026-07-19T23:59:59")
    Do $$$AssertEquals(dateFiltered.startDate, "2026-07-18 00:00:00", "Message facets startDate filter mismatch")
    Do $$$AssertEquals(dateFiltered.endDate, "2026-07-19 23:59:59", "Message facets endDate filter mismatch")
}

Method TestListProductionMessageFacets()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductionMessageFacets("esh.interoperability.aid.tests.DemoProduction", 25)
    Do $$$AssertTrue($IsObject(result), "Production-scoped message facets response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production-scoped message facets production mismatch")
    Do $$$AssertEquals(result.limit, 25, "Production-scoped message facets limit mismatch")
    Do $$$AssertEquals(result.payloadReturned, 0, "Production-scoped message facets must not return payloads")
    Do $$$AssertTrue($IsObject(result.metrics), "Production-scoped message facets must include metrics")
    Do $$$AssertTrue($IsObject(result.sourceConfigNames), "Production-scoped message facets must include source names")
    Do $$$AssertTrue($IsObject(result.targetConfigNames), "Production-scoped message facets must include target names")
    Do $$$AssertTrue($IsObject(result.messageBodyClassNames), "Production-scoped message facets must include body classes")
    Do $$$AssertTrue($IsObject(result.sessionIds), "Production-scoped message facets must include session ids")
    Do $$$AssertTrue($IsObject(result.componentNames), "Production-scoped message facets must include component names")
}

Method TestListProductionLogs()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductionLogs("esh.interoperability.aid.tests.DemoProduction", 5, 0)
    Do $$$AssertTrue($IsObject(result), "Production log list response must be an object")
    Do $$$AssertEquals(result.namespace, $Namespace, "Production log namespace mismatch")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Production log production mismatch")
    Do $$$AssertEquals(result.limit, 5, "Production log limit mismatch")
    Do $$$AssertEquals(result.offset, 0, "Production log offset mismatch")
    Do $$$AssertTrue($IsObject(result.items), "Production log items must be an array")
    Do $$$AssertTrue($IsObject(result.sourceNames), "Production log source facets must be an array")
    Do $$$AssertTrue($IsObject(result.typeNames), "Production log type facets must be an array")
    Do $$$AssertTrue($IsObject(result.metrics), "Production log list must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.itemCount, result.count, "Production log metrics item count mismatch")
        Do $$$AssertEquals(result.metrics.hasMore, result.hasMore, "Production log metrics hasMore mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, result.warnings.%Size(), "Production log metrics warning count mismatch")
    }
    Set dateFiltered = ##class(esh.interoperability.aid.api.impl).ListProductionLogs("esh.interoperability.aid.tests.DemoProduction", 5, 0, "", "", "", "2026-07-18T00:00:00Z", "2026-07-19")
    Do $$$AssertEquals(dateFiltered.startDate, "2026-07-18 00:00:00", "Production log startDate filter mismatch")
    Do $$$AssertEquals(dateFiltered.endDate, "2026-07-19 23:59:59", "Production log endDate filter mismatch")
}

Method TestListProductionLogsInvalidName()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ListProductionLogs("bad name", 5, 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production log response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production log name should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_PRODUCTION_NAME", "Invalid production log name error code mismatch")
}

Method TestGetMessageTraceInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessageTrace(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message trace response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message id error code mismatch")
}

Method TestGetProductionMessageTraceStaticContext()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Set fixture = ..CreateRuntimeMessage("Patient Router", "FHIR Operation")
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Trace fixture should save successfully")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageTrace("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)
    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)

    Do $$$AssertTrue($IsObject(result), "Production-scoped trace response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Trace production mismatch")
    Do $$$AssertEquals(result.productionStepCount, 1, "Trace production step count mismatch")
    Do $$$AssertEquals(result.steps.%Size(), 1, "Trace step count mismatch")
    Do $$$AssertTrue($IsObject(result.metrics), "Trace response should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.stepCount, 1, "Trace metrics step count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Trace metrics evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Trace metrics evidence confidence total mismatch")
    }
    Set step = result.steps.%Get(0)
    Do $$$AssertTrue($IsObject(step), "Trace step must be an object")
    Do $$$AssertEquals(step.inProduction, 1, "Trace step should be in production")
    Do $$$AssertEquals(step.staticConnectionKind, "routing-rule", "Trace step static connection kind mismatch")
    Do $$$AssertEquals(step.staticConnectionConfidence, "confirmed", "Trace step static confidence mismatch")
    Do $$$AssertEquals(step.staticRuleName, "esh.interoperability.aid.tests.DemoRoutingRule", "Trace step static rule mismatch")
    Do $$$AssertTrue($IsObject(step.staticTransformNames), "Trace step static transforms must be an array")
    Do $$$AssertEquals(step.staticTransformNames.%Size(), 1, "Trace step static transform count mismatch")
    Do $$$AssertEquals(step.staticTransformNames.%Get(0), "esh.interoperability.aid.tests.DemoTransform", "Trace step static transform mismatch")
    Do $$$AssertTrue($Find(step.explanation, "routing rule") > 0, "Trace step explanation should mention routing rule")
    Do $$$AssertTrue($Find(step.explanation, "static connection") > 0, "Trace step explanation should mention static connection")
    Do $$$AssertTrue($Find(step.explanation, "DemoTransform") > 0, "Trace step explanation should mention transformation")
    Do $$$AssertTrue($IsObject(result.traceExplanation), "Trace should include aggregate explanation")
    Do $$$AssertEquals(result.traceExplanation.productionName, "esh.interoperability.aid.tests.DemoProduction", "Trace explanation production mismatch")
    Do $$$AssertTrue($Find(result.traceExplanation.text, "DemoRoutingRule") > 0, "Trace explanation should mention routing rule")
    Do $$$AssertTrue($Find(result.traceExplanation.text, "DemoTransform") > 0, "Trace explanation should mention transformation")
}

Method TestGetMessageExplanationInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessageExplanation(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message explanation response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message explanation id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message explanation error code mismatch")
}

Method TestGetProductionMessageExplanationMetrics()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Set fixture = ..CreateRuntimeMessage("Patient Router", "FHIR Operation")
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Message explanation fixture should save successfully")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageExplanation("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)
    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)

    Do $$$AssertTrue($IsObject(result), "Production-scoped message explanation response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Message explanation production mismatch")
    Do $$$AssertTrue($IsObject(result.metrics), "Message explanation should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.stepCount, 1, "Message explanation metrics step count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Message explanation metrics evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Message explanation metrics evidence confidence total mismatch")
    }
}

Method TestGetMessagePayloadMetadataInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessagePayloadMetadata(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message payload metadata response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message payload metadata id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message payload metadata error code mismatch")
}

Method TestGetMessagePayloadPreviewInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessagePayloadPreview(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message payload preview response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message payload preview id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message payload preview error code mismatch")
}

Method TestGetMessagePayloadPreview()
{
    Do ..InitRequestResponse()
    Set enable = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":1,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set update = ##class(esh.interoperability.aid.api.impl).UpdateSettings(enable)
    Set fixture = ..CreatePayloadPreviewMessage()
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Payload preview fixture should save successfully")

    Do ..InitRequestResponse()
    Set metadata = ##class(esh.interoperability.aid.api.impl).GetProductionMessagePayloadMetadata("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)
    Do $$$AssertTrue($IsObject(metadata), "Payload metadata response must be an object")
    Do $$$AssertEquals(metadata.payloadInspectionSupported, 1, "Payload metadata should report preview support when body is available")
    Do $$$AssertEquals(metadata.restrictionReason, "PAYLOAD_PREVIEW_REQUIRED", "Payload metadata should direct callers to preview endpoint")
    Do $$$AssertTrue($IsObject(metadata.metrics), "Payload metadata should include metrics")
    If $IsObject(metadata.metrics) {
        Do $$$AssertEquals(metadata.metrics.fieldCount, 0, "Payload metadata metrics field count mismatch")
        Do $$$AssertEquals(metadata.metrics.warningCount, 1, "Payload metadata metrics warning count mismatch")
        Do $$$AssertTrue(metadata.metrics.evidenceCount > 0, "Payload metadata metrics evidence count should be populated")
    }
    Do $$$AssertTrue($IsObject(..FindWarning(metadata.warnings, "PAYLOAD_PREVIEW_REQUIRED")), "Payload metadata should include preview endpoint warning")
    Do $$$AssertTrue('$IsObject(..FindWarning(metadata.warnings, "PAYLOAD_INSPECTION_UNSUPPORTED")), "Payload metadata should not report preview as unsupported")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessagePayloadPreview("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)

    Do $$$AssertTrue($IsObject(result), "Payload preview response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Payload preview production mismatch")
    Do $$$AssertEquals(result.messageId, fixture.messageId, "Payload preview message id mismatch")
    Do $$$AssertEquals(result.payloadReturned, 1, "Payload preview should return scalar preview fields")
    Do $$$AssertEquals(result.bodyContentReturned, 1, "Payload preview should report body content returned")
    Do $$$AssertEquals(result.restricted, 0, "Payload preview should not be restricted when enabled")
    Do $$$AssertTrue($IsObject(result.fields), "Payload preview fields must be an array")
    Do $$$AssertEquals(result.fields.%Size(), 2, "Payload preview field count mismatch")
    Do $$$AssertTrue($IsObject(result.metrics), "Payload preview should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.fieldCount, 2, "Payload preview metrics field count mismatch")
        Do $$$AssertEquals(result.metrics.redactedFieldCount, 1, "Payload preview metrics redacted field count mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, 0, "Payload preview metrics warning count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Payload preview metrics evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Payload preview metrics evidence confidence total mismatch")
    }
    Set eventType = ..FindPayloadPreviewField(result.fields, "EventType")
    Do $$$AssertTrue($IsObject(eventType), "Payload preview should include EventType")
    Do $$$AssertEquals(eventType.value, "ADT", "Payload preview EventType value mismatch")
    Do $$$AssertEquals(eventType.redacted, 0, "Payload preview EventType should not be redacted")
    Set patientId = ..FindPayloadPreviewField(result.fields, "PatientId")
    Do $$$AssertTrue($IsObject(patientId), "Payload preview should include PatientId")
    Do $$$AssertEquals(patientId.value, "[redacted]", "Payload preview PatientId value should be redacted")
    Do $$$AssertEquals(patientId.redacted, 1, "Payload preview PatientId should report redacted")
    Do $$$AssertTrue($IsObject(result.metadata.fields), "Payload metadata should include preview fields")
    Do $$$AssertEquals(result.metadata.fields.%Size(), 2, "Payload metadata preview field count mismatch")

    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)
}

Method TestGetMessageInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessage(0)
    Do $$$AssertTrue($IsObject(result), "Invalid message response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid message id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid message id error code mismatch")
}

Method TestGetMessagePayloadMetadataMetrics()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Set fixture = ..CreateRuntimeMessage("CSV Patient Service", "Patient Router")
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Message detail fixture should save successfully")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetMessage(fixture.messageId)

    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)

    Do $$$AssertTrue($IsObject(result), "Message detail response must be an object")
    Do $$$AssertTrue($IsObject(result.metrics), "Message detail should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.payloadReturned, 0, "Message detail payload returned metric mismatch")
        Do $$$AssertEquals(result.metrics.payloadInspectionSupported, 1, "Message detail payload inspection support metric mismatch")
        Do $$$AssertEquals(result.metrics.bodyReferenceAvailable, 1, "Message detail body reference metric mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, 1, "Message detail warning count metric mismatch")
        Do $$$AssertTrue(result.metrics.messageEvidenceCount > 0, "Message detail message evidence count should be populated")
        Do $$$AssertTrue(result.metrics.payloadEvidenceCount > 0, "Message detail payload evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Message detail evidence confidence total mismatch")
    }
    Do $$$AssertTrue($IsObject(result.payloadMetadata), "Message detail should include payload metadata")
    If $IsObject(result.payloadMetadata) {
        Do $$$AssertTrue($IsObject(result.payloadMetadata.metrics), "Message detail payload metadata should include metrics")
        If $IsObject(result.payloadMetadata.metrics) {
            Do $$$AssertEquals(result.payloadMetadata.metrics.fieldCount, 0, "Message detail payload metadata field count mismatch")
            Do $$$AssertEquals(result.payloadMetadata.metrics.warningCount, 1, "Message detail payload metadata warning count mismatch")
            Do $$$AssertTrue(result.payloadMetadata.metrics.evidenceCount > 0, "Message detail payload metadata evidence count should be populated")
            Do $$$AssertEquals(result.payloadMetadata.metrics.evidenceCount, result.payloadMetadata.metrics.confirmedEvidenceCount + result.payloadMetadata.metrics.observedEvidenceCount + result.payloadMetadata.metrics.inferredEvidenceCount + result.payloadMetadata.metrics.unknownEvidenceCount, "Message detail payload metadata evidence confidence total mismatch")
        }
    }
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

Method TestGetProductionMessagePayloadPreviewInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessagePayloadPreview("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message payload preview response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message payload preview id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message payload preview id error code mismatch")
}

Method TestGetProductionMessageTraceInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageTrace("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message trace response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message trace id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message trace id error code mismatch")
}

Method TestGetProductionMessageSessionSummaryInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageSessionSummary("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message session response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message session id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message session id error code mismatch")
}

Method TestGetProductionMessageSessionSummaryStaticContext()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Set fixture = ..CreateRuntimeMessage("Patient Router", "FHIR Operation")
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Session fixture should save successfully")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionMessageSessionSummary("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)
    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)

    Do $$$AssertTrue($IsObject(result), "Production-scoped session response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Session production mismatch")
    Do $$$AssertTrue($IsObject(result.staticContext), "Session static context must be an object")
    Do $$$AssertTrue($IsObject(result.metrics), "Session summary metrics must be an object")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.stepCount, 1, "Session summary metrics step count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Session summary metrics evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Session summary metrics evidence confidence total mismatch")
    }
    Do $$$AssertEquals(result.staticContext.matchedStepCount, 1, "Session static matched step count mismatch")
    Do $$$AssertEquals(result.staticContext.ruleNames.%Size(), 1, "Session static rule count mismatch")
    Do $$$AssertEquals(result.staticContext.ruleNames.%Get(0), "esh.interoperability.aid.tests.DemoRoutingRule", "Session static rule mismatch")
    Do $$$AssertEquals(result.staticContext.transformNames.%Size(), 1, "Session static transform count mismatch")
    Do $$$AssertEquals(result.staticContext.transformNames.%Get(0), "esh.interoperability.aid.tests.DemoTransform", "Session static transform mismatch")
    Do $$$AssertTrue($Find(result.text, "DemoRoutingRule") > 0, "Session summary should mention routing rule")
    Do $$$AssertTrue($Find(result.text, "DemoTransform") > 0, "Session summary should mention transformation")
}

Method TestResendProductionMessageInvalidId()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ResendProductionMessage("esh.interoperability.aid.tests.DemoProduction", 0)
    Do $$$AssertTrue($IsObject(result), "Invalid production-scoped message resend response must be an object")
    Do $$$AssertEquals(%response.Status, 400, "Invalid production-scoped message resend id should set 400")
    Do $$$AssertEquals(result.error.code, "INVALID_MESSAGE_ID", "Invalid production-scoped message resend id error code mismatch")
}

Method TestResendProductionMessageDisabledMetrics()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Set fixture = ..CreateRuntimeMessage("Patient Router", "FHIR Operation")
    Do $$$AssertTrue('fixture.%IsDefined("errorCode"), "Disabled resend fixture should save successfully")

    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).ResendProductionMessage("esh.interoperability.aid.tests.DemoProduction", fixture.messageId)

    Do ##class(Ens.MessageHeader).%DeleteId(fixture.messageId)
    Do ##class(esh.interoperability.aid.tests.DemoMessage).%DeleteId(fixture.bodyId)

    Do $$$AssertTrue($IsObject(result), "Disabled resend response must be an object")
    Do $$$AssertEquals(result.reason, "MESSAGE_RESEND_DISABLED", "Disabled resend reason mismatch")
    Do $$$AssertEquals(result.allowed, 0, "Disabled resend should not be allowed")
    Do $$$AssertEquals(result.executed, 0, "Disabled resend should not execute")
    Do $$$AssertTrue($IsObject(result.metrics), "Disabled resend response should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.requested, 1, "Disabled resend metrics requested mismatch")
        Do $$$AssertEquals(result.metrics.allowed, 0, "Disabled resend metrics allowed mismatch")
        Do $$$AssertEquals(result.metrics.executed, 0, "Disabled resend metrics executed mismatch")
        Do $$$AssertEquals(result.metrics.changed, 0, "Disabled resend metrics changed mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, 1, "Disabled resend metrics warning count mismatch")
        Do $$$AssertEquals(result.metrics.evidenceCount, 2, "Disabled resend metrics evidence count mismatch")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Disabled resend metrics evidence confidence total mismatch")
    }
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
    Do $$$AssertTrue($IsObject(result.metrics), "Analysis should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.componentCount, 4, "Analysis metrics component count mismatch")
        Do $$$AssertEquals(result.metrics.serviceCount, 1, "Analysis metrics service count mismatch")
        Do $$$AssertEquals(result.metrics.processCount, 1, "Analysis metrics process count mismatch")
        Do $$$AssertEquals(result.metrics.operationCount, 2, "Analysis metrics operation count mismatch")
        Do $$$AssertEquals(result.metrics.disabledComponentCount, 1, "Analysis metrics disabled component count mismatch")
        Do $$$AssertEquals(result.metrics.connectionCount, 5, "Analysis metrics connection count mismatch")
        Do $$$AssertEquals(result.metrics.targetConfigConnectionCount, 3, "Analysis metrics target-config connection count mismatch")
        Do $$$AssertEquals(result.metrics.routingRuleConnectionCount, 1, "Analysis metrics routing-rule connection count mismatch")
        Do $$$AssertEquals(result.metrics.bplCallConnectionCount, 1, "Analysis metrics BPL connection count mismatch")
    }
    Do $$$AssertTrue($IsObject(result.analysisCoverage), "Analysis should include coverage")
    If $IsObject(result.analysisCoverage) {
        Do $$$AssertEquals(result.analysisCoverage.componentCount, 4, "Analysis coverage component count mismatch")
        Do $$$AssertEquals(result.analysisCoverage.connectionCount, 5, "Analysis coverage connection count mismatch")
        Do $$$AssertEquals(result.analysisCoverage.ruleCount, 1, "Analysis coverage rule count mismatch")
        Do $$$AssertEquals(result.analysisCoverage.transformationCount, 1, "Analysis coverage transformation count mismatch")
        Do $$$AssertEquals(result.analysisCoverage.businessProcessCount, 1, "Analysis coverage BPL count mismatch")
        Do $$$AssertEquals(result.analysisCoverage.routingRuleAnalysisAvailable, 1, "Analysis coverage routing rule availability mismatch")
        Do $$$AssertEquals(result.analysisCoverage.transformationAnalysisAvailable, 1, "Analysis coverage transformation availability mismatch")
        Do $$$AssertEquals(result.analysisCoverage.businessProcessAnalysisAvailable, 1, "Analysis coverage BPL availability mismatch")
        Do $$$AssertTrue(result.analysisCoverage.evidenceCount > 0, "Analysis coverage evidence count should be populated")
        Do $$$AssertTrue(result.analysisCoverage.confirmedEvidenceCount > 0, "Analysis coverage confirmed evidence count should be populated")
        Do $$$AssertEquals(result.analysisCoverage.evidenceCount, result.analysisCoverage.confirmedEvidenceCount + result.analysisCoverage.observedEvidenceCount + result.analysisCoverage.inferredEvidenceCount + result.analysisCoverage.unknownEvidenceCount, "Analysis coverage evidence confidence total mismatch")
        Do $$$AssertTrue($IsObject(result.analysisCoverage.warningCodes), "Analysis coverage warning codes must be an array")
        Do $$$AssertTrue($IsObject(result.analysisCoverage.limitations), "Analysis coverage limitations must be an array")
    }
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
    Do $$$AssertEquals(result.externalSystemExplanations.%Size(), 2, "Analysis external endpoint explanation count mismatch")
    Set endpointExplanation = ..FindExternalSystemExplanation(result.externalSystemExplanations, "CSV Patient Service", "file-path")
    Do $$$AssertTrue($IsObject(endpointExplanation), "File path endpoint explanation should be present")
    If $IsObject(endpointExplanation) {
        Do $$$AssertTrue(endpointExplanation.text["CSV Patient Service", "Endpoint explanation should mention component")
        Do $$$AssertTrue(endpointExplanation.text["file path", "Endpoint explanation should mention kind")
        Do $$$AssertTrue($IsObject(endpointExplanation.evidence), "Endpoint explanation must include evidence")
    }
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "routing-rule", "esh.interoperability.aid.tests.DemoRoutingRule")), "Routing rule artifact should be present")
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "rule-transformation", "esh.interoperability.aid.tests.DemoTransform")), "Rule transform artifact should be present")
    Do $$$AssertTrue($IsObject(..FindArtifact(result.artifacts, "bpl-process", "esh.interoperability.aid.tests.DemoProcess")), "BPL artifact should be present")
    Do $$$AssertEquals(result.artifactExplanations.%Size(), result.artifacts.%Size(), "Analysis artifact explanation count mismatch")
    Set artifactExplanation = ..FindArtifactExplanation(result.artifactExplanations, "routing-rule", "esh.interoperability.aid.tests.DemoRoutingRule")
    Do $$$AssertTrue($IsObject(artifactExplanation), "Routing rule artifact explanation should be present")
    If $IsObject(artifactExplanation) {
        Do $$$AssertEquals(artifactExplanation.label, "routing rule", "Artifact explanation label mismatch")
        Do $$$AssertTrue(artifactExplanation.text["Patient Router", "Artifact explanation should mention component")
        Do $$$AssertTrue(artifactExplanation.text["DemoRoutingRule", "Artifact explanation should mention artifact")
        Do $$$AssertTrue($IsObject(artifactExplanation.evidence), "Artifact explanation must include evidence")
    }
    Do $$$AssertEquals(result.componentExplanations.%Size(), 4, "Analysis component explanation count mismatch")
    Do $$$AssertEquals(result.connectionExplanations.%Size(), 5, "Analysis connection explanation count mismatch")
    Set connectionExplanation = ..FindConnectionExplanation(result.connectionExplanations, "Patient Router", "FHIR Operation", "routing-rule")
    Do $$$AssertTrue($IsObject(connectionExplanation), "Routing rule connection explanation should be present")
    If $IsObject(connectionExplanation) {
        Do $$$AssertEquals(connectionExplanation.ruleName, "esh.interoperability.aid.tests.DemoRoutingRule", "Connection explanation rule mismatch")
        Do $$$AssertTrue(connectionExplanation.text["DemoRoutingRule", "Connection explanation should mention routing rule")
        Do $$$AssertTrue(connectionExplanation.text["Patient Router", "Connection explanation should mention source")
        Do $$$AssertTrue(connectionExplanation.text["FHIR Operation", "Connection explanation should mention target")
        Do $$$AssertTrue($IsObject(connectionExplanation.evidence), "Connection explanation must include evidence")
    }
    Do $$$AssertTrue(result.messageTypeExplanations.%Size() > 0, "Analysis message type explanations should be present")
    Set messageExplanation = ..FindMessageTypeExplanation(result.messageTypeExplanations, "CSV Patient Service", "OnProcessInput", "pInput")
    Do $$$AssertTrue($IsObject(messageExplanation), "Service input message explanation should be present")
    If $IsObject(messageExplanation) {
        Do $$$AssertEquals(messageExplanation.messageClass, "esh.interoperability.aid.tests.DemoMessage", "Message explanation class mismatch")
        Do $$$AssertTrue(messageExplanation.text["CSV Patient Service", "Message explanation should mention component")
        Do $$$AssertTrue(messageExplanation.text["DemoMessage", "Message explanation should mention message class")
        Do $$$AssertTrue($IsObject(messageExplanation.evidence), "Message explanation must include evidence")
    }
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
    Do $$$AssertEquals(result.ruleExplanations.%Size(), 1, "Analysis rule explanation count mismatch")
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
    Set ruleExplanation = ..FindRuleExplanation(result.ruleExplanations, "esh.interoperability.aid.tests.DemoRoutingRule")
    Do $$$AssertTrue($IsObject(ruleExplanation), "Rule explanation should be present")
    If $IsObject(ruleExplanation) {
        Do $$$AssertEquals(ruleExplanation.conditionCount, 1, "Rule explanation condition count mismatch")
        Do $$$AssertEquals(ruleExplanation.targetCount, 1, "Rule explanation target count mismatch")
        Do $$$AssertEquals(ruleExplanation.transformCount, 1, "Rule explanation transform count mismatch")
        Do $$$AssertEquals(ruleExplanation.targets.%Get(0), "FHIR Operation", "Rule explanation target mismatch")
        Do $$$AssertEquals(ruleExplanation.transforms.%Get(0), "esh.interoperability.aid.tests.DemoTransform", "Rule explanation transform mismatch")
        Do $$$AssertTrue(ruleExplanation.text["DemoRoutingRule", "Rule explanation should mention rule")
        Do $$$AssertTrue(ruleExplanation.text["FHIR Operation", "Rule explanation should mention target")
        Do $$$AssertTrue($IsObject(ruleExplanation.evidence), "Rule explanation must include evidence")
    }
    Do $$$AssertEquals(result.transformations.%Size(), 1, "Analysis transformation count mismatch")
    Do $$$AssertEquals(result.transformationExplanations.%Size(), 1, "Analysis transformation explanation count mismatch")
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
    Set transformationExplanation = ..FindTransformationExplanation(result.transformationExplanations, "esh.interoperability.aid.tests.DemoTransform")
    Do $$$AssertTrue($IsObject(transformationExplanation), "Transformation explanation should be present")
    If $IsObject(transformationExplanation) {
        Do $$$AssertEquals(transformationExplanation.assignmentCount, 2, "Transformation explanation assignment count mismatch")
        Do $$$AssertTrue(transformationExplanation.text["DemoTransform", "Transformation explanation should mention transform")
        Do $$$AssertTrue(transformationExplanation.text["DemoMessage", "Transformation explanation should mention message class")
        Do $$$AssertTrue($IsObject(transformationExplanation.evidence), "Transformation explanation must include evidence")
    }
    Do $$$AssertEquals(result.businessProcesses.%Size(), 1, "Analysis BPL process count mismatch")
    Do $$$AssertEquals(result.businessProcessExplanations.%Size(), 1, "Analysis BPL process explanation count mismatch")
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
    Set bplExplanation = ..FindBusinessProcessExplanation(result.businessProcessExplanations, "esh.interoperability.aid.tests.DemoProcess")
    Do $$$AssertTrue($IsObject(bplExplanation), "BPL process explanation should be present")
    If $IsObject(bplExplanation) {
        Do $$$AssertEquals(bplExplanation.callCount, 1, "BPL process explanation call count mismatch")
        Do $$$AssertEquals(bplExplanation.assignCount, 2, "BPL process explanation assign count mismatch")
        Do $$$AssertEquals(bplExplanation.callTargets.%Size(), 1, "BPL process explanation target count mismatch")
        Do $$$AssertEquals(bplExplanation.callTargets.%Get(0), "FHIR Operation", "BPL process explanation target mismatch")
        Do $$$AssertTrue(bplExplanation.text["DemoProcess", "BPL process explanation should mention process")
        Do $$$AssertTrue(bplExplanation.text["FHIR Operation", "BPL process explanation should mention call target")
        Do $$$AssertTrue($IsObject(bplExplanation.evidence), "BPL process explanation must include evidence")
    }
    Do $$$AssertTrue(result.messageTypes.%Size() > 0, "Analysis message types should be present")
    Set serviceInput = ..FindMessageType(result.messageTypes, "CSV Patient Service", "OnProcessInput", "pInput")
    Do $$$AssertTrue($IsObject(serviceInput), "Service input message type should be present")
    If $IsObject(serviceInput) {
        Do $$$AssertEquals(serviceInput.direction, "input", "Service input message direction mismatch")
        Do $$$AssertEquals(serviceInput.messageClass, "esh.interoperability.aid.tests.DemoMessage", "Service input message class mismatch")
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
    Do $$$AssertTrue(result.summaryBullets.%Size() >= 3, "Analysis should include summary bullets")
    Do $$$AssertTrue(result.summaryBullets.%Get(0)["service", "Summary bullets should describe service count")
    Do $$$AssertTrue(result.summaryBullets.%Get(1)["target connection", "Summary bullets should describe target connections")
    Do $$$AssertTrue(result.summaryBullets.%Get(result.summaryBullets.%Size()-1)["component is disabled", "Summary bullets should use singular disabled-component wording")
}

Method TestGetProductionSummary()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionSummary("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Summary response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Summary production name mismatch")
    Set hasConnectionText = result.summary["target connection"
    Do $$$AssertTrue(hasConnectionText, "Summary should mention target connections")
    Do $$$AssertTrue(result.summaryBullets.%Size() >= 3, "Summary response should include summary bullets")
    Do $$$AssertTrue(result.summaryBullets.%Get(2)["message signature", "Summary bullets should mention message signatures")
    Do $$$AssertTrue($IsObject(result.metrics), "Summary response should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.componentCount, 4, "Summary metrics component count mismatch")
        Do $$$AssertEquals(result.metrics.connectionCount, 5, "Summary metrics connection count mismatch")
        Do $$$AssertEquals(result.metrics.messageTypeCount, 9, "Summary metrics message type count mismatch")
    }
    Do $$$AssertEquals(result.confidence, "confirmed", "Summary confidence mismatch")
}

Method TestGetProductionAISummaryDisabled()
{
    Do ..InitRequestResponse()
    Set restore = {"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0,"aiSummaryEnabled":0,"aiProvider":"openai","aiModel":"gpt-4o-mini","aiEndpoint":"https://api.openai.com/v1/chat/completions","clearOpenAIApiKey":1}
    Set restored = ##class(esh.interoperability.aid.api.impl).UpdateSettings(restore)
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionAISummary("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Disabled AI summary response must be an object")
    Do $$$AssertEquals(%response.Status, 403, "Disabled AI provider should set 403")
    Do $$$AssertEquals(result.error.code, "AI_PROVIDER_DISABLED", "Disabled AI provider error code mismatch")
}

Method TestGetProductionGraph()
{
    Do ..InitRequestResponse()
    Set result = ##class(esh.interoperability.aid.api.impl).GetProductionGraph("esh.interoperability.aid.tests.DemoProduction")
    Do $$$AssertTrue($IsObject(result), "Graph response must be an object")
    Do $$$AssertEquals(result.productionName, "esh.interoperability.aid.tests.DemoProduction", "Graph production name mismatch")
    Do $$$AssertEquals(result.nodes.%Size(), 4, "Graph node count mismatch")
    Do $$$AssertEquals(result.edges.%Size(), 5, "Graph edge count mismatch")
    Do $$$AssertTrue($IsObject(result.metrics), "Graph response should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.nodeCount, 4, "Graph metrics node count mismatch")
        Do $$$AssertEquals(result.metrics.edgeCount, 5, "Graph metrics edge count mismatch")
        Do $$$AssertEquals(result.metrics.serviceCount, 1, "Graph metrics service count mismatch")
        Do $$$AssertEquals(result.metrics.processCount, 1, "Graph metrics process count mismatch")
        Do $$$AssertEquals(result.metrics.operationCount, 2, "Graph metrics operation count mismatch")
        Do $$$AssertEquals(result.metrics.targetConfigEdgeCount, 3, "Graph metrics target-config edge count mismatch")
        Do $$$AssertEquals(result.metrics.routingRuleEdgeCount, 1, "Graph metrics routing-rule edge count mismatch")
        Do $$$AssertEquals(result.metrics.bplCallEdgeCount, 1, "Graph metrics BPL edge count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Graph metrics evidence count should be populated")
        Do $$$AssertTrue(result.metrics.confirmedEvidenceCount > 0, "Graph metrics confirmed evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Graph metrics evidence confidence total mismatch")
    }
    Do $$$AssertTrue(result.summaryBullets.%Size() >= 3, "Graph response should include summary bullets")
    Do $$$AssertTrue(result.summaryBullets.%Get(0)["graph node", "Graph summary should describe graph nodes")
    Do $$$AssertTrue(result.summaryBullets.%Get(1)["graph edge", "Graph summary should describe graph edges")
    Do $$$AssertTrue(result.summaryBullets.%Get(2)["configured target connection", "Graph summary should describe configured target edges")
    Set node = ..FindGraphNode(result.nodes, "Patient Router")
    Do $$$AssertTrue($IsObject(node), "Graph should include Patient Router node")
    If $IsObject(node) {
        Do $$$AssertEquals(node.type, "business-process", "Graph node type mismatch")
        Do $$$AssertEquals(node.label, "Patient Router", "Graph node label mismatch")
        Do $$$AssertTrue(node.text["DemoRoutingRule", "Graph node explanation should mention routing rule")
    }
    Set edge = ..FindGraphEdge(result.edges, "Patient Router", "FHIR Operation", "routing-rule")
    Do $$$AssertTrue($IsObject(edge), "Graph should include routing-rule edge")
    If $IsObject(edge) {
        Do $$$AssertEquals(edge.relationship, "sends", "Graph edge relationship mismatch")
        Do $$$AssertEquals(edge.ruleName, "esh.interoperability.aid.tests.DemoRoutingRule", "Graph edge rule mismatch")
        Do $$$AssertTrue($IsObject(edge.messageTypes), "Graph edge should include messageTypes")
        Do $$$AssertTrue(edge.text["DemoRoutingRule", "Graph edge explanation should mention routing rule")
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
    Do $$$AssertTrue($IsObject(result.metrics), "Component list response must include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.componentCount, 4, "Component list metrics component count mismatch")
        Do $$$AssertEquals(result.metrics.serviceCount, 1, "Component list metrics service count mismatch")
        Do $$$AssertEquals(result.metrics.processCount, 1, "Component list metrics process count mismatch")
        Do $$$AssertEquals(result.metrics.operationCount, 2, "Component list metrics operation count mismatch")
        Do $$$AssertEquals(result.metrics.disabledComponentCount, 1, "Component list metrics disabled component count mismatch")
        Do $$$AssertEquals(result.metrics.warningCount, result.warnings.%Size(), "Component list metrics warning count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Component list metrics evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Component list metrics evidence confidence total mismatch")
    }

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
    Do $$$AssertTrue(result.connectionExplanations.%Size() > 0, "Component detail should include connection explanations")
    Do $$$AssertTrue(result.artifactExplanations.%Size() > 0, "Component detail should include artifact explanations")
    Do $$$AssertTrue($IsObject(result.metrics), "Component detail should include metrics")
    If $IsObject(result.metrics) {
        Do $$$AssertEquals(result.metrics.connectionCount, 5, "Component metrics connection count mismatch")
        Do $$$AssertEquals(result.metrics.artifactCount, 3, "Component metrics artifact count mismatch")
        Do $$$AssertEquals(result.metrics.ruleCount, 1, "Component metrics rule count mismatch")
        Do $$$AssertEquals(result.metrics.messageTypeCount, 2, "Component metrics message type count mismatch")
        Do $$$AssertEquals(result.metrics.transformationCount, 1, "Component metrics transformation count mismatch")
        Do $$$AssertEquals(result.metrics.businessProcessCount, 1, "Component metrics BPL count mismatch")
        Do $$$AssertTrue(result.metrics.evidenceCount > 0, "Component metrics evidence count should be populated")
        Do $$$AssertTrue(result.metrics.confirmedEvidenceCount > 0, "Component metrics confirmed evidence count should be populated")
        Do $$$AssertEquals(result.metrics.evidenceCount, result.metrics.confirmedEvidenceCount + result.metrics.observedEvidenceCount + result.metrics.inferredEvidenceCount + result.metrics.unknownEvidenceCount, "Component metrics evidence confidence total mismatch")
    }
    Do $$$AssertTrue(result.summaryBullets.%Size() > 0, "Component detail should include summary bullets")
    Do $$$AssertTrue(result.summaryBullets.%Get(0)["business process", "Component summary bullet should describe component type")
    Do $$$AssertTrue(result.summaryBullets.%Get(0)["related connection", "Component summary bullet should describe connections")
    Do $$$AssertEquals(result.ruleExplanations.%Size(), 1, "Component detail rule explanation count mismatch")
    Do $$$AssertTrue($IsObject(result.messageTypeExplanations), "Component detail must include message type explanations array")
    Do $$$AssertEquals(result.transformationExplanations.%Size(), 1, "Component detail transformation explanation count mismatch")
    Do $$$AssertEquals(result.businessProcessExplanations.%Size(), 1, "Component detail BPL explanation count mismatch")
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
