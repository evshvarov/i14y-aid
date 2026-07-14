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
- read-only module analysis settings with runtime message limits and feature flags;
- recent interoperability message header listing, session trace reconstruction, and deterministic trace explanations without returning payload bodies;
- deterministic component-level explanations with evidence and confidence;
- deterministic production summaries;
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
GET /i14y-aid/api/settings
GET /i14y-aid/api/messages
GET /i14y-aid/api/messages/facets
GET /i14y-aid/api/messages/{messageId}
GET /i14y-aid/api/messages/{messageId}/trace
GET /i14y-aid/api/productions
GET /i14y-aid/api/productions/{productionName}
GET /i14y-aid/api/productions/{productionName}/components
GET /i14y-aid/api/productions/{productionName}/components/{componentName}
GET /i14y-aid/api/productions/{productionName}/analysis
GET /i14y-aid/api/productions/{productionName}/summary
GET /i14y-aid/api/productions/{productionName}/graph
GET /i14y-aid/api/productions/{productionName}/status
POST /i14y-aid/api/productions/{productionName}/start
POST /i14y-aid/api/productions/{productionName}/stop
```

Example:

```sh
curl http://localhost:57337/i14y-aid/api/health
curl http://localhost:57337/i14y-aid/api/settings
curl "http://localhost:57337/i14y-aid/api/messages?limit=10"
curl http://localhost:57337/i14y-aid/api/productions
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/components"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/analysis"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/summary"
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/graph"
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

## Current Scope

This version analyzes only the current namespace. It reads compiled class metadata, production XData, accessible routing-rule XData, accessible DTL XData, accessible BPL XData, and interoperability message header metadata. Deeper BPL internals and payload inspection are intentionally deferred.

Message bodies are not read or returned by this increment.
