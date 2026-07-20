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
    Set capabilities.payloadInspection = capabilities.runtimeTraceAnalysis
    Set capabilities.payloadPreview = capabilities.runtimeTraceAnalysis
    Set capabilities.productionLogs = (..ProductionLogClassName() '= "")
    Set capabilities.monitorInterop = 1
    Set capabilities.aiProvider = 1
    Set capabilities.aiSummary = 1
    Set capabilities.openapiVersion = "2.0"
    return capabilities
}

ClassMethod Codes() As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.messageStatuses = []
    Set result.logTypes = []

    For status = 1:1:9 {
        Do result.messageStatuses.%Push(..NewCodeValue(status, ..MessageStatusLabel(status)))
    }
    For type = 1:1:6 {
        Do result.logTypes.%Push(..NewCodeValue(type, ..LogTypeLabel(type)))
    }

    Set result.metrics = {}
    Set result.metrics.messageStatusCount = result.messageStatuses.%Size()
    Set result.metrics.logTypeCount = result.logTypes.%Size()
    return result
}

ClassMethod GetMonitorInteropRange(period As %VarString = "current") As %DynamicObject
{
    Set normalizedPeriod = ..NormalizeMonitorPeriod(period)
    If normalizedPeriod = "" {
        return ..NewMonitorError("INVALID_MONITOR_PERIOD", "period must be current or historical.")
    }

    Set path = "/api/monitor/interop/"_normalizedPeriod_"/range"
    Set response = ..FetchMonitorOpenMetrics(path)
    If response.%IsDefined("errorCode") {
        return response
    }

    Set result = ..NewMonitorResult(path)
    Set result.period = normalizedPeriod
    Set result.samples = ..ParseOpenMetricsSamples(response.body, "", 50)
    Set result.sampleCount = result.samples.%Size()
    Set result.startDate = ""
    Set result.endDate = ""
    For index = 0:1:result.samples.%Size()-1 {
        Set sample = result.samples.%Get(index)
        Continue:'$IsObject(sample)
        If sample.name = "iris_interop_range_start" {
            Set result.startDate = sample.value
        }
        If sample.name = "iris_interop_range_end" {
            Set result.endDate = sample.value
        }
    }
    Set result.metrics = ..NewMonitorMetrics(result.samples.%Size(), response.httpStatus)
    Do result.evidence.%Push(..NewEvidence("iris-monitor", "/api/monitor", path, "sampleCount", result.samples.%Size(), "observed"))
    return result
}

ClassMethod GetMonitorInteropVolume(period As %VarString = "current", namespace As %VarString = "", startDate As %VarString = "", endDate As %VarString = "", startMonth As %VarString = "", endMonth As %VarString = "") As %DynamicObject
{
    Set normalizedPeriod = ..NormalizeMonitorPeriod(period)
    If normalizedPeriod = "" {
        return ..NewMonitorError("INVALID_MONITOR_PERIOD", "period must be current or historical.")
    }

    Set namespaceFilter = ..NormalizeMonitorNamespace(namespace)
    If namespaceFilter = "" {
        return ..NewMonitorError("INVALID_MONITOR_NAMESPACE", "Invalid monitor namespace filter.")
    }

    Set path = "/api/monitor/interop/"_normalizedPeriod_"/volume"
    If normalizedPeriod = "current" {
        Set start = ..NormalizeMonitorDate(startDate)
        If start.%IsDefined("errorCode") {
            return start
        }
        Set finish = ..NormalizeMonitorDate(endDate)
        If finish.%IsDefined("errorCode") {
            return finish
        }
        Set path = ..AppendMonitorQuery(path, "namespace", namespaceFilter)
        If start.value '= "" {
            Set path = ..AppendMonitorQuery(path, "startDate", start.value)
        }
        If finish.value '= "" {
            Set path = ..AppendMonitorQuery(path, "endDate", finish.value)
        }
    } Else {
        Set start = ..NormalizeMonitorMonth(startMonth)
        If start.%IsDefined("errorCode") {
            return start
        }
        Set finish = ..NormalizeMonitorMonth(endMonth)
        If finish.%IsDefined("errorCode") {
            return finish
        }
        Set path = ..AppendMonitorQuery(path, "namespace", namespaceFilter)
        If start.value '= "" {
            Set path = ..AppendMonitorQuery(path, "startmonth", start.value)
        }
        If finish.value '= "" {
            Set path = ..AppendMonitorQuery(path, "endmonth", finish.value)
        }
    }

    Set response = ..FetchMonitorOpenMetrics(path)
    If response.%IsDefined("errorCode") {
        return response
    }

    Set result = ..NewMonitorResult(path)
    Set result.period = normalizedPeriod
    Set result.namespaceFilter = namespaceFilter
    Set result.samples = ..ParseOpenMetricsSamples(response.body, "", 500)
    Set result.sampleCount = result.samples.%Size()
    Set result.metrics = ..NewMonitorMetrics(result.samples.%Size(), response.httpStatus)
    Do result.evidence.%Push(..NewEvidence("iris-monitor", "/api/monitor", path, "sampleCount", result.samples.%Size(), "observed"))
    return result
}

ClassMethod GetMonitorInteropMetrics(limit As %Integer = 200) As %DynamicObject
{
    Set limit = ..NormalizeLimit(limit)
    Set response = ..FetchMonitorOpenMetrics("/api/monitor/metrics")
    If response.%IsDefined("errorCode") {
        return response
    }

    Set result = ..NewMonitorResult("/api/monitor/metrics")
    Set result.samples = ..ParseOpenMetricsSamples(response.body, "iris_interop", limit)
    Set lastActivity = ..ParseOpenMetricsSamples(response.body, "iris_last_activity", limit)
    For index = 0:1:lastActivity.%Size()-1 {
        Quit:(result.samples.%Size() >= limit)
        Do result.samples.%Push(lastActivity.%Get(index))
    }
    Set result.sampleCount = result.samples.%Size()
    Set result.metrics = ..NewMonitorMetrics(result.samples.%Size(), response.httpStatus)
    If result.samples.%Size() = 0 {
        Do result.warnings.%Push(..NewWarning("INTEROP_METRICS_NOT_ENABLED", "No iris_interop metrics were returned by /api/monitor/metrics. Interoperability metrics may not be enabled for active productions."))
    }
    Do result.evidence.%Push(..NewEvidence("iris-monitor", "/api/monitor", "/api/monitor/metrics", "sampleCount", result.samples.%Size(), "observed"))
    return result
}

ClassMethod GetSettings() As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.settings = settings
    Set result.evidence = []
    Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "settings", "Runtime analysis limits and feature flags", "confirmed"))
    Set result.metrics = ..BuildSettingsMetrics(result)
    return result
}

ClassMethod UpdateSettings(payload As %DynamicObject) As %DynamicObject
{
    Set result = ##class(esh.interoperability.aid.config.Settings).UpdateFromPayload(payload)
    If $IsObject(result) {
        Set result.metrics = ..BuildSettingsMetrics(result)
    }
    return result
}

ClassMethod ListProductions() As %DynamicObject
{
    Set result = ..NewListResult()
    If '..ClassExists("Ens.Production") {
        Do result.warnings.%Push(..NewWarning("INTEROPERABILITY_NOT_AVAILABLE", "Ens.Production is not available in this namespace."))
        Set result.metrics = ..BuildProductionListMetrics(result)
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
        Set components = ..ListComponents(className).items
        Set item.componentCount = components.%Size()
        Set item.serviceCount = ..CountComponentsByType(components, "business-service")
        Set item.processCount = ..CountComponentsByType(components, "business-process")
        Set item.operationCount = ..CountComponentsByType(components, "business-operation")
        Set item.disabledComponentCount = ..CountDisabledComponents(components)
        Set item.runtime = ..GetRuntimeStatus(className)
        Set item.isRunning = item.runtime.isRunning
        Set item.runtimeState = item.runtime.stateLabel
        Set item.runtimeMetrics = ..BuildProductionRuntimeMetrics(item)
        Set item.evidence = []
        Do item.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", className, "Super", "Ens.Production", "confirmed"))
        Do result.items.%Push(item)
    }

    Do result.%Set("count", result.items.%Size())
    Set result.metrics = ..BuildProductionListMetrics(result)
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
    Set result.runtimeMetrics = ..BuildProductionRuntimeMetrics(result)
    Set result.components = ..ListComponents(productionName).items
    Set result.componentCount = result.components.%Size()
    Set result.serviceCount = ..CountComponentsByType(result.components, "business-service")
    Set result.processCount = ..CountComponentsByType(result.components, "business-process")
    Set result.operationCount = ..CountComponentsByType(result.components, "business-operation")
    Set result.disabledComponentCount = ..CountDisabledComponents(result.components)
    Set result.summary = ..BuildProductionOverviewSummary(result)
    Set result.summaryBullets = ..BuildProductionOverviewSummaryBullets(result)
    Set result.metrics = ..BuildProductionOverviewMetrics(result)
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
    Set result.metrics = ..BuildProductionRuntimeMetrics(result)
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
    Set result.externalSystemExplanations = []
    Set result.artifacts = []
    Set result.artifactExplanations = []
    Set result.rules = []
    Set result.ruleExplanations = []
    Set result.messageTypes = []
    Set result.transformations = []
    Set result.transformationExplanations = []
    Set result.businessProcesses = []
    Set result.businessProcessExplanations = []
    Set result.componentExplanations = []
    Set result.connectionExplanations = []
    Set result.messageTypeExplanations = []
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "confirmed"

    Do ..AddConnections(productionName, result.components, result.connections, result.warnings)
    Do ..AddRoutingRuleAnalysis(productionName, result.components, result.connections, result.artifacts, result.rules, result.warnings)
    Do ..AddRuleExplanations(result.rules, result.ruleExplanations)
    Do ..AddExternalSystems(productionName, result.components, result.externalSystems)
    Do ..AddExternalSystemExplanations(result.externalSystems, result.externalSystemExplanations)
    Do ..AddArtifacts(productionName, result.components, result.artifacts)
    Do ..AddMessageTypes(productionName, result.components, result.messageTypes, result.warnings)
    Do ..AddTransformationAnalysis(productionName, result.artifacts, result.transformations, result.warnings)
    Do ..AddTransformationExplanations(result.transformations, result.transformationExplanations)
    Do ..AddBPLAnalysis(productionName, result.components, result.connections, result.artifacts, result.businessProcesses, result.warnings)
    Do ..AddArtifactExplanations(result.artifacts, result.artifactExplanations)
    Do ..AddBusinessProcessExplanations(result.businessProcesses, result.businessProcessExplanations)
    Do ..AddComponentExplanations(result.components, result.connections, result.externalSystems, result.messageTypes, result.rules, result.transformations, result.businessProcesses, result.componentExplanations)
    Do ..AddConnectionExplanations(result.connections, result.messageTypes, result.connectionExplanations)
    Do ..AddMessageTypeExplanations(result.messageTypes, result.messageTypeExplanations)
    Set result.summary = ..BuildProductionSummary(production, result.connections, result.externalSystems, result.artifacts, result.messageTypes, result.transformations, result.businessProcesses)
    Set result.metrics = ..BuildProductionMetrics(result)
    Set result.analysisCoverage = ..BuildAnalysisCoverage(result)
    Set result.summaryBullets = ..BuildProductionSummaryBullets(production, result.connections, result.externalSystems, result.artifacts, result.messageTypes, result.transformations, result.businessProcesses)
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
    Set result.summaryBullets = analysis.summaryBullets
    Set result.metrics = analysis.metrics
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

    Do ..AddGraphNodes(analysis.components, analysis.componentExplanations, result.nodes)
    Do ..AddGraphEdges(analysis.connections, analysis.messageTypes, analysis.connectionExplanations, result.edges)
    Set result.metrics = ..BuildGraphMetrics(analysis, result.nodes, result.edges)
    Set result.summaryBullets = ..BuildGraphSummaryBullets(analysis, result.nodes, result.edges)
    return result
}

ClassMethod GetProductionRAGContext(productionName As %VarString, question As %VarString = "", componentName As %VarString = "", maxChunks As %Integer = 12) As %DynamicObject
{
    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }

    If maxChunks < 1 {
        Set maxChunks = 12
    }
    If maxChunks > 100 {
        Set maxChunks = 100
    }
    Set question = $ZStrip($Extract(question, 1, 1000), "<>W")
    Set componentName = $ZStrip($Extract(componentName, 1, 200), "<>W")

    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.question = question
    Set result.componentName = componentName
    Set result.maxChunks = maxChunks
    Set result.chunks = ..BuildProductionRAGChunks(analysis)
    Set result.chunkCount = result.chunks.%Size()
    If question '= "" {
        Set result.retrievedChunks = ..RetrieveRAGChunks(result.chunks, question, componentName, maxChunks)
    } Else {
        Set result.retrievedChunks = []
    }
    Set result.retrievedChunkCount = result.retrievedChunks.%Size()
    Set result.metrics = ..BuildRAGContextMetrics(result)
    Set result.warnings = analysis.warnings
    Set result.evidence = []
    Do result.evidence.%Push(..NewEvidence("rag-context", productionName, productionName, "chunks", result.chunkCount, "inferred"))
    Set result.confidence = "inferred"
    return result
}

ClassMethod RebuildProductionRAGIndex(productionName As %VarString, request As %DynamicObject = "") As %DynamicObject
{
    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }

    Set chunks = ..BuildProductionRAGChunks(analysis)
    Set options = ..NormalizeRAGIndexOptions(request)
    Set runtimeChunks = []
    If options.includeRuntime {
        Set runtimeChunks = ..BuildRuntimeRAGChunks(productionName, options)
        For runtimeIndex = 0:1:runtimeChunks.%Size()-1 {
            Do chunks.%Push(runtimeChunks.%Get(runtimeIndex))
        }
    }
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.chunkCount = chunks.%Size()
    Set result.includeRuntime = options.includeRuntime
    Set result.runtimeStartDate = options.startDate
    Set result.runtimeEndDate = options.endDate
    Set result.runtimeMaxMessages = options.maxMessages
    Set result.runtimeMaxLogs = options.maxLogs
    Set result.includePayload = options.includePayload
    Set result.payloadMaxFields = options.maxPayloadFields
    Set result.runtimeChunkCount = runtimeChunks.%Size()
    Set result.warnings = analysis.warnings
    Set result.evidence = []
    Set result.confidence = "inferred"

    Set run = ##class(esh.interoperability.aid.rag.IndexRun).%New()
    Set run.Namespace = $Namespace
    Set run.ProductionName = productionName
    Set run.RunTimestamp = $ZDateTime($Horolog, 3, 1)
    Set run.ChunkCount = chunks.%Size()
    Set run.Status = "building"
    Set sc = run.%Save()
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STATUS_ERROR")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }
    Set runId = run.%Id()
    Do ..DeleteRAGChunksForProduction(productionName)

    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        Set stored = ##class(esh.interoperability.aid.rag.Chunk).%New()
        Set stored.Namespace = $Namespace
        Set stored.ProductionName = productionName
        Set stored.RunId = runId
        Set stored.ChunkId = chunk.id
        Set stored.Kind = chunk.kind
        Set stored.Title = chunk.title
        Set stored.Source = chunk.source
        Set stored.Component = chunk.component
        Set stored.Confidence = chunk.confidence
        Set stored.Score = $Select(chunk.%IsDefined("score"):chunk.score,1:0)
        Set stored.CreatedAt = $ZDateTime($Horolog, 3, 1)
        Set stored.Text = ##class(%Stream.GlobalCharacter).%New()
        Do stored.Text.Write(chunk.text)
        Set stored.EvidenceJSON = ##class(%Stream.GlobalCharacter).%New()
        Do stored.EvidenceJSON.Write($Select($IsObject(chunk.evidence):chunk.evidence.%ToJSON(),1:"[]"))
        Set sc = stored.%Save()
        If $$$ISERR(sc) {
            Set run.Status = "error"
            Set run.StatusText = $System.Status.GetErrorText(sc)
            Do run.%Save()
            Do result.%Set("errorCode", "STATUS_ERROR")
            Do result.%Set("statusText", $System.Status.GetErrorText(sc))
            return result
        }
    }
    Set run.Status = "complete"
    Set run.ChunkCount = chunks.%Size()
    Set sc = run.%Save()
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STATUS_ERROR")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }

    Set result.runId = runId
    Set result.status = run.Status
    Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
    Do result.evidence.%Push(..NewEvidence("rag-index", productionName, productionName, "runId", runId, "confirmed"))
    If options.includeRuntime {
        Do result.evidence.%Push(..NewEvidence("runtime-rag", productionName, productionName, "runtimeChunkCount", runtimeChunks.%Size(), "observed"))
    }
    return result
}

ClassMethod GetProductionRAGIndexStatus(productionName As %VarString) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.indexed = 0
    Set result.stale = 0
    Set result.status = "not-built"
    Set result.chunkCount = 0
    Set result.warnings = []
    Set result.evidence = []

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set runId = ..LatestRAGRunId(productionName)
    Set sourceStamp = ..LatestProductionSourceStamp(productionName)
    Set result.sourceClassCount = sourceStamp.classCount
    Set result.latestSourceClassName = sourceStamp.className
    Set result.latestSourceChangedAt = sourceStamp.changedAt

    If runId = "" {
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_NOT_BUILT", "No persisted RAG index exists for this production. Rebuild the RAG index first."))
        Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
        Do result.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", productionName, "latestSourceChangedAt", result.latestSourceChangedAt, "confirmed"))
        return result
    }

    Set run = ##class(esh.interoperability.aid.rag.IndexRun).%OpenId(runId)
    If '$IsObject(run) {
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_NOT_FOUND", "The latest RAG index run record could not be opened."))
        Set result.metrics = ..BuildStoredRAGMetrics(productionName, "")
        return result
    }

    Set result.indexed = 1
    Set result.runId = runId
    Set result.status = run.Status
    Set result.runTimestamp = run.RunTimestamp
    Set result.chunkCount = run.ChunkCount
    Set result.statusText = run.StatusText
    Set runHorolog = ..TimestampToHorolog(run.RunTimestamp)
    Set result.stale = ..HorologSeconds(sourceStamp.changedAtHorolog) > (..HorologSeconds(runHorolog) + 1)
    If result.stale {
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_STALE", "Production source metadata changed after the latest RAG index run. Rebuild the RAG index."))
    }
    Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
    Do result.evidence.%Push(..NewEvidence("rag-index", productionName, productionName, "runId", runId, "confirmed"))
    Do result.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", sourceStamp.className, "TimeChanged", sourceStamp.changedAt, "confirmed"))
    return result
}

ClassMethod NormalizeRAGIndexOptions(request As %DynamicObject = "") As %DynamicObject [ Private ]
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set options = {}
    Set options.includeRuntime = settings.ragRuntimeDataEnabled
    Set options.lookbackHours = settings.ragRuntimeLookbackHours
    Set options.maxMessages = settings.ragRuntimeMaxMessages
    Set options.maxLogs = settings.ragRuntimeMaxLogs
    Set options.includePayload = settings.ragPayloadIndexingEnabled
    Set options.maxPayloadFields = settings.ragPayloadMaxFields
    Set options.startDate = ""
    Set options.endDate = ""

    If $IsObject(request) {
        If request.%IsDefined("includeRuntime") {
            Set options.includeRuntime = ..NormalizeBoolean(request.%Get("includeRuntime"), options.includeRuntime)
        }
        If request.%IsDefined("lookbackHours") {
            Set options.lookbackHours = ..NormalizeInteger(request.%Get("lookbackHours"), options.lookbackHours)
        }
        If request.%IsDefined("maxMessages") {
            Set options.maxMessages = ..NormalizeInteger(request.%Get("maxMessages"), options.maxMessages)
        }
        If request.%IsDefined("maxLogs") {
            Set options.maxLogs = ..NormalizeInteger(request.%Get("maxLogs"), options.maxLogs)
        }
        If request.%IsDefined("includePayload") {
            Set options.includePayload = ..NormalizeBoolean(request.%Get("includePayload"), options.includePayload)
        }
        If request.%IsDefined("maxPayloadFields") {
            Set options.maxPayloadFields = ..NormalizeInteger(request.%Get("maxPayloadFields"), options.maxPayloadFields)
        }
        If request.%IsDefined("startDate") {
            Set options.startDate = $ZStrip($Extract(request.%Get("startDate"), 1, 50), "<>W")
        }
        If request.%IsDefined("endDate") {
            Set options.endDate = $ZStrip($Extract(request.%Get("endDate"), 1, 50), "<>W")
        }
    }
    If options.lookbackHours < 1 {
        Set options.lookbackHours = 24
    }
    If options.lookbackHours > 720 {
        Set options.lookbackHours = 720
    }
    If options.maxMessages < 0 {
        Set options.maxMessages = 0
    }
    If options.maxMessages > 1000 {
        Set options.maxMessages = 1000
    }
    If options.maxLogs < 0 {
        Set options.maxLogs = 0
    }
    If options.maxLogs > 1000 {
        Set options.maxLogs = 1000
    }
    If options.maxPayloadFields < 1 {
        Set options.maxPayloadFields = 50
    }
    If options.maxPayloadFields > 200 {
        Set options.maxPayloadFields = 200
    }
    If options.includeRuntime && (options.startDate = "") && (options.endDate = "") {
        Set options.startDate = ..HorologToTimestamp(..HorologAddSeconds($Horolog, -(options.lookbackHours * 3600)))
        Set options.endDate = $ZDateTime($Horolog, 3, 1)
    }
    return options
}

ClassMethod BuildRuntimeRAGChunks(productionName As %VarString, options As %DynamicObject) As %DynamicArray [ Private ]
{
    Set chunks = []
    If options.maxMessages > 0 {
        Set messages = ..ListMessages(productionName, options.maxMessages, 0, "", "", "", "", 0, options.startDate, options.endDate)
        If $IsObject(messages) && 'messages.%IsDefined("errorCode") && $IsObject(messages.items) {
            For index = 0:1:messages.items.%Size()-1 {
                Set message = messages.items.%Get(index)
                Continue:'$IsObject(message)
                Do chunks.%Push(..NewMessageRAGChunk(message, productionName))
                If options.includePayload {
                    Set payloadChunk = ..NewPayloadRAGChunk(message, productionName, options)
                    If $IsObject(payloadChunk) {
                        Do chunks.%Push(payloadChunk)
                    }
                }
            }
        }
    }
    If options.maxLogs > 0 {
        Set logs = ..ListProductionLogs(productionName, options.maxLogs, 0, "", "", "", options.startDate, options.endDate)
        If $IsObject(logs) && 'logs.%IsDefined("errorCode") && $IsObject(logs.items) {
            For index = 0:1:logs.items.%Size()-1 {
                Set log = logs.items.%Get(index)
                Continue:'$IsObject(log)
                Do chunks.%Push(..NewLogRAGChunk(log, productionName))
            }
        }
    }
    return chunks
}

ClassMethod NewMessageRAGChunk(message As %DynamicObject, productionName As %VarString) As %DynamicObject [ Private ]
{
    Set text = "Runtime message "_message.messageId_" in production "_productionName_". Session: "_message.sessionId_". Source: "_message.sourceConfigName_". Target: "_message.targetConfigName_". Body class: "_message.messageBodyClassName_". Status: "_message.status
    If message.statusLabel '= "" {
        Set text = text_" ("_message.statusLabel_")"
    }
    Set text = text_". Is error: "_message.isError_". Created: "_message.timeCreated_"."
    If message.errorStatus '= "" {
        Set text = text_" Error status: "_message.errorStatus_"."
    }
    Set evidence = []
    Do evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", message.messageId, "MessageId", message.messageId, "observed"))
    return ..NewRAGChunk("message-"_message.messageId, "message", "Message "_message.messageId, text, "Ens.MessageHeader", message.sourceConfigName, "observed", evidence)
}

ClassMethod NewPayloadRAGChunk(message As %DynamicObject, productionName As %VarString, options As %DynamicObject) As %DynamicObject [ Private ]
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    If 'settings.payloadInspectionEnabled {
        return ""
    }
    If (message.messageBodyClassName = "") || (message.messageBodyId = "") {
        return ""
    }
    If '..ClassExists(message.messageBodyClassName) {
        return ""
    }
    Set body = ""
    Try {
        Set body = $classmethod(message.messageBodyClassName, "%OpenId", message.messageBodyId)
    } Catch ex {
        Set body = ""
    }
    If '$IsObject(body) {
        return ""
    }
    Set fields = []
    Set evidence = []
    Do ..AddPayloadPreviewFields(body, message.messageBodyClassName, settings.fieldRedactionPatterns, fields, evidence)
    If fields.%Size() = 0 {
        return ""
    }
    Set text = "Redacted scalar payload preview for message "_message.messageId_" in production "_productionName_". Body class: "_message.messageBodyClassName_". Body id: "_message.messageBodyId_"."
    Set fieldCount = 0
    Set redactedCount = 0
    For index = 0:1:fields.%Size()-1 {
        Quit:(fieldCount >= options.maxPayloadFields)
        Set field = fields.%Get(index)
        Continue:'$IsObject(field)
        Set text = text_" "_field.name_"="
        If field.redacted {
            Set text = text_"[redacted]"
            Set redactedCount = redactedCount + 1
        } Else {
            Set text = text_field.value
        }
        Set fieldCount = fieldCount + 1
    }
    Set text = text_". Indexed fields: "_fieldCount_". Redacted fields: "_redactedCount_"."
    Do evidence.%Push(..NewEvidence("payload-preview", message.messageBodyClassName, message.messageId, "MessageBodyId", message.messageBodyId, "observed"))
    return ..NewRAGChunk("payload-"_message.messageId, "payload", "Payload "_message.messageId, text, message.messageBodyClassName, message.sourceConfigName, "observed", evidence)
}

ClassMethod NewLogRAGChunk(log As %DynamicObject, productionName As %VarString) As %DynamicObject [ Private ]
{
    Set text = "Runtime log "_log.logId_" in production "_productionName_". Time: "_log.timeLogged_". Type: "_log.type
    If log.typeLabel '= "" {
        Set text = text_" ("_log.typeLabel_")"
    }
    Set text = text_". Source: "_log.source_". Session: "_log.sessionId_". Job: "_log.job_". Text: "_$Extract(log.text, 1, 1200)
    Set evidence = []
    Do evidence.%Push(..NewEvidence("production-log", "interoperability-log", log.logId, "LogId", log.logId, "observed"))
    return ..NewRAGChunk("log-"_log.logId, "log", "Log "_log.logId, text, "interoperability-log", log.source, "observed", evidence)
}

ClassMethod ListProductionRAGChunks(productionName As %VarString, limit As %Integer = 50, offset As %Integer = 0, kind As %VarString = "", componentName As %VarString = "") As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.limit = ..NormalizeLimit(limit)
    Set result.offset = ..NormalizeOffset(offset)
    Set kindFilter = $ZConvert(kind, "U")
    Set result.kind = kind
    Set result.componentName = componentName
    Set result.items = []
    Set result.count = 0
    Set result.totalCount = 0
    Set result.hasMore = 0
    Set result.warnings = []
    Set result.evidence = []

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }

    Set runId = ..LatestRAGRunId(productionName)
    If runId = "" {
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_NOT_BUILT", "No persisted RAG index exists for this production. Rebuild the RAG index first."))
        Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
        return result
    }
    Set result.runId = runId
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT %ID AS ID, ChunkId, Kind, Title, Source, Component, Confidence, Score FROM esh_interoperability_aid_rag.Chunk WHERE Namespace = ? AND ProductionName = ? AND RunId = ?"
    If kindFilter '= "" {
        Set sql = sql_" AND Kind = ?"
    }
    If componentName '= "" {
        Set sql = sql_" AND Component = ?"
    }
    Set sql = sql_" ORDER BY Kind, Title"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STATUS_ERROR")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }
    If (kindFilter '= "") && (componentName '= "") {
        Set rset = stmt.%Execute($Namespace, productionName, runId, kindFilter, componentName)
    } ElseIf kindFilter '= "" {
        Set rset = stmt.%Execute($Namespace, productionName, runId, kindFilter)
    } ElseIf componentName '= "" {
        Set rset = stmt.%Execute($Namespace, productionName, runId, componentName)
    } Else {
        Set rset = stmt.%Execute($Namespace, productionName, runId)
    }
    If rset.%SQLCODE < 0 {
        Do result.%Set("errorCode", "STATUS_ERROR")
        Do result.%Set("statusText", rset.%Message)
        return result
    }

    Set skipped = 0
    While rset.%Next() {
        Set result.totalCount = result.totalCount + 1
        If skipped < result.offset {
            Set skipped = skipped + 1
            Continue
        }
        If result.items.%Size() >= result.limit {
            Set result.hasMore = 1
            Continue
        }
        Set item = ..OpenStoredRAGChunk(rset.%Get("ID"))
        If $IsObject(item) {
            Do result.items.%Push(item)
        }
    }
    Set result.count = result.items.%Size()
    Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
    Do result.evidence.%Push(..NewEvidence("rag-index", productionName, productionName, "runId", runId, "confirmed"))
    return result
}

ClassMethod SearchProductionRAGChunks(productionName As %VarString, question As %VarString = "", componentName As %VarString = "", maxChunks As %Integer = 12) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.question = $ZStrip($Extract(question, 1, 1000), "<>W")
    Set result.componentName = $ZStrip($Extract(componentName, 1, 200), "<>W")
    Set result.maxChunks = maxChunks
    Set result.chunks = []
    Set result.count = 0
    Set result.totalChunkCount = 0
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "inferred"

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }
    If result.question = "" {
        Do result.%Set("errorCode", "INVALID_AI_QUESTION")
        return result
    }
    If result.maxChunks < 1 {
        Set result.maxChunks = 12
    }
    If result.maxChunks > 100 {
        Set result.maxChunks = 100
    }

    Set runId = ..LatestRAGRunId(productionName)
    If runId = "" {
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_NOT_BUILT", "No persisted RAG index exists for this production. Rebuild the RAG index first."))
        return result
    }
    Set result.runId = runId
    Set allChunks = ..OpenStoredRAGChunksForRun(productionName, runId)
    Set result.totalChunkCount = allChunks.%Size()
    Set result.chunks = ..RetrieveRAGChunks(allChunks, result.question, result.componentName, result.maxChunks)
    Set result.count = result.chunks.%Size()
    Set result.metrics = ..BuildStoredRAGMetrics(productionName, runId)
    Do result.evidence.%Push(..NewEvidence("rag-index", productionName, productionName, "runId", runId, "confirmed"))
    return result
}

ClassMethod GetProductionAISummary(productionName As %VarString) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.provider = settings.aiProvider
    Set result.model = settings.aiModel
    Set result.generated = 0
    Set result.answerGrounded = 0
    Set result.citations = []
    Set result.citationCount = 0
    Set result.invalidCitationIds = []
    Set result.invalidCitationCount = 0
    Set result.uncitedChunkIds = []
    Set result.aiProviderEnabled = settings.aiProviderEnabled
    Set result.aiSummaryEnabled = settings.aiSummaryEnabled
    Set result.aiApiKeyConfigured = settings.aiApiKeyConfigured
    Set result.aiApiKeySource = settings.aiApiKeySource
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "inferred"

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }
    If 'settings.aiProviderEnabled {
        Do result.%Set("errorCode", "AI_PROVIDER_DISABLED")
        Do result.warnings.%Push(..NewWarning("AI_PROVIDER_DISABLED", "AI provider is disabled in module settings."))
        return result
    }
    If 'settings.aiSummaryEnabled {
        Do result.%Set("errorCode", "AI_SUMMARY_DISABLED")
        Do result.warnings.%Push(..NewWarning("AI_SUMMARY_DISABLED", "AI summary generation is disabled in module settings."))
        return result
    }
    If settings.aiProvider '= "openai" {
        Do result.%Set("errorCode", "AI_PROVIDER_UNSUPPORTED")
        Do result.warnings.%Push(..NewWarning("AI_PROVIDER_UNSUPPORTED", "Only the OpenAI provider is supported in this release."))
        return result
    }

    Set apiKey = ##class(esh.interoperability.aid.config.Settings).EffectiveOpenAIKey()
    If apiKey = "" {
        Do result.%Set("errorCode", "AI_API_KEY_NOT_CONFIGURED")
        Do result.warnings.%Push(..NewWarning("AI_API_KEY_NOT_CONFIGURED", "Set OPENAI_API_KEY in the IRIS environment or save an OpenAI key in settings."))
        return result
    }

    Set analysis = ..GetProductionAnalysis(productionName)
    If analysis.%IsDefined("errorCode") {
        return analysis
    }
    Set result.deterministicSummary = analysis.summary
    Set result.deterministicSummaryBullets = analysis.summaryBullets
    Set result.metrics = analysis.metrics
    Do result.evidence.%Push(..NewEvidence("analysis", productionName, productionName, "ProductionAnalysis", "AI summary prompt grounded in deterministic production analysis", "confirmed"))

    Set prompt = ..BuildAISummaryPrompt(analysis)
    Set aiResponse = ..CallOpenAIChat(settings.aiEndpoint, settings.aiModel, apiKey, prompt)
    If aiResponse.%IsDefined("errorCode") {
        Do result.%Set("errorCode", aiResponse.errorCode)
        Do result.%Set("statusText", aiResponse.statusText)
        Do result.warnings.%Push(..NewWarning(aiResponse.errorCode, aiResponse.statusText))
        return result
    }

    Set result.generated = 1
    Set result.summary = aiResponse.text
    Set result.rawUsage = aiResponse.usage
    Do result.evidence.%Push(..NewEvidence("ai-provider", settings.aiProvider, productionName, "model", settings.aiModel, "inferred"))
    return result
}

ClassMethod AskProductionAI(productionName As %VarString, request As %DynamicObject) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.provider = settings.aiProvider
    Set result.model = settings.aiModel
    Set result.generated = 0
    Set result.aiProviderEnabled = settings.aiProviderEnabled
    Set result.aiApiKeyConfigured = settings.aiApiKeyConfigured
    Set result.aiApiKeySource = settings.aiApiKeySource
    Set result.warnings = []
    Set result.evidence = []
    Set result.chunks = []
    Set result.confidence = "inferred"

    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        return result
    }
    If '$IsObject(request) {
        Do result.%Set("errorCode", "INVALID_AI_QUESTION")
        return result
    }

    Set question = $ZStrip($Extract(request.%Get("question"), 1, 1000), "<>W")
    If question = "" {
        Do result.%Set("errorCode", "INVALID_AI_QUESTION")
        return result
    }
    Set componentName = $ZStrip($Extract(request.%Get("componentName"), 1, 200), "<>W")
    Set maxChunks = +request.%Get("maxChunks")
    If maxChunks < 1 {
        Set maxChunks = 12
    }
    If maxChunks > 30 {
        Set maxChunks = 30
    }
    Set result.question = question
    Set result.componentName = componentName
    Set result.maxChunks = maxChunks

    If 'settings.aiProviderEnabled {
        Do result.%Set("errorCode", "AI_PROVIDER_DISABLED")
        Do result.warnings.%Push(..NewWarning("AI_PROVIDER_DISABLED", "AI provider is disabled in module settings."))
        return result
    }
    If settings.aiProvider '= "openai" {
        Do result.%Set("errorCode", "AI_PROVIDER_UNSUPPORTED")
        Do result.warnings.%Push(..NewWarning("AI_PROVIDER_UNSUPPORTED", "Only the OpenAI provider is supported in this release."))
        return result
    }

    Set apiKey = ##class(esh.interoperability.aid.config.Settings).EffectiveOpenAIKey()
    If apiKey = "" {
        Do result.%Set("errorCode", "AI_API_KEY_NOT_CONFIGURED")
        Do result.warnings.%Push(..NewWarning("AI_API_KEY_NOT_CONFIGURED", "Set OPENAI_API_KEY in the IRIS environment or save an OpenAI key in settings."))
        return result
    }

    Set runId = ..LatestRAGRunId(productionName)
    If runId '= "" {
        Set allChunks = ..OpenStoredRAGChunksForRun(productionName, runId)
        Set result.runId = runId
        Set result.chunkSource = "persisted"
    } Else {
        Set analysis = ..GetProductionAnalysis(productionName)
        If analysis.%IsDefined("errorCode") {
            return analysis
        }
        Set allChunks = ..BuildProductionRAGChunks(analysis)
        Set result.chunkSource = "transient"
        Do result.warnings.%Push(..NewWarning("RAG_INDEX_NOT_BUILT", "No persisted RAG index exists for this production. Built transient chunks for this request."))
    }
    Set result.chunks = ..RetrieveRAGChunks(allChunks, question, componentName, maxChunks)
    Set result.chunkCount = result.chunks.%Size()
    Set result.totalChunkCount = allChunks.%Size()
    Do result.evidence.%Push(..NewEvidence("rag-index", productionName, productionName, "chunks", result.chunks.%Size()_" of "_allChunks.%Size(), "inferred"))

    Set prompt = ..BuildAIAskPrompt(question, result.chunks)
    Set systemPrompt = "Answer questions about an InterSystems IRIS interoperability production using only the provided retrieved chunks. Cite factual claims with exact bracketed chunk ids such as [component-Patient Router]. If the chunks do not contain enough evidence, say what is missing. Do not invent components, routes, payloads, credentials, or runtime facts."
    Set aiResponse = ..CallOpenAIChat(settings.aiEndpoint, settings.aiModel, apiKey, prompt, systemPrompt)
    If aiResponse.%IsDefined("errorCode") {
        Do result.%Set("errorCode", aiResponse.errorCode)
        Do result.%Set("statusText", aiResponse.statusText)
        Do result.warnings.%Push(..NewWarning(aiResponse.errorCode, aiResponse.statusText))
        return result
    }

    Set result.generated = 1
    Set result.answer = aiResponse.text
    Set result.rawUsage = aiResponse.usage
    Set citationAudit = ..ValidateAIAnswerCitations(aiResponse.text, result.chunks)
    Set result.citations = citationAudit.citations
    Set result.citationCount = citationAudit.citationCount
    Set result.invalidCitationIds = citationAudit.invalidCitationIds
    Set result.invalidCitationCount = citationAudit.invalidCitationCount
    Set result.uncitedChunkIds = citationAudit.uncitedChunkIds
    Set result.answerGrounded = citationAudit.answerGrounded
    If result.citationCount = 0 {
        Do result.warnings.%Push(..NewWarning("AI_CITATIONS_MISSING", "The AI answer did not cite retrieved chunk ids."))
    }
    If result.invalidCitationCount > 0 {
        Do result.warnings.%Push(..NewWarning("AI_CITATIONS_INVALID", "The AI answer cited chunk ids that were not retrieved for this request."))
    }
    Do result.evidence.%Push(..NewEvidence("ai-provider", settings.aiProvider, productionName, "model", settings.aiModel, "inferred"))
    return result
}

ClassMethod GetComponentDetail(productionName As %VarString, componentName As %VarString) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.componentName = componentName
    Set result.connections = []
    Set result.connectionExplanations = []
    Set result.externalSystems = []
    Set result.externalSystemExplanations = []
    Set result.artifacts = []
    Set result.artifactExplanations = []
    Set result.rules = []
    Set result.ruleExplanations = []
    Set result.messageTypes = []
    Set result.messageTypeExplanations = []
    Set result.transformations = []
    Set result.transformationExplanations = []
    Set result.businessProcesses = []
    Set result.businessProcessExplanations = []
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
    Do ..AddConnectionsForComponent(analysis.connectionExplanations, componentName, result.connectionExplanations)
    Do ..AddItemsForComponent(analysis.externalSystems, componentName, result.externalSystems)
    Do ..AddItemsForComponent(analysis.externalSystemExplanations, componentName, result.externalSystemExplanations)
    Do ..AddItemsForComponent(analysis.artifacts, componentName, result.artifacts)
    Do ..AddItemsForComponent(analysis.artifactExplanations, componentName, result.artifactExplanations)
    Do ..AddItemsForComponent(analysis.rules, componentName, result.rules)
    Do ..AddItemsForComponent(analysis.ruleExplanations, componentName, result.ruleExplanations)
    Do ..AddItemsForComponent(analysis.messageTypes, componentName, result.messageTypes)
    Do ..AddItemsForComponent(analysis.messageTypeExplanations, componentName, result.messageTypeExplanations)
    Do ..AddItemsForComponent(analysis.transformations, componentName, result.transformations)
    Do ..AddItemsForComponent(analysis.transformationExplanations, componentName, result.transformationExplanations)
    Do ..AddItemsForComponent(analysis.businessProcesses, componentName, result.businessProcesses)
    Do ..AddItemsForComponent(analysis.businessProcessExplanations, componentName, result.businessProcessExplanations)
    Set result.metrics = ..BuildComponentMetrics(result)
    Set result.summaryBullets = ..BuildComponentSummaryBullets(result)
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
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }
    If (before.state = 1) && (before.currentProduction '= "") && (before.currentProduction '= productionName) {
        Do result.%Set("errorCode", "PRODUCTION_ALREADY_RUNNING")
        Set result.runtime = before
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }

    New $ROLES
    Do ..EnableRuntimeControlRole()
    Set sc = ##class(Ens.Director).StartProduction(productionName)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "START_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        Set result.runtime = ..GetRuntimeStatus(productionName)
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }

    Set result.changed = 1
    Set result.runtime = ..GetRuntimeStatus(productionName)
    Set result.metrics = ..BuildProductionRuntimeMetrics(result)
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
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }
    If before.currentProduction '= productionName {
        Do result.%Set("errorCode", "PRODUCTION_NOT_ACTIVE")
        Set result.runtime = before
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }

    New $ROLES
    Do ..EnableRuntimeControlRole()
    Set sc = ##class(Ens.Director).StopProduction(..NormalizeInteger(timeout, 10), +force)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STOP_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        Set result.runtime = ..GetRuntimeStatus(productionName)
        Set result.metrics = ..BuildProductionRuntimeMetrics(result)
        return result
    }

    Set result.changed = 1
    Set result.runtime = ..GetRuntimeStatus(productionName)
    Set result.metrics = ..BuildProductionRuntimeMetrics(result)
    return result
}

ClassMethod ListMessages(productionName As %VarString = "", limit As %Integer = 50, offset As %Integer = 0, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0, startDate As %VarString = "", endDate As %VarString = "", status As %VarString = "") As %DynamicObject
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
    Set status = ..NormalizeMessageStatusFilter(status)
    Set dateRange = ..NormalizeDateRange(startDate, endDate)
    If 'dateRange.valid {
        Do result.%Set("errorCode", "INVALID_DATE_FILTER")
        Do result.%Set("statusText", dateRange.statusText)
        return result
    }
    Do result.%Set("limit", limit)
    Do result.%Set("offset", offset)
    Do result.%Set("sourceConfigName", sourceConfigName)
    Do result.%Set("targetConfigName", targetConfigName)
    Do result.%Set("messageBodyClassName", messageBodyClassName)
    Do result.%Set("sessionId", sessionId)
    Do result.%Set("errorsOnly", errorsOnly)
    Do result.%Set("status", status)
    Do result.%Set("startDate", dateRange.startDate)
    Do result.%Set("endDate", dateRange.endDate)
    Do result.%Set("hasMore", 0)

    If '..ClassExists("Ens.MessageHeader") {
        Do result.warnings.%Push(..NewWarning("MESSAGE_HEADER_NOT_AVAILABLE", "Ens.MessageHeader is not available in this namespace."))
        Set result.metrics = ..BuildMessageListMetrics(result)
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
        Continue:'..ShouldIncludeMessageHeader(rset, componentNames, sourceConfigName, targetConfigName, messageBodyClassName, sessionId, errorsOnly, status, dateRange.startHorolog, dateRange.endHorolog)
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
    Set result.metrics = ..BuildMessageListMetrics(result)
    return result
}

ClassMethod ListMessageFacets(productionName As %VarString = "", limit As %Integer = 500, startDate As %VarString = "", endDate As %VarString = "", status As %VarString = "") As %DynamicObject
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
    Set status = ..NormalizeMessageStatusFilter(status)
    Set dateRange = ..NormalizeDateRange(startDate, endDate)
    If 'dateRange.valid {
        Do result.%Set("errorCode", "INVALID_DATE_FILTER")
        Do result.%Set("statusText", dateRange.statusText)
        return result
    }
    Set result.limit = limit
    Set result.status = status
    Set result.startDate = dateRange.startDate
    Set result.endDate = dateRange.endDate
    Set result.totalCount = 0
    Set result.errorCount = 0
    Set result.hasMore = 0
    Set result.sourceConfigNames = []
    Set result.targetConfigNames = []
    Set result.messageBodyClassNames = []
    Set result.sessionIds = []
    Set result.statusNames = []
    Set result.statusFacets = []
    Set result.componentNames = []
    Set result.warnings = []

    If '..ClassExists("Ens.MessageHeader") {
        Do result.warnings.%Push(..NewWarning("MESSAGE_HEADER_NOT_AVAILABLE", "Ens.MessageHeader is not available in this namespace."))
        Set result.metrics = ..BuildMessageListMetrics(result)
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
        Continue:'..ShouldIncludeMessageHeader(rset, componentNames, "", "", "", "", 0, status, dateRange.startHorolog, dateRange.endHorolog)
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
        Do ..PushUnique(result.statusNames, rset.%Get("Status"))
        Do ..PushStatusFacet(result.statusFacets, rset.%Get("Status"))
        Do ..PushUnique(result.componentNames, rset.%Get("SourceConfigName"))
        Do ..PushUnique(result.componentNames, rset.%Get("TargetConfigName"))
    }
    Set result.metrics = ..BuildMessageListMetrics(result)
    return result
}

ClassMethod ListProductionLogs(productionName As %VarString = "", limit As %Integer = 50, offset As %Integer = 0, type As %VarString = "", source As %VarString = "", contains As %VarString = "", startDate As %VarString = "", endDate As %VarString = "") As %DynamicObject
{
    Set result = ..NewListResult()
    Set result.productionName = productionName
    Set result.limit = ..NormalizeLimitWithMaximum(limit, 50, 500)
    Set result.offset = ..NormalizeOffset(offset)
    Set type = ..NormalizeLogTypeFilter(type)
    Set dateRange = ..NormalizeDateRange(startDate, endDate)
    If 'dateRange.valid {
        Do result.%Set("errorCode", "INVALID_DATE_FILTER")
        Do result.%Set("statusText", dateRange.statusText)
        Set result.metrics = ..BuildProductionLogMetrics(result)
        return result
    }
    Set result.type = type
    Set result.source = source
    Set result.contains = contains
    Set result.startDate = dateRange.startDate
    Set result.endDate = dateRange.endDate
    Set result.hasMore = 0
    Set result.sourceNames = []
    Set result.typeNames = []
    Set result.typeFacets = []
    Set result.logClassName = ""

    If productionName '= "" {
        If '..IsValidClassName(productionName) {
            Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
            Set result.metrics = ..BuildProductionLogMetrics(result)
            return result
        }
        If '..ClassExtends(productionName, "Ens.Production") {
            Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
            Set result.metrics = ..BuildProductionLogMetrics(result)
            return result
        }
    }

    Set logClassName = ..ProductionLogClassName()
    If logClassName = "" {
        Do result.warnings.%Push(..NewWarning("PRODUCTION_LOG_NOT_AVAILABLE", "No supported interoperability event log class is available in this namespace."))
        Set result.metrics = ..BuildProductionLogMetrics(result)
        return result
    }

    Set result.logClassName = logClassName
    Set componentNames = []
    If productionName '= "" {
        Set componentNames = ..ProductionComponentNames(productionName)
    }

    Set timeProperty = ..FirstExistingProperty(logClassName, ["TimeLogged","TimeCreated","TimeStamp","Timestamp"])
    Set typeProperty = ..FirstExistingProperty(logClassName, ["Type","EventType","Level","Severity"])
    Set sourceProperty = ..FirstExistingProperty(logClassName, ["Source","ConfigName","SourceConfigName","Component","ComponentName"])
    Set textProperty = ..FirstExistingProperty(logClassName, ["Text","Message","Description"])
    Set sessionProperty = ..FirstExistingProperty(logClassName, ["SessionId","Session"])
    Set jobProperty = ..FirstExistingProperty(logClassName, ["Job","JobId","ProcessId"])

    Set sql = "SELECT %ID AS LogId, "_..LogSelectExpression(timeProperty,"TimeLogged")_", "_..LogSelectExpression(typeProperty,"Type")_", "_..LogSelectExpression(sourceProperty,"Source")_", "_..LogSelectExpression(textProperty,"Text")_", "_..LogSelectExpression(sessionProperty,"SessionId")_", "_..LogSelectExpression(jobProperty,"Job")_" FROM "_..ClassSqlTableReference(logClassName)
    If timeProperty '= "" {
        Set sql = sql _ " ORDER BY "_timeProperty_" DESC, %ID DESC"
    } Else {
        Set sql = sql _ " ORDER BY %ID DESC"
    }

    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return ..AddStatusError(.result, "Status error: "_$System.Status.GetErrorText(sc))
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ..AddStatusError(.result, "SQL error: "_rset.%Message)
    }

    Set skipped = 0
    Set matched = 0
    For {
        Quit:'rset.%Next()
        Continue:'..ShouldIncludeProductionLog(rset, componentNames, productionName, type, source, contains, dateRange.startHorolog, dateRange.endHorolog)
        Set matched = matched + 1
        Do ..PushUnique(result.sourceNames, rset.%Get("Source"))
        Do ..PushUnique(result.typeNames, rset.%Get("Type"))
        Do ..PushLogTypeFacet(result.typeFacets, rset.%Get("Type"))
        If skipped < result.offset {
            Set skipped = skipped + 1
            Continue
        }
        If result.items.%Size() >= result.limit {
            Set result.hasMore = 1
            Quit
        }
        Do result.items.%Push(..NewProductionLogEntryFromRow(rset, productionName))
    }
    Set result.count = result.items.%Size()
    Set result.totalCount = matched
    Set result.metrics = ..BuildProductionLogMetrics(result)
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
    Set result.payloadMetadata.metrics = ..BuildPayloadMetrics(result.payloadMetadata)
    Set result.metrics = ..BuildMessageDetailMetrics(result)
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
    Set result.payloadReturned = metadata.payloadReturned
    Set result.payloadMetadataEnabled = metadata.payloadMetadataEnabled
    Set result.payloadInspectionSupported = metadata.payloadInspectionSupported
    Set result.restricted = metadata.restricted
    Set result.restrictionReason = metadata.restrictionReason
    Set result.fields = metadata.fields
    Set result.warnings = metadata.warnings
    Set result.evidence = metadata.evidence
    Do ..AddPayloadMetrics(result)
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

ClassMethod GetMessagePayloadPreview(messageId As %Integer) As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set metadataResult = ..GetMessagePayloadMetadata(messageId)
    If metadataResult.%IsDefined("errorCode") {
        return metadataResult
    }

    Set result = {}
    Set result.namespace = metadataResult.namespace
    Set result.messageId = messageId
    Set result.message = metadataResult.message
    Set result.metadata = metadataResult.metadata
    Set result.messageBodyClassName = metadataResult.messageBodyClassName
    Set result.messageBodyId = metadataResult.messageBodyId
    Set result.bodyReferenceAvailable = metadataResult.bodyReferenceAvailable
    Set result.payloadReturned = 0
    Set result.bodyContentReturned = 0
    Set result.runtimeMessageAnalysisEnabled = metadataResult.runtimeMessageAnalysisEnabled
    Set result.payloadInspectionEnabled = metadataResult.payloadInspectionEnabled
    Set result.payloadInspectionSupported = 1
    Set result.restricted = 1
    Set result.restrictionReason = metadataResult.restrictionReason
    Set result.fields = []
    Set result.warnings = metadataResult.warnings
    Set result.evidence = metadataResult.evidence

    If 'result.payloadInspectionEnabled {
        Set result.payloadInspectionSupported = 0
        Do ..AddPayloadMetrics(result)
        return result
    }
    Set result.warnings = []
    If 'result.bodyReferenceAvailable {
        Set result.restrictionReason = "PAYLOAD_BODY_REFERENCE_MISSING"
        Do result.warnings.%Push(..NewWarning("PAYLOAD_BODY_REFERENCE_MISSING", "Message body class or ID is missing."))
        Do ..AddPayloadMetrics(result)
        return result
    }
    If '..ClassExists(result.messageBodyClassName) {
        Set result.restrictionReason = "PAYLOAD_BODY_CLASS_NOT_FOUND"
        Do result.warnings.%Push(..NewWarning("PAYLOAD_BODY_CLASS_NOT_FOUND", "Message body class "_result.messageBodyClassName_" was not found."))
        Do ..AddPayloadMetrics(result)
        return result
    }

    Set body = ""
    Try {
        Set body = $classmethod(result.messageBodyClassName, "%OpenId", result.messageBodyId)
    } Catch ex {
        Set body = ""
    }
    If '$IsObject(body) {
        Set result.restrictionReason = "PAYLOAD_BODY_OPEN_FAILED"
        Do result.warnings.%Push(..NewWarning("PAYLOAD_BODY_OPEN_FAILED", "Message body could not be opened for safe preview."))
        Do ..AddPayloadMetrics(result)
        return result
    }

    Do ..AddPayloadPreviewFields(body, result.messageBodyClassName, settings.fieldRedactionPatterns, result.fields, result.evidence)
    Set result.payloadReturned = 1
    Set result.bodyContentReturned = 1
    Set result.restricted = 0
    Set result.restrictionReason = ""
    Set result.metadata.payloadInspectionSupported = 1
    Set result.metadata.restricted = 0
    Set result.metadata.restrictionReason = ""
    Set result.metadata.fields = result.fields
    Set result.metadata.warnings = []
    Do result.evidence.%Push(..NewEvidence("payload-preview", result.messageBodyClassName, result.messageBodyId, "fields", result.fields.%Size(), "observed"))
    Do ..AddPayloadMetrics(result)
    return result
}

ClassMethod GetProductionMessagePayloadPreview(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set result = ..GetMessagePayloadPreview(messageId)
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
    Set result.metrics = ..BuildTraceMetrics(result)
    return result
}

ClassMethod GetProductionMessageTrace(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set result = ..GetMessageTrace(messageId)
    If result.%IsDefined("errorCode") {
        return result
    }
    Do result.%Set("productionName", productionName)
    Do result.%Set("productionScoped", 1)
    Do ..AnnotateTraceStepsForProduction(result, productionName)
    Set result.traceExplanation = ..NewProductionTraceExplanation(result, productionName)
    return result
}

ClassMethod GetProductionMessageSessionSummary(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set trace = ..GetProductionMessageTrace(productionName, messageId)
    If trace.%IsDefined("errorCode") {
        return trace
    }

    return ..NewMessageSessionSummaryFromTrace(trace, productionName)
}

ClassMethod GetProductionSessionTimeline(productionName As %VarString, sessionId As %VarString, limit As %Integer = 100, startDate As %VarString = "", endDate As %VarString = "") As %DynamicObject
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.sessionId = sessionId
    Set result.limit = ..NormalizeLimitWithMaximum(limit, 100, 500)
    Set result.startDate = ""
    Set result.endDate = ""
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.messages = []
    Set result.logs = []
    Set result.events = []
    Set result.messageCount = 0
    Set result.logCount = 0
    Set result.eventCount = 0
    Set result.warnings = []
    Set result.evidence = []
    Set result.confidence = "observed"

    If 'settings.runtimeMessageAnalysisEnabled {
        Do result.%Set("errorCode", "RUNTIME_MESSAGE_ANALYSIS_DISABLED")
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    If '..IsValidClassName(productionName) {
        Do result.%Set("errorCode", "INVALID_PRODUCTION_NAME")
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    If '..ClassExtends(productionName, "Ens.Production") {
        Do result.%Set("errorCode", "PRODUCTION_NOT_FOUND")
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    If '..IsPositiveInteger(sessionId) {
        Do result.%Set("errorCode", "INVALID_SESSION_ID")
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }

    Set dateRange = ..NormalizeDateRange(startDate, endDate)
    If 'dateRange.valid {
        Do result.%Set("errorCode", "INVALID_DATE_FILTER")
        Do result.%Set("statusText", dateRange.statusText)
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    Set result.startDate = dateRange.startDate
    Set result.endDate = dateRange.endDate

    Set messages = ..ListMessages(productionName, result.limit, 0, "", "", "", sessionId, 0, dateRange.startDate, dateRange.endDate)
    If messages.%IsDefined("errorCode") {
        Do result.%Set("errorCode", messages.errorCode)
        If messages.%IsDefined("statusText") {
            Do result.%Set("statusText", messages.%Get("statusText"))
        }
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    If $IsObject(messages.items) {
        For messageIndex = 0:1:messages.items.%Size()-1 {
            Set message = messages.items.%Get(messageIndex)
            Continue:'$IsObject(message)
            Do result.messages.%Push(message)
            Do result.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", message.messageId, "SessionId", sessionId, "observed"))
        }
    }

    Set logs = ..ListProductionLogs(productionName, 500, 0, "", "", "", dateRange.startDate, dateRange.endDate)
    If logs.%IsDefined("errorCode") {
        Do result.%Set("errorCode", logs.errorCode)
        If logs.%IsDefined("statusText") {
            Do result.%Set("statusText", logs.%Get("statusText"))
        }
        Set result.metrics = ..BuildSessionTimelineMetrics(result)
        return result
    }
    If $IsObject(logs.warnings) {
        For warningIndex = 0:1:logs.warnings.%Size()-1 {
            Set warning = logs.warnings.%Get(warningIndex)
            Continue:'$IsObject(warning)
            Do result.warnings.%Push(warning)
        }
    }
    If $IsObject(logs.items) {
        For logIndex = 0:1:logs.items.%Size()-1 {
            Set log = logs.items.%Get(logIndex)
            Continue:'$IsObject(log)
            Continue:(""_log.sessionId '= ""_sessionId)
            Quit:(result.logs.%Size() >= result.limit)
            Do result.logs.%Push(log)
            Do result.evidence.%Push(..NewEvidence("production-log", logs.logClassName, log.logId, "SessionId", sessionId, "observed"))
        }
    }

    Do ..BuildSessionTimelineEvents(result)
    Set result.messageCount = result.messages.%Size()
    Set result.logCount = result.logs.%Size()
    Set result.eventCount = result.events.%Size()
    Set result.metrics = ..BuildSessionTimelineMetrics(result)
    return result
}

ClassMethod ResendProductionMessage(productionName As %VarString, messageId As %Integer) As %DynamicObject
{
    Set scoped = ..GetProductionMessage(productionName, messageId)
    If scoped.%IsDefined("errorCode") {
        return scoped
    }

    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set result = {}
    Set result.namespace = $Namespace
    Set result.productionName = productionName
    Set result.messageId = messageId
    Set result.sessionId = scoped.message.sessionId
    Set result.action = "resend"
    Set result.requested = 1
    Set result.allowed = 0
    Set result.executed = 0
    Set result.dryRun = 0
    Set result.supported = ..ClassMethodExists("Ens.MessageHeader", "ResendMessage")
    Set result.changed = 0
    Set result.payloadReturned = 0
    Set result.runtimeMessageAnalysisEnabled = settings.runtimeMessageAnalysisEnabled
    Set result.messageResendEnabled = settings.messageResendEnabled
    Set result.selectedMessage = scoped.message
    Set result.warnings = []
    Set result.evidence = []

    If 'settings.messageResendEnabled {
        Set result.reason = "MESSAGE_RESEND_DISABLED"
        Do result.warnings.%Push(..NewWarning("MESSAGE_RESEND_DISABLED", "Message resend is disabled by module settings."))
        Do result.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", messageId, "SessionId", scoped.message.sessionId, "observed"))
        Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "messageResendEnabled", settings.messageResendEnabled, "confirmed"))
        Set result.metrics = ..BuildRuntimeActionMetrics(result)
        return result
    }

    If 'result.supported {
        Set result.reason = "MESSAGE_RESEND_UNSUPPORTED"
        Do result.warnings.%Push(..NewWarning("MESSAGE_RESEND_UNSUPPORTED", "Ens.MessageHeader.ResendMessage is not available in this namespace."))
        Do result.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", messageId, "SessionId", scoped.message.sessionId, "observed"))
        Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "messageResendEnabled", settings.messageResendEnabled, "confirmed"))
        Set result.metrics = ..BuildRuntimeActionMetrics(result)
        return result
    }

    Set result.allowed = 1
    Set result.reason = "MESSAGE_RESEND_EXECUTED"
    New $ROLES
    Do ..EnableRuntimeControlRole()
    Set sc = ##class(Ens.MessageHeader).ResendMessage(messageId)
    If $$$ISERR(sc) {
        Set result.allowed = 0
        Set result.executed = 0
        Set result.changed = 0
        Set result.reason = "RESEND_FAILED"
        Do result.%Set("errorCode", "RESEND_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        Do result.warnings.%Push(..NewWarning("RESEND_FAILED", $System.Status.GetErrorText(sc)))
    } Else {
        Set result.executed = 1
        Set result.changed = 1
    }

    Do result.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", messageId, "SessionId", scoped.message.sessionId, "observed"))
    Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "messageResendEnabled", settings.messageResendEnabled, "confirmed"))
    Do result.evidence.%Push(..NewEvidence("runtime-action", "Ens.MessageHeader", messageId, "ResendMessage", "Called Ens.MessageHeader.ResendMessage", "observed"))
    Set result.metrics = ..BuildRuntimeActionMetrics(result)
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
    Set result.metrics = trace.metrics
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
        Set result.metrics = ..BuildComponentListMetrics(result)
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
    Set result.metrics = ..BuildComponentListMetrics(result)
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

ClassMethod AddConnectionExplanations(connections As %DynamicArray, messageTypes As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        Do explanations.%Push(..NewConnectionExplanation(connection, messageTypes))
    }
    return
}

ClassMethod AddMessageTypeExplanations(messageTypes As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:messageTypes.%Size()-1 {
        Set messageType = messageTypes.%Get(index)
        Continue:'$IsObject(messageType)
        Continue:'..ShouldIncludeMessageClass(messageType.messageClass)
        Do explanations.%Push(..NewMessageTypeExplanation(messageType))
    }
    return
}

ClassMethod AddExternalSystemExplanations(externalSystems As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:externalSystems.%Size()-1 {
        Set external = externalSystems.%Get(index)
        Continue:'$IsObject(external)
        Do explanations.%Push(..NewExternalSystemExplanation(external))
    }
    return
}

ClassMethod AddArtifactExplanations(artifacts As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:artifacts.%Size()-1 {
        Set artifact = artifacts.%Get(index)
        Continue:'$IsObject(artifact)
        Do explanations.%Push(..NewArtifactExplanation(artifact))
    }
    return
}

ClassMethod AddTransformationExplanations(transformations As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:transformations.%Size()-1 {
        Set transformation = transformations.%Get(index)
        Continue:'$IsObject(transformation)
        Do explanations.%Push(..NewTransformationExplanation(transformation))
    }
    return
}

ClassMethod AddRuleExplanations(rules As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:rules.%Size()-1 {
        Set rule = rules.%Get(index)
        Continue:'$IsObject(rule)
        Do explanations.%Push(..NewRuleExplanation(rule))
    }
    return
}

ClassMethod AddBusinessProcessExplanations(businessProcesses As %DynamicArray, explanations As %DynamicArray) [ Private ]
{
    For index = 0:1:businessProcesses.%Size()-1 {
        Set process = businessProcesses.%Get(index)
        Continue:'$IsObject(process)
        Do explanations.%Push(..NewBusinessProcessExplanation(process))
    }
    return
}

ClassMethod AddGraphNodes(components As %DynamicArray, componentExplanations As %DynamicArray, nodes As %DynamicArray) [ Private ]
{
    For index = 0:1:components.%Size()-1 {
        Set component = components.%Get(index)
        Continue:'$IsObject(component)
        Do nodes.%Push(..NewGraphNode(component, componentExplanations))
    }
    return
}

ClassMethod NewGraphNode(component As %DynamicObject, componentExplanations As %DynamicArray) As %DynamicObject [ Private ]
{
    Set node = {}
    Set node.id = component.name
    Set node.label = component.name
    Set node.type = component.type
    Set node.className = component.className
    Set node.enabled = component.enabled
    Set node.protocol = component.protocol
    Set node.adapterClass = component.adapterClass
    Set explanation = ..FindComponentExplanationByName(componentExplanations, component.name)
    If $IsObject(explanation) {
        Set node.text = explanation.text
    }
    Set node.confidence = component.confidence
    Set node.evidence = component.evidence
    return node
}

ClassMethod AddGraphEdges(connections As %DynamicArray, messageTypes As %DynamicArray, connectionExplanations As %DynamicArray, edges As %DynamicArray) [ Private ]
{
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        Do edges.%Push(..NewGraphEdge(connection, messageTypes, connectionExplanations, index))
    }
    return
}

ClassMethod NewGraphEdge(connection As %DynamicObject, messageTypes As %DynamicArray, connectionExplanations As %DynamicArray, index As %Integer) As %DynamicObject [ Private ]
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
    Set explanation = ..FindConnectionExplanationForGraphEdge(connectionExplanations, connection)
    If $IsObject(explanation) {
        Set edge.text = explanation.text
    }
    Set edge.confidence = connection.confidence
    Set edge.evidence = connection.evidence
    return edge
}

ClassMethod FindConnectionExplanationForGraphEdge(connectionExplanations As %DynamicArray, connection As %DynamicObject) As %DynamicObject [ Private ]
{
    Set found = ""
    For index = 0:1:connectionExplanations.%Size()-1 {
        Set explanation = connectionExplanations.%Get(index)
        Continue:'$IsObject(explanation)
        If (explanation.%Get("from") = connection.%Get("from")) && (explanation.%Get("to") = connection.%Get("to")) && (explanation.kind = connection.kind) {
            Set found = explanation
            Quit
        }
    }
    return found
}

ClassMethod MessageClassesForGraphEdge(messageTypes As %DynamicArray, sourceName As %VarString, targetName As %VarString) As %DynamicArray [ Private ]
{
    Set names = ..MessageClassesForComponent(messageTypes, sourceName, "output")
    Set targetNames = ..MessageClassesForComponent(messageTypes, targetName, "input")
    For index = 0:1:targetNames.%Size()-1 {
        Do ..PushUnique(names, targetNames.%Get(index))
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

ClassMethod NewRuleExplanation(rule As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.name = rule.name
    Set explanation.component = rule.component
    Set explanation.conditionCount = 0
    If $IsObject(rule.conditions) {
        Set explanation.conditionCount = rule.conditions.%Size()
    }
    Set explanation.targets = ..TargetsForRule(rule)
    Set explanation.transforms = ..TransformsForRule(rule)
    Set explanation.targetCount = explanation.targets.%Size()
    Set explanation.transformCount = explanation.transforms.%Size()
    Set explanation.text = ..BuildRuleExplanationText(rule, explanation.conditionCount, explanation.targets, explanation.transforms)
    Set explanation.confidence = rule.confidence
    Set explanation.evidence = []
    If $IsObject(rule.evidence) {
        For evidenceIndex = 0:1:rule.evidence.%Size()-1 {
            Set evidence = rule.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildRuleExplanationText(rule As %DynamicObject, conditionCount As %Integer, targets As %DynamicArray, transforms As %DynamicArray) As %VarString [ Private ]
{
    Set text = rule.name_" routes messages for component "_rule.component
    If conditionCount > 0 {
        Set text = text_" using "_conditionCount_" condition"_..Plural(conditionCount)
    }
    If targets.%Size() > 0 {
        Set text = text_" to "_..JoinArray(targets)
    }
    If transforms.%Size() > 0 {
        Set text = text_" and applies "_..JoinArray(transforms)
    }
    Set text = text_"."
    return text
}

ClassMethod TargetsForRule(rule As %DynamicObject) As %DynamicArray [ Private ]
{
    Set targets = []
    If '$IsObject(rule.sends) {
        return targets
    }
    For index = 0:1:rule.sends.%Size()-1 {
        Set send = rule.sends.%Get(index)
        Continue:'$IsObject(send)
        Continue:(send.target = "")
        Do ..PushUnique(targets, send.target)
    }
    return targets
}

ClassMethod TransformsForRule(rule As %DynamicObject) As %DynamicArray [ Private ]
{
    Set transforms = []
    If '$IsObject(rule.sends) {
        return transforms
    }
    For index = 0:1:rule.sends.%Size()-1 {
        Set send = rule.sends.%Get(index)
        Continue:'$IsObject(send)
        Continue:(send.transform = "")
        Do ..PushUnique(transforms, send.transform)
    }
    return transforms
}

ClassMethod NewConnectionExplanation(connection As %DynamicObject, messageTypes As %DynamicArray) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Do explanation.%Set("from", connection.%Get("from"))
    Do explanation.%Set("to", connection.%Get("to"))
    Set explanation.kind = connection.kind
    If connection.%IsDefined("ruleName") {
        Set explanation.ruleName = connection.ruleName
    }
    If connection.%IsDefined("processClass") {
        Set explanation.processClass = connection.processClass
    }
    Set explanation.messageClasses = ..MessageClassesForGraphEdge(messageTypes, connection.%Get("from"), connection.%Get("to"))
    Set explanation.text = ..BuildConnectionExplanationText(connection, explanation.messageClasses)
    Set explanation.confidence = connection.confidence
    Set explanation.evidence = []
    If $IsObject(connection.evidence) {
        For evidenceIndex = 0:1:connection.evidence.%Size()-1 {
            Set evidence = connection.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildConnectionExplanationText(connection As %DynamicObject, messageClasses As %DynamicArray) As %VarString [ Private ]
{
    Set text = connection.%Get("from")_" sends messages to "_connection.%Get("to")
    If connection.kind '= "" {
        Set text = text_" through a "_connection.kind_" connection"
    }
    If connection.%IsDefined("ruleName") {
        Set text = text_" controlled by routing rule "_connection.ruleName
    }
    If connection.%IsDefined("processClass") {
        Set text = text_" implemented by BPL process "_connection.processClass
    }
    If messageClasses.%Size() > 0 {
        Set text = text_". Message signatures include "_..JoinArray(messageClasses)
    }
    Set text = text_"."
    return text
}

ClassMethod NewMessageTypeExplanation(messageType As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.component = messageType.component
    Set explanation.componentType = messageType.componentType
    Set explanation.className = messageType.className
    Set explanation.method = messageType.method
    Set explanation.parameter = messageType.parameter
    Set explanation.direction = messageType.direction
    Set explanation.messageClass = messageType.messageClass
    Set explanation.text = ..BuildMessageTypeExplanationText(messageType)
    Set explanation.confidence = messageType.confidence
    Set explanation.evidence = []
    If $IsObject(messageType.evidence) {
        For evidenceIndex = 0:1:messageType.evidence.%Size()-1 {
            Set evidence = messageType.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildMessageTypeExplanationText(messageType As %DynamicObject) As %VarString [ Private ]
{
    Set directionText = $Select(messageType.direction="input":"accepts",messageType.direction="output":"returns",1:"uses")
    Set text = messageType.component_" "_directionText_" "_messageType.messageClass
    If messageType.parameter '= "" {
        Set text = text_" as parameter "_messageType.parameter
    }
    If messageType.method '= "" {
        Set text = text_" in "_messageType.className_"."_messageType.method
    } Else {
        Set text = text_" in "_messageType.className
    }
    Set text = text_"."
    return text
}

ClassMethod NewExternalSystemExplanation(external As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.component = external.component
    Set explanation.componentType = external.componentType
    Set explanation.kind = external.kind
    Set explanation.value = external.value
    Set explanation.text = ..BuildExternalSystemExplanationText(external)
    Set explanation.confidence = external.confidence
    Set explanation.evidence = []
    If $IsObject(external.evidence) {
        For evidenceIndex = 0:1:external.evidence.%Size()-1 {
            Set evidence = external.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildExternalSystemExplanationText(external As %DynamicObject) As %VarString [ Private ]
{
    Set kindText = $Select(external.kind="file-path":"file path",external.kind="url":"URL",external.kind="http-server":"HTTP server",external.kind="port":"network port",1:external.kind)
    Set actionText = $Select(external.componentType="business-service":"receives from",external.componentType="business-operation":"sends to",1:"references")
    Set text = external.component_" "_actionText_" external "_kindText_" "_external.value_"."
    return text
}

ClassMethod NewArtifactExplanation(artifact As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.kind = artifact.kind
    Set explanation.name = artifact.name
    Set explanation.component = artifact.component
    Set explanation.label = ..ArtifactKindText(artifact.kind)
    Set explanation.text = ..BuildArtifactExplanationText(artifact)
    Set explanation.confidence = artifact.confidence
    Set explanation.evidence = []
    If $IsObject(artifact.evidence) {
        For evidenceIndex = 0:1:artifact.evidence.%Size()-1 {
            Set evidence = artifact.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildArtifactExplanationText(artifact As %DynamicObject) As %VarString [ Private ]
{
    Set label = ..ArtifactKindText(artifact.kind)
    Set text = artifact.component_" references "_label_" "_artifact.name
    If artifact.kind = "rule-transformation" {
        Set text = artifact.component_" applies rule transformation "_artifact.name
    }
    If artifact.kind = "bpl-process" {
        Set text = artifact.component_" implements BPL process "_artifact.name
    }
    Set text = text_"."
    return text
}

ClassMethod ArtifactKindText(kind As %VarString) As %VarString [ Private ]
{
    If kind = "routing-rule" {
        return "routing rule"
    }
    If kind = "rule-transformation" {
        return "rule transformation"
    }
    If kind = "transformation" {
        return "transformation"
    }
    If kind = "bpl-process" {
        return "BPL process"
    }
    If kind = "record-map" {
        return "record map"
    }
    return "artifact"
}

ClassMethod NewTransformationExplanation(transformation As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.name = transformation.name
    Set explanation.component = transformation.component
    Set explanation.sourceKind = transformation.sourceKind
    Set explanation.sourceClass = transformation.sourceClass
    Set explanation.targetClass = transformation.targetClass
    Set explanation.assignmentCount = 0
    If $IsObject(transformation.assignments) {
        Set explanation.assignmentCount = transformation.assignments.%Size()
    }
    Set explanation.text = ..BuildTransformationExplanationText(transformation, explanation.assignmentCount)
    Set explanation.confidence = transformation.confidence
    Set explanation.evidence = []
    If $IsObject(transformation.evidence) {
        For evidenceIndex = 0:1:transformation.evidence.%Size()-1 {
            Set evidence = transformation.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildTransformationExplanationText(transformation As %DynamicObject, assignmentCount As %Integer) As %VarString [ Private ]
{
    Set text = transformation.name_" maps "_$Select(transformation.sourceClass'="":transformation.sourceClass,1:"an unknown source class")_" to "_$Select(transformation.targetClass'="":transformation.targetClass,1:"an unknown target class")
    If transformation.component '= "" {
        Set text = text_" for component "_transformation.component
    }
    If assignmentCount > 0 {
        Set text = text_" using "_assignmentCount_" assignment"_..Plural(assignmentCount)
    }
    Set text = text_"."
    return text
}

ClassMethod NewBusinessProcessExplanation(process As %DynamicObject) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set explanation.name = process.name
    Set explanation.component = process.component
    Set explanation.requestClass = process.requestClass
    Set explanation.responseClass = process.responseClass
    Set explanation.contextClass = process.contextClass
    Set explanation.callTargets = ..CallTargetsForBusinessProcess(process)
    Set explanation.callCount = explanation.callTargets.%Size()
    Set explanation.assignCount = 0
    If $IsObject(process.actions) {
        Set explanation.assignCount = process.actions.assign
    }
    Set explanation.text = ..BuildBusinessProcessExplanationText(process, explanation.callTargets, explanation.assignCount)
    Set explanation.confidence = process.confidence
    Set explanation.evidence = []
    If $IsObject(process.evidence) {
        For evidenceIndex = 0:1:process.evidence.%Size()-1 {
            Set evidence = process.evidence.%Get(evidenceIndex)
            If $IsObject(evidence) {
                Do explanation.evidence.%Push(evidence)
            }
        }
    }
    return explanation
}

ClassMethod BuildBusinessProcessExplanationText(process As %DynamicObject, callTargets As %DynamicArray, assignCount As %Integer) As %VarString [ Private ]
{
    Set text = process.name_" defines BPL process logic"
    If process.component '= "" {
        Set text = text_" for component "_process.component
    }
    If process.requestClass '= "" {
        Set text = text_" accepting "_process.requestClass
    }
    If process.responseClass '= "" {
        Set text = text_" and returning "_process.responseClass
    }
    Set text = text_"."
    If callTargets.%Size() > 0 {
        Set text = text_" It calls "_..JoinArray(callTargets)_"."
    }
    If assignCount > 0 {
        Set text = text_" It performs "_assignCount_" assignment"_..Plural(assignCount)_"."
    }
    return text
}

ClassMethod CallTargetsForBusinessProcess(process As %DynamicObject) As %DynamicArray [ Private ]
{
    Set targets = []
    If '$IsObject(process.calls) {
        return targets
    }
    For index = 0:1:process.calls.%Size()-1 {
        Set call = process.calls.%Get(index)
        Continue:'$IsObject(call)
        Continue:(call.target = "")
        Do ..PushUnique(targets, call.target)
    }
    return targets
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
            Continue:'..ShouldIncludeMessageClass(message.messageClass)
            Do ..PushUnique(names, message.messageClass)
        }
    }
    return names
}

ClassMethod ShouldIncludeMessageClass(messageClass As %VarString) As %Boolean [ Private ]
{
    If messageClass = "" {
        return 0
    }
    Set normalized = $ZConvert(messageClass, "L")
    If (normalized = "%persistent") || (normalized = "%registeredobject") || (normalized = "%serialobject") {
        return 0
    }
    If (normalized = "%library.persistent") || (normalized = "%library.registeredobject") || (normalized = "%library.serialobject") {
        return 0
    }
    If (normalized = "%string") || (normalized = "%varstring") || (normalized = "%integer") || (normalized = "%boolean") || (normalized = "%status") {
        return 0
    }
    If (normalized = "%library.string") || (normalized = "%library.varstring") || (normalized = "%library.integer") || (normalized = "%library.boolean") || (normalized = "%library.status") {
        return 0
    }
    return 1
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

ClassMethod PushStatusFacet(items As %DynamicArray, status As %VarString) [ Private ]
{
    If status = "" {
        return
    }
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        Continue:'$IsObject(item)
        If item.status = status {
            return
        }
    }
    Set facet = {}
    Set facet.status = status
    Set facet.statusLabel = ..MessageStatusLabel(status)
    Do items.%Push(facet)
    return
}

ClassMethod PushLogTypeFacet(items As %DynamicArray, type As %VarString) [ Private ]
{
    If type = "" {
        return
    }
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        Continue:'$IsObject(item)
        If item.type = type {
            return
        }
    }
    Set facet = {}
    Set facet.type = type
    Set facet.typeLabel = ..LogTypeLabel(type)
    Do items.%Push(facet)
    return
}

ClassMethod NewCodeValue(code As %Integer, label As %VarString) As %DynamicObject [ Private ]
{
    Set value = {}
    Set value.code = code
    Set value.label = label
    return value
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

ClassMethod BuildAISummaryPrompt(analysis As %DynamicObject) As %VarString [ Private ]
{
    Set prompt = "You are explaining an InterSystems IRIS interoperability production to an engineer. Use only the deterministic facts below. Return concise Markdown with sections: Overview, Runtime shape, Key flows, Risks or gaps. Do not invent components or external systems."_$Char(10,10)
    Set prompt = prompt_"Production: "_analysis.productionName_$Char(10)
    Set prompt = prompt_"Deterministic summary: "_analysis.summary_$Char(10)
    If $IsObject(analysis.metrics) {
        Set prompt = prompt_"Metrics: components="_analysis.metrics.componentCount_", services="_analysis.metrics.serviceCount_", processes="_analysis.metrics.processCount_", operations="_analysis.metrics.operationCount_", connections="_analysis.metrics.connectionCount_", rules="_analysis.metrics.ruleCount_", transforms="_analysis.metrics.transformationCount_", BPL="_analysis.metrics.businessProcessCount_$Char(10)
    }
    Set prompt = prompt_$Char(10)_"Components:"_$Char(10)
    If $IsObject(analysis.components) {
        For index = 0:1:analysis.components.%Size()-1 {
            Set component = analysis.components.%Get(index)
            Continue:'$IsObject(component)
            Set prompt = prompt_"- "_component.name_" ("_component.type_") class="_component.className_" enabled="_component.enabled_$Char(10)
        }
    }
    Set prompt = prompt_$Char(10)_"Connections:"_$Char(10)
    If $IsObject(analysis.connections) {
        For index = 0:1:analysis.connections.%Size()-1 {
            Set connection = analysis.connections.%Get(index)
            Continue:'$IsObject(connection)
            Set prompt = prompt_"- "_connection.from_" -> "_connection.to_" via "_connection.kind_$Char(10)
        }
    }
    If $IsObject(analysis.warnings),analysis.warnings.%Size() > 0 {
        Set prompt = prompt_$Char(10)_"Warnings:"_$Char(10)
        For index = 0:1:analysis.warnings.%Size()-1 {
            Set warning = analysis.warnings.%Get(index)
            Continue:'$IsObject(warning)
            Set prompt = prompt_"- "_warning.code_": "_warning.message_$Char(10)
        }
    }
    return $Extract(prompt, 1, 12000)
}

ClassMethod BuildProductionRAGChunks(analysis As %DynamicObject) As %DynamicArray [ Private ]
{
    Set chunks = []
    Do chunks.%Push(..NewRAGChunk("production-summary", "summary", analysis.productionName, analysis.summary, analysis.productionName, analysis.productionName, "confirmed", analysis.evidence))

    If $IsObject(analysis.summaryBullets) {
        Set text = ..JoinArrayWithSeparator(analysis.summaryBullets, "; ")
        If text '= "" {
            Do chunks.%Push(..NewRAGChunk("production-bullets", "summary", "Summary bullets", text, analysis.productionName, analysis.productionName, "confirmed", analysis.evidence))
        }
    }
    Do ..AddMessageSchemaRAGChunks(analysis, chunks)
    If $IsObject(analysis.components) {
        For index = 0:1:analysis.components.%Size()-1 {
            Set component = analysis.components.%Get(index)
            Continue:'$IsObject(component)
            Set text = "Component "_component.name_" is a "_component.type_" using class "_component.className_". Enabled: "_component.enabled_"."
            If component.%IsDefined("adapterClass") && (component.adapterClass '= "") {
                Set text = text_" Adapter: "_component.adapterClass_"."
            }
            If component.%IsDefined("protocol") && (component.protocol '= "") {
                Set text = text_" Protocol: "_component.protocol_"."
            }
            Do chunks.%Push(..NewRAGChunk("component-"_component.name, "component", component.name, text, component.className, component.name, component.confidence, component.evidence))
        }
    }
    If $IsObject(analysis.componentExplanations) {
        For index = 0:1:analysis.componentExplanations.%Size()-1 {
            Set explanation = analysis.componentExplanations.%Get(index)
            Continue:'$IsObject(explanation)
            Do chunks.%Push(..NewRAGChunk("component-explanation-"_explanation.component, "component-explanation", explanation.component, explanation.text, "component-explanation", explanation.component, explanation.confidence, explanation.evidence))
        }
    }
    If $IsObject(analysis.connections) {
        For index = 0:1:analysis.connections.%Size()-1 {
            Set connection = analysis.connections.%Get(index)
            Continue:'$IsObject(connection)
            Set text = connection.from_" connects to "_connection.to_" via "_connection.kind_"."
            If connection.%IsDefined("ruleName") && (connection.ruleName '= "") {
                Set text = text_" Rule: "_connection.ruleName_"."
            }
            If connection.%IsDefined("processClass") && (connection.processClass '= "") {
                Set text = text_" Process class: "_connection.processClass_"."
            }
            Do chunks.%Push(..NewRAGChunk("connection-"_index, "connection", connection.from_" to "_connection.to, text, analysis.productionName, connection.from, connection.confidence, connection.evidence))
        }
    }
    If $IsObject(analysis.connectionExplanations) {
        For index = 0:1:analysis.connectionExplanations.%Size()-1 {
            Set explanation = analysis.connectionExplanations.%Get(index)
            Continue:'$IsObject(explanation)
            Do chunks.%Push(..NewRAGChunk("connection-explanation-"_index, "connection-explanation", explanation.from_" to "_explanation.to, explanation.text, "connection-explanation", explanation.from, explanation.confidence, explanation.evidence))
        }
    }
    If $IsObject(analysis.externalSystems) {
        For index = 0:1:analysis.externalSystems.%Size()-1 {
            Set external = analysis.externalSystems.%Get(index)
            Continue:'$IsObject(external)
            Set text = external.component_" has external "_external.kind_" setting "_external.field_" = "_external.value_"."
            Do chunks.%Push(..NewRAGChunk("external-"_index, "external-system", external.component_" "_external.field, text, external.source, external.component, external.confidence, external.evidence))
        }
    }
    If $IsObject(analysis.rules) {
        For index = 0:1:analysis.rules.%Size()-1 {
            Set rule = analysis.rules.%Get(index)
            Continue:'$IsObject(rule)
            Set text = "Routing rule "_rule.name_" is used by "_rule.component_"."
            If $IsObject(rule.sends) {
                Set targets = []
                For sendIndex = 0:1:rule.sends.%Size()-1 {
                    Set send = rule.sends.%Get(sendIndex)
                    Continue:'$IsObject(send)
                    Do targets.%Push(send.target)
                }
                Set text = text_" Targets: "_..JoinArrayWithSeparator(targets, ", ")_"."
            }
            Do chunks.%Push(..NewRAGChunk("rule-"_rule.name, "routing-rule", rule.name, text, rule.name, rule.component, rule.confidence, rule.evidence))
        }
    }
    If $IsObject(analysis.ruleExplanations) {
        For index = 0:1:analysis.ruleExplanations.%Size()-1 {
            Set explanation = analysis.ruleExplanations.%Get(index)
            Continue:'$IsObject(explanation)
            Do chunks.%Push(..NewRAGChunk("rule-explanation-"_explanation.name, "routing-rule-explanation", explanation.name, explanation.text, explanation.name, explanation.component, explanation.confidence, explanation.evidence))
        }
    }
    If $IsObject(analysis.messageTypes) {
        For index = 0:1:analysis.messageTypes.%Size()-1 {
            Set messageType = analysis.messageTypes.%Get(index)
            Continue:'$IsObject(messageType)
            Set text = messageType.component_" "_messageType.direction_" message type "_messageType.messageClass_" from "_messageType.method_"."
            Do chunks.%Push(..NewRAGChunk("message-type-"_index, "message-type", messageType.component_" "_messageType.messageClass, text, messageType.className, messageType.component, messageType.confidence, messageType.evidence))
        }
    }
    If $IsObject(analysis.transformations) {
        For index = 0:1:analysis.transformations.%Size()-1 {
            Set transform = analysis.transformations.%Get(index)
            Continue:'$IsObject(transform)
            Set text = "DTL "_transform.name_" maps "_transform.sourceClass_" to "_transform.targetClass_" for "_transform.component_". Assignment count: "_transform.assignmentCount_"."
            Do chunks.%Push(..NewRAGChunk("transformation-"_transform.name, "transformation", transform.name, text, transform.name, transform.component, transform.confidence, transform.evidence))
        }
    }
    If $IsObject(analysis.businessProcesses) {
        For index = 0:1:analysis.businessProcesses.%Size()-1 {
            Set process = analysis.businessProcesses.%Get(index)
            Continue:'$IsObject(process)
            Set text = "Business process "_process.name_" for component "_process.component_" has "_process.callCount_" calls and "_process.assignCount_" assignments."
            Do chunks.%Push(..NewRAGChunk("business-process-"_process.name, "business-process", process.name, text, process.name, process.component, process.confidence, process.evidence))
        }
    }
    If $IsObject(analysis.warnings) {
        For index = 0:1:analysis.warnings.%Size()-1 {
            Set warning = analysis.warnings.%Get(index)
            Continue:'$IsObject(warning)
            Do chunks.%Push(..NewRAGChunk("warning-"_index, "warning", warning.code, warning.message, analysis.productionName, analysis.productionName, "observed", []))
        }
    }
    return chunks
}

ClassMethod AddMessageSchemaRAGChunks(analysis As %DynamicObject, chunks As %DynamicArray) [ Private ]
{
    Set schemas = []
    If $IsObject(analysis.messageTypes) {
        For index = 0:1:analysis.messageTypes.%Size()-1 {
            Set messageType = analysis.messageTypes.%Get(index)
            Continue:'$IsObject(messageType)
            Do ..AddMessageSchemaCandidate(schemas, messageType.messageClass, messageType.component, messageType.direction, "compiled-method")
        }
    }
    If $IsObject(analysis.transformations) {
        For index = 0:1:analysis.transformations.%Size()-1 {
            Set transform = analysis.transformations.%Get(index)
            Continue:'$IsObject(transform)
            Do ..AddMessageSchemaCandidate(schemas, transform.sourceClass, transform.component, "source", "dtl-transformation")
            Do ..AddMessageSchemaCandidate(schemas, transform.targetClass, transform.component, "target", "dtl-transformation")
        }
    }
    If $IsObject(analysis.businessProcesses) {
        For index = 0:1:analysis.businessProcesses.%Size()-1 {
            Set process = analysis.businessProcesses.%Get(index)
            Continue:'$IsObject(process)
            Do ..AddMessageSchemaCandidate(schemas, process.requestClass, process.component, "request", "bpl-process")
            Do ..AddMessageSchemaCandidate(schemas, process.responseClass, process.component, "response", "bpl-process")
        }
    }
    For index = 0:1:schemas.%Size()-1 {
        Set schema = schemas.%Get(index)
        Continue:'$IsObject(schema)
        Set chunk = ..NewMessageSchemaRAGChunk(schema)
        If $IsObject(chunk) {
            Do chunks.%Push(chunk)
        }
    }
    return
}

ClassMethod AddMessageSchemaCandidate(schemas As %DynamicArray, className As %VarString, componentName As %VarString, direction As %VarString, sourceType As %VarString) [ Private ]
{
    Set className = ..NormalizeClassName(className)
    If className = "" {
        return
    }
    If $Extract(className, 1, 1) = "%" {
        return
    }
    If '..ClassExists(className) {
        return
    }
    If '(..ClassExtends(className, "Ens.MessageBody") || ..ClassExtends(className, "Ens.Request") || ..ClassExtends(className, "Ens.Response")) {
        return
    }

    Set schema = ""
    For index = 0:1:schemas.%Size()-1 {
        Set candidate = schemas.%Get(index)
        Continue:'$IsObject(candidate)
        If candidate.className = className {
            Set schema = candidate
            Quit
        }
    }
    If '$IsObject(schema) {
        Set schema = {}
        Set schema.className = className
        Set schema.consumers = []
        Set schema.producers = []
        Set schema.components = []
        Set schema.sources = []
        Set schema.evidence = []
        Do schemas.%Push(schema)
    }

    Set normalizedDirection = $ZConvert(direction, "L")
    If componentName '= "" {
        Do ..PushUnique(schema.components, componentName)
        If (normalizedDirection = "input") || (normalizedDirection = "source") || (normalizedDirection = "request") {
            Do ..PushUnique(schema.consumers, componentName)
        } ElseIf (normalizedDirection = "output") || (normalizedDirection = "target") || (normalizedDirection = "response") {
            Do ..PushUnique(schema.producers, componentName)
        }
    }
    Do ..PushUnique(schema.sources, sourceType)
    If schema.evidence.%Size() < 20 {
        Do schema.evidence.%Push(..NewEvidence(sourceType, className, componentName, "messageClass", className_" "_direction, "confirmed"))
    }
    return
}

ClassMethod NewMessageSchemaRAGChunk(schema As %DynamicObject) As %DynamicObject [ Private ]
{
    Set fields = []
    Set evidence = schema.evidence
    Do ..AddMessageSchemaFields(schema.className, fields, evidence)
    If fields.%Size() = 0 {
        return ""
    }

    Set text = "Message body class "_schema.className_" metadata-only schema for payload data fields and message structure. It defines fields: "
    Set maxFields = 80
    For index = 0:1:fields.%Size()-1 {
        Quit:(index >= maxFields)
        Set field = fields.%Get(index)
        Continue:'$IsObject(field)
        If index > 0 {
            Set text = text_", "
        }
        Set text = text_field.name_" ("_field.type_", "_field.category
        If field.collection '= "" {
            Set text = text_" "_field.collection
        }
        Set text = text_")"
    }
    If fields.%Size() > maxFields {
        Set text = text_", and "_(fields.%Size()-maxFields)_" more"
    }
    Set text = text_". Field count: "_fields.%Size()_"."
    If schema.consumers.%Size() > 0 {
        Set text = text_" Consumed by components: "_..JoinArrayWithSeparator(schema.consumers, ", ")_"."
    }
    If schema.producers.%Size() > 0 {
        Set text = text_" Produced by components: "_..JoinArrayWithSeparator(schema.producers, ", ")_"."
    }
    If schema.components.%Size() > 0 {
        Set text = text_" Related components: "_..JoinArrayWithSeparator(schema.components, ", ")_"."
    }
    Set text = text_" No live payload values are included in this chunk."
    return ..NewRAGChunk("message-schema-"_schema.className, "message-schema", "Message schema "_schema.className, text, "%Dictionary.CompiledProperty", ..FirstArrayValue(schema.components), "confirmed", evidence)
}

ClassMethod AddMessageSchemaFields(bodyClassName As %VarString, fields As %DynamicArray, evidence As %DynamicArray) [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Name, Type, Collection FROM %Dictionary.CompiledProperty WHERE Parent = ? ORDER BY Name"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return
    }
    Set rset = stmt.%Execute(bodyClassName)
    If rset.%SQLCODE < 0 {
        return
    }

    While rset.%Next() {
        Set propertyName = rset.%Get("Name")
        Set propertyType = rset.%Get("Type")
        Set collection = rset.%Get("Collection")
        Continue:(propertyName = "")
        Continue:($Extract(propertyName, 1) = "%")

        Set field = {}
        Set field.name = propertyName
        Set field.type = propertyType
        Set field.collection = collection
        Set field.scalar = (collection = "") && ..IsPreviewScalarType(propertyType)
        Set field.object = (collection = "") && 'field.scalar
        Set field.collectionFlag = (collection '= "")
        Set field.category = $Select(field.collectionFlag:"collection",field.scalar:"scalar",1:"object")
        Do fields.%Push(field)
        Do evidence.%Push(..NewEvidence("message-schema-property", bodyClassName, propertyName, "Type", propertyType_" "_field.category, "confirmed"))
    }
    return
}

ClassMethod FirstArrayValue(items As %DynamicArray) As %VarString [ Private ]
{
    If '$IsObject(items) {
        return ""
    }
    If items.%Size() = 0 {
        return ""
    }
    return items.%Get(0)
}

ClassMethod NewRAGChunk(chunkId As %VarString, kind As %VarString, title As %VarString, text As %VarString, source As %VarString, component As %VarString, confidence As %VarString, evidence) As %DynamicObject [ Private ]
{
    Set chunk = {}
    Set chunk.id = chunkId
    Set chunk.kind = kind
    Set chunk.title = title
    Set chunk.text = $Extract(text, 1, 2000)
    Set chunk.source = source
    Set chunk.component = component
    Set chunk.confidence = $Select(confidence'="":confidence,1:"inferred")
    If $IsObject(evidence) {
        Set chunk.evidence = evidence
    } Else {
        Set chunk.evidence = []
    }
    return chunk
}

ClassMethod RetrieveRAGChunks(chunks As %DynamicArray, question As %VarString, componentName As %VarString, maxChunks As %Integer) As %DynamicArray [ Private ]
{
    Set result = []
    Set candidates = []
    Set normalizedQuestion = $ZConvert(question, "L")
    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        If componentName '= "" {
            Continue:'..RAGChunkMatchesComponent(chunk, componentName)
        }
        Set score = ..RAGChunkScore(chunk, normalizedQuestion)
        Continue:(score < 1)
        Set chunk.score = score
        Do candidates.%Push(chunk)
    }
    Set used = []
    For {
        Quit:(result.%Size() >= maxChunks)
        Set bestIndex = -1
        Set bestScore = -1
        For index = 0:1:candidates.%Size()-1 {
            Continue:..DynamicArrayContains(used, index)
            Set chunk = candidates.%Get(index)
            Continue:'$IsObject(chunk)
            If chunk.score > bestScore {
                Set bestScore = chunk.score
                Set bestIndex = index
            }
        }
        Quit:(bestIndex < 0)
        Do used.%Push(bestIndex)
        Do result.%Push(candidates.%Get(bestIndex))
    }
    If result.%Size() = 0 {
        For index = 0:1:chunks.%Size()-1 {
            Quit:(result.%Size() >= maxChunks)
            Set chunk = chunks.%Get(index)
            Continue:'$IsObject(chunk)
            If componentName '= "" {
                Continue:'..RAGChunkMatchesComponent(chunk, componentName)
            }
            Set chunk.score = 0
            Do result.%Push(chunk)
        }
    }
    return result
}

ClassMethod RAGChunkMatchesComponent(chunk As %DynamicObject, componentName As %VarString) As %Boolean [ Private ]
{
    If chunk.component = componentName {
        return 1
    }
    If chunk.text [ componentName {
        return 1
    }
    If chunk.title [ componentName {
        return 1
    }
    return 0
}

ClassMethod BuildRAGContextMetrics(context As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.chunkCount = context.chunkCount
    Set metrics.retrievedChunkCount = context.retrievedChunkCount
    Set metrics.componentChunkCount = 0
    Set metrics.connectionChunkCount = 0
    Set metrics.ruleChunkCount = 0
    Set metrics.messageTypeChunkCount = 0
    Set metrics.externalSystemChunkCount = 0
    Set metrics.transformationChunkCount = 0
    Set metrics.businessProcessChunkCount = 0
    Set metrics.messageChunkCount = 0
    Set metrics.logChunkCount = 0
    Set metrics.payloadChunkCount = 0
    Set metrics.messageSchemaChunkCount = 0
    Set metrics.runtimeChunkCount = 0
    Set metrics.warningChunkCount = 0
    If $IsObject(context.chunks) {
        For index = 0:1:context.chunks.%Size()-1 {
            Set chunk = context.chunks.%Get(index)
            Continue:'$IsObject(chunk)
            If chunk.kind = "component" {
                Set metrics.componentChunkCount = metrics.componentChunkCount + 1
            }
            If (chunk.kind = "connection") || (chunk.kind = "connection-explanation") {
                Set metrics.connectionChunkCount = metrics.connectionChunkCount + 1
            }
            If (chunk.kind = "routing-rule") || (chunk.kind = "routing-rule-explanation") {
                Set metrics.ruleChunkCount = metrics.ruleChunkCount + 1
            }
            If chunk.kind = "message-type" {
                Set metrics.messageTypeChunkCount = metrics.messageTypeChunkCount + 1
            }
            If chunk.kind = "external-system" {
                Set metrics.externalSystemChunkCount = metrics.externalSystemChunkCount + 1
            }
            If chunk.kind = "transformation" {
                Set metrics.transformationChunkCount = metrics.transformationChunkCount + 1
            }
            If chunk.kind = "business-process" {
                Set metrics.businessProcessChunkCount = metrics.businessProcessChunkCount + 1
            }
            If chunk.kind = "message" {
                Set metrics.messageChunkCount = metrics.messageChunkCount + 1
                Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + 1
            }
            If chunk.kind = "log" {
                Set metrics.logChunkCount = metrics.logChunkCount + 1
                Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + 1
            }
            If chunk.kind = "payload" {
                Set metrics.payloadChunkCount = metrics.payloadChunkCount + 1
                Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + 1
            }
            If chunk.kind = "message-schema" {
                Set metrics.messageSchemaChunkCount = metrics.messageSchemaChunkCount + 1
            }
            If chunk.kind = "warning" {
                Set metrics.warningChunkCount = metrics.warningChunkCount + 1
            }
        }
    }
    return metrics
}

ClassMethod DeleteRAGChunksForProduction(productionName As %VarString) [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT %ID AS ID FROM esh_interoperability_aid_rag.Chunk WHERE Namespace = ? AND ProductionName = ?")
    If $$$ISERR(sc) {
        return
    }
    Set rset = stmt.%Execute($Namespace, productionName)
    If rset.%SQLCODE < 0 {
        return
    }
    While rset.%Next() {
        Do ##class(esh.interoperability.aid.rag.Chunk).%DeleteId(rset.%Get("ID"))
    }
    return
}

ClassMethod LatestRAGRunId(productionName As %VarString) As %VarString [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TOP 1 %ID AS ID FROM esh_interoperability_aid_rag.IndexRun WHERE Namespace = ? AND ProductionName = ? AND Status = ? ORDER BY RunTimestamp DESC, %ID DESC")
    If $$$ISERR(sc) {
        return ""
    }
    Set rset = stmt.%Execute($Namespace, productionName, "complete")
    If rset.%SQLCODE < 0 {
        return ""
    }
    If rset.%Next() {
        return rset.%Get("ID")
    }
    return ""
}

ClassMethod LatestProductionSourceStamp(productionName As %VarString) As %DynamicObject [ Private ]
{
    Set stamp = {}
    Set stamp.className = productionName
    Set stamp.changedAtHorolog = ..ClassChangedHorolog(productionName)
    Set stamp.changedAt = ..HorologToTimestamp(stamp.changedAtHorolog)
    Set stamp.classCount = 1
    Set classNames = []
    Do classNames.%Push(productionName)
    Set analysis = ..GetProductionAnalysis(productionName)
    If $IsObject(analysis) && 'analysis.%IsDefined("errorCode") && $IsObject(analysis.components) {
        For index = 0:1:analysis.components.%Size()-1 {
            Set component = analysis.components.%Get(index)
            Continue:'$IsObject(component)
            Set className = component.className
            Continue:(className = "")
            Continue:..DynamicArrayContains(classNames, className)
            Do classNames.%Push(className)
        }
    }
    Set stamp.classCount = classNames.%Size()
    For index = 0:1:classNames.%Size()-1 {
        Set className = classNames.%Get(index)
        Set changedAtHorolog = ..ClassChangedHorolog(className)
        If ..HorologSeconds(changedAtHorolog) > ..HorologSeconds(stamp.changedAtHorolog) {
            Set stamp.className = className
            Set stamp.changedAtHorolog = changedAtHorolog
            Set stamp.changedAt = ..HorologToTimestamp(changedAtHorolog)
        }
    }
    return stamp
}

ClassMethod ClassChangedHorolog(className As %VarString) As %VarString [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TimeChanged FROM %Dictionary.CompiledClass WHERE Name = ?")
    If $$$ISERR(sc) {
        return "0,0"
    }
    Set rset = stmt.%Execute(className)
    If rset.%SQLCODE < 0 {
        return "0,0"
    }
    If rset.%Next() {
        return rset.%Get("TimeChanged")
    }
    return "0,0"
}

ClassMethod TimestampToHorolog(timestamp As %VarString) As %VarString [ Private ]
{
    If timestamp = "" {
        return "0,0"
    }
    Try {
        return $ZDateTimeH(timestamp, 3, 1)
    } Catch ex {
        return "0,0"
    }
}

ClassMethod HorologToTimestamp(horologValue As %VarString) As %VarString [ Private ]
{
    If horologValue = "" {
        return ""
    }
    Try {
        return $ZDateTime(horologValue, 3, 1)
    } Catch ex {
        return ""
    }
}

ClassMethod HorologSeconds(horologValue As %VarString) As %Numeric [ Private ]
{
    If horologValue = "" {
        return 0
    }
    return (+$Piece(horologValue, ",", 1) * 86400) + (+$Piece(horologValue, ",", 2))
}

ClassMethod HorologAddSeconds(horologValue As %VarString, deltaSeconds As %Integer) As %VarString [ Private ]
{
    Set days = +$Piece(horologValue, ",", 1)
    Set seconds = +$Piece(horologValue, ",", 2) + deltaSeconds
    While seconds < 0 {
        Set days = days - 1
        Set seconds = seconds + 86400
    }
    While seconds >= 86400 {
        Set days = days + 1
        Set seconds = seconds - 86400
    }
    return days_","_seconds
}

ClassMethod DynamicArrayContains(items As %DynamicArray, value As %VarString) As %Boolean [ Private ]
{
    For index = 0:1:items.%Size()-1 {
        If items.%Get(index) = value {
            return 1
        }
    }
    return 0
}

ClassMethod OpenStoredRAGChunk(chunkInternalId As %Integer) As %DynamicObject [ Private ]
{
    Set stored = ##class(esh.interoperability.aid.rag.Chunk).%OpenId(chunkInternalId)
    If '$IsObject(stored) {
        return ""
    }
    Set chunk = {}
    Set chunk.id = stored.ChunkId
    Set chunk.kind = stored.Kind
    Set chunk.title = stored.Title
    Set chunk.source = stored.Source
    Set chunk.component = stored.Component
    Set chunk.confidence = stored.Confidence
    Set chunk.score = stored.Score
    Set chunk.text = ""
    If $IsObject(stored.Text) {
        Do stored.Text.Rewind()
        While 'stored.Text.AtEnd {
            Set chunk.text = chunk.text _ stored.Text.Read(32000)
        }
    }
    If $IsObject(stored.EvidenceJSON) {
        Set evidenceJson = ""
        Do stored.EvidenceJSON.Rewind()
        While 'stored.EvidenceJSON.AtEnd {
            Set evidenceJson = evidenceJson _ stored.EvidenceJSON.Read(32000)
        }
        Try {
            Set chunk.evidence = [].%FromJSON(evidenceJson)
        } Catch ex {
            Set chunk.evidence = []
        }
    } Else {
        Set chunk.evidence = []
    }
    return chunk
}

ClassMethod OpenStoredRAGChunksForRun(productionName As %VarString, runId As %VarString) As %DynamicArray [ Private ]
{
    Set chunks = []
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT %ID AS ID FROM esh_interoperability_aid_rag.Chunk WHERE Namespace = ? AND ProductionName = ? AND RunId = ? ORDER BY Kind, Title")
    If $$$ISERR(sc) {
        return chunks
    }
    Set rset = stmt.%Execute($Namespace, productionName, runId)
    If rset.%SQLCODE < 0 {
        return chunks
    }
    While rset.%Next() {
        Set chunk = ..OpenStoredRAGChunk(rset.%Get("ID"))
        If $IsObject(chunk) {
            Do chunks.%Push(chunk)
        }
    }
    return chunks
}

ClassMethod BuildStoredRAGMetrics(productionName As %VarString, runId As %VarString) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.chunkCount = 0
    Set metrics.componentChunkCount = 0
    Set metrics.connectionChunkCount = 0
    Set metrics.ruleChunkCount = 0
    Set metrics.messageTypeChunkCount = 0
    Set metrics.externalSystemChunkCount = 0
    Set metrics.transformationChunkCount = 0
    Set metrics.businessProcessChunkCount = 0
    Set metrics.messageChunkCount = 0
    Set metrics.logChunkCount = 0
    Set metrics.payloadChunkCount = 0
    Set metrics.messageSchemaChunkCount = 0
    Set metrics.runtimeChunkCount = 0
    Set metrics.warningChunkCount = 0
    If runId = "" {
        return metrics
    }
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Kind, COUNT(*) AS Cnt FROM esh_interoperability_aid_rag.Chunk WHERE Namespace = ? AND ProductionName = ? AND RunId = ? GROUP BY Kind")
    If $$$ISERR(sc) {
        return metrics
    }
    Set rset = stmt.%Execute($Namespace, productionName, runId)
    If rset.%SQLCODE < 0 {
        return metrics
    }
    While rset.%Next() {
        Set kind = rset.%Get("Kind")
        Set count = rset.%Get("Cnt")
        Set metrics.chunkCount = metrics.chunkCount + count
        If kind = "COMPONENT" {
            Set metrics.componentChunkCount = metrics.componentChunkCount + count
        }
        If (kind = "CONNECTION") || (kind = "CONNECTION-EXPLANATION") {
            Set metrics.connectionChunkCount = metrics.connectionChunkCount + count
        }
        If (kind = "ROUTING-RULE") || (kind = "ROUTING-RULE-EXPLANATION") {
            Set metrics.ruleChunkCount = metrics.ruleChunkCount + count
        }
        If kind = "MESSAGE-TYPE" {
            Set metrics.messageTypeChunkCount = metrics.messageTypeChunkCount + count
        }
        If kind = "EXTERNAL-SYSTEM" {
            Set metrics.externalSystemChunkCount = metrics.externalSystemChunkCount + count
        }
        If kind = "TRANSFORMATION" {
            Set metrics.transformationChunkCount = metrics.transformationChunkCount + count
        }
        If kind = "BUSINESS-PROCESS" {
            Set metrics.businessProcessChunkCount = metrics.businessProcessChunkCount + count
        }
        If kind = "MESSAGE" {
            Set metrics.messageChunkCount = metrics.messageChunkCount + count
            Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + count
        }
        If kind = "LOG" {
            Set metrics.logChunkCount = metrics.logChunkCount + count
            Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + count
        }
        If kind = "PAYLOAD" {
            Set metrics.payloadChunkCount = metrics.payloadChunkCount + count
            Set metrics.runtimeChunkCount = metrics.runtimeChunkCount + count
        }
        If kind = "MESSAGE-SCHEMA" {
            Set metrics.messageSchemaChunkCount = metrics.messageSchemaChunkCount + count
        }
        If kind = "WARNING" {
            Set metrics.warningChunkCount = metrics.warningChunkCount + count
        }
    }
    return metrics
}

ClassMethod RAGChunkScore(chunk As %DynamicObject, normalizedQuestion As %VarString) As %Integer [ Private ]
{
    Set haystack = $ZConvert(chunk.kind_" "_chunk.title_" "_chunk.text_" "_chunk.component, "L")
    Set score = 0
    For index = 1:1:$Length(normalizedQuestion, " ") {
        Set term = $ZStrip($Piece(normalizedQuestion, " ", index), "<>P")
        Continue:($Length(term) < 3)
        If haystack [ term {
            Set score = score + 1
        }
    }
    If chunk.kind = "message-schema" {
        If (normalizedQuestion["data") || (normalizedQuestion["field") || (normalizedQuestion["payload") || (normalizedQuestion["schema") || (normalizedQuestion["structure") {
            Set score = score + 3
        }
    }
    If score = 0 {
        If (chunk.kind = "summary") || (chunk.kind = "component") || (chunk.kind = "connection") {
            Set score = 1
        }
    }
    return score
}

ClassMethod BuildAIAskPrompt(question As %VarString, chunks As %DynamicArray) As %VarString [ Private ]
{
    Set prompt = "Question: "_question_$Char(10,10)_"Retrieved chunks:"_$Char(10)
    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        Set prompt = prompt_"Chunk id ["_chunk.id_"]; kind="_chunk.kind_"; component="_chunk.component_"; source="_chunk.source_"; confidence="_chunk.confidence_$Char(10)
        Set prompt = prompt_chunk.text_$Char(10,10)
    }
    Set prompt = prompt_"Answer with concise paragraphs. Cite factual claims with exact bracketed chunk ids from the retrieved chunks, for example [summary] or [component-Patient Router]. Do not cite ordinal numbers like [1] or [2]. If evidence is insufficient, say what is missing and cite the closest relevant chunk ids."
    return $Extract(prompt, 1, 12000)
}

ClassMethod ValidateAIAnswerCitations(answer As %VarString, chunks As %DynamicArray) As %DynamicObject
{
    Set result = {}
    Set result.citations = []
    Set result.citationCount = 0
    Set result.invalidCitationIds = []
    Set result.invalidCitationCount = 0
    Set result.uncitedChunkIds = []
    Set result.answerGrounded = 0

    Set citedIds = ..ExtractCitationIds(answer)
    Set canonicalCitedIds = []
    For index = 0:1:citedIds.%Size()-1 {
        Set chunkId = citedIds.%Get(index)
        Set canonicalChunkId = ..CanonicalCitationChunkId(chunkId, chunks)
        If canonicalChunkId '= "" {
            Set citation = ..NewCitation(canonicalChunkId, chunks)
            If canonicalChunkId '= chunkId {
                Set citation.originalCitation = chunkId
                Set citation.normalized = 1
            }
            Do result.citations.%Push(citation)
            Do ..PushUnique(canonicalCitedIds, canonicalChunkId)
        } Else {
            Do result.invalidCitationIds.%Push(chunkId)
        }
    }
    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        Continue:..DynamicArrayContains(canonicalCitedIds, chunk.id)
        Do result.uncitedChunkIds.%Push(chunk.id)
    }
    Set result.citationCount = result.citations.%Size()
    Set result.invalidCitationCount = result.invalidCitationIds.%Size()
    Set result.answerGrounded = (result.citationCount > 0) && (result.invalidCitationCount = 0)
    return result
}

ClassMethod CanonicalCitationChunkId(citationId As %VarString, chunks As %DynamicArray) As %VarString [ Private ]
{
    If ..ChunkIdInArray(chunks, citationId) {
        return citationId
    }
    If citationId?1.N {
        Set ordinal = +citationId
        If (ordinal > 0) && (ordinal <= chunks.%Size()) {
            Set chunk = chunks.%Get(ordinal - 1)
            If $IsObject(chunk) {
                return chunk.id
            }
        }
    }
    return ""
}

ClassMethod ExtractCitationIds(answer As %VarString) As %DynamicArray
{
    Set ids = []
    Set position = 1
    For {
        Set open = $Find(answer, "[", position)
        Quit:(open = 0)
        Set close = $Find(answer, "]", open)
        Quit:(close = 0)
        Set id = $ZStrip($Extract(answer, open, close - 2), "<>W")
        If (id '= "") && '..DynamicArrayContains(ids, id) && (id '[ $Char(10)) && (id '[ $Char(13)) {
            Do ids.%Push(id)
        }
        Set position = close
    }
    return ids
}

ClassMethod NewCitation(chunkId As %VarString, chunks As %DynamicArray) As %DynamicObject [ Private ]
{
    Set citation = {}
    Set citation.chunkId = chunkId
    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        Continue:(chunk.id '= chunkId)
        Set citation.kind = chunk.kind
        Set citation.title = chunk.title
        Set citation.component = chunk.component
        Set citation.source = chunk.source
        Set citation.confidence = chunk.confidence
        return citation
    }
    return citation
}

ClassMethod ChunkIdInArray(chunks As %DynamicArray, chunkId As %VarString) As %Boolean [ Private ]
{
    For index = 0:1:chunks.%Size()-1 {
        Set chunk = chunks.%Get(index)
        Continue:'$IsObject(chunk)
        If chunk.id = chunkId {
            return 1
        }
    }
    return 0
}

ClassMethod CallOpenAIChat(endpoint As %VarString, model As %VarString, apiKey As %VarString, prompt As %VarString, systemPrompt As %VarString = "") As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.text = ""
    Set result.usage = {}

    Set endpointParts = ..ParseEndpoint(endpoint)
    If endpointParts.%IsDefined("errorCode") {
        return endpointParts
    }

    Set request = ##class(%Net.HttpRequest).%New()
    Set request.Server = endpointParts.server
    Set request.Port = endpointParts.port
    Set request.Https = endpointParts.https
    If request.Https {
        Set request.SSLConfiguration = "default"
    }
    Set request.ContentType = "application/json"
    Do request.SetHeader("Authorization", "Bearer "_apiKey)
    Do request.SetHeader("Accept", "application/json")

    Set payload = {}
    Set payload.model = model
    Set payload.temperature = 0.2
    Set payload.messages = []
    If systemPrompt = "" {
        Set systemPrompt = "You summarize deterministic IRIS interoperability analysis. Keep secrets out of the answer."
    }
    Do payload.messages.%Push({"role":"system","content":(systemPrompt)})
    Do payload.messages.%Push({"role":"user","content":(prompt)})
    Do request.EntityBody.Write(payload.%ToJSON())

    Set sc = request.Post(endpointParts.path)
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "AI_REQUEST_FAILED")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }
    If (request.HttpResponse.StatusCode < 200) || (request.HttpResponse.StatusCode > 299) {
        Do result.%Set("errorCode", "AI_REQUEST_FAILED")
        Do result.%Set("statusText", "OpenAI request failed with HTTP "_request.HttpResponse.StatusCode_".")
        return result
    }

    Try {
        Set response = {}.%FromJSON(request.HttpResponse.Data)
    } Catch ex {
        Do result.%Set("errorCode", "AI_RESPONSE_PARSE_FAILED")
        Do result.%Set("statusText", "OpenAI response was not valid JSON.")
        return result
    }

    If response.%IsDefined("usage") {
        Set result.usage = response.usage
    }
    If response.%IsDefined("choices"),response.choices.%Size() > 0 {
        Set choice = response.choices.%Get(0)
        If $IsObject(choice),choice.%IsDefined("message"),$IsObject(choice.message),choice.message.%IsDefined("content") {
            Set result.text = choice.message.content
            return result
        }
    }

    Do result.%Set("errorCode", "AI_RESPONSE_PARSE_FAILED")
    Do result.%Set("statusText", "OpenAI response did not include message content.")
    return result
}

ClassMethod ParseEndpoint(endpoint As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Do ##class(%Net.URLParser).Parse(endpoint, .parts)
    If '$Data(parts("host")) {
        Do result.%Set("errorCode", "AI_ENDPOINT_INVALID")
        Do result.%Set("statusText", "AI endpoint must be an absolute URL.")
        return result
    }
    Set scheme = $ZConvert(parts("scheme"), "L")
    Set result.https = $Select(scheme="https":1,1:0)
    Set result.server = parts("host")
    If $Data(parts("port")) {
        Set result.port = +parts("port")
    } Else {
        Set result.port = $Select(result.https:443,1:80)
    }
    Set path = "/"
    If $Data(parts("path")) {
        Set path = parts("path")
    }
    If $Data(parts("query")) {
        Set path = path_"?"_parts("query")
    }
    Set result.path = path
    return result
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

ClassMethod ShouldIncludeMessageHeader(rset As %SQL.IResultSet, componentNames As %DynamicArray, sourceConfigName As %VarString = "", targetConfigName As %VarString = "", messageBodyClassName As %VarString = "", sessionId As %VarString = "", errorsOnly As %Boolean = 0, status As %VarString = "", startHorolog As %VarString = "", endHorolog As %VarString = "") As %Boolean [ Private ]
{
    Set source = rset.%Get("SourceConfigName")
    Set target = rset.%Get("TargetConfigName")
    If '..ShouldIncludeDateTime(rset.%Get("TimeCreated"), startHorolog, endHorolog) {
        return 0
    }
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
    If (status '= "") && (rset.%Get("Status") '= status) {
        return 0
    }
    If errorsOnly && (rset.%Get("IsError") '= 1) {
        return 0
    }
    return 1
}

ClassMethod ShouldIncludeProductionLog(rset As %SQL.IResultSet, componentNames As %DynamicArray, productionName As %VarString = "", type As %VarString = "", source As %VarString = "", contains As %VarString = "", startHorolog As %VarString = "", endHorolog As %VarString = "") As %Boolean [ Private ]
{
    Set logSource = rset.%Get("Source")
    Set logType = rset.%Get("Type")
    Set logText = rset.%Get("Text")
    If '..ShouldIncludeDateTime(rset.%Get("TimeLogged"), startHorolog, endHorolog) {
        return 0
    }
    If componentNames.%Size() > 0 {
        Set productionMatch = 0
        For index = 0:1:componentNames.%Size()-1 {
            Set componentName = componentNames.%Get(index)
            If logSource = componentName {
                Set productionMatch = 1
                Quit
            }
            If logText [ componentName {
                Set productionMatch = 1
                Quit
            }
        }
        If 'productionMatch {
            If (productionName '= "") && ((logSource = productionName) || (logText [ productionName)) {
                Set productionMatch = 1
            }
        }
        If 'productionMatch {
            return 0
        }
    }
    If (type '= "") && (logType '= type) {
        return 0
    }
    If (source '= "") && (logSource '= source) {
        return 0
    }
    If contains '= "" {
        Set normalizedText = $ZConvert(logText, "L")
        Set normalizedContains = $ZConvert(contains, "L")
        If normalizedText '[ normalizedContains {
            return 0
        }
    }
    return 1
}

ClassMethod NormalizeDateRange(startDate As %VarString = "", endDate As %VarString = "") As %DynamicObject [ Private ]
{
    Set range = {}
    Set range.valid = 1
    Set range.startDate = ""
    Set range.endDate = ""
    Set range.startHorolog = ""
    Set range.endHorolog = ""
    Set range.statusText = ""

    Set start = ..NormalizeDateFilter(startDate, 0)
    If 'start.valid {
        Set range.valid = 0
        Set range.statusText = "Invalid startDate. Use ISO 8601, for example 2026-07-18T10:00:00."
        return range
    }

    Set finish = ..NormalizeDateFilter(endDate, 1)
    If 'finish.valid {
        Set range.valid = 0
        Set range.statusText = "Invalid endDate. Use ISO 8601, for example 2026-07-18T23:59:59."
        return range
    }

    Set range.startDate = start.value
    Set range.endDate = finish.value
    Set range.startHorolog = start.horolog
    Set range.endHorolog = finish.horolog
    If (range.startHorolog '= "") && (range.endHorolog '= "") && (..CompareHorolog(range.startHorolog, range.endHorolog) > 0) {
        Set range.valid = 0
        Set range.statusText = "startDate must be earlier than or equal to endDate."
    }
    return range
}

ClassMethod FetchMonitorOpenMetrics(path As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.body = ""
    Set request = ##class(%Net.HttpRequest).%New()
    Set request.Server = "127.0.0.1"
    Set request.Port = ..MonitorPort()
    Set request.Https = 0
    Set request.ContentType = "text/plain"
    Do request.SetHeader("Accept", "text/plain")

    Set sc = request.Get(path)
    If $$$ISERR(sc) {
        return ..NewMonitorError("MONITOR_REQUEST_FAILED", $System.Status.GetErrorText(sc))
    }
    Set result.httpStatus = request.HttpResponse.StatusCode
    If (request.HttpResponse.StatusCode < 200) || (request.HttpResponse.StatusCode > 299) {
        return ..NewMonitorError("MONITOR_REQUEST_FAILED", "/api/monitor request failed with HTTP "_request.HttpResponse.StatusCode_".")
    }
    If $IsObject(request.HttpResponse.Data) {
        Do request.HttpResponse.Data.Rewind()
        While 'request.HttpResponse.Data.AtEnd {
            Set result.body = result.body_request.HttpResponse.Data.Read(32000)
        }
    }
    return result
}

ClassMethod MonitorPort() As %Integer [ Private ]
{
    Set port = 52773
    Try {
        If $IsObject(%request) && %request.CgiEnvs("SERVER_PORT") '= "" {
            Set port = +%request.CgiEnvs("SERVER_PORT")
        }
    } Catch ex {
        Set port = 52773
    }
    If port < 1 {
        Set port = 52773
    }
    return port
}

ClassMethod ParseOpenMetricsSamples(text As %VarString, prefix As %VarString = "", limit As %Integer = 200) As %DynamicArray [ Private ]
{
    Set samples = []
    If limit < 1 {
        Set limit = 200
    }
    For lineIndex = 1:1:$Length(text, $Char(10)) {
        Quit:(samples.%Size() >= limit)
        Set line = $ZStrip($Piece(text, $Char(10), lineIndex), "<>W")
        Continue:(line = "")
        Continue:($Extract(line, 1) = "#")
        Set space = $Find(line, " ")
        Continue:(space = 0)
        Set nameAndLabels = $Extract(line, 1, space-2)
        Set value = $ZStrip($Extract(line, space, *), "<>W")
        Continue:(nameAndLabels = "")
        Set metricName = nameAndLabels
        Set labels = {}
        If nameAndLabels["{" {
            Set metricName = $Piece(nameAndLabels, "{", 1)
            Set labelText = $Piece($Piece(nameAndLabels, "{", 2), "}", 1)
            Do ..AddOpenMetricLabels(labelText, labels)
        }
        Continue:(metricName = "")
        If prefix '= "" {
            Continue:($Extract(metricName, 1, $Length(prefix)) '= prefix)
        }
        Set sample = {}
        Set sample.name = metricName
        Set sample.value = value
        Set sample.labels = labels
        Set sample.labelCount = labels.%Size()
        Set sample.numeric = ..IsMonitorNumericValue(value)
        If sample.numeric {
            Set sample.numericValue = +value
        }
        Do samples.%Push(sample)
    }
    return samples
}

ClassMethod AddOpenMetricLabels(labelText As %VarString, labels As %DynamicObject) [ Private ]
{
    For index = 1:1:$Length(labelText, ",") {
        Set pair = $ZStrip($Piece(labelText, ",", index), "<>W")
        Quit:(pair = "")
        Set key = $ZStrip($Piece(pair, "=", 1), "<>W")
        Set value = $Piece(pair, "=", 2, *)
        Continue:(key = "")
        If ($Extract(value, 1) = """") && ($Extract(value, $Length(value)) = """") {
            Set value = $Extract(value, 2, $Length(value)-1)
        }
        Set value = $Replace(value, "\""", """")
        Do labels.%Set(key, value)
    }
    return
}

ClassMethod NormalizeMonitorPeriod(period As %VarString) As %VarString [ Private ]
{
    Set value = $ZConvert($ZStrip(period, "<>W"), "L")
    If value = "" {
        return "current"
    }
    If (value = "current") || (value = "historical") {
        return value
    }
    return ""
}

ClassMethod NormalizeMonitorNamespace(namespace As %VarString) As %VarString [ Private ]
{
    Set value = $ZStrip(namespace, "<>W")
    If value = "" {
        return $Namespace
    }
    If value = "*" {
        return value
    }
    If $Length(value) > 64 {
        return ""
    }
    For index = 1:1:$Length(value) {
        Set char = $Extract(value, index)
        Continue:((char?1AN) || (char = "%") || (char = "_") || (char = "-"))
        return ""
    }
    return value
}

ClassMethod NormalizeMonitorDate(value As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.value = ""
    Set date = ..NormalizeDateFilter(value, 0)
    If 'date.valid {
        return ..NewMonitorError("INVALID_MONITOR_DATE_FILTER", "Invalid date filter. Use YYYY-MM-DD or ISO 8601.")
    }
    If date.value '= "" {
        Set result.value = $Piece(date.value, " ", 1)
    }
    return result
}

ClassMethod NormalizeMonitorMonth(value As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.value = ""
    Set month = $ZStrip(value, "<>W")
    If month = "" {
        return result
    }
    If '(month?4N1"-"2N) {
        return ..NewMonitorError("INVALID_MONITOR_DATE_FILTER", "Invalid month filter. Use YYYY-MM.")
    }
    Set result.value = month
    return result
}

ClassMethod AppendMonitorQuery(path As %VarString, name As %VarString, value As %VarString) As %VarString [ Private ]
{
    If value = "*" {
        return path
    }
    If path["?" {
        return path_"&"_name_"="_value
    }
    return path_"?"_name_"="_value
}

ClassMethod NewMonitorResult(sourcePath As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.source = sourcePath
    Set result.contentType = "application/json"
    Set result.samples = []
    Set result.sampleCount = 0
    Set result.warnings = []
    Set result.evidence = []
    return result
}

ClassMethod NewMonitorMetrics(sampleCount As %Integer, httpStatus As %Integer) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.sampleCount = sampleCount
    Set metrics.httpStatus = httpStatus
    return metrics
}

ClassMethod NewMonitorError(code As %VarString, message As %VarString) As %DynamicObject [ Private ]
{
    Set result = {}
    Do result.%Set("errorCode", code)
    Do result.%Set("statusText", message)
    Set result.warnings = []
    Do result.warnings.%Push(..NewWarning(code, message))
    return result
}

ClassMethod IsMonitorNumericValue(value As %VarString) As %Boolean [ Private ]
{
    If value = "" {
        return 0
    }
    If value?1"-".N {
        return 1
    }
    If value?.N {
        return 1
    }
    If value?1"-".N1".".N {
        return 1
    }
    If value?.N1".".N {
        return 1
    }
    return 0
}

ClassMethod NormalizeDateFilter(value As %VarString = "", endOfDay As %Boolean = 0) As %DynamicObject [ Private ]
{
    Set result = {}
    Set result.valid = 1
    Set result.value = ""
    Set result.horolog = ""

    Set text = $ZStrip(value, "<>W")
    If text = "" {
        return result
    }

    Set text = $Replace(text, "T", " ")
    If $Extract(text, $Length(text)) = "Z" {
        Set text = $Extract(text, 1, $Length(text)-1)
    }
    If text["." {
        Set text = $Piece(text, ".", 1)
    }
    If $Length(text) > 19 {
        Set text = $Extract(text, 1, 19)
    }
    If $Length(text) = 10 {
        Set text = text_$Select(endOfDay:" 23:59:59",1:" 00:00:00")
    }

    Try {
        Set horolog = $ZDATETIMEH(text, 3)
    } Catch ex {
        Set result.valid = 0
        return result
    }

    Set result.value = $ZDATETIME(horolog, 3)
    Set result.horolog = horolog
    return result
}

ClassMethod ShouldIncludeDateTime(value As %VarString, startHorolog As %VarString = "", endHorolog As %VarString = "") As %Boolean [ Private ]
{
    If (startHorolog = "") && (endHorolog = "") {
        return 1
    }
    Set rowDate = ..NormalizeDateFilter(value, 0)
    If 'rowDate.valid {
        return 0
    }
    If rowDate.horolog = "" {
        return 0
    }
    If (startHorolog '= "") && (..CompareHorolog(rowDate.horolog, startHorolog) < 0) {
        return 0
    }
    If (endHorolog '= "") && (..CompareHorolog(rowDate.horolog, endHorolog) > 0) {
        return 0
    }
    return 1
}

ClassMethod CompareHorolog(left As %VarString, right As %VarString) As %Integer [ Private ]
{
    Set leftDay = +$Piece(left, ",", 1)
    Set rightDay = +$Piece(right, ",", 1)
    If leftDay < rightDay {
        return -1
    }
    If leftDay > rightDay {
        return 1
    }
    Set leftSecond = +$Piece(left, ",", 2)
    Set rightSecond = +$Piece(right, ",", 2)
    If leftSecond < rightSecond {
        return -1
    }
    If leftSecond > rightSecond {
        return 1
    }
    return 0
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
    Set analysis = ..GetProductionAnalysis(productionName)
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
            If $IsObject(analysis) {
                Do ..AnnotateTraceStepWithStaticContext(step, analysis)
            }
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

ClassMethod AnnotateTraceStepWithStaticContext(step As %DynamicObject, analysis As %DynamicObject) [ Private ]
{
    If '$IsObject(step) {
        return
    }
    If '$IsObject(analysis.connections) {
        return
    }

    Set connection = ..FindConnectionForTraceStep(analysis.connections, step.source, step.target)
    If '$IsObject(connection) {
        return
    }

    Set step.staticConnectionKind = connection.kind
    Set step.staticConnectionConfidence = connection.confidence
    If connection.%IsDefined("ruleName") {
        Set step.staticRuleName = connection.ruleName
        Set transformNames = ..TransformNamesForTraceRule(analysis.rules, connection.ruleName, step.target)
        If transformNames.%Size() > 0 {
            Set step.staticTransformNames = transformNames
        }
    }
    If connection.%IsDefined("processClass") {
        Set step.staticProcessClass = connection.processClass
    }
    Set step.explanation = ..BuildTraceStepStaticText(step, connection)
    Do step.evidence.%Push(..NewEvidence("static-connection", analysis.productionName, step.source, "connection", step.target, connection.confidence))
    return
}

ClassMethod TransformNamesForTraceRule(rules As %DynamicArray, ruleName As %VarString, target As %VarString) As %DynamicArray [ Private ]
{
    Set names = []
    If '$IsObject(rules) {
        return names
    }

    For ruleIndex = 0:1:rules.%Size()-1 {
        Set rule = rules.%Get(ruleIndex)
        Continue:'$IsObject(rule)
        Continue:(rule.name '= ruleName)
        Do ..AddTransformNamesFromRuleSends(rule.sends, target, names)
        For conditionIndex = 0:1:rule.conditions.%Size()-1 {
            Set condition = rule.conditions.%Get(conditionIndex)
            Continue:'$IsObject(condition)
            Do ..AddTransformNamesFromRuleSends(condition.sends, target, names)
        }
    }
    return names
}

ClassMethod AddTransformNamesFromRuleSends(sends As %DynamicArray, target As %VarString, names As %DynamicArray) [ Private ]
{
    If '$IsObject(sends) {
        return
    }
    For sendIndex = 0:1:sends.%Size()-1 {
        Set send = sends.%Get(sendIndex)
        Continue:'$IsObject(send)
        Continue:(send.transform = "")
        If (target = "") || (send.target = "") || (send.target = target) {
            Do ..PushUnique(names, send.transform)
        }
    }
    return
}

ClassMethod FindConnectionForTraceStep(connections As %DynamicArray, source As %VarString, target As %VarString) As %DynamicObject [ Private ]
{
    If (source = "") || (target = "") {
        return ""
    }

    Set fallback = ""
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        Continue:'$IsObject(connection)
        Continue:(connection.%Get("from") '= source)
        Continue:(connection.%Get("to") '= target)
        If '$IsObject(fallback) {
            Set fallback = connection
        }
        If connection.kind '= "target-config" {
            return connection
        }
    }
    return fallback
}

ClassMethod BuildTraceStepStaticText(step As %DynamicObject, connection As %DynamicObject) As %VarString [ Private ]
{
    Set text = "Step "_step.sequence_" observed message "_step.messageId
    If step.messageBodyClassName '= "" {
        Set text = text_" with body class "_step.messageBodyClassName
    }
    Set text = text_" moving from "_$Select(step.source'="":step.source,1:"unknown source")_" to "_$Select(step.target'="":step.target,1:"unknown target")
    Set text = text_". This hop matches the production's "_connection.kind_" static connection"
    If connection.%IsDefined("ruleName") {
        Set text = text_" controlled by routing rule "_connection.ruleName
    }
    If step.%IsDefined("staticTransformNames"),step.staticTransformNames.%Size() > 0 {
        Set text = text_" using "_..JoinArray(step.staticTransformNames)
    }
    If connection.%IsDefined("processClass") {
        Set text = text_" from BPL process "_connection.processClass
    }
    If step.isError {
        Set text = text_". The message header is marked as an error"
    } Else {
        Set text = text_". The message header is not marked as an error"
    }
    Set text = text_". Payload body content was not returned."
    return text
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

ClassMethod NewMessageSessionSummaryFromTrace(trace As %DynamicObject, productionName As %VarString) As %DynamicObject [ Private ]
{
    Set settings = ##class(esh.interoperability.aid.config.Settings).Current()
    Set summary = {}
    Set overview = trace.traceOverview
    Set selected = trace.selectedMessage

    Set summary.namespace = trace.namespace
    Set summary.productionName = productionName
    Set summary.messageId = trace.messageId
    Set summary.sessionId = trace.sessionId
    Set summary.selectedMessage = selected
    Set summary.stepCount = trace.stepCount
    Set summary.productionStepCount = trace.productionStepCount
    Set summary.outsideProductionStepCount = trace.stepCount - trace.productionStepCount
    Set summary.errorCount = overview.errorCount
    Set summary.firstSeen = overview.firstSeen
    Set summary.lastSeen = overview.lastSeen
    Set summary.origin = overview.origin
    Set summary.finalTarget = overview.finalTarget
    Set summary.path = overview.path
    Set summary.participants = overview.participants
    Set summary.payloadReturned = trace.payloadReturned
    Set summary.runtimeMessageAnalysisEnabled = trace.runtimeMessageAnalysisEnabled
    Set summary.payloadPolicy = {}
    Set summary.payloadPolicy.payloadReturned = trace.payloadReturned
    Set summary.payloadPolicy.payloadInspectionEnabled = settings.payloadInspectionEnabled
    Set summary.payloadPolicy.payloadInspectionSupported = 0
    Set summary.payloadPolicy.bodyContentReturned = 0
    Set summary.payloadPolicy.summary = "Payload body content was not returned."
    Set summary.staticContext = ..NewTraceStaticContext(trace)
    Set summary.metrics = trace.metrics
    Set summary.text = ..BuildMessageSessionSummaryText(summary)
    Set summary.warnings = trace.warnings
    Set summary.evidence = trace.evidence
    Set summary.confidence = trace.confidence
    return summary
}

ClassMethod NewTraceStaticContext(trace As %DynamicObject) As %DynamicObject [ Private ]
{
    Set context = {}
    Set context.connectionKinds = []
    Set context.ruleNames = []
    Set context.transformNames = []
    Set context.processClasses = []
    Set context.matchedStepCount = 0

    If '$IsObject(trace) {
        return context
    }
    If '$IsObject(trace.steps) {
        return context
    }

    For index = 0:1:trace.steps.%Size()-1 {
        Set step = trace.steps.%Get(index)
        Continue:'$IsObject(step)
        Set matched = 0
        If step.%IsDefined("staticConnectionKind") {
            Do ..PushUnique(context.connectionKinds, step.staticConnectionKind)
            Set matched = 1
        }
        If step.%IsDefined("staticRuleName") {
            Do ..PushUnique(context.ruleNames, step.staticRuleName)
            Set matched = 1
        }
        If step.%IsDefined("staticProcessClass") {
            Do ..PushUnique(context.processClasses, step.staticProcessClass)
            Set matched = 1
        }
        If step.%IsDefined("staticTransformNames"),$IsObject(step.staticTransformNames) {
            For transformIndex = 0:1:step.staticTransformNames.%Size()-1 {
                Do ..PushUnique(context.transformNames, step.staticTransformNames.%Get(transformIndex))
                Set matched = 1
            }
        }
        If matched {
            Set context.matchedStepCount = context.matchedStepCount + 1
        }
    }
    return context
}

ClassMethod BuildMessageSessionSummaryText(summary As %DynamicObject) As %VarString [ Private ]
{
    Set text = "Message "_summary.messageId_" is in session "_summary.sessionId_" with "_summary.stepCount_" reconstructed step"_..Plural(summary.stepCount)
    Set text = text_", including "_summary.productionStepCount_" step"_..Plural(summary.productionStepCount)_" in production "_summary.productionName
    If summary.outsideProductionStepCount > 0 {
        Set text = text_" and "_summary.outsideProductionStepCount_" step"_..Plural(summary.outsideProductionStepCount)_" outside that production"
    }
    If summary.path '= "" {
        Set text = text_". Observed path: "_summary.path
    }
    If summary.errorCount > 0 {
        Set text = text_". "_summary.errorCount_" step"_..Plural(summary.errorCount)_" marked as error"
    }
    If $IsObject(summary.staticContext),summary.staticContext.matchedStepCount > 0 {
        Set text = text_". Static analysis matched "_summary.staticContext.matchedStepCount_" step"_..Plural(summary.staticContext.matchedStepCount)
        If summary.staticContext.ruleNames.%Size() > 0 {
            Set text = text_" with routing rule"_..Plural(summary.staticContext.ruleNames.%Size())_" "_..JoinArray(summary.staticContext.ruleNames)
        }
        If summary.staticContext.transformNames.%Size() > 0 {
            Set text = text_" and transformation"_..Plural(summary.staticContext.transformNames.%Size())_" "_..JoinArray(summary.staticContext.transformNames)
        }
    }
    Set text = text_". Payload body content was not returned."
    return text
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
    Set header.statusLabel = ..MessageStatusLabel(header.status)
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

ClassMethod MessageStatusLabel(status As %VarString) As %VarString [ Private ]
{
    If status = 1 {
        return "Created"
    }
    If status = 2 {
        return "Queued"
    }
    If status = 3 {
        return "Delivered"
    }
    If status = 4 {
        return "Discarded"
    }
    If status = 5 {
        return "Suspended"
    }
    If status = 6 {
        return "Deferred"
    }
    If status = 7 {
        return "Aborted"
    }
    If status = 8 {
        return "Error"
    }
    If status = 9 {
        return "Completed"
    }
    return ""
}

ClassMethod NormalizeMessageStatusFilter(status As %VarString) As %VarString [ Private ]
{
    Set normalized = $ZConvert($ZStrip(status, "<>W"), "L")
    If normalized = "" {
        return ""
    }
    If status?1.N {
        return +status
    }
    If normalized = "created" {
        return 1
    }
    If normalized = "queued" {
        return 2
    }
    If normalized = "delivered" {
        return 3
    }
    If normalized = "discarded" {
        return 4
    }
    If normalized = "suspended" {
        return 5
    }
    If normalized = "deferred" {
        return 6
    }
    If normalized = "aborted" {
        return 7
    }
    If normalized = "error" {
        return 8
    }
    If normalized = "completed" {
        return 9
    }
    return status
}

ClassMethod LogTypeLabel(type As %VarString) As %VarString [ Private ]
{
    If type = 1 {
        return "Assert"
    }
    If type = 2 {
        return "Error"
    }
    If type = 3 {
        return "Warning"
    }
    If type = 4 {
        return "Info"
    }
    If type = 5 {
        return "Trace"
    }
    If type = 6 {
        return "Alert"
    }
    return ""
}

ClassMethod NormalizeLogTypeFilter(type As %VarString) As %VarString [ Private ]
{
    Set normalized = $ZConvert($ZStrip(type, "<>W"), "L")
    If normalized = "" {
        return ""
    }
    If type?1.N {
        return +type
    }
    If normalized = "assert" {
        return 1
    }
    If normalized = "error" {
        return 2
    }
    If normalized = "warning" {
        return 3
    }
    If normalized = "info" {
        return 4
    }
    If normalized = "trace" {
        return 5
    }
    If normalized = "alert" {
        return 6
    }
    return type
}

ClassMethod NewProductionLogEntryFromRow(rset As %SQL.IResultSet, productionName As %VarString = "") As %DynamicObject [ Private ]
{
    Set entry = {}
    Set entry.logId = rset.%Get("LogId")
    Set entry.timeLogged = rset.%Get("TimeLogged")
    Set entry.type = rset.%Get("Type")
    Set entry.typeLabel = ..LogTypeLabel(entry.type)
    Set entry.source = rset.%Get("Source")
    Set entry.sessionId = rset.%Get("SessionId")
    Set entry.job = rset.%Get("Job")
    Set entry.text = rset.%Get("Text")
    Set entry.productionName = productionName
    Set entry.inProduction = $Select(productionName'="":1,1:0)
    Set entry.confidence = "observed"
    Set entry.evidence = []
    Do entry.evidence.%Push(..NewEvidence("production-log", "event-log", entry.logId, "Source", entry.source, "observed"))
    return entry
}

ClassMethod BuildSessionTimelineEvents(result As %DynamicObject) [ Private ]
{
    Set messageIndex = 0
    Set logIndex = 0
    Set sequence = 1
    For {
        Quit:((messageIndex >= result.messages.%Size()) && (logIndex >= result.logs.%Size()))
        Set useMessage = 0
        If logIndex >= result.logs.%Size() {
            Set useMessage = 1
        } ElseIf messageIndex < result.messages.%Size() {
            Set message = result.messages.%Get(messageIndex)
            Set log = result.logs.%Get(logIndex)
            If ..CompareTimelineTimestamp(message.timeCreated, log.timeLogged) >= 0 {
                Set useMessage = 1
            }
        }
        If useMessage {
            Set message = result.messages.%Get(messageIndex)
            Do result.events.%Push(..NewSessionTimelineMessageEvent(message, sequence))
            Set messageIndex = messageIndex + 1
        } Else {
            Set log = result.logs.%Get(logIndex)
            Do result.events.%Push(..NewSessionTimelineLogEvent(log, sequence))
            Set logIndex = logIndex + 1
        }
        Set sequence = sequence + 1
    }
    return
}

ClassMethod CompareTimelineTimestamp(left As %VarString, right As %VarString) As %Integer [ Private ]
{
    Set leftDate = ..NormalizeDateFilter(left, 0)
    Set rightDate = ..NormalizeDateFilter(right, 0)
    If leftDate.valid && rightDate.valid && (leftDate.horolog '= "") && (rightDate.horolog '= "") {
        return ..CompareHorolog(leftDate.horolog, rightDate.horolog)
    }
    If left = right {
        return 0
    }
    If left > right {
        return 1
    }
    return -1
}

ClassMethod NewSessionTimelineMessageEvent(message As %DynamicObject, sequence As %Integer) As %DynamicObject [ Private ]
{
    Set event = {}
    Set event.sequence = sequence
    Set event.type = "message"
    Set event.timestamp = message.timeCreated
    Set event.messageId = message.messageId
    Set event.sessionId = message.sessionId
    Set event.source = message.sourceConfigName
    Set event.target = message.targetConfigName
    Set event.status = message.status
    Set event.statusLabel = message.statusLabel
    Set event.isError = message.isError
    Set event.text = "Message "_message.messageId_" moved from "_$Select(message.sourceConfigName'="":message.sourceConfigName,1:"unknown source")_" to "_$Select(message.targetConfigName'="":message.targetConfigName,1:"unknown target")_". Payload body content was not returned."
    Set event.confidence = "observed"
    Set event.evidence = []
    Do event.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", message.messageId, "TimeCreated", message.timeCreated, "observed"))
    return event
}

ClassMethod NewSessionTimelineLogEvent(log As %DynamicObject, sequence As %Integer) As %DynamicObject [ Private ]
{
    Set event = {}
    Set event.sequence = sequence
    Set event.type = "log"
    Set event.timestamp = log.timeLogged
    Set event.logId = log.logId
    Set event.sessionId = log.sessionId
    Set event.source = log.source
    Set event.target = ""
    Set event.status = log.type
    Set event.statusLabel = log.typeLabel
    Set event.isError = $Select((log.type = 2) || ($ZConvert(log.type, "L")["error") || ($ZConvert(log.typeLabel, "L") = "error"):1,1:0)
    Set event.text = log.text
    Set event.confidence = "observed"
    Set event.evidence = []
    Do event.evidence.%Push(..NewEvidence("production-log", "event-log", log.logId, "TimeLogged", log.timeLogged, "observed"))
    return event
}

ClassMethod NewPayloadMetadata(message As %DynamicObject, settings As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metadata = {}
    Set metadata.messageId = message.messageId
    Set metadata.messageBodyClassName = message.messageBodyClassName
    Set metadata.messageBodyId = message.messageBodyId
    Set metadata.payloadReturned = 0
    Set metadata.payloadInspectionEnabled = settings.payloadInspectionEnabled
    Set metadata.payloadMetadataEnabled = settings.payloadMetadataEnabled
    Set metadata.payloadInspectionSupported = 0
    Set metadata.bodyReferenceAvailable = (message.messageBodyClassName '= "") && (message.messageBodyId '= "")
    Set metadata.bodyClassExists = 0
    If message.messageBodyClassName '= "" {
        Set metadata.bodyClassExists = ..ClassExists(message.messageBodyClassName)
    }
    Set metadata.payloadInspectionSupported = metadata.bodyReferenceAvailable && metadata.bodyClassExists
    Set metadata.restricted = 1
    Set metadata.restrictionReason = "PAYLOAD_METADATA_DISABLED"
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
    If 'settings.payloadMetadataEnabled {
        Do metadata.warnings.%Push(..NewWarning("PAYLOAD_METADATA_DISABLED", "Payload metadata is disabled by module settings. Use the payload preview endpoint to inspect redacted scalar fields."))
        return metadata
    }
    If 'metadata.bodyReferenceAvailable {
        Set metadata.restrictionReason = "PAYLOAD_BODY_REFERENCE_MISSING"
        Do metadata.warnings.%Push(..NewWarning("PAYLOAD_BODY_REFERENCE_MISSING", "Message body class or ID is missing."))
        return metadata
    }
    If 'metadata.bodyClassExists {
        Set metadata.restrictionReason = "PAYLOAD_BODY_CLASS_NOT_FOUND"
        Do metadata.warnings.%Push(..NewWarning("PAYLOAD_BODY_CLASS_NOT_FOUND", "Message body class "_metadata.messageBodyClassName_" was not found."))
        return metadata
    }
    Do ..AddPayloadMetadataFields(metadata.messageBodyClassName, metadata.fields, metadata.evidence)
    Set metadata.payloadReturned = 1
    Set metadata.restricted = 0
    Set metadata.restrictionReason = ""
    return metadata
}

ClassMethod AddPayloadMetadataFields(bodyClassName As %VarString, fields As %DynamicArray, evidence As %DynamicArray) [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Name, Type, Collection FROM %Dictionary.CompiledProperty WHERE Parent = ? ORDER BY Name"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return
    }
    Set rset = stmt.%Execute(bodyClassName)
    If rset.%SQLCODE < 0 {
        return
    }

    While rset.%Next() {
        Set propertyName = rset.%Get("Name")
        Set propertyType = rset.%Get("Type")
        Set collection = rset.%Get("Collection")
        Continue:(propertyName = "")
        Continue:($Extract(propertyName, 1) = "%")

        Set field = {}
        Set field.name = propertyName
        Set field.type = propertyType
        Set field.collection = collection
        Set field.previewScalar = (collection = "") && ..IsPreviewScalarType(propertyType)
        Do fields.%Push(field)
        Do evidence.%Push(..NewEvidence("payload-property", bodyClassName, propertyName, "Type", propertyType, "observed"))
    }
    return
}

ClassMethod AddPayloadPreviewFields(body As %RegisteredObject, bodyClassName As %VarString, redactionPatterns As %VarString, fields As %DynamicArray, evidence As %DynamicArray) [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT Name, Type, Collection FROM %Dictionary.CompiledProperty WHERE Parent = ? ORDER BY Name"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return
    }
    Set rset = stmt.%Execute(bodyClassName)
    If rset.%SQLCODE < 0 {
        return
    }

    While rset.%Next() {
        Set propertyName = rset.%Get("Name")
        Set propertyType = rset.%Get("Type")
        Set collection = rset.%Get("Collection")
        Continue:(propertyName = "")
        Continue:($Extract(propertyName, 1) = "%")
        Continue:(collection '= "")
        Continue:'..IsPreviewScalarType(propertyType)

        Set field = {}
        Set field.name = propertyName
        Set field.type = propertyType
        Set field.redacted = ..ShouldRedactField(propertyName, redactionPatterns)
        Set field.value = ""
        If field.redacted {
            Set field.value = "[redacted]"
        } Else {
            Try {
                Set field.value = ..NormalizePreviewValue($Property(body, propertyName))
            } Catch ex {
                Set field.value = "[unavailable]"
            }
        }
        Do fields.%Push(field)
        Do evidence.%Push(..NewEvidence("payload-property", bodyClassName, propertyName, "Type", propertyType, "observed"))
    }
    return
}

ClassMethod IsPreviewScalarType(propertyType As %VarString) As %Boolean [ Private ]
{
    If propertyType = "" {
        return 1
    }
    If $Extract(propertyType, 1, 1) '= "%" {
        return 0
    }
    If (propertyType = "%String") || (propertyType = "%VarString") || (propertyType = "%Integer") || (propertyType = "%Numeric") || (propertyType = "%Boolean") || (propertyType = "%Date") || (propertyType = "%Time") || (propertyType = "%TimeStamp") {
        return 1
    }
    If (propertyType = "%Library.String") || (propertyType = "%Library.VarString") || (propertyType = "%Library.Integer") || (propertyType = "%Library.Numeric") || (propertyType = "%Library.Boolean") || (propertyType = "%Library.Date") || (propertyType = "%Library.Time") || (propertyType = "%Library.TimeStamp") {
        return 1
    }
    return 0
}

ClassMethod ShouldRedactField(fieldName As %VarString, redactionPatterns As %VarString) As %Boolean [ Private ]
{
    Set normalizedField = $ZConvert(fieldName, "L")
    For index = 1:1:$Length(redactionPatterns, ",") {
        Set pattern = $ZConvert($ZStrip($Piece(redactionPatterns, ",", index), "<>W"), "L")
        Continue:(pattern = "")
        If normalizedField [ pattern {
            return 1
        }
    }
    return 0
}

ClassMethod NormalizePreviewValue(value As %String) As %VarString [ Private ]
{
    Set text = ""_value
    If $Length(text) > 500 {
        Set text = $Extract(text, 1, 500)_"..."
    }
    return text
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
    Set step.statusLabel = header.statusLabel
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
    If header.statusLabel '= "" {
        Set text = text_" and has status "_header.status_" ("_header.statusLabel_")"
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

ClassMethod NewProductionTraceExplanation(trace As %DynamicObject, productionName As %VarString) As %DynamicObject [ Private ]
{
    Set explanation = {}
    Set selected = trace.selectedMessage
    Set explanation.messageId = trace.messageId
    Set explanation.sessionId = trace.sessionId
    Set explanation.productionName = productionName
    Set explanation.confidence = "observed"
    Set explanation.text = ..BuildProductionTraceExplanationText(trace, productionName)
    Set explanation.evidence = []
    If $IsObject(selected) {
        Do explanation.evidence.%Push(..NewEvidence("message-header", "Ens.MessageHeader", selected.messageId, "SessionId", selected.sessionId, "observed"))
    }
    Do explanation.evidence.%Push(..NewEvidence("static-analysis", productionName, productionName, "TraceStaticContext", "Production-scoped trace matched against static analysis", "confirmed"))
    return explanation
}

ClassMethod BuildProductionTraceExplanationText(trace As %DynamicObject, productionName As %VarString) As %VarString [ Private ]
{
    Set selected = trace.selectedMessage
    Set text = "Message "_trace.messageId
    If $IsObject(selected),selected.messageBodyClassName '= "" {
        Set text = text_" is an observed "_selected.messageBodyClassName_" message"
    } Else {
        Set text = text_" is an observed interoperability message"
    }
    If trace.sessionId '= "" {
        Set text = text_" in session "_trace.sessionId
    }
    Set text = text_" for production "_productionName
    If trace.stepCount > 0 {
        Set text = text_". The reconstructed trace has "_trace.stepCount_" step"_..Plural(trace.stepCount)_", with "_trace.productionStepCount_" step"_..Plural(trace.productionStepCount)_" in this production"
    }

    Set connectionKinds = []
    Set ruleNames = []
    Set transformNames = []
    Set processClasses = []
    For index = 0:1:trace.steps.%Size()-1 {
        Set step = trace.steps.%Get(index)
        Continue:'$IsObject(step)
        If step.%IsDefined("staticConnectionKind") {
            Do ..PushUnique(connectionKinds, step.staticConnectionKind)
        }
        If step.%IsDefined("staticRuleName") {
            Do ..PushUnique(ruleNames, step.staticRuleName)
        }
        If step.%IsDefined("staticProcessClass") {
            Do ..PushUnique(processClasses, step.staticProcessClass)
        }
        If step.%IsDefined("staticTransformNames"),$IsObject(step.staticTransformNames) {
            For transformIndex = 0:1:step.staticTransformNames.%Size()-1 {
                Do ..PushUnique(transformNames, step.staticTransformNames.%Get(transformIndex))
            }
        }
    }

    If connectionKinds.%Size() > 0 {
        Set text = text_". Static analysis matched "_connectionKinds.%Size()_" connection kind"_..Plural(connectionKinds.%Size())_": "_..JoinArray(connectionKinds)
    }
    If ruleNames.%Size() > 0 {
        Set text = text_". Routing rule"_..Plural(ruleNames.%Size())_" involved: "_..JoinArray(ruleNames)
    }
    If transformNames.%Size() > 0 {
        Set text = text_". Transformation"_..Plural(transformNames.%Size())_" involved: "_..JoinArray(transformNames)
    }
    If processClasses.%Size() > 0 {
        Set text = text_". BPL process"_..Plural(processClasses.%Size())_" involved: "_..JoinArray(processClasses)
    }
    Set text = text_". Payload body content was not returned."
    return text
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

ClassMethod BuildProductionSummaryBullets(production As %DynamicObject, connections As %DynamicArray, externalSystems As %DynamicArray, artifacts As %DynamicArray, messageTypes As %DynamicArray, transformations As %DynamicArray, businessProcesses As %DynamicArray) As %DynamicArray [ Private ]
{
    Set serviceCount = ..CountComponentsByType(production.components, "business-service")
    Set processCount = ..CountComponentsByType(production.components, "business-process")
    Set operationCount = ..CountComponentsByType(production.components, "business-operation")
    Set disabledCount = ..CountDisabledComponents(production.components)
    Set bullets = []

    Do bullets.%Push(serviceCount_" service"_..Plural(serviceCount)_", "_processCount_" process"_..Plural(processCount)_", and "_operationCount_" operation"_..Plural(operationCount)_" are configured.")
    Do bullets.%Push(connections.%Size()_" target connection"_..Plural(connections.%Size())_" describe component routing.")
    Do bullets.%Push(messageTypes.%Size()_" message signature"_..Plural(messageTypes.%Size())_", "_transformations.%Size()_" transformation definition"_..Plural(transformations.%Size())_", and "_businessProcesses.%Size()_" BPL process definition"_..Plural(businessProcesses.%Size())_" were identified.")

    If externalSystems.%Size() > 0 {
        Do bullets.%Push(externalSystems.%Size()_" external endpoint setting"_..Plural(externalSystems.%Size())_" can be inspected.")
    }
    If artifacts.%Size() > 0 {
        Do bullets.%Push(artifacts.%Size()_" rule, transformation, or BPL artifact"_..Plural(artifacts.%Size())_" support the explanation.")
    }
    If disabledCount > 0 {
        If disabledCount = 1 {
            Do bullets.%Push(disabledCount_" component is disabled.")
        } Else {
            Do bullets.%Push(disabledCount_" components are disabled.")
        }
    }
    return bullets
}

ClassMethod BuildProductionOverviewSummary(production As %DynamicObject) As %VarString [ Private ]
{
    Set text = "Production "_production.name_" contains "_production.serviceCount_" business service"_..Plural(production.serviceCount)_", "_production.processCount_" business process"_..Plural(production.processCount)_", and "_production.operationCount_" business operation"_..Plural(production.operationCount)_"."
    If production.disabledComponentCount > 0 {
        If production.disabledComponentCount = 1 {
            Set text = text_" 1 component is disabled."
        } Else {
            Set text = text_" "_production.disabledComponentCount_" components are disabled."
        }
    }
    If production.runtimeState '= "" {
        Set text = text_" Runtime state is "_production.runtimeState_"."
    }
    return text
}

ClassMethod BuildProductionOverviewSummaryBullets(production As %DynamicObject) As %DynamicArray [ Private ]
{
    Set bullets = []

    Do bullets.%Push(production.componentCount_" configured component"_..Plural(production.componentCount)_" are available for inspection.")
    Do bullets.%Push(production.serviceCount_" service"_..Plural(production.serviceCount)_", "_production.processCount_" process"_..Plural(production.processCount)_", and "_production.operationCount_" operation"_..Plural(production.operationCount)_" are configured.")
    If production.disabledComponentCount > 0 {
        If production.disabledComponentCount = 1 {
            Do bullets.%Push("1 component is disabled.")
        } Else {
            Do bullets.%Push(production.disabledComponentCount_" components are disabled.")
        }
    }
    If production.runtimeState '= "" {
        Do bullets.%Push("Runtime state is "_production.runtimeState_".")
    }
    return bullets
}

ClassMethod BuildProductionOverviewMetrics(production As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.componentCount = production.componentCount
    Set metrics.serviceCount = production.serviceCount
    Set metrics.processCount = production.processCount
    Set metrics.operationCount = production.operationCount
    Set metrics.disabledComponentCount = production.disabledComponentCount
    return metrics
}

ClassMethod BuildProductionListMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.productionCount = 0
    Set metrics.runningProductionCount = 0
    Set metrics.componentCount = 0
    Set metrics.serviceCount = 0
    Set metrics.processCount = 0
    Set metrics.operationCount = 0
    Set metrics.disabledComponentCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(result.items) {
        Set metrics.productionCount = result.items.%Size()
        For index = 0:1:result.items.%Size()-1 {
            Set item = result.items.%Get(index)
            Continue:'$IsObject(item)
            If item.isRunning {
                Set metrics.runningProductionCount = metrics.runningProductionCount + 1
            }
            Set metrics.componentCount = metrics.componentCount + item.componentCount
            Set metrics.serviceCount = metrics.serviceCount + item.serviceCount
            Set metrics.processCount = metrics.processCount + item.processCount
            Set metrics.operationCount = metrics.operationCount + item.operationCount
            Set metrics.disabledComponentCount = metrics.disabledComponentCount + item.disabledComponentCount
            Do ..AddEvidenceCoverageFromObject(item, metrics)
        }
    }
    If $IsObject(result.warnings) {
        Set metrics.warningCount = result.warnings.%Size()
    }
    return metrics
}

ClassMethod BuildProductionRuntimeMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.state = 0
    Set metrics.isRunning = 0
    Set metrics.isCurrent = 0
    Set metrics.hasActiveProduction = 0
    Set metrics.changed = 0
    Set metrics.hasError = 0
    If $IsObject(result.runtime) {
        Set metrics.state = result.runtime.state
        Set metrics.isRunning = result.runtime.isRunning
        Set metrics.isCurrent = result.runtime.isCurrent
        Set metrics.hasActiveProduction = $Select(result.runtime.currentProduction '= "":1, 1:0)
    }
    If result.%IsDefined("changed") {
        Set metrics.changed = result.changed
    }
    If result.%IsDefined("errorCode") {
        Set metrics.hasError = 1
    }
    return metrics
}

ClassMethod BuildComponentSummaryBullets(detail As %DynamicObject) As %DynamicArray [ Private ]
{
    Set bullets = []
    Set componentType = "component"
    If $IsObject(detail.component) {
        Set componentType = ..ComponentTypeText(detail.component.type)
    }

    Do bullets.%Push(detail.componentName_" is a "_componentType_" with "_detail.connections.%Size()_" related connection"_..Plural(detail.connections.%Size())_".")
    If detail.messageTypes.%Size() > 0 {
        Do bullets.%Push(detail.messageTypes.%Size()_" message signature"_..Plural(detail.messageTypes.%Size())_" describe request and response contracts.")
    }
    If detail.externalSystems.%Size() > 0 {
        If detail.externalSystems.%Size() = 1 {
            Do bullets.%Push(detail.externalSystems.%Size()_" external endpoint setting is attached to this component.")
        } Else {
            Do bullets.%Push(detail.externalSystems.%Size()_" external endpoint settings are attached to this component.")
        }
    }
    If detail.rules.%Size() > 0 {
        If detail.rules.%Size() = 1 {
            Do bullets.%Push(detail.rules.%Size()_" routing rule is linked to this component.")
        } Else {
            Do bullets.%Push(detail.rules.%Size()_" routing rules are linked to this component.")
        }
    }
    If detail.transformations.%Size() > 0 {
        If detail.transformations.%Size() = 1 {
            Do bullets.%Push(detail.transformations.%Size()_" transformation definition is linked to this component.")
        } Else {
            Do bullets.%Push(detail.transformations.%Size()_" transformation definitions are linked to this component.")
        }
    }
    If detail.businessProcesses.%Size() > 0 {
        If detail.businessProcesses.%Size() = 1 {
            Do bullets.%Push(detail.businessProcesses.%Size()_" BPL process definition is linked to this component.")
        } Else {
            Do bullets.%Push(detail.businessProcesses.%Size()_" BPL process definitions are linked to this component.")
        }
    }
    If detail.artifacts.%Size() > 0 {
        Do bullets.%Push(detail.artifacts.%Size()_" supporting artifact"_..Plural(detail.artifacts.%Size())_" provide evidence.")
    }
    return bullets
}

ClassMethod BuildProductionMetrics(analysis As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.componentCount = analysis.components.%Size()
    Set metrics.serviceCount = ..CountComponentsByType(analysis.components, "business-service")
    Set metrics.processCount = ..CountComponentsByType(analysis.components, "business-process")
    Set metrics.operationCount = ..CountComponentsByType(analysis.components, "business-operation")
    Set metrics.disabledComponentCount = ..CountDisabledComponents(analysis.components)
    Set metrics.connectionCount = analysis.connections.%Size()
    Set metrics.targetConfigConnectionCount = ..CountConnectionsByKind(analysis.connections, "target-config")
    Set metrics.routingRuleConnectionCount = ..CountConnectionsByKind(analysis.connections, "routing-rule")
    Set metrics.bplCallConnectionCount = ..CountConnectionsByKind(analysis.connections, "bpl-call")
    Set metrics.externalSystemCount = analysis.externalSystems.%Size()
    Set metrics.artifactCount = analysis.artifacts.%Size()
    Set metrics.ruleCount = analysis.rules.%Size()
    Set metrics.messageTypeCount = analysis.messageTypes.%Size()
    Set metrics.transformationCount = analysis.transformations.%Size()
    Set metrics.businessProcessCount = analysis.businessProcesses.%Size()
    Set metrics.warningCount = analysis.warnings.%Size()
    Set metrics.explanationCount = analysis.componentExplanations.%Size() + analysis.connectionExplanations.%Size() + analysis.externalSystemExplanations.%Size() + analysis.artifactExplanations.%Size() + analysis.ruleExplanations.%Size() + analysis.messageTypeExplanations.%Size() + analysis.transformationExplanations.%Size() + analysis.businessProcessExplanations.%Size()
    return metrics
}

ClassMethod BuildAnalysisCoverage(analysis As %DynamicObject) As %DynamicObject [ Private ]
{
    Set coverage = {}
    Set coverage.componentCount = analysis.components.%Size()
    Set coverage.connectionCount = analysis.connections.%Size()
    Set coverage.messageTypeCount = analysis.messageTypes.%Size()
    Set coverage.externalSystemCount = analysis.externalSystems.%Size()
    Set coverage.artifactCount = analysis.artifacts.%Size()
    Set coverage.ruleCount = analysis.rules.%Size()
    Set coverage.transformationCount = analysis.transformations.%Size()
    Set coverage.businessProcessCount = analysis.businessProcesses.%Size()
    Set coverage.warningCount = analysis.warnings.%Size()
    Set coverage.componentAnalysisAvailable = (coverage.componentCount > 0)
    Set coverage.targetAnalysisAvailable = (coverage.connectionCount > 0)
    Set coverage.messageSignatureAnalysisAvailable = (coverage.messageTypeCount > 0)
    Set coverage.routingRuleAnalysisAvailable = (coverage.ruleCount > 0)
    Set coverage.transformationAnalysisAvailable = (coverage.transformationCount > 0)
    Set coverage.businessProcessAnalysisAvailable = (coverage.businessProcessCount > 0)
    Set coverage.warningCodes = []
    Set coverage.limitations = []
    Set coverage.evidenceCount = 0
    Set coverage.confirmedEvidenceCount = 0
    Set coverage.observedEvidenceCount = 0
    Set coverage.inferredEvidenceCount = 0
    Set coverage.unknownEvidenceCount = 0

    For index = 0:1:analysis.warnings.%Size()-1 {
        Set warning = analysis.warnings.%Get(index)
        Continue:'$IsObject(warning)
        Set code = warning.code
        Continue:(code = "")
        Continue:(..ArrayContains(coverage.warningCodes, code))
        Do coverage.warningCodes.%Push(code)
    }

    If 'coverage.routingRuleAnalysisAvailable {
        Do coverage.limitations.%Push("No accessible routing-rule definitions were identified.")
    }
    If 'coverage.transformationAnalysisAvailable {
        Do coverage.limitations.%Push("No accessible DTL transformation definitions were identified.")
    }
    If 'coverage.businessProcessAnalysisAvailable {
        Do coverage.limitations.%Push("No accessible BPL process definitions were identified.")
    }
    If coverage.warningCodes.%Size() > 0 {
        Do coverage.limitations.%Push("Review warning codes for unsupported or ambiguous analysis findings.")
    }
    Do ..AddEvidenceCoverageFromArray(analysis.components, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.connections, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.externalSystems, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.artifacts, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.rules, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.messageTypes, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.transformations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.businessProcesses, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.componentExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.connectionExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.externalSystemExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.artifactExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.ruleExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.messageTypeExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.transformationExplanations, coverage)
    Do ..AddEvidenceCoverageFromArray(analysis.businessProcessExplanations, coverage)
    return coverage
}

ClassMethod AddEvidenceCoverageFromArray(items As %DynamicArray, coverage As %DynamicObject) [ Private ]
{
    For index = 0:1:items.%Size()-1 {
        Set item = items.%Get(index)
        Continue:'$IsObject(item)
        Continue:'$IsObject(item.evidence)
        Do ..AddEvidenceCoverageFromEvidenceArray(item.evidence, coverage)
    }
    return
}

ClassMethod AddEvidenceCoverageFromObject(item As %DynamicObject, coverage As %DynamicObject) [ Private ]
{
    If '$IsObject(item) {
        return
    }
    If '$IsObject(item.evidence) {
        return
    }
    Do ..AddEvidenceCoverageFromEvidenceArray(item.evidence, coverage)
    return
}

ClassMethod AddEvidenceCoverageFromEvidenceArray(items As %DynamicArray, coverage As %DynamicObject) [ Private ]
{
    For index = 0:1:items.%Size()-1 {
        Set evidence = items.%Get(index)
        Continue:'$IsObject(evidence)
        Set confidence = evidence.confidence
        Set coverage.evidenceCount = coverage.evidenceCount + 1
        If confidence = "confirmed" {
            Set coverage.confirmedEvidenceCount = coverage.confirmedEvidenceCount + 1
        } ElseIf confidence = "observed" {
            Set coverage.observedEvidenceCount = coverage.observedEvidenceCount + 1
        } ElseIf confidence = "inferred" {
            Set coverage.inferredEvidenceCount = coverage.inferredEvidenceCount + 1
        } Else {
            Set coverage.unknownEvidenceCount = coverage.unknownEvidenceCount + 1
        }
    }
    return
}

ClassMethod BuildComponentMetrics(detail As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.connectionCount = detail.connections.%Size()
    Set metrics.externalSystemCount = detail.externalSystems.%Size()
    Set metrics.artifactCount = detail.artifacts.%Size()
    Set metrics.ruleCount = detail.rules.%Size()
    Set metrics.messageTypeCount = detail.messageTypes.%Size()
    Set metrics.transformationCount = detail.transformations.%Size()
    Set metrics.businessProcessCount = detail.businessProcesses.%Size()
    Set metrics.explanationCount = detail.connectionExplanations.%Size() + detail.externalSystemExplanations.%Size() + detail.artifactExplanations.%Size() + detail.ruleExplanations.%Size() + detail.messageTypeExplanations.%Size() + detail.transformationExplanations.%Size() + detail.businessProcessExplanations.%Size()
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    Do ..AddEvidenceCoverageFromObject(detail.component, metrics)
    Do ..AddEvidenceCoverageFromObject(detail.explanation, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.connections, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.connectionExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.externalSystems, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.externalSystemExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.artifacts, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.artifactExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.rules, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.ruleExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.messageTypes, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.messageTypeExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.transformations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.transformationExplanations, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.businessProcesses, metrics)
    Do ..AddEvidenceCoverageFromArray(detail.businessProcessExplanations, metrics)
    return metrics
}

ClassMethod BuildComponentListMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.componentCount = 0
    Set metrics.serviceCount = 0
    Set metrics.processCount = 0
    Set metrics.operationCount = 0
    Set metrics.disabledComponentCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(result.items) {
        Set metrics.componentCount = result.items.%Size()
        Set metrics.serviceCount = ..CountComponentsByType(result.items, "business-service")
        Set metrics.processCount = ..CountComponentsByType(result.items, "business-process")
        Set metrics.operationCount = ..CountComponentsByType(result.items, "business-operation")
        Set metrics.disabledComponentCount = ..CountDisabledComponents(result.items)
        Do ..AddEvidenceCoverageFromArray(result.items, metrics)
    }
    If $IsObject(result.warnings) {
        Set metrics.warningCount = result.warnings.%Size()
    }
    return metrics
}

ClassMethod ArrayContains(items As %DynamicArray, value As %VarString) As %Boolean [ Private ]
{
    For index = 0:1:items.%Size()-1 {
        If items.%Get(index) = value {
            return 1
        }
    }
    return 0
}

ClassMethod BuildGraphSummaryBullets(analysis As %DynamicObject, nodes As %DynamicArray, edges As %DynamicArray) As %DynamicArray [ Private ]
{
    Set serviceCount = ..CountComponentsByType(analysis.components, "business-service")
    Set processCount = ..CountComponentsByType(analysis.components, "business-process")
    Set operationCount = ..CountComponentsByType(analysis.components, "business-operation")
    Set routingCount = ..CountConnectionsByKind(analysis.connections, "routing-rule")
    Set bplCount = ..CountConnectionsByKind(analysis.connections, "bpl-call")
    Set targetCount = ..CountConnectionsByKind(analysis.connections, "target-config")
    Set bullets = []

    Do bullets.%Push(nodes.%Size()_" graph node"_..Plural(nodes.%Size())_" represent "_serviceCount_" service"_..Plural(serviceCount)_", "_processCount_" process"_..Plural(processCount)_", and "_operationCount_" operation"_..Plural(operationCount)_".")
    Do bullets.%Push(edges.%Size()_" graph edge"_..Plural(edges.%Size())_" describe target-config, routing-rule, and BPL relationships.")
    If targetCount > 0 {
        Do bullets.%Push(targetCount_" configured target connection"_..Plural(targetCount)_" came from component settings.")
    }
    If routingCount > 0 {
        Do bullets.%Push(routingCount_" routing-rule edge"_..Plural(routingCount)_" came from rule analysis.")
    }
    If bplCount > 0 {
        Do bullets.%Push(bplCount_" BPL call edge"_..Plural(bplCount)_" came from process analysis.")
    }
    return bullets
}

ClassMethod BuildGraphMetrics(analysis As %DynamicObject, nodes As %DynamicArray, edges As %DynamicArray) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.nodeCount = nodes.%Size()
    Set metrics.edgeCount = edges.%Size()
    Set metrics.serviceCount = ..CountComponentsByType(analysis.components, "business-service")
    Set metrics.processCount = ..CountComponentsByType(analysis.components, "business-process")
    Set metrics.operationCount = ..CountComponentsByType(analysis.components, "business-operation")
    Set metrics.disabledNodeCount = ..CountDisabledComponents(analysis.components)
    Set metrics.targetConfigEdgeCount = ..CountConnectionsByKind(analysis.connections, "target-config")
    Set metrics.routingRuleEdgeCount = ..CountConnectionsByKind(analysis.connections, "routing-rule")
    Set metrics.bplCallEdgeCount = ..CountConnectionsByKind(analysis.connections, "bpl-call")
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    Do ..AddEvidenceCoverageFromArray(nodes, metrics)
    Do ..AddEvidenceCoverageFromArray(edges, metrics)
    return metrics
}

ClassMethod BuildTraceMetrics(trace As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.stepCount = trace.steps.%Size()
    Set metrics.warningCount = trace.warnings.%Size()
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    Do ..AddEvidenceCoverageFromEvidenceArray(trace.evidence, metrics)
    Do ..AddEvidenceCoverageFromArray(trace.steps, metrics)
    return metrics
}

ClassMethod BuildMessageListMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.itemCount = 0
    Set metrics.totalCount = 0
    Set metrics.errorCount = 0
    Set metrics.hasMore = 0
    Set metrics.sourceFacetCount = 0
    Set metrics.targetFacetCount = 0
    Set metrics.messageBodyClassFacetCount = 0
    Set metrics.sessionFacetCount = 0
    Set metrics.statusFacetCount = 0
    Set metrics.componentFacetCount = 0
    Set metrics.warningCount = 0

    If $IsObject(result.items) {
        Set metrics.itemCount = result.items.%Size()
        Set metrics.totalCount = metrics.itemCount
        For index = 0:1:result.items.%Size()-1 {
            Set item = result.items.%Get(index)
            Continue:'$IsObject(item)
            If item.isError {
                Set metrics.errorCount = metrics.errorCount + 1
            }
        }
    }
    If result.%IsDefined("count") {
        Set metrics.itemCount = result.count
        Set metrics.totalCount = result.count
    }
    If result.%IsDefined("totalCount") {
        Set metrics.totalCount = result.totalCount
    }
    If result.%IsDefined("errorCount") {
        Set metrics.errorCount = result.errorCount
    }
    If result.%IsDefined("hasMore") {
        Set metrics.hasMore = result.hasMore
    }
    If $IsObject(result.sourceConfigNames) {
        Set metrics.sourceFacetCount = result.sourceConfigNames.%Size()
    }
    If $IsObject(result.targetConfigNames) {
        Set metrics.targetFacetCount = result.targetConfigNames.%Size()
    }
    If $IsObject(result.messageBodyClassNames) {
        Set metrics.messageBodyClassFacetCount = result.messageBodyClassNames.%Size()
    }
    If $IsObject(result.sessionIds) {
        Set metrics.sessionFacetCount = result.sessionIds.%Size()
    }
    If $IsObject(result.statusFacets) {
        Set metrics.statusFacetCount = result.statusFacets.%Size()
    } ElseIf $IsObject(result.statusNames) {
        Set metrics.statusFacetCount = result.statusNames.%Size()
    }
    If $IsObject(result.componentNames) {
        Set metrics.componentFacetCount = result.componentNames.%Size()
    }
    If $IsObject(result.warnings) {
        Set metrics.warningCount = result.warnings.%Size()
    }
    return metrics
}

ClassMethod BuildProductionLogMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.itemCount = 0
    Set metrics.totalCount = 0
    Set metrics.hasMore = 0
    Set metrics.sourceFacetCount = 0
    Set metrics.typeFacetCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(result.items) {
        Set metrics.itemCount = result.items.%Size()
        Do ..AddEvidenceCoverageFromArray(result.items, metrics)
    }
    If result.%IsDefined("totalCount") {
        Set metrics.totalCount = result.totalCount
    } Else {
        Set metrics.totalCount = metrics.itemCount
    }
    If result.%IsDefined("hasMore") {
        Set metrics.hasMore = result.hasMore
    }
    If $IsObject(result.sourceNames) {
        Set metrics.sourceFacetCount = result.sourceNames.%Size()
    }
    If $IsObject(result.typeFacets) {
        Set metrics.typeFacetCount = result.typeFacets.%Size()
    } ElseIf $IsObject(result.typeNames) {
        Set metrics.typeFacetCount = result.typeNames.%Size()
    }
    If $IsObject(result.warnings) {
        Set metrics.warningCount = result.warnings.%Size()
    }
    return metrics
}

ClassMethod BuildSessionTimelineMetrics(result As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.messageCount = 0
    Set metrics.logCount = 0
    Set metrics.eventCount = 0
    Set metrics.errorCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(result.messages) {
        Set metrics.messageCount = result.messages.%Size()
        For messageIndex = 0:1:result.messages.%Size()-1 {
            Set message = result.messages.%Get(messageIndex)
            Continue:'$IsObject(message)
            If message.isError {
                Set metrics.errorCount = metrics.errorCount + 1
            }
        }
        Do ..AddEvidenceCoverageFromArray(result.messages, metrics)
    }
    If $IsObject(result.logs) {
        Set metrics.logCount = result.logs.%Size()
        Do ..AddEvidenceCoverageFromArray(result.logs, metrics)
    }
    If $IsObject(result.events) {
        Set metrics.eventCount = result.events.%Size()
        Do ..AddEvidenceCoverageFromArray(result.events, metrics)
    }
    If $IsObject(result.warnings) {
        Set metrics.warningCount = result.warnings.%Size()
    }
    If $IsObject(result.evidence) {
        Do ..AddEvidenceCoverageFromEvidenceArray(result.evidence, metrics)
    }
    return metrics
}

ClassMethod BuildMessageDetailMetrics(detail As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.payloadReturned = 0
    Set metrics.payloadInspectionSupported = 0
    Set metrics.bodyReferenceAvailable = 0
    Set metrics.messageEvidenceCount = 0
    Set metrics.payloadEvidenceCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0

    If detail.%IsDefined("payloadReturned") {
        Set metrics.payloadReturned = detail.payloadReturned
    }
    If $IsObject(detail.warnings) {
        Set metrics.warningCount = detail.warnings.%Size()
    }
    If $IsObject(detail.message) {
        If $IsObject(detail.message.evidence) {
            Set metrics.messageEvidenceCount = detail.message.evidence.%Size()
            Do ..AddEvidenceCoverageFromEvidenceArray(detail.message.evidence, metrics)
        }
    }
    If $IsObject(detail.payloadMetadata) {
        If detail.payloadMetadata.%IsDefined("payloadInspectionSupported") {
            Set metrics.payloadInspectionSupported = detail.payloadMetadata.payloadInspectionSupported
        }
        If detail.payloadMetadata.%IsDefined("bodyReferenceAvailable") {
            Set metrics.bodyReferenceAvailable = detail.payloadMetadata.bodyReferenceAvailable
        }
        If $IsObject(detail.payloadMetadata.warnings) {
            Set metrics.warningCount = metrics.warningCount + detail.payloadMetadata.warnings.%Size()
        }
        If $IsObject(detail.payloadMetadata.evidence) {
            Set metrics.payloadEvidenceCount = detail.payloadMetadata.evidence.%Size()
            Do ..AddEvidenceCoverageFromEvidenceArray(detail.payloadMetadata.evidence, metrics)
        }
    }
    return metrics
}

ClassMethod BuildRuntimeActionMetrics(action As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.requested = action.requested
    Set metrics.allowed = action.allowed
    Set metrics.executed = action.executed
    Set metrics.changed = action.changed
    Set metrics.dryRun = action.dryRun
    Set metrics.supported = action.supported
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(action.warnings) {
        Set metrics.warningCount = action.warnings.%Size()
    }
    If $IsObject(action.evidence) {
        Do ..AddEvidenceCoverageFromEvidenceArray(action.evidence, metrics)
    }
    return metrics
}

ClassMethod BuildSettingsMetrics(settingsResult As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.featureFlagCount = 0
    Set metrics.enabledFeatureFlagCount = 0
    Set metrics.limitSettingCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(settingsResult.settings) {
        Set flagNames = ["runtimeMessageAnalysisEnabled","payloadInspectionEnabled","payloadMetadataEnabled","messageResendEnabled","sourceCodeInferenceEnabled","aiProviderEnabled","aiSummaryEnabled","ragRuntimeDataEnabled","ragPayloadIndexingEnabled"]
        For index = 0:1:flagNames.%Size()-1 {
            Set flagName = flagNames.%Get(index)
            Continue:'settingsResult.settings.%IsDefined(flagName)
            Set metrics.featureFlagCount = metrics.featureFlagCount + 1
            If settingsResult.settings.%Get(flagName) {
                Set metrics.enabledFeatureFlagCount = metrics.enabledFeatureFlagCount + 1
            }
        }
        Set limitNames = ["maxMessagesReturned","maxTraceDepth","defaultMessageLookbackDays","ragRuntimeLookbackHours","ragRuntimeMaxMessages","ragRuntimeMaxLogs","ragPayloadMaxFields"]
        For index = 0:1:limitNames.%Size()-1 {
            Set limitName = limitNames.%Get(index)
            Continue:'settingsResult.settings.%IsDefined(limitName)
            Set metrics.limitSettingCount = metrics.limitSettingCount + 1
        }
    }
    If $IsObject(settingsResult.warnings) {
        Set metrics.warningCount = settingsResult.warnings.%Size()
    }
    If $IsObject(settingsResult.evidence) {
        Do ..AddEvidenceCoverageFromEvidenceArray(settingsResult.evidence, metrics)
    }
    return metrics
}

ClassMethod AddPayloadMetrics(payload As %DynamicObject) [ Private ]
{
    Set payload.metrics = ..BuildPayloadMetrics(payload)
    If $IsObject(payload.metadata) {
        Set payload.metadata.metrics = payload.metrics
    }
    return
}

ClassMethod BuildPayloadMetrics(payload As %DynamicObject) As %DynamicObject [ Private ]
{
    Set metrics = {}
    Set metrics.fieldCount = 0
    Set metrics.redactedFieldCount = 0
    Set metrics.warningCount = 0
    Set metrics.evidenceCount = 0
    Set metrics.confirmedEvidenceCount = 0
    Set metrics.observedEvidenceCount = 0
    Set metrics.inferredEvidenceCount = 0
    Set metrics.unknownEvidenceCount = 0
    If $IsObject(payload.fields) {
        Set metrics.fieldCount = payload.fields.%Size()
        For index = 0:1:payload.fields.%Size()-1 {
            Set field = payload.fields.%Get(index)
            Continue:'$IsObject(field)
            If field.redacted {
                Set metrics.redactedFieldCount = metrics.redactedFieldCount + 1
            }
        }
    }
    If $IsObject(payload.warnings) {
        Set metrics.warningCount = payload.warnings.%Size()
    }
    If $IsObject(payload.evidence) {
        Do ..AddEvidenceCoverageFromEvidenceArray(payload.evidence, metrics)
    }
    return metrics
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

ClassMethod CountConnectionsByKind(connections As %DynamicArray, kind As %VarString) As %Integer [ Private ]
{
    Set count = 0
    For index = 0:1:connections.%Size()-1 {
        Set connection = connections.%Get(index)
        If $IsObject(connection) {
            If connection.kind = kind {
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

ClassMethod ClassMethodExists(className As %VarString, methodName As %VarString) As %Boolean [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name FROM %Dictionary.CompiledMethod WHERE Parent = ? AND Name = ?")
    If $$$ISERR(sc) {
        return 0
    }
    Set rset = stmt.%Execute(className, methodName)
    If rset.%SQLCODE < 0 {
        return 0
    }
    return rset.%Next()
}

ClassMethod ClassPropertyExists(className As %VarString, propertyName As %VarString) As %Boolean [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT Name FROM %Dictionary.CompiledProperty WHERE Parent = ? AND Name = ?")
    If $$$ISERR(sc) {
        return 0
    }
    Set rset = stmt.%Execute(className, propertyName)
    If rset.%SQLCODE < 0 {
        return 0
    }
    return rset.%Next()
}

ClassMethod FirstExistingProperty(className As %VarString, propertyNames As %DynamicArray) As %VarString [ Private ]
{
    For index = 0:1:propertyNames.%Size()-1 {
        Set propertyName = propertyNames.%Get(index)
        If ..ClassPropertyExists(className, propertyName) {
            return propertyName
        }
    }
    return ""
}

ClassMethod ProductionLogClassName() As %VarString [ Private ]
{
    Set candidates = ["Ens.Util.Log","Ens.EventLog","EnsLib.Util.Log"]
    For index = 0:1:candidates.%Size()-1 {
        Set className = candidates.%Get(index)
        If ..ClassExists(className) {
            return className
        }
    }
    return ""
}

ClassMethod LogSelectExpression(propertyName As %VarString, alias As %VarString) As %VarString [ Private ]
{
    If propertyName = "" {
        return "'' AS "_alias
    }
    return propertyName_" AS "_alias
}

ClassMethod ClassSqlTableReference(className As %VarString) As %VarString [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT SqlSchemaName, SqlTableName FROM %Dictionary.CompiledClass WHERE Name = ?")
    If $$$ISERR(sc) {
        return className
    }
    Set rset = stmt.%Execute(className)
    If rset.%SQLCODE < 0 {
        return className
    }
    If 'rset.%Next() {
        return className
    }
    If (rset.%Get("SqlSchemaName") '= "") && (rset.%Get("SqlTableName") '= "") {
        return rset.%Get("SqlSchemaName")_"."_rset.%Get("SqlTableName")
    }
    return className
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
