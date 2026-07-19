Class esh.interoperability.aid.rag.IndexRun Extends %Persistent
{

Property Namespace As %VarString;

Property ProductionName As %VarString(MAXLEN = 500);

Property RunTimestamp As %TimeStamp;

Property ChunkCount As %Integer;

Property Status As %VarString;

Property StatusText As %VarString(MAXLEN = 1000);

Index ProductionNameIndex On (Namespace, ProductionName, RunTimestamp);

Storage Default
{
<Data name="IndexRunDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Namespace</Value>
</Value>
<Value name="3">
<Value>ProductionName</Value>
</Value>
<Value name="4">
<Value>RunTimestamp</Value>
</Value>
<Value name="5">
<Value>ChunkCount</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>StatusText</Value>
</Value>
</Data>
<DataLocation>^esh.interoperabil9A46.IndexRunD</DataLocation>
<DefaultData>IndexRunDefaultData</DefaultData>
<IdLocation>^esh.interoperabil9A46.IndexRunD</IdLocation>
<IndexLocation>^esh.interoperabil9A46.IndexRunI</IndexLocation>
<StreamLocation>^esh.interoperabil9A46.IndexRunS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
