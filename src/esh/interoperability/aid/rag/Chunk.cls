Class esh.interoperability.aid.rag.Chunk Extends %Persistent
{

Property Namespace As %VarString;

Property ProductionName As %VarString(MAXLEN = 500);

Property RunId As %Integer;

Property ChunkId As %VarString(MAXLEN = 500);

Property Kind As %VarString;

Property Title As %VarString(MAXLEN = 500);

Property Source As %VarString(MAXLEN = 500);

Property Component As %VarString(MAXLEN = 500);

Property Confidence As %VarString;

Property Score As %Integer;

Property Text As %Stream.GlobalCharacter;

Property EvidenceJSON As %Stream.GlobalCharacter;

Property CreatedAt As %TimeStamp;

Index ProductionIndex On (Namespace, ProductionName, RunId);

Index ChunkIdIndex On ChunkId;

Storage Default
{
<Data name="ChunkDefaultData">
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
<Value>RunId</Value>
</Value>
<Value name="5">
<Value>ChunkId</Value>
</Value>
<Value name="6">
<Value>Kind</Value>
</Value>
<Value name="7">
<Value>Title</Value>
</Value>
<Value name="8">
<Value>Source</Value>
</Value>
<Value name="9">
<Value>Component</Value>
</Value>
<Value name="10">
<Value>Confidence</Value>
</Value>
<Value name="11">
<Value>Score</Value>
</Value>
<Value name="12">
<Value>Text</Value>
</Value>
<Value name="13">
<Value>EvidenceJSON</Value>
</Value>
<Value name="14">
<Value>CreatedAt</Value>
</Value>
</Data>
<DataLocation>^esh.interoperability9A46.ChunkD</DataLocation>
<DefaultData>ChunkDefaultData</DefaultData>
<IdLocation>^esh.interoperability9A46.ChunkD</IdLocation>
<IndexLocation>^esh.interoperability9A46.ChunkI</IndexLocation>
<StreamLocation>^esh.interoperability9A46.ChunkS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
