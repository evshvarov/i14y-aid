Class esh.interoperability.aid.service.ProductionDiscovery Extends %RegisteredObject
{

ClassMethod Capabilities() As %DynamicObject
{
    Set capabilities = {}
    Set capabilities.namespace = $Namespace
    Set capabilities.interoperabilityAvailable = ..ClassExists("Ens.Production")
    Set capabilities.currentNamespaceOnly = 1
    Set capabilities.productionDiscovery = capabilities.interoperabilityAvailable
    Set capabilities.productionXDataAnalysis = capabilities.interoperabilityAvailable
    Set capabilities.productionControl = capabilities.interoperabilityAvailable
    Set capabilities.runtimeTraceAnalysis = ..ClassExists("Ens.MessageHeader")
    Set capabilities.payloadInspection = 0
    Set capabilities.openapiVersion = "2.0"
    return capabilities
}

ClassMethod GetSettings() As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.settings = settings
    Set result.evidence = []
    Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "settings", "Runtime analysis limits and feature flags", "confirmed"))
    return result
}

ClassMethod UpdateSettings(payload As %DynamicObject) As %DynamicObject
{
    return ##class(esh.interoperability.aid.config.Settings).UpdateFromPayload(payload)
}

ClassMethod ListProductions() As %DynamicObject
{
    Set result = ..NewListResult()
    If '..ClassExists("Ens.Production") {
        Do result.warnings.%Push(..NewWarning("INTEROPERABILITY_NOT_AVAILABLE", "Ens.Production is not available in this namespace."))
        return result
    }

    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name, Description FROM %Dictionary.CompiledClass ORDER BY Name")
    If $$$ISERR(sc) {
        return ..AddStatusError(.result, "Status error: "_$System.Status.GetErrorText(sc))
    }

    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ..AddStatusError(.result, "SQL error: "_rset.%Message)
    }

    While rset.%Next() {
        Set className = rset.%Get("Name")
        Continue:($Extract(className, 1) = "%")
        Continue:('..ClassExtends(className, "Ens.Production"))

        Set item = {}
        Set item.name = className
        Set item.namespace = $Namespace
        Set item.description = rset.%Get("Description")
        Set item.componentCount = ..ListComponents(className).items.%Size()
        Set item.runtime = ..GetRuntimeStatus(className)
        Set item.isRunning = item.runtime.isRunning
        Set item.runtimeState = item.runtime.stateLabel
        Set item.evidence = []
        Do item.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", className, "Super", "Ens.Production", "confirmed"))
        Do result.items.%Push(item)
    }

    Do result.%Set("count", result.items.%Size())
    return result
}

ClassMethod GetProduction(productionName As %VarString) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.name = productionName

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set result.description = ..GetClassDescription(productionName)
    Set result.runtime = ..GetRuntimeStatus(productionName)
    Set result.isRunning = result.runtime.isRunning
    Set result.runtimeState = result.runtime.stateLabel
    Set result.components = ..ListComponents(productionName).items
    Set result.componentCount = result.components.%Size()
    Set result.evidence = []
    Do result.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", productionName, "Super", "Ens.Production", "confirmed"))
    return result
}

ClassMethod GetProductionRuntimeStatus(productionName As %VarString) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.name = productionName

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set result.runtime = ..GetRuntimeStatus(productionName)
    Set result.isRunning = result.runtime.isRunning
    Set result.runtimeState = result.runtime.stateLabel
    return result
}

ClassMethod GetProductionAnalysis(productionName As %VarString) As %DynamicObject
{
    Set production = ..GetProduction(productionName)
    If production.%IsDefined("errorCode") {
        return production
    }

    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.production = production
    Set result.components = production.components
    Set result.connections = []
    Set result.externalSystems = []
    Set result.artifacts = []
    Set result.rules = []
    Set result.messageTypes = []
    Set result.transformations = []
    Set result.businessProcesses = []
    Set result.componentExplanations = []
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "confirmed"

    Do ..AddConnections(productionName, result.components, result.connections, result.warnings)
    Do ..AddRoutingRuleAnalysis(productionName, result.components, result.connections, result.artifacts, result.rules, result.warnings)
    Do ..AddExternalSystems(productionName, result.components, result.externalSystems)
    Do ..AddArtifacts(productionName, result.components, result.artifacts)
    Do ..AddMessageTypes(productionName, result.components, result.messageTypes, result.warnings)
    Do ..AddTransformationAnalysis(productionName, result.artifacts, result.transformations, result.warnings)
    Do ..AddBPLAnalysis(productionName, result.components, result.connections, result.artifacts, result.businessProcesses, result.warnings)
    Do ..AddComponentExplanations(result.components, result.connections, result.externalSystems, result.messageTypes, result.rules, result.transformations, result.businessProcesses, result.componentExplanations)
    Set result.summary = ..BuildProductionSummary(production, result.connections, result.externalSystems, result.artifacts, result.messageTypes, result.transformations, result.businessProcesses)
    Do result.evidence.%Push(..NewEvidence("analysis", productionName, productionName, "ProductionDefinition", "Static analysis model", "confirmed"))
    return result
}

ClassMethod GetProductionSummary(productionName As %VarString) As %DynamicObject
{
    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }

    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.summary = analysis.summary
    Set result.confidence = analysis.confidence
    Set result.evidence = analysis.evidence
    Set result.warnings = analysis.warnings
    return result
}

ClassMethod GetProductionGraph(productionName As %VarString) As %DynamicObject
{
    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }

    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.nodes = []
    Set result.edges = []
    Set result.warnings = analysis.warnings
    Set result.evidence = analysis.evidence
    Set result.confidence = analysis.confidence

    Do ..AddGraphNodes(analysis.components, result.nodes)
    Do ..AddGraphEdges(analysis.connections, analysis.messageTypes, result.edges)
    return result
}

ClassMethod GetComponentDetail(productionName As %VarString, componentName As %VarString) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.componentName = componentName
    Set result.connections = []
    Set result.externalSystems = []
    Set result.artifacts = []
    Set result.rules = []
    Set result.messageTypes = []
    Set result.transformations = []
    Set result.businessProcesses = []
    Set result.warnings = []
    Set result.evidence = []

    If componentName = "" {
        Do result.%Set("errorCode", "INVALID_COMPONENT_NAME")
        return result
    }

    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }

    Set component = ..FindComponentByName(analysis.components, componentName)
    If '$IsObject(component) {
        Do result.%Set("errorCode", "COMPONENT_NOT_FOUND")
        return result
    }

    Set result.component = component
    Set result.explanation = ..FindComponentExplanationByName(analysis.componentExplanations, componentName)
    Set result.confidence = component.confidence
    Set result.warnings = analysis.warnings
    Do ..AddConnectionsForComponent(analysis.connections, componentName, result.connections)
    Do ..AddItemsForComponent(analysis.externalSystems, componentName, result.externalSystems)
    Do ..AddItemsForComponent(analysis.artifacts, componentName, result.artifacts)
    Do ..AddItemsForComponent(analysis.rules, componentName, result.rules)
    Do ..AddItemsForComponent(analysis.messageTypes, componentName, result.messageTypes)
    Do ..AddItemsForComponent(analysis.transformations, componentName, result.transformations)
    Do ..AddItemsForComponent(analysis.businessProcesses, componentName, result.businessProcesses)
    Do ..AddEvidenceFromObject(component, result.evidence)
    Do ..AddEvidenceFromObject(result.explanation, result.evidence)
    return result
}

ClassMethod StartProduction(productionName As %VarString) As %DynamicObject
{
    Set result = ..NewActionResult(productionName, "start")
    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set before = ..GetRuntimeStatus(productionName)
    If (before.isRunning = 1) && (before.currentProduction = productionName) {
        Set result.changed = 0
        Set result.runtime = before
        return result
    }
    If (before.state = 1) && (before.currentProduction '= "") && (before.currentProduction '= productionName) {
        Do result.%Set("errorCode", "PRODUCTION_ALREADY_RUNNING")
        Set result.runtime = before
        return result
    }

    New $ROLES
    Do ..EnableRuntimeControlRole()
    Set sc = ##class(Ens.Director).StartProduction(productionName)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "START_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        Set result.runtime = ..GetRuntimeStatus(productionName)
        return result
    }

    Set result.changed = 1
    Set result.runtime = ..GetRuntimeStatus(productionName)
    return result
}

ClassMethod StopProduction(productionName As %VarString, timeout As %Integer = 10, force As %Boolean = 0) As %DynamicObject
{
    Set result = ..NewActionResult(productionName, "stop")
    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set before = ..GetRuntimeStatus(productionName)
    If before.isRunning '= 1 {
        Set result.changed = 0
        Set result.runtime = before
        return result
    }
    If before.currentProduction '= productionName {
        Do result.%Set("errorCode", "PRODUCTION_NOT_ACTIVE")
        Set result.runtime = before
        return result
    }

    New $ROLES
    Do ..EnableRuntimeControlRole()
    Set sc = ##class(Ens.Director).StopProduction(..NormalizeInteger(timeout, 10), +force)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STOP_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        Set result.runtime = ..GetRuntimeStatus(productionName)
        return result
    }

    Set result.changed = 1
    Set result.runtime = ..GetRuntimeStatus(productionName)
    return result
}

ClassMethod ListMessages(productionName As %VarString = "", limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0) As %DynamicObject
{
    Set result = ..NewListResult()
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Do result.%Set("productionName", productionName)
    Do result.%Set("payloadReturned", 0)
    Do result.%Set("runtimeMessageAnalysisEnabled", settings.runtimeMessageAnalysisEnabled)
    Do result.%Set("maxMessagesReturned", settings.maxMessagesReturned)
    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        return result
    }
    Set limit = ..NormalizeLimitWithMaximum(limit, 50, settings.maxMessagesReturned)
    Set offset = ..NormalizeOffset(offset)
    Set errorsOnly = ..NormalizeBoolean(errorsOnly, 0)
    Do result.%Set("limit", limit)
    Do result.%Set("offset", offset)
    Do result.%Set("sourceConfigName", sourceConfigName)
    Do result.%Set("targetConfigName", targetConfigName)
    Do result.%Set("messageBodyClassName", messageBodyClassName)
    Do result.%Set("sessionId", sessionId)
    Do result.%Set("errorsOnly", errorsOnly)
    Do result.%Set("hasMore", 0)

    If '..ClassExists("Ens.MessageHeader") {
        Do result.warnings.%Push(..NewWarning("MESSAGE_HEADER_NOT_AVAILABLE", "Ens.MessageHeader is not available in this namespace."))
        return result
    }

    Set componentNames = []
    If productionName '= "" {
        If '..IsValidClassName(productionName) {
            Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
            return result
        }
        If '..ClassExtends(productionName, "Ens.Production") {
            Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
            return result
        }
        Set componentList = ..ListComponents(productionName)
        If $IsObject(componentList.items) {
            For componentIndex = 0:1:componentList.items.%Size()-1 {
                Set component = componentList.items.%Get(componentIndex)
                If $IsObject(component) {
                    Do ..PushUnique(componentNames, component.name)
                }
            }
        }
    }

    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT %ID AS MessageId, SessionId, TimeCreated, TimeProcessed, SourceConfigName, TargetConfigName, MessageBodyClassName, MessageBodyId, Status, IsError, ErrorStatus, Type, Invocation, CorrespondingMessageId FROM Ens.MessageHeader ORDER BY TimeCreated DESC, %ID DESC"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return ..AddStatusError(.result, "Status error: "_$System.Status.GetErrorText(sc))
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ..AddStatusError(.result, "SQL error: "_rset.%Message)
    }

    Set skipped = 0
    Set collected = 0
    For {
        Quit:'rset.%Next()
        Continue:'..ShouldIncludeMessageHeader(rset, componentNames, sourceConfigName, targetConfigName, messageBodyClassName, sessionId, errorsOnly)
        If skipped < offset {
            Set skipped = skipped + 1
            Continue
        }
        If collected >= limit {
            Do result.%Set("hasMore", 1)
            Quit
        }
        Do result.items.%Push(..NewMessageHeaderFromRow(rset))
        Set collected = collected + 1
    }

    Do result.%Set("count", result.items.%Size())
    return result
}

ClassMethod ListMessageFacets(productionName As %VarString = "", limit As %Integer = 500) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.maxMessagesReturned = settings.maxMessagesReturned
    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        return result
    }
    Set limit = ..NormalizeLimitWithMaximum(limit, 500, settings.maxMessagesReturned)
    Set result.limit = limit
    Set result.totalCount = 0
    Set result.errorCount = 0
    Set result.hasMore = 0
    Set result.sourceConfigNames = []
    Set result.targetConfigNames = []
    Set result.messageBodyClassNames = []
    Set result.sessionIds = []
    Set result.componentNames = []
    Set result.warnings = []

    If '..ClassExists("Ens.MessageHeader") {
        Do result.warnings.%Push(..NewWarning("MESSAGE_HEADER_NOT_AVAILABLE", "Ens.MessageHeader is not available in this namespace."))
        return result
    }

    Set componentNames = []
    If productionName '= "" {
        If '..IsValidClassName(productionName) {
            Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
            return result
        }
        If '..ClassExtends(productionName, "Ens.Production") {
            Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
            return result
        }
        Set componentList = ..ListComponents(productionName)
        If $IsObject(componentList.items) {
            For componentIndex = 0:1:componentList.items.%Size()-1 {
                Set component = componentList.items.%Get(componentIndex)
                If $IsObject(component) {
                    Do ..PushUnique(componentNames, component.name)
                }
            }
        }
    }

    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT %ID AS MessageId, SessionId, TimeCreated, TimeProcessed, SourceConfigName, TargetConfigName, MessageBodyClassName, MessageBodyId, Status, IsError, ErrorStatus, Type, Invocation, CorrespondingMessageId FROM Ens.MessageHeader ORDER BY TimeCreated DESC, %ID DESC"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return ..AddStatusError(.result, "Status error: "_$System.Status.GetErrorText(sc))
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ..AddStatusError(.result, "SQL error: "_rset.%Message)
    }

    For {
        Quit:'rset.%Next()
        Continue:'..ShouldIncludeMessageHeader(rset, componentNames)
        If result.totalCount >= limit {
            Set result.hasMore = 1
            Quit
        }
        Set result.totalCount = result.totalCount + 1
        If rset.%Get("IsError") {
            Set result.errorCount = result.errorCount + 1
        }
        Do ..PushUnique(result.sourceConfigNames, rset.%Get("SourceConfigName"))
        Do ..PushUnique(result.targetConfigNames, rset.%Get("TargetConfigName"))
        Do ..PushUnique(result.messageBodyClassNames, rset.%Get("MessageBodyClassName"))
        Do ..PushUnique(result.sessionIds, rset.%Get("SessionId"))
        Do ..PushUnique(result.componentNames, rset.%Get("SourceConfigName"))
        Do ..PushUnique(result.componentNames, rset.%Get("TargetConfigName"))
    }
    return result
}

ClassMethod GetMessage(messageId As %Integer) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.messageId = messageId
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.warnings = []

    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        return result
    }

    If '..ClassExists("Ens.MessageHeader") {
        Do result.%Set("errorCode", "MESSAGE_HEADER_NOT_AVAILABLE")
        return result
    }
    If '..IsPositiveInteger(messageId) {
        Do result.%Set("errorCode", "INVALID_MESSAGE_ID")
        return result
    }

    Set message = ..GetMessageHeaderById(messageId)
    If '$IsObject(message) {
        Do result.%Set("errorCode", "MESSAGE_NOT_FOUND")
        return result
    }

    Set result.message = message
    Set result.payloadMetadata = ..NewPayloadMetadata(message, settings)
    return result
}

ClassMethod GetProductionMessage(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set result = {}
    Do result.%Set("productionName", productionName)
    Do result.%Set("messageId", messageId)

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set result = ..GetMessage(messageId)
    If result.%IsDefined("errorCode") {
        Do result.%Set("productionName", productionName)
        return result
    }

    If '..MessageBelongsToProduction(result.message, productionName) {
        Do result.%Set("errorCode", "MESSAGE_NOT_IN_PRODUCTION")
        Do result.%Set("productionName", productionName)
        return result
    }

    Do result.%Set("productionName", productionName)
    return result
}

ClassMethod GetMessagePayloadMetadata(messageId As %Integer) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.messageId = messageId
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.payloadInspectionEnabled = settings.payloadInspectionEnabled
    Set result.payloadInspectionSupported = 0
    Set result.warnings = []
    Set result.evidence = []

    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        return result
    }

    If '..ClassExists("Ens.MessageHeader") {
        Do result.%Set("errorCode", "MESSAGE_HEADER_NOT_AVAILABLE")
        return result
    }
    If '..IsPositiveInteger(messageId) {
        Do result.%Set("errorCode", "INVALID_MESSAGE_ID")
        return result
    }

    Set message = ..GetMessageHeaderById(messageId)
    If '$IsObject(message) {
        Do result.%Set("errorCode", "MESSAGE_NOT_FOUND")
        return result
    }

    Set metadata = ..NewPayloadMetadata(message, settings)
    Set result.metadata = metadata
    Set result.message = message
    Set result.messageBodyClassName = metadata.messageBodyClassName
    Set result.messageBodyId = metadata.messageBodyId
    Set result.bodyReferenceAvailable = metadata.bodyReferenceAvailable
    Set result.restricted = metadata.restricted
    Set result.restrictionReason = metadata.restrictionReason
    Set result.warnings = metadata.warnings
    Set result.evidence = metadata.evidence
    return result
}

ClassMethod GetProductionMessagePayloadMetadata(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set result = ..GetMessagePayloadMetadata(messageId)
    Do result.%Set("productionName", productionName)
    return result
}

ClassMethod GetMessageTrace(messageId As %Integer) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.messageId = messageId
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.maxTraceDepth = settings.maxTraceDepth
    Set result.steps = []
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "observed"

    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        return result
    }

    If '..ClassExists("Ens.MessageHeader") {
        Do result.%Set("errorCode", "MESSAGE_HEADER_NOT_AVAILABLE")
        return result
    }
    If '..IsPositiveInteger(messageId) {
        Do result.%Set("errorCode", "INVALID_MESSAGE_ID")
        return result
    }

    Set selected = ..GetMessageHeaderById(messageId)
    If '$IsObject(selected) {
        Do result.%Set("errorCode", "MESSAGE_NOT_FOUND")
        return result
    }

    Set result.selectedMessage = selected
    Set result.sessionId = selected.sessionId
    Set result.summary = ..BuildTraceSummary(selected)
    If selected.sessionId '= "" {
        Do ..AddTraceStepsBySession(selected.sessionId, result.steps, result.evidence, settings.maxTraceDepth, result.warnings)
    } Else {
        Do result.steps.%Push(..NewTraceStep(selected, 1))
        Do result.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", selected.messageId, "SessionId", selected.sessionId, "observed"))
    }
    Do result.%Set("stepCount", result.steps.%Size())
    If result.steps.%Size() = 0 {
        Do result.warnings.%Push(..NewWarning("TRACE_STEPS_NOT_FOUND", "No message headers were found for the selected message session."))
    }
    Set result.traceOverview = ..NewTraceOverview(selected, result.steps)
    Set result.traceExplanation = ..NewTraceExplanation(selected, result.steps)
    return result
}

ClassMethod GetProductionMessageTrace(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set result = ..GetMessageTrace(messageId)
    Do result.%Set("productionName", productionName)
    Do result.%Set("productionScoped", 1)
    Do ..AnnotateTraceStepsForProduction(result, productionName)
    return result
}

ClassMethod GetMessageExplanation(messageId As %Integer) As %DynamicObject
{
    Set trace = ..GetMessageTrace(messageId)
    If trace.%IsDefined("errorCode") {
        return trace
    }

    Set result = {}
    Set result.namespace = trace.namespace
    Set result.messageId = trace.messageId
    Set result.sessionId = trace.sessionId
    Set result.explanation = trace.traceExplanation
    Set result.summary = trace.summary
    Set result.stepCount = trace.stepCount
    Set result.payloadReturned = trace.payloadReturned
    Set result.runtimeMessageAnalysisEnabled = trace.runtimeMessageAnalysisEnabled
    Set result.warnings = trace.warnings
    Set result.evidence = trace.evidence
    Set result.confidence = trace.confidence
    return result
}

ClassMethod GetProductionMessageExplanation(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set result = ..GetMessageExplanation(messageId)
    Do result.%Set("productionName", productionName)
    return result
}

ClassMethod ListComponents(productionName As %VarString) As %DynamicObject
{
    Set result = ..NewListResult()
    Do result.%Set("productionName", productionName)

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set productionXData = ..ReadXData(productionName, "ProductionDefinition")
    If productionXData = "" {
        Set productionXData = ..ReadXData(productionName, "Production")
    }
    If productionXData = "" {
        Do result.warnings.%Push(..NewWarning("PRODUCTION_XDATA_NOT_FOUND", "No Production XData block was found."))
        return result
    }

    Set position = 1
    For {
        Set found = $Find(productionXData, "<Item ", position)
        Quit:(found = 0)
        Set tagStart = found - $Length("<Item ")
        Set tagEnd = $Find(productionXData, ">", found)
        Quit:(tagEnd = 0)
        Set tag = $Extract(productionXData, tagStart, tagEnd - 1)
        Set close = $Find(productionXData, "</Item>", tagEnd)
        Set next = $Find(productionXData, "<Item ", tagEnd)
        Set block = ""
        If (close '= 0) && ((next = 0) || (close < next)) {
            Set block = $Extract(productionXData, tagEnd, close - $Length("</Item>") - 1)
            Set position = close
        } Else {
            Set position = tagEnd
        }

        Set item = ..BuildComponent(productionName, tag, block)
        Do result.items.%Push(item)
    }

    Do result.%Set("count", result.items.%Size())
    return result
}

ClassMethod BuildComponent(productionName As %VarString, tag As %VarString, block As %VarString) As %DynamicObject [ Private ]
{
    Set component = {}
    Set component.name = ..DecodeXml(..ExtractAttribute(tag, "Name"))
    Set component.className = ..DecodeXml(..ExtractAttribute(tag, "ClassName"))
    Set component.type = ..ComponentType(component.className)
    Set component.enabled = ..NormalizeBoolean(..ExtractAttribute(tag, "Enabled"), 1)
    Set component.category = ..DecodeXml(..ExtractAttribute(tag, "Category"))
    Set component.poolSize = ..NormalizeInteger(..ExtractAttribute(tag, "PoolSize"), 0)
    Set component.comment = ..DecodeXml(..ExtractAttribute(tag, "Comment"))
    Set component.adapterClass = ..GetAdapterClass(component.className)
    Set component.protocol = ..ProtocolFromAdapter(component.adapterClass)
    Set component.settings = ..ExtractSettings(block)
    Set component.targets = ..ExtractTargets(component.settings)
    Set component.confidence = "confirmed"
    Set component.evidence = []
    Do component.evidence.%Push(..NewEvidence("production-definition", productionName, component.name, "Item", component.className, "confirmed"))
    If component.adapterClass '= "" {
        Do component.evidence.%Push(..NewEvidence("adapter-configuration", component.className, component.name, "ADAPTER", component.adapterClass, "confirmed"))
    }
    return component
}

ClassMethod AddConnections(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, warnings As %DynamicArray) [ Private ]
{
    For sourceIndex = 0:1:components.%Size()-1 {
        Set component = components.%Get(sourceIndex)
        Continue:'$IsObject(component)
        Continue:'$IsObject(component.targets)

        For targetIndex = 0:1:component.targets.%Size()-1 {
            Set targetName = component.targets.%Get(targetIndex)
            Continue:(targetName = "")
            Set connection = {}
            Do connection.%Set("from", component.name)
            Do connection.%Set("to", targetName)
            Set connection.kind = "target-config"
            Set connection.confidence = "confirmed"
            Set connection.evidence = []
            Do connection.evidence.%Push(..NewEvidence("production-setting", productionName, component.name, "TargetConfigNames", targetName, "confirmed"))
            If '$IsObject(..FindComponentByName(components, targetName)) {
                Set connection.confidence = "unknown"
                Do warnings.%Push(..NewWarning("TARGET_COMPONENT_NOT_FOUND", "Component "_component.name_" targets "_targetName_", but that target was not found in the production definition."))
            }
            Do connections.%Push(connection)
        }
    }
    return
}

ClassMethod AddRoutingRuleAnalysis(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, artifacts As %DynamicArray, rules As %DynamicArray, warnings As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Continue:'$IsObject(component.settings)
        Continue:'component.settings.%IsDefined("BusinessRuleName")

        Set ruleName = component.settings.%Get("BusinessRuleName")
        Continue:(ruleName = "")
        Set ruleXData = ..ReadXData(ruleName, "RuleDefinition")
        If ruleXData = "" {
            Do warnings.%Push(..NewWarning("ROUTING_RULE_NOT_ACCESSIBLE", "Routing rule "_ruleName_" was referenced by "_component.name_", but its RuleDefinition XData was not available."))
            Continue
        }

        Set rule = ..NewRuleDetail(productionName, ruleName, component.name)
        Set position = 1
        For {
            Set found = $Find(ruleXData, "<when ", position)
            Quit:(found = 0)
            Set tagStart = found - $Length("<when ")
            Set tagEnd = $Find(ruleXData, ">", found)
            Quit:(tagEnd = 0)
            Set tag = $Extract(ruleXData, tagStart, tagEnd - 1)
            Set close = $Find(ruleXData, "</when>", tagEnd)
            Set block = ""
            If close '= 0 {
                Set block = $Extract(ruleXData, tagEnd, close - $Length("</when>") - 1)
                Set position = close
            } Else {
                Set block = $Extract(ruleXData, tagEnd, $Length(ruleXData))
                Set position = tagEnd
            }
            Do ..AddRoutingRuleCondition(productionName, components, connections, artifacts, warnings, rule, component.name, ruleName, tag, block)
        }
        If rule.conditions.%Size() = 0 {
            Do ..AddRoutingRuleCondition(productionName, components, connections, artifacts, warnings, rule, component.name, ruleName, "", ruleXData)
        }
        Do rules.%Push(rule)
    }
    return
}

ClassMethod AddRoutingRuleCondition(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, artifacts As %DynamicArray, warnings As %DynamicArray, rule As %DynamicObject, componentName As %VarString, ruleName As %VarString, whenTag As %VarString, block As %VarString) [ Private ]
{
    Set condition = {}
    Set condition.condition = ..DecodeXml(..ExtractAttribute(whenTag, "condition"))
    Set condition.comment = ..DecodeXml(..ExtractAttribute(whenTag, "comment"))
    Set condition.sends = []
    Set condition.confidence = "confirmed"
    Set condition.evidence = []
    Do condition.evidence.%Push(..NewEvidence("routing-rule", ruleName, componentName, "when.condition", condition.condition, "confirmed"))

    Set position = 1
    For {
        Set found = $Find(block, "<send ", position)
        Quit:(found = 0)
        Set tagStart = found - $Length("<send ")
        Set tagEnd = $Find(block, ">", found)
        Quit:(tagEnd = 0)
        Set tag = $Extract(block, tagStart, tagEnd - 1)
        Set send = ..NewRuleSend(ruleName, componentName, tag)
        Do condition.sends.%Push(send)
        Do rule.sends.%Push(send)
        Do ..AddRoutingRuleTargetConnections(productionName, components, connections, warnings, componentName, ruleName, send.target)
        If send.transform '= "" {
            Do artifacts.%Push(..NewRuleArtifact(ruleName, componentName, "rule-transformation", send.transform, "send.transform"))
        }
        Set position = tagEnd
    }

    If (condition.condition '= "") || (condition.sends.%Size() > 0) {
        Do rule.conditions.%Push(condition)
    }
    return
}

ClassMethod NewRuleDetail(productionName As %VarString, ruleName As %VarString, componentName As %VarString) As %DynamicObject [ Private ]
{
    Set rule = {}
    Set rule.name = ruleName
    Set rule.component = componentName
    Set rule.conditions = []
    Set rule.sends = []
    Set rule.confidence = "confirmed"
    Set rule.evidence = []
    Do rule.evidence.%Push(..NewEvidence("production-setting", productionName, componentName, "BusinessRuleName", ruleName, "confirmed"))
    return rule
}

ClassMethod NewRuleSend(ruleName As %VarString, componentName As %VarString, sendTag As %VarString) As %DynamicObject [ Private ]
{
    Set send = {}
    Set send.target = ..DecodeXml(..ExtractAttribute(sendTag, "target"))
    Set send.transform = ..DecodeXml(..ExtractAttribute(sendTag, "transform"))
    Set send.confidence = "confirmed"
    Set send.evidence = []
    Do send.evidence.%Push(..NewEvidence("routing-rule", ruleName, componentName, "send.target", send.target, "confirmed"))
    If send.transform '= "" {
        Do send.evidence.%Push(..NewEvidence("routing-rule", ruleName, componentName, "send.transform", send.transform, "confirmed"))
    }
    return send
}

ClassMethod AddRoutingRuleTargetConnections(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, warnings As %DynamicArray, componentName As %VarString, ruleName As %VarString, targetValue As %VarString) [ Private ]
{
    Set targetValue = $Translate(targetValue, ";", ",")
    For index = 1:1:$Length(targetValue, ",") {
        Set targetName = $ZStrip($Piece(targetValue, ",", index), "<>W")
        Continue:(targetName = "")
        Set connection = {}
        Do connection.%Set("from", componentName)
        Do connection.%Set("to", targetName)
        Set connection.kind = "routing-rule"
        Set connection.confidence = "confirmed"
        Set connection.ruleName = ruleName
        Set connection.evidence = []
        Do connection.evidence.%Push(..NewEvidence("routing-rule", ruleName, componentName, "send.target", targetName, "confirmed"))
        If '$IsObject(..FindComponentByName(components, targetName)) {
            Set connection.confidence = "unknown"
            Do warnings.%Push(..NewWarning("ROUTING_RULE_TARGET_NOT_FOUND", "Routing rule "_ruleName_" sends from "_componentName_" to "_targetName_", but that target was not found in the production definition."))
        }
        Do connections.%Push(connection)
    }
    return
}

ClassMethod AddExternalSystems(productionName As %VarString, components As %DynamicArray, externalSystems As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Continue:'$IsObject(component.settings)

        If component.settings.%IsDefined("FilePath") {
            Set value = component.settings.%Get("FilePath")
            If value '= "" {
                Do externalSystems.%Push(..NewExternalSystem(productionName, component.name, component.type, "file-path", value, "FilePath"))
            }
        }
        If component.settings.%IsDefined("URL") {
            Set value = component.settings.%Get("URL")
            If value '= "" {
                Do externalSystems.%Push(..NewExternalSystem(productionName, component.name, component.type, "url", value, "URL"))
            }
        }
        If component.settings.%IsDefined("HTTPServer") {
            Set value = component.settings.%Get("HTTPServer")
            If value '= "" {
                Do externalSystems.%Push(..NewExternalSystem(productionName, component.name, component.type, "http-server", value, "HTTPServer"))
            }
        }
        If component.settings.%IsDefined("Port") {
            Set value = component.settings.%Get("Port")
            If value '= "" {
                Do externalSystems.%Push(..NewExternalSystem(productionName, component.name, component.type, "port", value, "Port"))
            }
        }
    }
    return
}

ClassMethod AddArtifacts(productionName As %VarString, components As %DynamicArray, artifacts As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Continue:'$IsObject(component.settings)

        If component.settings.%IsDefined("BusinessRuleName") {
            Set value = component.settings.%Get("BusinessRuleName")
            If value '= "" {
                Do artifacts.%Push(..NewArtifact(productionName, component.name, "routing-rule", value, "BusinessRuleName"))
            }
        }
        If component.settings.%IsDefined("Transform") {
            Set value = component.settings.%Get("Transform")
            If value '= "" {
                Do artifacts.%Push(..NewArtifact(productionName, component.name, "transformation", value, "Transform"))
            }
        }
        If component.settings.%IsDefined("RecordMap") {
            Set value = component.settings.%Get("RecordMap")
            If value '= "" {
                Do artifacts.%Push(..NewArtifact(productionName, component.name, "record-map", value, "RecordMap"))
            }
        }
    }
    return
}

ClassMethod AddMessageTypes(productionName As %VarString, components As %DynamicArray, messageTypes As %DynamicArray, warnings As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Continue:(component.className = "")

        Set methodName = ..MessageHandlerMethod(component.type)
        Continue:(methodName = "")

        Set method = ..GetCompiledMethod(component.className, methodName)
        If '$IsObject(method) {
            Do warnings.%Push(..NewWarning("MESSAGE_HANDLER_NOT_FOUND", "Component "_component.name_" uses class "_component.className_", but method "_methodName_" was not found in compiled metadata."))
            Continue
        }

        Set parameters = ..ParseFormalSpec(method.formalSpec)
        For paramIndex = 0:1:parameters.%Size()-1 {
            Set parameter = parameters.%Get(paramIndex)
            Continue:'$IsObject(parameter)
            Continue:(parameter.type = "")
            Do messageTypes.%Push(..NewMessageType(productionName, component, methodName, parameter.name, parameter.type, parameter.direction))
        }
    }
    return
}

ClassMethod AddTransformationAnalysis(productionName As %VarString, artifacts As %DynamicArray, transformations As %DynamicArray, warnings As %DynamicArray) [ Private ]
{
    For index = 0:1:artifacts.%Size()-1 {
        Set artifact = artifacts.%Get(index)
        Continue:'$IsObject(artifact)
        Continue:((artifact.kind '= "transformation") && (artifact.kind '= "rule-transformation"))
        Continue:(artifact.name = "")
        Continue:..HasTransformation(transformations, artifact.name, artifact.component)

        Set transformXData = ..ReadXData(artifact.name, "DTL")
        If transformXData = "" {
            Do warnings.%Push(..NewWarning("TRANSFORMATION_NOT_ACCESSIBLE", "Transformation "_artifact.name_" was referenced by "_artifact.component_", but its DTL XData was not available."))
            Continue
        }
        Do transformations.%Push(..NewTransformationDetail(productionName, artifact.name, artifact.component, artifact.kind, transformXData))
    }
    return
}

ClassMethod HasTransformation(transformations As %DynamicArray, transformName As %VarString, componentName As %VarString) As %Boolean [ Private ]
{
    For index = 0:1:transformations.%Size()-1 {
        Set transformation = transformations.%Get(index)
        If $IsObject(transformation) {
            If (transformation.name = transformName) && (transformation.component = componentName) {
                return 1
            }
        }
    }
    return 0
}

ClassMethod NewTransformationDetail(productionName As %VarString, transformName As %VarString, componentName As %VarString, sourceKind As %VarString, transformXData As %VarString) As %DynamicObject [ Private ]
{
    Set detail = {}
    Set transformTag = ..FindXmlStartTag(transformXData, "transform")
    Set detail.name = transformName
    Set detail.component = componentName
    Set detail.sourceKind = sourceKind
    Set detail.sourceClass = ..NormalizeClassName(..DecodeXml(..ExtractAttribute(transformTag, "sourceClass")))
    Set detail.targetClass = ..NormalizeClassName(..DecodeXml(..ExtractAttribute(transformTag, "targetClass")))
    Set detail.create = ..DecodeXml(..ExtractAttribute(transformTag, "create"))
    Set detail.language = ..DecodeXml(..ExtractAttribute(transformTag, "language"))
    Set detail.actions = ..NewTransformationActionCounts(transformXData)
    Set detail.assignments = []
    Do ..AddTransformationAssignments(transformName, componentName, transformXData, detail.assignments)
    Set detail.confidence = "confirmed"
    Set detail.evidence = []
    Do detail.evidence.%Push(..NewEvidence("dtl-transformation", transformName, componentName, "DTL", detail.sourceClass_" -> "_detail.targetClass, "confirmed"))
    return detail
}

ClassMethod NewTransformationActionCounts(transformXData As %VarString) As %DynamicObject [ Private ]
{
    Set actions = {}
    Set actions.assign = ..CountXmlElements(transformXData, "assign")
    Do actions.%Set("if", ..CountXmlElements(transformXData, "if"))
    Set actions.foreach = ..CountXmlElements(transformXData, "foreach")
    Set actions.subtransform = ..CountXmlElements(transformXData, "subtransform")
    Set actions.code = ..CountXmlElements(transformXData, "code")
    return actions
}

ClassMethod AddTransformationAssignments(transformName As %VarString, componentName As %VarString, transformXData As %VarString, assignments As %DynamicArray) [ Private ]
{
    Set lowerXData = $ZConvert(transformXData, "L")
    Set position = 1
    For {
        Set found = $Find(lowerXData, "<assign ", position)
        Quit:(found = 0)
        Set tagStart = found - $Length("<assign ")
        Set tagEnd = $Find(transformXData, ">", found)
        Quit:(tagEnd = 0)
        Set tag = $Extract(transformXData, tagStart, tagEnd - 1)
        Set assignment = {}
        Set assignment.property = ..DecodeXml(..ExtractAttribute(tag, "property"))
        Set assignment.value = ..DecodeXml(..ExtractAttribute(tag, "value"))
        Set assignment.action = ..DecodeXml(..ExtractAttribute(tag, "action"))
        Set assignment.confidence = "confirmed"
        Set assignment.evidence = []
        Do assignment.evidence.%Push(..NewEvidence("dtl-transformation", transformName, componentName, "assign", assignment.property_" = "_assignment.value, "confirmed"))
        Do assignments.%Push(assignment)
        Set position = tagEnd
    }
    return
}

ClassMethod AddBPLAnalysis(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, artifacts As %DynamicArray, businessProcesses As %DynamicArray, warnings As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Continue:(component.type '= "business-process")
        Continue:(component.className = "")
        Set bplXData = ..ReadXData(component.className, "BPL")
        If bplXData = "" {
            Continue
        }

        Do artifacts.%Push(..NewArtifact(productionName, component.name, "bpl-process", component.className, "BPL"))
        Do businessProcesses.%Push(..NewBPLDetail(productionName, component, bplXData))
        Do ..AddBPLCallConnections(productionName, components, connections, warnings, component.name, component.className, bplXData)
    }
    return
}

ClassMethod NewBPLDetail(productionName As %VarString, component As %DynamicObject, bplXData As %VarString) As %DynamicObject [ Private ]
{
    Set detail = {}
    Set processTag = ..FindXmlStartTag(bplXData, "process")
    Set detail.name = component.className
    Set detail.component = component.name
    Set detail.requestClass = ..NormalizeClassName(..DecodeXml(..ExtractAttribute(processTag, "request")))
    Set detail.responseClass = ..NormalizeClassName(..DecodeXml(..ExtractAttribute(processTag, "response")))
    Set detail.contextClass = ..NormalizeClassName(..DecodeXml(..ExtractAttribute(processTag, "context")))
    Set detail.actions = ..NewBPLActionCounts(bplXData)
    Set detail.calls = []
    Do ..AddBPLCalls(component.className, component.name, bplXData, detail.calls)
    Set detail.confidence = "confirmed"
    Set detail.evidence = []
    Do detail.evidence.%Push(..NewEvidence("bpl-process", component.className, component.name, "BPL", "Business process definition", "confirmed"))
    return detail
}

ClassMethod NewBPLActionCounts(bplXData As %VarString) As %DynamicObject [ Private ]
{
    Set actions = {}
    Set actions.call = ..CountXmlElements(bplXData, "call")
    Set actions.sync = ..CountXmlElements(bplXData, "sync")
    Set actions.reply = ..CountXmlElements(bplXData, "reply")
    Set actions.assign = ..CountXmlElements(bplXData, "assign")
    Set actions.switch = ..CountXmlElements(bplXData, "switch")
    Set actions.case = ..CountXmlElements(bplXData, "case")
    Do actions.%Set("if", ..CountXmlElements(bplXData, "if"))
    Set actions.code = ..CountXmlElements(bplXData, "code")
    Set actions.trace = ..CountXmlElements(bplXData, "trace")
    return actions
}

ClassMethod AddBPLCalls(processClass As %VarString, componentName As %VarString, bplXData As %VarString, calls As %DynamicArray) [ Private ]
{
    Set lowerXData = $ZConvert(bplXData, "L")
    Set position = 1
    For {
        Set found = $Find(lowerXData, "<call ", position)
        Quit:(found = 0)
        Set tagStart = found - $Length("<call ")
        Set tagEnd = $Find(bplXData, ">", found)
        Quit:(tagEnd = 0)
        Set tag = $Extract(bplXData, tagStart, tagEnd - 1)
        Set call = {}
        Set call.name = ..DecodeXml(..ExtractAttribute(tag, "name"))
        Set call.target = ..DecodeXml(..ExtractAttribute(tag, "target"))
        Set call.async = ..NormalizeBoolean(..ExtractAttribute(tag, "async"), 0)
        Set call.timeout = ..DecodeXml(..ExtractAttribute(tag, "timeout"))
        Set call.confidence = "confirmed"
        Set call.evidence = []
        Do call.evidence.%Push(..NewEvidence("bpl-process", processClass, componentName, "call.target", call.target, "confirmed"))
        Do calls.%Push(call)
        Set position = tagEnd
    }
    return
}

ClassMethod AddBPLCallConnections(productionName As %VarString, components As %DynamicArray, connections As %DynamicArray, warnings As %DynamicArray, componentName As %VarString, processClass As %VarString, bplXData As %VarString) [ Private ]
{
    Set calls = []
    Do ..AddBPLCalls(processClass, componentName, bplXData, calls)
    For index = 0:1:calls.%Size()-1 {
        Set call = calls.%Get(index)
        Continue:'$IsObject(call)
        Continue:(call.target = "")
        Set connection = {}
        Do connection.%Set("from", componentName)
        Do connection.%Set("to", call.target)
        Set connection.kind = "bpl-call"
        Set connection.confidence = "confirmed"
        Set connection.processClass = processClass
        Set connection.evidence = []
        Do connection.evidence.%Push(..NewEvidence("bpl-process", processClass, componentName, "call.target", call.target, "confirmed"))
        If '$IsObject(..FindComponentByName(components, call.target)) {
            Set connection.confidence = "unknown"
            Do warnings.%Push(..NewWarning("BPL_CALL_TARGET_NOT_FOUND", "BPL process "_processClass_" calls target "_call.target_", but that target was not found in the production definition."))
        }
        Do connections.%Push(connection)
    }
    return
}

ClassMethod CountXmlElements(content As %VarString, elementName As %VarString) As %Integer [ Private ]
{
    Set count = 0
    Set lowerContent = $ZConvert(content, "L")
    Set token = "<"_$ZConvert(elementName, "L")
    Set position = 1
    For {
        Set found = $Find(lowerContent, token, position)
        Quit:(found = 0)
        Set nextChar = $Extract(lowerContent, found)
        If (nextChar = " ") || (nextChar = ">") || (nextChar = "/") {
            Set count = count + 1
        }
        Set position = found
    }
    return count
}

ClassMethod AddComponentExplanations(components As %DynamicArray, connections As %DynamicArray, externalSystems As %DynamicArray, messageTypes As %DynamicArray, rules As %DynamicArray, transformations As %DynamicArray, businessProcesses As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Do explanations.%Push(..NewComponentExplanation(component, connections, externalSystems, messageTypes, rules, transformations, businessProcesses))
    }
    return
}

ClassMethod AddGraphNodes(components As %DynamicArray, nodes As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Do nodes.%Push(..NewGraphNode(component))
    }
    return
}

ClassMethod NewGraphNode(component As %DynamicObject) As %DynamicObject [ Private ]
{
    Set node = {}
    Set node.id = component.name
    Set node.label = component.name
    Set node.type = component.type
    Set node.className = component.className
    Set node.enabled = component.enabled
    Set node.protocol = component.protocol
    Set node.adapterClass = component.adapterClass
    Set node.confidence = component.confidence
    Set node.evidence = component.evidence
    return node
}

ClassMethod AddGraphEdges(connections As %DynamicArray, messageTypes As %DynamicArray, edges As %DynamicArray) [ Private ]
{
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        Do edges.%Push(..NewGraphEdge(connection, messageTypes, index))
    }
    return
}

ClassMethod NewGraphEdge(connection As %DynamicObject, messageTypes As %DynamicArray, index As %Integer) As %DynamicObject [ Private ]
{
    Set edge = {}
    Set edge.id = connection.%Get("from")_"->"_connection.%Get("to")_"#"_index
    Set edge.source = connection.%Get("from")
    Set edge.target = connection.%Get("to")
    Set edge.relationship = "sends"
    Set edge.kind = connection.kind
    Set edge.messageTypes = ..MessageClassesForGraphEdge(messageTypes, connection.%Get("from"), connection.%Get("to"))
    If connection.%IsDefined("ruleName") {
        Set edge.ruleName = connection.ruleName
    }
    If connection.%IsDefined("processClass") {
        Set edge.processClass = connection.processClass
    }
    Set edge.confidence = connection.confidence
    Set edge.evidence = connection.evidence
    return edge
}

ClassMethod MessageClassesForGraphEdge(messageTypes As %DynamicArray, sourceName As %VarString, targetName As %VarString) As %DynamicArray [ Private ]
{
    Set names = ..MessageClassesForComponent(messageTypes, sourceName, "output")
    If names.%Size() = 0 {
        Set names = ..MessageClassesForComponent(messageTypes, targetName, "input")
    }
    return names
}

ClassMethod NewComponentExplanation(component As %DynamicObject, connections As %DynamicArray, externalSystems As %DynamicArray, messageTypes As %DynamicArray, rules As %DynamicArray, transformations As %DynamicArray, businessProcesses As %DynamicArray) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.component = component.name
    Set explanation.componentType = component.type
    Set explanation.text = ..BuildComponentExplanationText(component, connections, externalSystems, messageTypes, rules, transformations, businessProcesses)
    Set explanation.confidence = "confirmed"
    Set explanation.evidence = []
    If $IsObject(component.evidence) {
        For evidenceIndex = 0:1:component.evidence.%Size()-1 {
            Set evidence = component.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildComponentExplanationText(component As %DynamicObject, connections As %DynamicArray, externalSystems As %DynamicArray, messageTypes As %DynamicArray, rules As %DynamicArray, transformations As %DynamicArray, businessProcesses As %DynamicArray) As %VarString [ Private ]
{
    Set typeText = ..ComponentTypeText(component.type)
    Set text = component.name_" is a "_typeText
    If component.protocol '= "unknown" {
        Set text = text_" using "_component.protocol
    }
    Set text = text_"."

    Set incoming = ..ConnectionNamesForComponent(connections, component.name, "incoming")
    Set outgoing = ..ConnectionNamesForComponent(connections, component.name, "outgoing")
    If incoming.%Size() > 0 {
        Set text = text_" It receives from "_..JoinArray(incoming)_"."
    }
    If outgoing.%Size() > 0 {
        Set text = text_" It sends to "_..JoinArray(outgoing)_"."
    }

    Set inputMessages = ..MessageClassesForComponent(messageTypes, component.name, "input")
    Set outputMessages = ..MessageClassesForComponent(messageTypes, component.name, "output")
    If inputMessages.%Size() > 0 {
        Set text = text_" Input message signatures include "_..JoinArray(inputMessages)_"."
    }
    If outputMessages.%Size() > 0 {
        Set text = text_" Output message signatures include "_..JoinArray(outputMessages)_"."
    }

    Set endpoints = ..ExternalValuesForComponent(externalSystems, component.name)
    If endpoints.%Size() > 0 {
        Set text = text_" External settings include "_..JoinArray(endpoints)_"."
    }

    Set ruleNames = ..RuleNamesForComponent(rules, component.name)
    If ruleNames.%Size() > 0 {
        Set text = text_" Routing is controlled by "_..JoinArray(ruleNames)_"."
    }

    Set transformNames = ..TransformationNamesForComponent(transformations, component.name)
    If transformNames.%Size() > 0 {
        Set text = text_" It applies "_..JoinArray(transformNames)_"."
    }

    Set processNames = ..BPLNamesForComponent(businessProcesses, component.name)
    If processNames.%Size() > 0 {
        Set text = text_" BPL process logic is defined by "_..JoinArray(processNames)_"."
    }

    If component.enabled = 0 {
        Set text = text_" The component is disabled."
    }
    return text
}

ClassMethod ComponentTypeText(componentType As %VarString) As %VarString [ Private ]
{
    If componentType = "business-service" {
        return "business service"
    }
    If componentType = "business-process" {
        return "business process"
    }
    If componentType = "business-operation" {
        return "business operation"
    }
    return "production component"
}

ClassMethod ConnectionNamesForComponent(connections As %DynamicArray, componentName As %VarString, direction As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        If direction = "incoming" {
            If connection.%Get("to") = componentName {
                Do ..PushUnique(names, connection.%Get("from"))
            }
        } Else {
            If connection.%Get("from") = componentName {
                Do ..PushUnique(names, connection.%Get("to"))
            }
        }
    }
    return names
}

ClassMethod MessageClassesForComponent(messageTypes As %DynamicArray, componentName As %VarString, direction As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    For index = 0:1:messageTypes.%Size()-1 {
        Set message = messageTypes.%Get(index)
        Continue:'$IsObject(message)
        If (message.component = componentName) && (message.direction = direction) {
            Do ..PushUnique(names, message.messageClass)
        }
    }
    return names
}

ClassMethod ExternalValuesForComponent(externalSystems As %DynamicArray, componentName As %VarString) As %DynamicArray [ Private ]
{
    Set values = []
    For index = 0:1:externalSystems.%Size()-1 {
        Set external = externalSystems.%Get(index)
        Continue:'$IsObject(external)
        If external.component = componentName {
            Do ..PushUnique(values, external.kind_": "_external.value)
        }
    }
    return values
}

ClassMethod RuleNamesForComponent(rules As %DynamicArray, componentName As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    For index = 0:1:rules.%Size()-1 {
        Set rule = rules.%Get(index)
        Continue:'$IsObject(rule)
        If rule.component = componentName {
            Do ..PushUnique(names, rule.name)
        }
    }
    return names
}

ClassMethod TransformationNamesForComponent(transformations As %DynamicArray, componentName As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    For index = 0:1:transformations.%Size()-1 {
        Set transformation = transformations.%Get(index)
        Continue:'$IsObject(transformation)
        If transformation.component = componentName {
            Do ..PushUnique(names, transformation.name)
        }
    }
    return names
}

ClassMethod BPLNamesForComponent(businessProcesses As %DynamicArray, componentName As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    For index = 0:1:businessProcesses.%Size()-1 {
        Set process = businessProcesses.%Get(index)
        Continue:'$IsObject(process)
        If process.component = componentName {
            Do ..PushUnique(names, process.name)
        }
    }
    return names
}

ClassMethod PushUnique(items As %DynamicArray, value As %VarString) [ Private ]
{
    If value = "" {
        return
    }
    For index = 0:1:items.%Size()-1 {
        If items.%Get(index) = value {
            return
        }
    }
    Do items.%Push(value)
    return
}

ClassMethod JoinArray(items As %DynamicArray) As %VarString [ Private ]
{
    Set text = ""
    For index = 0:1:items.%Size()-1 {
        If index > 0 {
            Set text = text_", "
        }
        Set text = text_items.%Get(index)
    }
    return text
}

ClassMethod JoinArrayWithSeparator(items As %DynamicArray, separator As %VarString) As %VarString [ Private ]
{
    Set text = ""
    For index = 0:1:items.%Size()-1 {
        If index > 0 {
            Set text = text_separator
        }
        Set text = text_items.%Get(index)
    }
    return text
}

ClassMethod MessageHandlerMethod(componentType As %VarString) As %VarString [ Private ]
{
    If componentType = "business-service" {
        return "OnProcessInput"
    }
    If componentType = "business-process" {
        return "OnRequest"
    }
    If componentType = "business-operation" {
        return "OnMessage"
    }
    return ""
}

ClassMethod GetCompiledMethod(className As %VarString, methodName As %VarString) As %DynamicObject [ Private ]
{
    Set method = ""
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name, FormalSpec, ReturnType FROM %Dictionary.CompiledMethod WHERE parent = ? AND Name = ?")
    If $$$ISERR(sc) {
        return method
    }
    Set rset = stmt.%Execute(className, methodName)
    If rset.%SQLCODE < 0 {
        return method
    }
    If rset.%Next() {
        Set method = {}
        Set method.name = rset.%Get("Name")
        Set method.formalSpec = rset.%Get("FormalSpec")
        Set method.returnType = rset.%Get("ReturnType")
    }
    return method
}

ClassMethod ParseFormalSpec(formalSpec As %VarString) As %DynamicArray [ Private ]
{
    Set parameters = []
    For index = 1:1:$Length(formalSpec, ",") {
        Set part = $ZStrip($Piece(formalSpec, ",", index), "<>W")
        Continue:(part = "")
        Set parameter = ..ParseFormalParameter(part, index)
        If $IsObject(parameter) {
            Do parameters.%Push(parameter)
        }
    }
    return parameters
}

ClassMethod ParseFormalParameter(part As %VarString, position As %Integer) As %DynamicObject [ Private ]
{
    Set parameter = {}
    Set parameter.name = ""
    Set parameter.type = ""
    Set parameter.direction = $Select(position = 1:"input", 1:"output")

    Set lower = $ZConvert(part, "L")
    If lower["output " {
        Set parameter.direction = "output"
        Set part = $ZStrip($Replace(part, "Output ", ""), "<>W")
        Set part = $ZStrip($Replace(part, "output ", ""), "<>W")
    }
    If lower["byref " {
        Set parameter.direction = "output"
        Set part = $ZStrip($Replace(part, "ByRef ", ""), "<>W")
        Set part = $ZStrip($Replace(part, "byref ", ""), "<>W")
    }

    If $ZConvert(part, "L")[" as " {
        Set namePart = $Piece(part, " As ", 1)
        If namePart = part {
            Set namePart = $Piece(part, " as ", 1)
        }
        Set typePart = $Piece(part, " As ", 2, *)
        If typePart = "" {
            Set typePart = $Piece(part, " as ", 2, *)
        }
        Set parameter.name = $ZStrip(namePart, "<>W")
        Set parameter.type = $ZStrip(typePart, "<>W")
    } Else {
        Set parameter.name = $ZStrip($Piece(part, ":", 1), "<>W")
        Set parameter.type = $ZStrip($Piece(part, ":", 2), "<>W")
        Set direction = $ZConvert($Piece(part, ":", 3), "L")
        If direction["output" {
            Set parameter.direction = "output"
        }
        If direction["byref" {
            Set parameter.direction = "output"
        }
    }

    If $Extract(parameter.name, 1) = "." {
        Set parameter.name = $Extract(parameter.name, 2, $Length(parameter.name))
    }
    If ($Extract(parameter.name, 1) = "*") || ($Extract(parameter.name, 1) = "&") {
        Set parameter.direction = "output"
        Set parameter.name = $Extract(parameter.name, 2, $Length(parameter.name))
    }
    If $Extract(parameter.type, 1) = "." {
        Set parameter.type = $Extract(parameter.type, 2, $Length(parameter.type))
    }
    Set parameter.type = ..NormalizeClassName(parameter.type)
    return parameter
}

ClassMethod NormalizeClassName(className As %VarString) As %VarString [ Private ]
{
    If $Extract(className, 1, 9) = "%Library." {
        return "%" _ $Piece(className, ".", 2, $Length(className, "."))
    }
    return className
}

ClassMethod NewMessageType(productionName As %VarString, component As %DynamicObject, methodName As %VarString, parameterName As %VarString, messageClass As %VarString, direction As %VarString) As %DynamicObject [ Private ]
{
    Set message = {}
    Set message.component = component.name
    Set message.componentType = component.type
    Set message.className = component.className
    Set message.method = methodName
    Set message.parameter = parameterName
    Set message.direction = direction
    Set message.messageClass = messageClass
    Set message.confidence = "confirmed"
    Set message.evidence = []
    Do message.evidence.%Push(..NewEvidence("compiled-method", component.className, component.name, methodName_"."_parameterName, messageClass, "confirmed"))
    return message
}

ClassMethod NewExternalSystem(productionName As %VarString, componentName As %VarString, componentType As %VarString, kind As %VarString, value As %VarString, field As %VarString) As %DynamicObject [ Private ]
{
    Set external = {}
    Set external.component = componentName
    Set external.componentType = componentType
    Set external.kind = kind
    Set external.value = value
    Set external.confidence = "confirmed"
    Set external.evidence = []
    Do external.evidence.%Push(..NewEvidence("production-setting", productionName, componentName, field, value, "confirmed"))
    return external
}

ClassMethod ShouldIncludeMessageHeader(rset As %SQL.IResultSet, componentNames As %DynamicArray, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0) As %Boolean [ Private ]
{
    Set source = rset.%Get("SourceConfigName")
    Set target = rset.%Get("TargetConfigName")
    If componentNames.%Size() > 0 {
        Set productionMatch = 0
        For index = 0:1:componentNames.%Size()-1 {
            Set componentName = componentNames.%Get(index)
            If (source = componentName) || (target = componentName) {
                Set productionMatch = 1
                Quit
            }
        }
        If 'productionMatch {
            return 0
        }
    }
    If (sourceConfigName '= "") && (source '= sourceConfigName) {
        return 0
    }
    If (targetConfigName '= "") && (target '= targetConfigName) {
        return 0
    }
    If (messageBodyClassName '= "") && (rset.%Get("MessageBodyClassName") '= messageBodyClassName) {
        return 0
    }
    If (sessionId '= "") && (rset.%Get("SessionId") '= sessionId) {
        return 0
    }
    If errorsOnly && (rset.%Get("IsError") '= 1) {
        return 0
    }
    return 1
}

ClassMethod MessageBelongsToProduction(message As %DynamicObject, productionName As %VarString) As %Boolean [ Private ]
{
    If '$IsObject(message) {
        return 0
    }

    Set componentList = ..ListComponents(productionName)
    If '$IsObject(componentList.items) {
        return 0
    }

    For index = 0:1:componentList.items.%Size()-1 {
        Set component = componentList.items.%Get(index)
        If $IsObject(component) {
            If (message.sourceConfigName = component.name) || (message.targetConfigName = component.name) {
                return 1
            }
        }
    }
    return 0
}

ClassMethod AnnotateTraceStepsForProduction(trace As %DynamicObject, productionName As %VarString) [ Private ]
{
    If '$IsObject(trace) {
        return
    }
    If '$IsObject(trace.steps) {
        return
    }

    Set componentNames = ..ProductionComponentNames(productionName)
    Set productionStepCount = 0
    For index = 0:1:trace.steps.%Size()-1 {
        Set step = trace.steps.%Get(index)
        If $IsObject(step) {
            Set sourceInProduction = ..NameInArray(componentNames, step.source)
            Set targetInProduction = ..NameInArray(componentNames, step.target)
            Set inProduction = sourceInProduction || targetInProduction
            Set step.productionName = productionName
            Set step.sourceInProduction = sourceInProduction
            Set step.targetInProduction = targetInProduction
            Set step.inProduction = inProduction
            If inProduction {
                Set productionStepCount = productionStepCount + 1
            }
        }
    }
    Do trace.%Set("productionStepCount", productionStepCount)
    If productionStepCount < trace.steps.%Size() {
        Do trace.warnings.%Push(..NewWarning("TRACE_HAS_EXTERNAL_STEPS", "The selected message belongs to the requested production, but the reconstructed session trace includes steps outside that production."))
    }
    return
}

ClassMethod ProductionComponentNames(productionName As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    Set componentList = ..ListComponents(productionName)
    If '$IsObject(componentList.items) {
        return names
    }

    For index = 0:1:componentList.items.%Size()-1 {
        Set component = componentList.items.%Get(index)
        If $IsObject(component) {
            Do ..PushUnique(names, component.name)
        }
    }
    return names
}

ClassMethod NameInArray(names As %DynamicArray, value As %VarString) As %Boolean [ Private ]
{
    If value = "" {
        return 0
    }
    For index = 0:1:names.%Size()-1 {
        If names.%Get(index) = value {
            return 1
        }
    }
    return 0
}

ClassMethod NewMessageHeaderFromRow(rset As %SQL.IResultSet) As %DynamicObject [ Private ]
{
    Set header = {}
    Set header.messageId = rset.%Get("MessageId")
    Set header.sessionId = rset.%Get("SessionId")
    Set header.timeCreated = rset.%Get("TimeCreated")
    Set header.timeProcessed = rset.%Get("TimeProcessed")
    Set header.sourceConfigName = rset.%Get("SourceConfigName")
    Set header.targetConfigName = rset.%Get("TargetConfigName")
    Set header.messageBodyClassName = rset.%Get("MessageBodyClassName")
    Set header.messageBodyId = rset.%Get("MessageBodyId")
    Set header.status = rset.%Get("Status")
    Set header.isError = rset.%Get("IsError")
    Set header.errorStatus = rset.%Get("ErrorStatus")
    Set header.type = rset.%Get("Type")
    Set header.invocation = rset.%Get("Invocation")
    Set header.correspondingMessageId = rset.%Get("CorrespondingMessageId")
    Set header.payloadReturned = 0
    Set header.confidence = "observed"
    Set header.evidence = []
    Do header.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", header.messageId, "MessageBodyClassName", header.messageBodyClassName, "observed"))
    return header
}

ClassMethod NewPayloadMetadata(message As %DynamicObject, settings As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metadata = {}
    Set metadata.messageId = message.messageId
    Set metadata.messageBodyClassName = message.messageBodyClassName
    Set metadata.messageBodyId = message.messageBodyId
    Set metadata.payloadReturned = 0
    Set metadata.payloadInspectionEnabled = settings.payloadInspectionEnabled
    Set metadata.payloadInspectionSupported = 0
    Set metadata.bodyReferenceAvailable = (message.messageBodyClassName '= "") && (message.messageBodyId '= "")
    Set metadata.bodyClassExists = 0
    If message.messageBodyClassName '= "" {
        Set metadata.bodyClassExists = ..ClassExists(message.messageBodyClassName)
    }
    Set metadata.restricted = 1
    Set metadata.restrictionReason = "PAYLOAD_INSPECTION_UNSUPPORTED"
    Set metadata.fields = []
    Set metadata.warnings = []
    Set metadata.evidence = []
    Do metadata.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", message.messageId, "MessageBodyClassName", message.messageBodyClassName, "observed"))
    Do metadata.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", message.messageId, "MessageBodyId", message.messageBodyId, "observed"))
    If 'settings.payloadInspectionEnabled {
        Set metadata.restrictionReason = "PAYLOAD_INSPECTION_DISABLED"
        Do metadata.warnings.%Push(..NewWarning("PAYLOAD_INSPECTION_DISABLED", "Payload inspection is disabled by module settings. Message body content was not read or returned."))
        return metadata
    }
    Do metadata.warnings.%Push(..NewWarning("PAYLOAD_INSPECTION_UNSUPPORTED", "Payload metadata inspection is not implemented in this version. Message body content was not read or returned."))
    return metadata
}

ClassMethod GetMessageHeaderById(messageId As %Integer) As %DynamicObject [ Private ]
{
    Set header = ""
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT %ID AS MessageId, SessionId, TimeCreated, TimeProcessed, SourceConfigName, TargetConfigName, MessageBodyClassName, MessageBodyId, Status, IsError, ErrorStatus, Type, Invocation, CorrespondingMessageId FROM Ens.MessageHeader WHERE %ID = ?"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return header
    }
    Set rset = stmt.%Execute(messageId)
    If rset.%SQLCODE < 0 {
        return header
    }
    If rset.%Next() {
        Set header = ..NewMessageHeaderFromRow(rset)
    }
    return header
}

ClassMethod AddTraceStepsBySession(sessionId As %Integer, steps As %DynamicArray, evidence As %DynamicArray, maxTraceDepth As %Integer = 50, warnings As %DynamicArray = "") [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT %ID AS MessageId, SessionId, TimeCreated, TimeProcessed, SourceConfigName, TargetConfigName, MessageBodyClassName, MessageBodyId, Status, IsError, ErrorStatus, Type, Invocation, CorrespondingMessageId FROM Ens.MessageHeader WHERE SessionId = ? ORDER BY TimeCreated, %ID"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return
    }
    Set rset = stmt.%Execute(sessionId)
    If rset.%SQLCODE < 0 {
        return
    }
    Set sequence = 1
    For {
        Quit:'rset.%Next()
        If sequence > maxTraceDepth {
            If $IsObject(warnings) {
                Do warnings.%Push(..NewWarning("TRACE_DEPTH_LIMIT_REACHED", "Trace reconstruction stopped at the configured maxTraceDepth of "_maxTraceDepth_"."))
            }
            Quit
        }
        Set header = ..NewMessageHeaderFromRow(rset)
        Do steps.%Push(..NewTraceStep(header, sequence))
        Do evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", header.messageId, "SessionId", sessionId, "observed"))
        Set sequence = sequence + 1
    }
    return
}

ClassMethod NewTraceStep(header As %DynamicObject, sequence As %Integer) As %DynamicObject [ Private ]
{
    Set step = {}
    Set step.sequence = sequence
    Set step.messageId = header.messageId
    Set step.sessionId = header.sessionId
    Set step.timeCreated = header.timeCreated
    Set step.timeProcessed = header.timeProcessed
    Set step.source = header.sourceConfigName
    Set step.target = header.targetConfigName
    Set step.messageBodyClassName = header.messageBodyClassName
    Set step.status = header.status
    Set step.isError = header.isError
    Set step.invocation = header.invocation
    Set step.correspondingMessageId = header.correspondingMessageId
    Set step.payloadReturned = 0
    Set step.confidence = "observed"
    Set step.explanation = ..BuildTraceStepText(header, sequence)
    Set step.evidence = []
    Do step.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", header.messageId, "SourceConfigName", header.sourceConfigName, "observed"))
    return step
}

ClassMethod BuildTraceStepText(header As %DynamicObject, sequence As %Integer) As %VarString [ Private ]
{
    Set text = "Step "_sequence_" observed message "_header.messageId
    If header.messageBodyClassName '= "" {
        Set text = text_" with body class "_header.messageBodyClassName
    }
    If (header.sourceConfigName '= "") || (header.targetConfigName '= "") {
        Set text = text_" moving from "_$Select(header.sourceConfigName'="":header.sourceConfigName,1:"unknown source")_" to "_$Select(header.targetConfigName'="":header.targetConfigName,1:"unknown target")
    }
    If header.isError {
        Set text = text_". The message header is marked as an error"
    } Else {
        Set text = text_". The message header is not marked as an error"
    }
    Set text = text_". Payload body content was not returned."
    return text
}

ClassMethod NewTraceExplanation(selected As %DynamicObject, steps As %DynamicArray) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.messageId = selected.messageId
    Set explanation.sessionId = selected.sessionId
    Set explanation.confidence = "observed"
    Set explanation.text = ..BuildTraceExplanationText(selected, steps)
    Set explanation.evidence = []
    Do explanation.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", selected.messageId, "SessionId", selected.sessionId, "observed"))
    return explanation
}

ClassMethod NewTraceOverview(selected As %DynamicObject, steps As %DynamicArray) As %DynamicObject [ Private ]
{
    Set overview = {}
    Set overview.messageId = selected.messageId
    Set overview.sessionId = selected.sessionId
    Set overview.stepCount = steps.%Size()
    Set overview.errorCount = 0
    Set overview.firstSeen = ""
    Set overview.lastSeen = ""
    Set overview.origin = ""
    Set overview.finalTarget = ""
    Set overview.path = ""
    Set overview.participants = []

    For index = 0:1:steps.%Size()-1 {
        Set step = steps.%Get(index)
        Continue:'$IsObject(step)
        If index = 0 {
            Set overview.firstSeen = step.timeCreated
            Set overview.origin = step.source
        }
        Set overview.lastSeen = $Select(step.timeProcessed'="":step.timeProcessed,1:step.timeCreated)
        Set overview.finalTarget = step.target
        If step.isError {
            Set overview.errorCount = overview.errorCount + 1
        }
        If step.source '= "" {
            Do ..PushUnique(overview.participants, step.source)
        }
        If step.target '= "" {
            Do ..PushUnique(overview.participants, step.target)
        }
    }
    Set overview.path = ..JoinArrayWithSeparator(overview.participants, " -> ")
    return overview
}

ClassMethod BuildTraceExplanationText(selected As %DynamicObject, steps As %DynamicArray) As %VarString [ Private ]
{
    Set text = "Message "_selected.messageId
    If selected.messageBodyClassName '= "" {
        Set text = text_" is an observed "_selected.messageBodyClassName_" message"
    } Else {
        Set text = text_" is an observed interoperability message"
    }
    If selected.sessionId '= "" {
        Set text = text_" in session "_selected.sessionId
    }
    If steps.%Size() > 0 {
        Set first = steps.%Get(0)
        Set last = steps.%Get(steps.%Size()-1)
        If $IsObject(first),$IsObject(last) {
            Set text = text_". The reconstructed header path has "_steps.%Size()_" step"_..Plural(steps.%Size())_" from "_$Select(first.source'="":first.source,1:"unknown source")_" to "_$Select(last.target'="":last.target,1:"unknown target")
        }
    }
    Set text = text_". This explanation is based on Ens.MessageHeader metadata only; payload body content was not read or returned."
    return text
}

ClassMethod BuildTraceSummary(selected As %DynamicObject) As %VarString [ Private ]
{
    Set text = "Message "_selected.messageId
    If selected.messageBodyClassName '= "" {
        Set text = text_" uses body class "_selected.messageBodyClassName
    }
    If (selected.sourceConfigName '= "") || (selected.targetConfigName '= "") {
        Set text = text_" and moved from "_$Select(selected.sourceConfigName'="":selected.sourceConfigName,1:"unknown source")_" to "_$Select(selected.targetConfigName'="":selected.targetConfigName,1:"unknown target")
    }
    If selected.sessionId '= "" {
        Set text = text_" in session "_selected.sessionId
    }
    Set text = text_". Payload body content was not returned."
    return text
}

ClassMethod NewArtifact(productionName As %VarString, componentName As %VarString, kind As %VarString, name As %VarString, field As %VarString) As %DynamicObject [ Private ]
{
    Set artifact = {}
    Set artifact.kind = kind
    Set artifact.name = name
    Set artifact.component = componentName
    Set artifact.confidence = "confirmed"
    Set artifact.evidence = []
    Do artifact.evidence.%Push(..NewEvidence("production-setting", productionName, componentName, field, name, "confirmed"))
    return artifact
}

ClassMethod NewRuleArtifact(ruleName As %VarString, componentName As %VarString, kind As %VarString, name As %VarString, field As %VarString) As %DynamicObject [ Private ]
{
    Set artifact = {}
    Set artifact.kind = kind
    Set artifact.name = name
    Set artifact.component = componentName
    Set artifact.confidence = "confirmed"
    Set artifact.evidence = []
    Do artifact.evidence.%Push(..NewEvidence("routing-rule", ruleName, componentName, field, name, "confirmed"))
    return artifact
}

ClassMethod FindComponentByName(components As %DynamicArray, componentName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        If $IsObject(component) {
            If component.name = componentName {
                Set found = component
                Quit
            }
        }
    }
    return found
}

ClassMethod FindComponentExplanationByName(explanations As %DynamicArray, componentName As %VarString) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:explanations.%Size()-1 {
        Set explanation = explanations.%Get(index)
        If $IsObject(explanation) {
            If explanation.component = componentName {
                Set found = explanation
                Quit
            }
        }
    }
    return found
}

ClassMethod AddConnectionsForComponent(connections As %DynamicArray, componentName As %VarString, resultArray As %DynamicArray) [ Private ]
{
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        If connection.%Get("from") = componentName {
            Do resultArray.%Push(connection)
            Continue
        }
        If connection.%Get("to") = componentName {
            Do resultArray.%Push(connection)
        }
    }
    return
}

ClassMethod AddItemsForComponent(items As %DynamicArray, componentName As %VarString, resultArray As %DynamicArray) [ Private ]
{
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        Continue:'$IsObject(item)
        If item.component = componentName {
            Do resultArray.%Push(item)
        }
    }
    return
}

ClassMethod AddEvidenceFromObject(item As %DynamicObject, resultArray As %DynamicArray) [ Private ]
{
    If '$IsObject(item) {
        return
    }
    If '$IsObject(item.evidence) {
        return
    }
    For index = 0:1:item.evidence.%Size()-1 {
        Set evidence = item.evidence.%Get(index)
        If $IsObject(evidence) {
            Do resultArray.%Push(evidence)
        }
    }
    return
}

ClassMethod BuildProductionSummary(production As %DynamicObject, connections As %DynamicArray, externalSystems As %DynamicArray, artifacts As %DynamicArray, messageTypes As %DynamicArray, transformations As %DynamicArray, businessProcesses As %DynamicArray) As %VarString [ Private ]
{
    Set serviceCount = ..CountComponentsByType(production.components, "business-service")
    Set processCount = ..CountComponentsByType(production.components, "business-process")
    Set operationCount = ..CountComponentsByType(production.components, "business-operation")
    Set disabledCount = ..CountDisabledComponents(production.components)

    Set text = "Production "_production.name_" contains "_serviceCount_" business service"_..Plural(serviceCount)_", "_processCount_" business process"_..Plural(processCount)_", and "_operationCount_" business operation"_..Plural(operationCount)_"."
    If connections.%Size() > 0 {
        Set text = text_" It has "_connections.%Size()_" target connection"_..Plural(connections.%Size())_"."
    }
    If externalSystems.%Size() > 0 {
        Set text = text_" It references "_externalSystems.%Size()_" external endpoint setting"_..Plural(externalSystems.%Size())_"."
    }
    If artifacts.%Size() > 0 {
        Set text = text_" It references "_artifacts.%Size()_" analysis artifact"_..Plural(artifacts.%Size())_"."
    }
    If messageTypes.%Size() > 0 {
        Set text = text_" It exposes "_messageTypes.%Size()_" message signature"_..Plural(messageTypes.%Size())_"."
    }
    If transformations.%Size() > 0 {
        Set text = text_" It analyzes "_transformations.%Size()_" transformation definition"_..Plural(transformations.%Size())_"."
    }
    If businessProcesses.%Size() > 0 {
        Set text = text_" It analyzes "_businessProcesses.%Size()_" BPL process definition"_..Plural(businessProcesses.%Size())_"."
    }
    If disabledCount > 0 {
        Set text = text_" "_disabledCount_" component"_..Plural(disabledCount)_" are disabled."
    }
    return text
}

ClassMethod CountComponentsByType(components As %DynamicArray, componentType As %VarString) As %Integer [ Private ]
{
    Set count = 0
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        If $IsObject(component) {
            If component.type = componentType {
                Set count = count + 1
            }
        }
    }
    return count
}

ClassMethod CountDisabledComponents(components As %DynamicArray) As %Integer [ Private ]
{
    Set count = 0
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        If $IsObject(component) {
            If component.enabled = 0 {
                Set count = count + 1
            }
        }
    }
    return count
}

ClassMethod Plural(count As %Integer) As %VarString [ Private ]
{
    If count = 1 {
        return ""
    }
    return "s"
}

ClassMethod ExtractSettings(block As %VarString) As %DynamicObject [ Private ]
{
    Set settings = {}
    Set position = 1
    For {
        Set found = $Find(block, "<Setting ", position)
        Quit:(found = 0)
        Set tagStart = found - $Length("<Setting ")
        Set tagEnd = $Find(block, ">", found)
        Quit:(tagEnd = 0)
        Set tag = $Extract(block, tagStart, tagEnd - 1)
        Set close = $Find(block, "</Setting>", tagEnd)
        Set settingName = ..DecodeXml(..ExtractAttribute(tag, "Name"))
        Set value = ..DecodeXml(..ExtractAttribute(tag, "Value"))
        If (value = "") && (close '= 0) {
            Set value = ..DecodeXml($ZStrip($Extract(block, tagEnd, close - $Length("</Setting>") - 1), "<>W"))
        }
        If settingName '= "" {
            Do settings.%Set(settingName, value)
        }
        If close '= 0 {
            Set position = close
        } Else {
            Set position = tagEnd
        }
    }
    return settings
}

ClassMethod ExtractTargets(settings As %DynamicObject) As %DynamicArray [ Private ]
{
    Set targets = []
    Set targetValue = ""
    If settings.%IsDefined("TargetConfigNames") {
        Set targetValue = settings.%Get("TargetConfigNames")
    }
    If targetValue = "" {
        return targets
    }

    Set targetValue = $Translate(targetValue, ";", ",")
    For index = 1:1:$Length(targetValue, ",") {
        Set target = $ZStrip($Piece(targetValue, ",", index), "<>W")
        Continue:(target = "")
        Do targets.%Push(target)
    }
    return targets
}

ClassMethod ComponentType(className As %VarString) As %VarString [ Private ]
{
    If className = "" {
        return "unknown"
    }
    If ..ClassExtends(className, "Ens.BusinessService") {
        return "business-service"
    }
    If ..ClassExtends(className, "Ens.BusinessProcess") {
        return "business-process"
    }
    If ..ClassExtends(className, "Ens.BusinessOperation") {
        return "business-operation"
    }
    return "unknown"
}

ClassMethod GetAdapterClass(className As %VarString) As %VarString [ Private ]
{
    If className = "" {
        return ""
    }
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Value FROM %Dictionary.CompiledParameter WHERE parent = ? AND Name = ?")
    If $$$ISERR(sc) {
        return ""
    }
    Set rset = stmt.%Execute(className, "ADAPTER")
    If rset.%SQLCODE < 0 {
        return ""
    }
    If 'rset.%Next() {
        return ""
    }
    return ..Unquote(rset.%Get("Value"))
}

ClassMethod ProtocolFromAdapter(adapterClass As %VarString) As %VarString [ Private ]
{
    Set lower = $ZConvert(adapterClass, "L")
    If lower["hl7" {
        return "HL7"
    }
    If lower["tcp" {
        return "TCP"
    }
    If lower["http" {
        return "HTTP"
    }
    If lower["rest" {
        return "REST"
    }
    If lower["soap" {
        return "SOAP"
    }
    If lower["ftp" {
        return "FTP"
    }
    If lower["file" {
        return "File"
    }
    If lower["sql" {
        return "SQL"
    }
    If adapterClass '= "" {
        return "custom"
    }
    return "unknown"
}

ClassMethod ReadXData(className As %VarString, xdataName As %VarString) As %VarString [ Private ]
{
    Set xdata = ##class(%Dictionary.CompiledXData).%OpenId(className_"||"_xdataName)
    If '$IsObject(xdata) {
        return ""
    }
    Set data = xdata.Data
    If '$IsObject(data) {
        return data
    }

    Set value = ""
    Do data.Rewind()
    While 'data.AtEnd {
        Set value = value _ data.Read(32000)
    }
    return value
}

ClassMethod ExtractAttribute(tag As %VarString, name As %VarString) As %VarString [ Private ]
{
    Set token = name _ "=" _ $Char(34)
    Set start = $Find(tag, token)
    If start '= 0 {
        Set finish = $Find(tag, """", start)
        If finish '= 0 {
            return $Extract(tag, start, finish - 2)
        }
    }

    Set token = name _ "=" _ "'"
    Set start = $Find(tag, token)
    If start '= 0 {
        Set finish = $Find(tag, "'", start)
        If finish '= 0 {
            return $Extract(tag, start, finish - 2)
        }
    }
    return ""
}

ClassMethod FindXmlStartTag(content As %VarString, elementName As %VarString) As %VarString [ Private ]
{
    Set lowerContent = $ZConvert(content, "L")
    Set token = "<"_$ZConvert(elementName, "L")
    Set found = $Find(lowerContent, token, 1)
    If found = 0 {
        return ""
    }
    Set tagStart = found - $Length(token)
    Set tagEnd = $Find(content, ">", found)
    If tagEnd = 0 {
        return ""
    }
    return $Extract(content, tagStart, tagEnd - 1)
}

ClassMethod DecodeXml(value As %VarString) As %VarString [ Private ]
{
    Set value = $Replace(value, "&quot;", """")
    Set value = $Replace(value, "&apos;", "'")
    Set value = $Replace(value, "&lt;", "<")
    Set value = $Replace(value, "&gt;", ">")
    Set value = $Replace(value, "&amp;", "&")
    return value
}

ClassMethod Unquote(value As %VarString) As %VarString [ Private ]
{
    Set value = $ZStrip(value, "<>W")
    If ($Extract(value, 1) = """") && ($Extract(value, $Length(value)) = """") {
        Set value = $Extract(value, 2, $Length(value) - 1)
    }
    return value
}

ClassMethod NormalizeBoolean(value As %VarString, defaultValue As %Boolean = 1) As %Boolean [ Private ]
{
    If value = "" {
        return defaultValue
    }
    Set lower = $ZConvert(value, "L")
    If (lower = "false") || (lower = "0") || (lower = "no") {
        return 0
    }
    return 1
}

ClassMethod NormalizeInteger(value As %VarString, defaultValue As %Integer = 0) As %Integer [ Private ]
{
    If value = "" {
        return defaultValue
    }
    return +value
}

ClassMethod NormalizeLimit(value As %VarString, defaultValue As %Integer = 50) As %Integer [ Private ]
{
    Set limit = ..NormalizeInteger(value, defaultValue)
    If limit < 1 {
        return defaultValue
    }
    If limit > 100 {
        return 100
    }
    return limit
}

ClassMethod NormalizeLimitWithMaximum(value As %VarString, defaultValue As %Integer, maximum As %Integer) As %Integer [ Private ]
{
    Set limit = ..NormalizeInteger(value, defaultValue)
    Set maximum = ..NormalizeInteger(maximum, defaultValue)
    If maximum < 1 {
        Set maximum = defaultValue
    }
    If limit < 1 {
        Set limit = defaultValue
    }
    If limit > maximum {
        return maximum
    }
    return limit
}

ClassMethod NormalizeFacetLimit(value As %VarString, defaultValue As %Integer = 500) As %Integer [ Private ]
{
    Set limit = ..NormalizeInteger(value, defaultValue)
    If limit < 1 {
        return defaultValue
    }
    If limit > 1000 {
        return 1000
    }
    return limit
}

ClassMethod NormalizeOffset(value As %VarString, defaultValue As %Integer = 0) As %Integer [ Private ]
{
    Set offset = ..NormalizeInteger(value, defaultValue)
    If offset < 0 {
        return defaultValue
    }
    return offset
}

ClassMethod GetRuntimeStatus(productionName As %VarString = "") As %DynamicObject [ Private ]
{
    Set status = {}
    Set currentProduction = ""
    Set state = ""
    Set sc = ##class(Ens.Director).GetProductionStatus(.currentProduction, .state)
    Set status.requestedProduction = productionName
    Set status.currentProduction = currentProduction
    Set status.state = +state
    Set status.stateLabel = ..RuntimeStateLabel(+state)
    Set status.isCurrent = $Select((productionName '= "") && (currentProduction = productionName):1, 1:0)
    Set status.isRunning = $Select((+state = 1) && ((productionName = "") || (currentProduction = productionName)):1, 1:0)
    If $$$ISERR(sc) {
        Do status.%Set("statusText", $System.Status.GetErrorText(sc))
    }
    return status
}

ClassMethod RuntimeStateLabel(state As %Integer) As %VarString [ Private ]
{
    If state = 1 {
        return "running"
    }
    If state = 2 {
        return "stopped"
    }
    If state = 0 {
        return "unknown"
    }
    return "state-"_state
}

ClassMethod NewActionResult(productionName As %VarString, action As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.action = action
    Set result.changed = 0
    return result
}

ClassMethod EnableRuntimeControlRole() [ Private ]
{
    If ("," _ $ROLES _ ",") [ ",i14yaid," {
        return
    }
    If $ROLES = "" {
        Set $ROLES = "i14yaid"
    } Else {
        Set $ROLES = $ROLES _ ",i14yaid"
    }
    return
}

ClassMethod ClassExists(className As %VarString) As %Boolean [ Private ]
{
    Set exists = 0
    Try {
        Set exists = $classmethod(className, "%ExistsId", className)
    } Catch ex {
        Set exists = 0
    }
    If exists {
        return 1
    }

    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name FROM %Dictionary.CompiledClass WHERE Name = ?")
    If $$$ISERR(sc) {
        return 0
    }
    Set rset = stmt.%Execute(className)
    If rset.%SQLCODE < 0 {
        return 0
    }
    return rset.%Next()
}

ClassMethod ClassExtends(className As %VarString, baseClass As %VarString) As %Boolean [ Private ]
{
    If '..ClassExists(className) {
        return 0
    }
    If '..ClassExists(baseClass) {
        return 0
    }

    Set result = 0
    Try {
        Set result = $classmethod(className, "%Extends", baseClass)
    } Catch ex {
        Set result = 0
    }
    return result
}

ClassMethod GetClassDescription(className As %VarString) As %VarString [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Description FROM %Dictionary.CompiledClass WHERE Name = ?")
    If $$$ISERR(sc) {
        return ""
    }
    Set rset = stmt.%Execute(className)
    If rset.%SQLCODE < 0 {
        return ""
    }
    If 'rset.%Next() {
        return ""
    }
    return rset.%Get("Description")
}

ClassMethod IsValidClassName(className As %VarString) As %Boolean [ Private ]
{
    Set length = $Length(className)
    If length = 0 {
        return 0
    }
    For index = 1:1:length {
        Set ch = $Extract(className, index)
        Continue:((ch?1A) || (ch?1N) || (ch = ".") || (ch = "%"))
        return 0
    }
    return 1
}

ClassMethod IsPositiveInteger(value As %VarString) As %Boolean [ Private ]
{
    If value = "" {
        return 0
    }
    If value'?1.N {
        return 0
    }
    return (+value > 0)
}

ClassMethod NewListResult() As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.items = []
    Set result.count = 0
    Set result.warnings = []
    return result
}

ClassMethod AddStatusError(ByRef result As %DynamicObject, message As %VarString) As %DynamicObject [ Private ]
{
    Do result.%Set("errorCode", "STATUS_ERROR")
    Do result.warnings.%Push(..NewWarning("STATUS_ERROR", message))
    return result
}

ClassMethod NewWarning(code As %VarString, message As %VarString) As %DynamicObject [ Private ]
{
    Set warning = {}
    Set warning.code = code
    Set warning.message = message
    return warning
}

ClassMethod NewEvidence(type As %VarString, source As %VarString, component As %VarString, field As %VarString, value As %VarString, confidence As %VarString) As %DynamicObject [ Private ]
{
    Set evidence = {}
    Set evidence.type = type
    Set evidence.source = source
    Set evidence.component = component
    Set evidence.field = field
    Set evidence.value = value
    Set evidence.confidence = confidence
    return evidence
}

}
