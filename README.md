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
- Swagger 2.0 API documentation at `/_spec`.

The module does not start, stop, modify, or deploy analysed productions.

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
GET /i14y-aid/api/productions
GET /i14y-aid/api/productions/{productionName}
GET /i14y-aid/api/productions/{productionName}/components
```

Example:

```sh
curl http://localhost:57337/i14y-aid/api/health
curl http://localhost:57337/i14y-aid/api/productions
curl "http://localhost:57337/i14y-aid/api/productions/esh.interoperability.aid.tests.DemoProduction/components"
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

This version analyzes only the current namespace. It reads compiled class metadata and production XData. Runtime message trace analysis, DTL/rule/BPL analysis, graph construction, and payload inspection are intentionally deferred.

Message bodies are not read or returned by this increment.
