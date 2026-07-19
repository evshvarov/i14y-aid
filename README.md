# IRIS Interoperability Production Explainer

`esh-i14y-aid` is an installable InterSystems IRIS module that exposes a REST API for deterministic analysis of interoperability productions in the current namespace.

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
GET /i14y-aid/api/productions/{productionName}/messages/{messageId}/explanation
POST /i14y-aid/api/productions/{productionName}/messages/{messageId}/resend
POST /i14y-aid/api/productions/{productionName}/start
POST /i14y-aid/api/productions/{productionName}/stop
```

Example:

```sh
curl http://localhost:57337/i14y-aid/api/health
curl http://localhost:57337/i14y-aid/api/capabilities
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
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/ai/ask" -H "Content-Type: application/json" -d '{"question":"Why does this production route messages?","componentName":"Patient Router","maxChunks":8}'
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/graph"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/logs?limit=10"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages?limit=10"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/facets?limit=100"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/trace"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/session"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/messages/1/payload/preview"
```

AI summaries are disabled by default. To enable them, turn on `aiProviderEnabled` and `aiSummaryEnabled` through `PUT /i14y-aid/api/settings` or the UI settings panel. The OpenAI API key can be supplied through the IRIS process environment as `OPENAI_API_KEY`, or saved from the UI settings panel. The settings API reports only `aiApiKeyConfigured` and `aiApiKeySource`; it never returns the stored key value.

AI ask uses deterministic retrieval over production analysis chunks. The response includes the retrieved chunks and evidence used to ground the answer.

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
