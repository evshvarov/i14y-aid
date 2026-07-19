# IRIS Interoperability Production Explainer

`esh-i14y-aid` is an installable InterSystems IRIS module that exposes a REST API for deterministic analysis of interoperability productions in the current namespace.

## How to use

Please install it as an IPM package on any of your IRIS system which has interoperability productions.
It will expose the api endpoint at /i14y-aid/api
Don't use your production system for it as this endpoint exposes all the interoperability productions. use only test/dev environment.

Point the UI project https://iris-prod-explorer.lovable.app/ to this dev/test system.
Make all the necessary settings:
<img width="737" height="808" alt="Screenshot 2026-07-19 at 16 16 39" src="https://github.com/user-attachments/assets/3bbd6a3d-a3f6-4b26-9b9e-865cff635724" />
<img width="683" height="701" alt="Screenshot 2026-07-19 at 16 16 49" src="https://github.com/user-attachments/assets/105fd25a-bb6b-427b-bea3-0ed368b9bf37" />

it will show the productions which you can start if you want:
<img width="1089" height="468" alt="Screenshot 2026-07-19 at 16 17 56" src="https://github.com/user-attachments/assets/6b83ed78-aab2-4a61-b39d-4e3836479735" />

And explore then also using the AI assistent about the production you are interested in.

## Features
The first implementation increment supports:

- module health and capabilities;
- discovery of interoperability productions;
- production metadata lookup;
- component extraction from production `XData ProductionDefinition`, with fallback support for `XData Production`;
- component classification as business service, business process, business operation, or unknown;
- target extraction from `TargetConfigNames`;
- adapter and likely protocol extraction where the component exposes an `ADAPTER` parameter;
- runtime production status with local start/stop controls;
- static analysis model with component connections, external endpoint settings, and analysis artifacts;
- static message signature extraction from compiled service, process, and operation handler methods;
- routing-rule detail extraction for accessible `RuleDefinition` XData;
- DTL transformation summary extraction for accessible `DTL` XData;
- BPL process summary extraction for accessible `BPL` XData;
- API-managed module analysis settings for runtime message limits and feature flags;
- recent interoperability message header listing, production-scoped session trace reconstruction, deterministic trace explanations, and safe payload metadata;
- safe payload metadata reporting and optional redacted scalar payload preview when enabled in settings;
- settings-gated production-scoped message resend through `Ens.MessageHeader.ResendMessage` when available;
- deterministic component-level explanations with evidence and confidence;
- deterministic production summaries;
- optional OpenAI-assisted production summaries, gated by module settings and server-side key configuration;
- Swagger 2.0 API documentation at `/_spec`.

The module does not deploy or modify analysed production definitions. Local production start/stop is available through explicit REST endpoints for the current namespace.

## Package Layout

- `esh.interoperability.aid.api.*` - REST implementation, Swagger spec, and security setup.
- `esh.interoperability.aid.service.*` - deterministic production discovery and component extraction.
- `esh.interoperability.aid.config.*` - module configuration defaults.
- `esh.interoperability.aid.tests.*` - unit tests and a minimal demo production.

## REST API

The ZPM module creates a CSP application:

```text
/i14y-aid/api
```

Implemented endpoints:

```text
GET /i14y-aid/api/_spec
GET /i14y-aid/api/health
GET /i14y-aid/api/capabilities
GET /i14y-aid/api/codes
GET /i14y-aid/api/settings
PUT /i14y-aid/api/settings
GET /i14y-aid/api/messages
GET /i14y-aid/api/messages/facets
GET /i14y-aid/api/logs
GET /i14y-aid/api/messages/{messageId}
GET /i14y-aid/api/messages/{messageId}/payload
GET /i14y-aid/api/messages/{messageId}/payload/preview
GET /i14y-aid/api/messages/{messageId}/trace
GET /i14y-aid/api/messages/{messageId}/explanation
GET /i14y-aid/api/productions
GET /i14y-aid/api/productions/{productionName}
GET /i14y-aid/api/productions/{productionName}/components
GET /i14y-aid/api/productions/{productionName}/components/{componentName}
GET /i14y-aid/api/productions/{productionName}/analysis
GET /i14y-aid/api/productions/{productionName}/summary
POST /i14y-aid/api/productions/{productionName}/ai/summary
GET /i14y-aid/api/productions/{productionName}/rag/context
GET /i14y-aid/api/productions/{productionName}/rag/index
POST /i14y-aid/api/productions/{productionName}/rag/index
GET /i14y-aid/api/productions/{productionName}/rag/chunks
GET /i14y-aid/api/productions/{productionName}/rag/search
POST /i14y-aid/api/productions/{productionName}/ai/ask
GET /i14y-aid/api/productions/{productionName}/graph
GET /i14y-aid/api/productions/{productionName}/status
GET /i14y-aid/api/productions/{productionName}/logs
GET /i14y-aid/api/productions/{productionName}/messages
GET /i14y-aid/api/productions/{productionName}/messages/facets
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/payload
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/payload/preview
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/trace
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/session
GET /i14y-aid/api/productions/{productionName}/sessions/{sessionId}/timeline
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/explanation
POST /i14y-aid/api/productions/{productionName}/messages/{messageId}/resend
POST /i14y-aid/api/productions/{productionName}/start
POST /i14y-aid/api/productions/{productionName}/stop
```

Example:

```sh
curl http://localhost:57337/i14y-aid/api/health
curl http://localhost:57337/i14y-aid/api/capabilities
curl http://localhost:57337/i14y-aid/api/codes
curl http://localhost:57337/i14y-aid/api/settings
curl -X PUT http://localhost:57337/i14y-aid/api/settings -H "Content-Type: application/json" -d '{"maxTraceDepth":25,"explanationVerbosity":"brief"}'
curl "http://localhost:57337/i14y-aid/api/messages?limit=10"
curl "http://localhost:57337/i14y-aid/api/logs?limit=10"
curl "http://localhost:57337/i14y-aid/api/messages/1/payload"
curl "http://localhost:57337/i14y-aid/api/messages/1/payload/preview"
curl http://localhost:57337/i14y-aid/api/productions
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/components"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/analysis"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/summary"
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/ai/summary"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/context?question=routing%20Patient%20Router&componentName=Patient%20Router&maxChunks=8"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/index"
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/index"
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/index" -H "Content-Type: application/json" -d '{"includeRuntime":true,"includePayload":true,"lookbackHours":24,"maxMessages":100,"maxLogs":100,"maxPayloadFields":50}'
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/chunks?limit=10&kind=component"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/chunks?limit=10&kind=message-schema"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/search?question=routing%20Patient%20Router&componentName=Patient%20Router&maxChunks=8"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/rag/search?question=what%20payload%20fields%20does%20DemoMessage%20move&maxChunks=8"
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/ai/ask" -H "Content-Type: application/json" -d '{"question":"Why does this production route messages?","componentName":"Patient Router","maxChunks":8}'
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/graph"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/logs?limit=10"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/logs?limit=10&type=Error"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages?limit=10"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages?limit=10&status=Completed"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/facets?limit=100"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/trace"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/session"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/payload/preview"
```

AI summaries are disabled by default. To enable them, turn on `aiProviderEnabled` and `aiSummaryEnabled` through `PUT /i14y-aid/api/settings` or the UI settings panel. The OpenAI API key can be supplied through the IRIS process environment as `OPENAI_API_KEY`, or saved from the UI settings panel. The settings API reports only `aiApiKeyConfigured` and `aiApiKeySource`; it never returns the stored key value.

AI ask uses deterministic retrieval over production analysis chunks. When a persisted RAG index exists, AI ask uses that index; otherwise it builds transient chunks for the request. The response includes the retrieved chunks, validated answer citations, invalid citation ids, uncited chunk ids, and evidence used to ground the answer.

Runtime RAG is off by default. Enable it with `ragRuntimeDataEnabled` in settings or pass `includeRuntime: true` to `POST /i14y-aid/api/productions/{productionName}/rag/index`. Runtime indexing adds recent message header chunks and production log chunks. Payload indexing is separately opt-in with `ragPayloadIndexingEnabled` or `includePayload: true`, requires payload inspection to be enabled, and indexes only redacted scalar payload preview fields. Full payload object graphs are not indexed. Runtime bounds can be controlled with `lookbackHours`, `startDate`, `endDate`, `maxMessages`, `maxLogs`, and `maxPayloadFields`.

Static RAG indexing also creates metadata-only `message-schema` chunks for discovered message body classes. These chunks come from `%Dictionary.CompiledProperty` and include class names, field names, field types, scalar/object/collection classification, and source components inferred from message signatures, DTL transformations, and BPL processes. They never include live payload values. Rebuild the index, then call `GET /i14y-aid/api/productions/{productionName}/rag/chunks?kind=message-schema` to inspect schema-based evidence. Frontends can show a "schema-based" hint whenever retrieved chunks have `kind=message-schema`.

Message APIs return both raw IRIS status codes and readable `statusLabel` values. The `status` query filter accepts either value, such as `status=9` or `status=Completed`. Message facets include `statusNames` and structured `statusFacets`. Frontends can also call `GET /i14y-aid/api/codes` to load the mappings dynamically.

Message status labels:

```text
1 Created
2 Queued
3 Delivered
4 Discarded
5 Suspended
6 Deferred
7 Aborted
8 Error
9 Completed
```

Log APIs return raw IRIS log `type` values and readable `typeLabel` values. The `type` query filter accepts either value, such as `type=2` or `type=Error`. Log responses include structured `typeFacets`. Frontends can also call `GET /i14y-aid/api/codes` to load the mappings dynamically.

Log type labels:

```text
1 Assert
2 Error
3 Warning
4 Info
5 Trace
6 Alert
```

## Build And Test

Build the container:

```sh
docker compose build --progress=plain
```

Run tests during build:

```sh
docker compose build --build-arg TESTS=1 --progress=plain
```

Start IRIS:

```sh
docker compose up -d
```

Run tests from an IRIS terminal:

```objectscript
zpm "test esh-i14y-aid -v -only"
```

## Demo Workflow

See [docs/demo.md](docs/demo.md) for an end-to-end walkthrough with the sample CSV production:

- install `esh-i14y-csv`;
- start the production;
- create a test CSV file in `/home/irisowner/irisdev/in/`;
- inspect production graph, component detail, runtime messages, trace, explanation, payload metadata, and optional redacted payload preview;
- use the optional `i14y-aid-ui` frontend.

## Current Scope

This version analyzes only the current namespace. It reads compiled class metadata, production XData, accessible routing-rule XData, accessible DTL XData, accessible BPL XData, interoperability message header metadata, settings-gated payload field metadata, and settings-gated scalar payload preview fields. Deeper BPL internals and full payload object graph inspection are intentionally deferred.

Payload bodies are not returned wholesale. When payload inspection and payload metadata are enabled, the metadata endpoint returns field names and types without values. The preview endpoint opens the stored body object and returns scalar fields only, applying configured redaction patterns.
