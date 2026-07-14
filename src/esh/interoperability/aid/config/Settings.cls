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
