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

}
