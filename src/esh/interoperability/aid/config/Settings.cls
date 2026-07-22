Class esh.interoperability.aid.config.Settings Extends %Persistent
{

Property RuntimeMessageAnalysisEnabled As %Boolean [ InitialExpression = 1 ];

Property PayloadInspectionEnabled As %Boolean [ InitialExpression = 1 ];

Property PayloadMetadataEnabled As %Boolean [ InitialExpression = 1 ];

Property RequestSessionAnalysisEnabled As %Boolean [ InitialExpression = 0 ];

Property RequestTraceAnalysisEnabled As %Boolean [ InitialExpression = 0 ];

Property MessageResendEnabled As %Boolean [ InitialExpression = 0 ];

Property MaxMessagesReturned As %Integer [ InitialExpression = 100 ];

Property MaxTraceDepth As %Integer [ InitialExpression = 50 ];

Property DefaultMessageLookbackDays As %Integer [ InitialExpression = 7 ];

Property FieldRedactionPatterns As %VarString(MAXLEN = 1000) [ InitialExpression = "patient,ssn,mrn,dob,address,phone,email" ];

Property ClassExclusions As %VarString(MAXLEN = 1000);

Property ProductionExclusions As %VarString(MAXLEN = 1000);

Property SourceCodeInferenceEnabled As %Boolean [ InitialExpression = 0 ];

Property ExplanationVerbosity As %VarString [ InitialExpression = "normal" ];

Property AIProviderEnabled As %Boolean [ InitialExpression = 0 ];

Property AISummaryEnabled As %Boolean [ InitialExpression = 0 ];

Property AIProvider As %VarString [ InitialExpression = "openai" ];

Property AIModel As %VarString [ InitialExpression = "gpt-4o-mini" ];

Property AIEndpoint As %VarString(MAXLEN = 500) [ InitialExpression = "https://api.openai.com/v1/chat/completions" ];

Property OpenAIApiKey As %VarString(MAXLEN = 500);

Property RAGRuntimeDataEnabled As %Boolean [ InitialExpression = 0 ];

Property RAGRuntimeLookbackHours As %Integer [ InitialExpression = 24 ];

Property RAGRuntimeMaxMessages As %Integer [ InitialExpression = 100 ];

Property RAGRuntimeMaxLogs As %Integer [ InitialExpression = 100 ];

Property RAGPayloadIndexingEnabled As %Boolean [ InitialExpression = 0 ];

Property RAGPayloadMaxFields As %Integer [ InitialExpression = 50 ];

ClassMethod Defaults() As %DynamicObject
{
    Set settings = {}
    Set settings.runtimeMessageAnalysisEnabled = 1
    Set settings.payloadInspectionEnabled = 1
    Set settings.payloadMetadataEnabled = 1
    Set settings.requestSessionAnalysisEnabled = 0
    Set settings.requestTraceAnalysisEnabled = 0
    Set settings.messageResendEnabled = 0
    Set settings.maxMessagesReturned = 100
    Set settings.maxTraceDepth = 50
    Set settings.defaultMessageLookbackDays = 7
    Set settings.fieldRedactionPatterns = "patient,ssn,mrn,dob,address,phone,email"
    Set settings.classExclusions = ""
    Set settings.productionExclusions = ""
    Set settings.sourceCodeInferenceEnabled = 0
    Set settings.explanationVerbosity = "normal"
    Set settings.aiProviderEnabled = 0
    Set settings.aiSummaryEnabled = 0
    Set settings.aiProvider = "openai"
    Set settings.aiModel = "gpt-4o-mini"
    Set settings.aiEndpoint = "https://api.openai.com/v1/chat/completions"
    Set settings.ragRuntimeDataEnabled = 0
    Set settings.ragRuntimeLookbackHours = 24
    Set settings.ragRuntimeMaxMessages = 100
    Set settings.ragRuntimeMaxLogs = 100
    Set settings.ragPayloadIndexingEnabled = 0
    Set settings.ragPayloadMaxFields = 50
    Set settings.aiApiKeyConfigured = (..EnvironmentOpenAIKey() '= "")
    Set settings.aiApiKeySource = $Select(settings.aiApiKeyConfigured:"environment",1:"none")
    return settings
}

ClassMethod Current() As %DynamicObject
{
    Set settings = ..Defaults()
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT TOP 1 RuntimeMessageAnalysisEnabled, PayloadInspectionEnabled, PayloadMetadataEnabled, RequestSessionAnalysisEnabled, RequestTraceAnalysisEnabled, MessageResendEnabled, MaxMessagesReturned, MaxTraceDepth, DefaultMessageLookbackDays, FieldRedactionPatterns, ClassExclusions, ProductionExclusions, SourceCodeInferenceEnabled, ExplanationVerbosity, AIProviderEnabled, AISummaryEnabled, AIProvider, AIModel, AIEndpoint, OpenAIApiKey, RAGRuntimeDataEnabled, RAGRuntimeLookbackHours, RAGRuntimeMaxMessages, RAGRuntimeMaxLogs, RAGPayloadIndexingEnabled, RAGPayloadMaxFields FROM esh_interoperability_aid_config.Settings ORDER BY ID"
    Set sc = stmt.%Prepare(sql)
    If $$$ISERR(sc) {
        return settings
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return settings
    }
    If rset.%Next() {
        Set settings.runtimeMessageAnalysisEnabled = rset.%Get("RuntimeMessageAnalysisEnabled")
        Set settings.payloadInspectionEnabled = rset.%Get("PayloadInspectionEnabled")
        Set settings.payloadMetadataEnabled = rset.%Get("PayloadMetadataEnabled")
        Set settings.requestSessionAnalysisEnabled = rset.%Get("RequestSessionAnalysisEnabled")
        Set settings.requestTraceAnalysisEnabled = rset.%Get("RequestTraceAnalysisEnabled")
        Set settings.messageResendEnabled = rset.%Get("MessageResendEnabled")
        Set settings.maxMessagesReturned = rset.%Get("MaxMessagesReturned")
        Set settings.maxTraceDepth = rset.%Get("MaxTraceDepth")
        Set settings.defaultMessageLookbackDays = rset.%Get("DefaultMessageLookbackDays")
        Set settings.fieldRedactionPatterns = rset.%Get("FieldRedactionPatterns")
        Set settings.classExclusions = rset.%Get("ClassExclusions")
        Set settings.productionExclusions = rset.%Get("ProductionExclusions")
        Set settings.sourceCodeInferenceEnabled = rset.%Get("SourceCodeInferenceEnabled")
        Set settings.explanationVerbosity = rset.%Get("ExplanationVerbosity")
        Set settings.aiProviderEnabled = rset.%Get("AIProviderEnabled")
        Set settings.aiSummaryEnabled = rset.%Get("AISummaryEnabled")
        Set settings.aiProvider = rset.%Get("AIProvider")
        Set settings.aiModel = rset.%Get("AIModel")
        Set settings.aiEndpoint = rset.%Get("AIEndpoint")
        Set settings.ragRuntimeDataEnabled = rset.%Get("RAGRuntimeDataEnabled")
        Set settings.ragRuntimeLookbackHours = rset.%Get("RAGRuntimeLookbackHours")
        Set settings.ragRuntimeMaxMessages = rset.%Get("RAGRuntimeMaxMessages")
        Set settings.ragRuntimeMaxLogs = rset.%Get("RAGRuntimeMaxLogs")
        Set settings.ragPayloadIndexingEnabled = rset.%Get("RAGPayloadIndexingEnabled")
        Set settings.ragPayloadMaxFields = rset.%Get("RAGPayloadMaxFields")
        Set storedKeyConfigured = (rset.%Get("OpenAIApiKey") '= "")
        Set envKeyConfigured = (..EnvironmentOpenAIKey() '= "")
        Set settings.aiApiKeyConfigured = $Select(envKeyConfigured:1,storedKeyConfigured:1,1:0)
        Set settings.aiApiKeySource = $Select(envKeyConfigured:"environment",storedKeyConfigured:"settings",1:"none")
    }
    Do ..ApplyDefaultBounds(settings)
    return settings
}

ClassMethod UpdateFromPayload(payload As %DynamicObject) As %DynamicObject
{
    Set result = {}
    Set result.namespace = $Namespace
    Set result.changed = 0
    Set result.warnings = []
    Set result.evidence = []

    If '$IsObject(payload) {
        Do result.%Set("errorCode", "INVALID_SETTINGS_PAYLOAD")
        return result
    }

    Set before = ..Current()
    Set settings = ..OpenWritableSettings()
    If '$IsObject(settings) {
        Do result.%Set("errorCode", "SETTINGS_OPEN_FAILED")
        return result
    }

    If payload.%IsDefined("runtimeMessageAnalysisEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("runtimeMessageAnalysisEnabled"), before.runtimeMessageAnalysisEnabled)
        If value '= before.runtimeMessageAnalysisEnabled {
            Set result.changed = 1
        }
        Set settings.RuntimeMessageAnalysisEnabled = value
    }
    If payload.%IsDefined("payloadInspectionEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("payloadInspectionEnabled"), before.payloadInspectionEnabled)
        If value '= before.payloadInspectionEnabled {
            Set result.changed = 1
        }
        Set settings.PayloadInspectionEnabled = value
    }
    If payload.%IsDefined("payloadMetadataEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("payloadMetadataEnabled"), before.payloadMetadataEnabled)
        If value '= before.payloadMetadataEnabled {
            Set result.changed = 1
        }
        Set settings.PayloadMetadataEnabled = value
    }
    If payload.%IsDefined("requestSessionAnalysisEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("requestSessionAnalysisEnabled"), before.requestSessionAnalysisEnabled)
        If value '= before.requestSessionAnalysisEnabled {
            Set result.changed = 1
        }
        Set settings.RequestSessionAnalysisEnabled = value
    }
    If payload.%IsDefined("requestTraceAnalysisEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("requestTraceAnalysisEnabled"), before.requestTraceAnalysisEnabled)
        If value '= before.requestTraceAnalysisEnabled {
            Set result.changed = 1
        }
        Set settings.RequestTraceAnalysisEnabled = value
    }
    If payload.%IsDefined("messageResendEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("messageResendEnabled"), before.messageResendEnabled)
        If value '= before.messageResendEnabled {
            Set result.changed = 1
        }
        Set settings.MessageResendEnabled = value
    }
    If payload.%IsDefined("maxMessagesReturned") {
        Set value = ..NormalizeIntegerValue(payload.%Get("maxMessagesReturned"), before.maxMessagesReturned, 1, 500)
        If value '= before.maxMessagesReturned {
            Set result.changed = 1
        }
        Set settings.MaxMessagesReturned = value
    }
    If payload.%IsDefined("maxTraceDepth") {
        Set value = ..NormalizeIntegerValue(payload.%Get("maxTraceDepth"), before.maxTraceDepth, 1, 500)
        If value '= before.maxTraceDepth {
            Set result.changed = 1
        }
        Set settings.MaxTraceDepth = value
    }
    If payload.%IsDefined("defaultMessageLookbackDays") {
        Set value = ..NormalizeIntegerValue(payload.%Get("defaultMessageLookbackDays"), before.defaultMessageLookbackDays, 1, 365)
        If value '= before.defaultMessageLookbackDays {
            Set result.changed = 1
        }
        Set settings.DefaultMessageLookbackDays = value
    }
    If payload.%IsDefined("fieldRedactionPatterns") {
        Set value = ..NormalizeStringValue(payload.%Get("fieldRedactionPatterns"), 1000)
        If value '= before.fieldRedactionPatterns {
            Set result.changed = 1
        }
        Set settings.FieldRedactionPatterns = value
    }
    If payload.%IsDefined("classExclusions") {
        Set value = ..NormalizeStringValue(payload.%Get("classExclusions"), 1000)
        If value '= before.classExclusions {
            Set result.changed = 1
        }
        Set settings.ClassExclusions = value
    }
    If payload.%IsDefined("productionExclusions") {
        Set value = ..NormalizeStringValue(payload.%Get("productionExclusions"), 1000)
        If value '= before.productionExclusions {
            Set result.changed = 1
        }
        Set settings.ProductionExclusions = value
    }
    If payload.%IsDefined("sourceCodeInferenceEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("sourceCodeInferenceEnabled"), before.sourceCodeInferenceEnabled)
        If value '= before.sourceCodeInferenceEnabled {
            Set result.changed = 1
        }
        Set settings.SourceCodeInferenceEnabled = value
    }
    If payload.%IsDefined("explanationVerbosity") {
        Set value = ..NormalizeVerbosityValue(payload.%Get("explanationVerbosity"), before.explanationVerbosity)
        If value '= before.explanationVerbosity {
            Set result.changed = 1
        }
        Set settings.ExplanationVerbosity = value
    }
    If payload.%IsDefined("aiProviderEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("aiProviderEnabled"), before.aiProviderEnabled)
        If value '= before.aiProviderEnabled {
            Set result.changed = 1
        }
        Set settings.AIProviderEnabled = value
    }
    If payload.%IsDefined("aiSummaryEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("aiSummaryEnabled"), before.aiSummaryEnabled)
        If value '= before.aiSummaryEnabled {
            Set result.changed = 1
        }
        Set settings.AISummaryEnabled = value
    }
    If payload.%IsDefined("aiProvider") {
        Set value = ..NormalizeAIProviderValue(payload.%Get("aiProvider"), before.aiProvider)
        If value '= before.aiProvider {
            Set result.changed = 1
        }
        Set settings.AIProvider = value
    }
    If payload.%IsDefined("aiModel") {
        Set value = ..NormalizeStringValue(payload.%Get("aiModel"), 100)
        If value = "" {
            Set value = before.aiModel
        }
        If value '= before.aiModel {
            Set result.changed = 1
        }
        Set settings.AIModel = value
    }
    If payload.%IsDefined("aiEndpoint") {
        Set value = ..NormalizeStringValue(payload.%Get("aiEndpoint"), 500)
        If value = "" {
            Set value = before.aiEndpoint
        }
        If value '= before.aiEndpoint {
            Set result.changed = 1
        }
        Set settings.AIEndpoint = value
    }
    If payload.%IsDefined("ragRuntimeDataEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("ragRuntimeDataEnabled"), before.ragRuntimeDataEnabled)
        If value '= before.ragRuntimeDataEnabled {
            Set result.changed = 1
        }
        Set settings.RAGRuntimeDataEnabled = value
    }
    If payload.%IsDefined("ragRuntimeLookbackHours") {
        Set value = ..NormalizeIntegerValue(payload.%Get("ragRuntimeLookbackHours"), before.ragRuntimeLookbackHours, 1, 720)
        If value '= before.ragRuntimeLookbackHours {
            Set result.changed = 1
        }
        Set settings.RAGRuntimeLookbackHours = value
    }
    If payload.%IsDefined("ragRuntimeMaxMessages") {
        Set value = ..NormalizeIntegerValue(payload.%Get("ragRuntimeMaxMessages"), before.ragRuntimeMaxMessages, 0, 1000)
        If value '= before.ragRuntimeMaxMessages {
            Set result.changed = 1
        }
        Set settings.RAGRuntimeMaxMessages = value
    }
    If payload.%IsDefined("ragRuntimeMaxLogs") {
        Set value = ..NormalizeIntegerValue(payload.%Get("ragRuntimeMaxLogs"), before.ragRuntimeMaxLogs, 0, 1000)
        If value '= before.ragRuntimeMaxLogs {
            Set result.changed = 1
        }
        Set settings.RAGRuntimeMaxLogs = value
    }
    If payload.%IsDefined("ragPayloadIndexingEnabled") {
        Set value = ..NormalizeBooleanValue(payload.%Get("ragPayloadIndexingEnabled"), before.ragPayloadIndexingEnabled)
        If value '= before.ragPayloadIndexingEnabled {
            Set result.changed = 1
        }
        Set settings.RAGPayloadIndexingEnabled = value
    }
    If payload.%IsDefined("ragPayloadMaxFields") {
        Set value = ..NormalizeIntegerValue(payload.%Get("ragPayloadMaxFields"), before.ragPayloadMaxFields, 1, 200)
        If value '= before.ragPayloadMaxFields {
            Set result.changed = 1
        }
        Set settings.RAGPayloadMaxFields = value
    }
    If payload.%IsDefined("openAIApiKey") {
        Set value = ..NormalizeStringValue(payload.%Get("openAIApiKey"), 500)
        If value '= "" {
            Set result.changed = 1
            Set settings.OpenAIApiKey = value
        }
    }
    If payload.%IsDefined("clearOpenAIApiKey") {
        Set value = ..NormalizeBooleanValue(payload.%Get("clearOpenAIApiKey"), 0)
        If value {
            Set result.changed = 1
            Set settings.OpenAIApiKey = ""
        }
    }

    Set sc = settings.%Save()
    If $$$ISERR(sc) {
        Do result.%Set("errorCode", "STATUS_ERROR")
        Do result.%Set("statusText", $System.Status.GetErrorText(sc))
        return result
    }

    Set result.settings = ..Current()
    Do result.evidence.%Push(..NewEvidence("module-settings", "esh.interoperability.aid.config.Settings", "current", "settings", "Runtime analysis limits and feature flags", "confirmed"))
    return result
}

ClassMethod ApplyDefaultBounds(settings As %DynamicObject) [ Private ]
{
    If settings.maxMessagesReturned < 1 {
        Set settings.maxMessagesReturned = 100
    }
    If settings.maxTraceDepth < 1 {
        Set settings.maxTraceDepth = 50
    }
    If settings.defaultMessageLookbackDays < 1 {
        Set settings.defaultMessageLookbackDays = 7
    }
    If settings.messageResendEnabled = "" {
        Set settings.messageResendEnabled = 0
    }
    If settings.payloadMetadataEnabled = "" {
        Set settings.payloadMetadataEnabled = 1
    }
    If settings.requestSessionAnalysisEnabled = "" {
        Set settings.requestSessionAnalysisEnabled = 0
    }
    If settings.requestTraceAnalysisEnabled = "" {
        Set settings.requestTraceAnalysisEnabled = 0
    }
    If settings.explanationVerbosity = "" {
        Set settings.explanationVerbosity = "normal"
    }
    If settings.aiProvider = "" {
        Set settings.aiProvider = "openai"
    }
    If settings.aiModel = "" {
        Set settings.aiModel = "gpt-4o-mini"
    }
    If settings.aiEndpoint = "" {
        Set settings.aiEndpoint = "https://api.openai.com/v1/chat/completions"
    }
    If settings.aiSummaryEnabled = "" {
        Set settings.aiSummaryEnabled = 0
    }
    If settings.ragRuntimeDataEnabled = "" {
        Set settings.ragRuntimeDataEnabled = 0
    }
    If settings.ragRuntimeLookbackHours < 1 {
        Set settings.ragRuntimeLookbackHours = 24
    }
    If settings.ragRuntimeMaxMessages = "" {
        Set settings.ragRuntimeMaxMessages = 100
    }
    If settings.ragRuntimeMaxMessages < 0 {
        Set settings.ragRuntimeMaxMessages = 0
    }
    If settings.ragRuntimeMaxLogs = "" {
        Set settings.ragRuntimeMaxLogs = 100
    }
    If settings.ragRuntimeMaxLogs < 0 {
        Set settings.ragRuntimeMaxLogs = 0
    }
    If settings.ragPayloadIndexingEnabled = "" {
        Set settings.ragPayloadIndexingEnabled = 0
    }
    If settings.ragPayloadMaxFields < 1 {
        Set settings.ragPayloadMaxFields = 50
    }
    If settings.aiApiKeyConfigured = "" {
        Set envKeyConfigured = (..EnvironmentOpenAIKey() '= "")
        Set settings.aiApiKeyConfigured = envKeyConfigured
        Set settings.aiApiKeySource = $Select(envKeyConfigured:"environment",1:"none")
    }
    return
}

ClassMethod OpenWritableSettings() As esh.interoperability.aid.config.Settings [ Private ]
{
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TOP 1 ID FROM esh_interoperability_aid_config.Settings ORDER BY ID")
    If $$$ISERR(sc) {
        return ""
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ""
    }
    If rset.%Next() {
        return ..%OpenId(rset.%Get("ID"))
    }
    return ..%New()
}

ClassMethod NormalizeBooleanValue(value, defaultValue As %Boolean = 0) As %Boolean [ Private ]
{
    Set normalized = $ZConvert(value, "L")
    If (normalized = "true") || (normalized = "1") || (normalized = "yes") {
        return 1
    }
    If (normalized = "false") || (normalized = "0") || (normalized = "no") {
        return 0
    }
    return +defaultValue
}

ClassMethod NormalizeIntegerValue(value, defaultValue As %Integer, minimum As %Integer, maximum As %Integer) As %Integer [ Private ]
{
    Set normalized = +value
    If normalized < minimum {
        return minimum
    }
    If normalized > maximum {
        return maximum
    }
    return normalized
}

ClassMethod NormalizeStringValue(value, maxLength As %Integer = 1000) As %VarString [ Private ]
{
    Set normalized = value
    If $Length(normalized) > maxLength {
        Set normalized = $Extract(normalized, 1, maxLength)
    }
    return normalized
}

ClassMethod NormalizeVerbosityValue(value, defaultValue As %VarString = "normal") As %VarString [ Private ]
{
    Set normalized = $ZConvert(value, "L")
    If (normalized = "brief") || (normalized = "normal") || (normalized = "detailed") {
        return normalized
    }
    return defaultValue
}

ClassMethod NormalizeAIProviderValue(value, defaultValue As %VarString = "openai") As %VarString [ Private ]
{
    Set normalized = $ZConvert(value, "L")
    If normalized = "openai" {
        return normalized
    }
    return defaultValue
}

ClassMethod EnvironmentOpenAIKey() As %VarString
{
    return $System.Util.GetEnviron("OPENAI_API_KEY")
}

ClassMethod EffectiveOpenAIKey() As %VarString
{
    Set envKey = ..EnvironmentOpenAIKey()
    If envKey '= "" {
        return envKey
    }
    Set stmt = ##class(%SQL.Statement).%New()
    Set sc = stmt.%Prepare("SELECT TOP 1 OpenAIApiKey FROM esh_interoperability_aid_config.Settings ORDER BY ID")
    If $$$ISERR(sc) {
        return ""
    }
    Set rset = stmt.%Execute()
    If rset.%SQLCODE < 0 {
        return ""
    }
    If rset.%Next() {
        return rset.%Get("OpenAIApiKey")
    }
    return ""
}

ClassMethod NewEvidence(evidenceType As %VarString, source As %VarString, component As %VarString, field As %VarString, value As %VarString, confidence As %VarString) As %DynamicObject [ Private ]
{
    Set evidence = {}
    Set evidence.type = evidenceType
    Set evidence.source = source
    Set evidence.component = component
    Set evidence.field = field
    Set evidence.value = value
    Set evidence.confidence = confidence
    return evidence
}

ClassMethod NewWarning(code As %VarString, message As %VarString) As %DynamicObject [ Private ]
{
    Set warning = {}
    Set warning.code = code
    Set warning.message = message
    return warning
}

Storage Default
{
<Data name="SettingsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RuntimeMessageAnalysisEnabled</Value>
</Value>
<Value name="3">
<Value>PayloadInspectionEnabled</Value>
</Value>
<Value name="4">
<Value>MaxMessagesReturned</Value>
</Value>
<Value name="5">
<Value>MaxTraceDepth</Value>
</Value>
<Value name="6">
<Value>DefaultMessageLookbackDays</Value>
</Value>
<Value name="7">
<Value>FieldRedactionPatterns</Value>
</Value>
<Value name="8">
<Value>ClassExclusions</Value>
</Value>
<Value name="9">
<Value>ProductionExclusions</Value>
</Value>
<Value name="10">
<Value>SourceCodeInferenceEnabled</Value>
</Value>
<Value name="11">
<Value>ExplanationVerbosity</Value>
</Value>
<Value name="12">
<Value>AIProviderEnabled</Value>
</Value>
<Value name="13">
<Value>MessageResendEnabled</Value>
</Value>
<Value name="14">
<Value>AISummaryEnabled</Value>
</Value>
<Value name="15">
<Value>AIProvider</Value>
</Value>
<Value name="16">
<Value>AIModel</Value>
</Value>
<Value name="17">
<Value>AIEndpoint</Value>
</Value>
<Value name="18">
<Value>OpenAIApiKey</Value>
</Value>
<Value name="19">
<Value>PayloadMetadataEnabled</Value>
</Value>
<Value name="20">
<Value>RAGRuntimeDataEnabled</Value>
</Value>
<Value name="21">
<Value>RAGRuntimeLookbackHours</Value>
</Value>
<Value name="22">
<Value>RAGRuntimeMaxMessages</Value>
</Value>
<Value name="23">
<Value>RAGRuntimeMaxLogs</Value>
</Value>
<Value name="24">
<Value>RAGPayloadIndexingEnabled</Value>
</Value>
<Value name="25">
<Value>RAGPayloadMaxFields</Value>
</Value>
</Data>
<DataLocation>^esh.interoperabilCC6D.SettingsD</DataLocation>
<DefaultData>SettingsDefaultData</DefaultData>
<IdLocation>^esh.interoperabilCC6D.SettingsD</IdLocation>
<IndexLocation>^esh.interoperabilCC6D.SettingsI</IndexLocation>
<StreamLocation>^esh.interoperabilCC6D.SettingsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
