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
    Set capabilities.runtimeTraceAnalysis = 0
    Set capabilities.payloadInspection = 0
    Set capabilities.openapiVersion = "2.0"
    return capabilities
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
    Set result.components = ..ListComponents(productionName).items
    Set result.componentCount = result.components.%Size()
    Set result.evidence = []
    Do result.evidence.%Push(..NewEvidence("class-metadata", "%Dictionary.CompiledClass", productionName, "Super", "Ens.Production", "confirmed"))
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
