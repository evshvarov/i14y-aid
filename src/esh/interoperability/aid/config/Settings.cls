Class esh.interoperability.aid.config.Settings Extends %Persistent
{

Property RuntimeMessageAnalysisEnabled As %Boolean [ InitialExpression = 1 ];

Property PayloadInspectionEnabled As %Boolean [ InitialExpression = 0 ];

Property MaxMessagesReturned As %Integer [ InitialExpression = 100 ];

Property MaxTraceDepth As %Integer [ InitialExpression = 50 ];

Property DefaultMessageLookbackDays As %Integer [ InitialExpression = 7 ];

Property FieldRedactionPatterns As %VarString(MAXLEN = 1000) [ InitialExpression = "patient,ssn,mrn,dob,address,phone,email" ];

Property ClassExclusions As %VarString(MAXLEN = 1000);

Property ProductionExclusions As %VarString(MAXLEN = 1000);

Property SourceCodeInferenceEnabled As %Boolean [ InitialExpression = 0 ];

Property ExplanationVerbosity As %VarString [ InitialExpression = "normal" ];

Property AIProviderEnabled As %Boolean [ InitialExpression = 0 ];

ClassMethod Defaults() As %DynamicObject
{
    Set settings = {}
    Set settings.runtimeMessageAnalysisEnabled = 1
    Set settings.payloadInspectionEnabled = 0
    Set settings.maxMessagesReturned = 100
    Set settings.maxTraceDepth = 50
    Set settings.defaultMessageLookbackDays = 7
    Set settings.fieldRedactionPatterns = "patient,ssn,mrn,dob,address,phone,email"
    Set settings.classExclusions = ""
    Set settings.productionExclusions = ""
    Set settings.sourceCodeInferenceEnabled = 0
    Set settings.explanationVerbosity = "normal"
    Set settings.aiProviderEnabled = 0
    return settings
}

ClassMethod Current() As %DynamicObject
{
    Set settings = ..Defaults()
    Set stmt = ##class(%SQL.Statement).%New()
    Set sql = "SELECT TOP 1 RuntimeMessageAnalysisEnabled, PayloadInspectionEnabled, MaxMessagesReturned, MaxTraceDepth, DefaultMessageLookbackDays, FieldRedactionPatterns, ClassExclusions, ProductionExclusions, SourceCodeInferenceEnabled, ExplanationVerbosity, AIProviderEnabled FROM esh_interoperability_aid_config.Settings ORDER BY ID"
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
        Set settings.maxMessagesReturned = rset.%Get("MaxMessagesReturned")
        Set settings.maxTraceDepth = rset.%Get("MaxTraceDepth")
        Set settings.defaultMessageLookbackDays = rset.%Get("DefaultMessageLookbackDays")
        Set settings.fieldRedactionPatterns = rset.%Get("FieldRedactionPatterns")
        Set settings.classExclusions = rset.%Get("ClassExclusions")
        Set settings.productionExclusions = rset.%Get("ProductionExclusions")
        Set settings.sourceCodeInferenceEnabled = rset.%Get("SourceCodeInferenceEnabled")
        Set settings.explanationVerbosity = rset.%Get("ExplanationVerbosity")
        Set settings.aiProviderEnabled = rset.%Get("AIProviderEnabled")
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
        If value {
            Do result.warnings.%Push(..NewWarning("PAYLOAD_INSPECTION_UNSUPPORTED", "Payload inspection can be enabled in settings, but payload body inspection is not implemented in this version."))
        }
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
    If settings.explanationVerbosity = "" {
        Set settings.explanationVerbosity = "normal"
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
</Data>
<DataLocation>^esh.interoperabilCC6D.SettingsD</DataLocation>
<DefaultData>SettingsDefaultData</DefaultData>
<IdLocation>^esh.interoperabilCC6D.SettingsD</IdLocation>
<IndexLocation>^esh.interoperabilCC6D.SettingsI</IndexLocation>
<StreamLocation>^esh.interoperabilCC6D.SettingsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
