This is what we discussed with CHAT.GPT

# Build an InterSystems IRIS Interoperability Production Explainer

## Objective

Build an installable InterSystems IRIS / IRIS for Health module that analyses an interoperability production and exposes a structured explanation of:

* what the production does;
* which business services, business processes, and business operations it contains;
* how components connect to each other;
* which messages are received, created, transformed, routed, and sent;
* which external systems and protocols are involved;
* what happened to a selected runtime message;
* which conclusions are confirmed, observed, inferred, or unknown.

The backend must expose its functionality through a documented REST API with an OpenAPI specification. The user interface may be developed separately using a frontend-focused tool, so avoid tightly coupling the backend to a particular UI framework.

## Product concept

The product should allow a user to select an IRIS namespace and interoperability production and receive a human-readable explanation such as:

> This production receives HL7 ADT messages over TCP, routes admission and discharge events through a patient-routing process, transforms selected messages into FHIR resources, and sends them to an external FHIR server.

For a selected runtime message, it should produce an explanation such as:

> This ADT^A01 message was received by the TrakCare HL7 service. The patient-routing process classified it as an inpatient admission, applied the ADT-to-FHIR transformation, and sent a Patient resource to the configured FHIR endpoint.

## Technical principles

1. Extract facts deterministically wherever possible.
2. Do not use an LLM as the primary source of architectural truth.
3. Build a structured intermediate representation of the production.
4. Keep explanations traceable to IRIS classes, configuration, rules, transformations, or message traces.
5. Clearly distinguish:

   * confirmed facts;
   * observed runtime behaviour;
   * inferred behaviour;
   * unknown or unsupported behaviour.
6. Design the backend as API-first.
7. Support IRIS and IRIS for Health without requiring a separate codebase.
8. Avoid modifying the analysed production.
9. Use read-only access for analysis unless explicitly required for module configuration.
10. Make the first version useful without requiring an external AI service.

## Initial scope

Implement an MVP that supports:

* discovering interoperability productions in the current namespace;
* reading a selected production definition;
* identifying enabled and disabled production items;
* identifying business services, business processes, and business operations;
* extracting component class names and configuration settings;
* identifying adapter classes and likely protocols;
* identifying configured target components;
* identifying request and response message classes;
* analysing standard routing rules where accessible;
* analysing DTL transformations where accessible;
* analysing BPL business processes where accessible;
* reading stored interoperability message headers;
* reconstructing the runtime path for a selected message;
* returning structured JSON;
* generating basic deterministic human-readable summaries;
* exposing all supported functions through REST endpoints;
* generating an OpenAPI 3 specification.

## Out of scope for the first version

Do not attempt to fully solve these areas in the MVP:

* perfect semantic understanding of arbitrary ObjectScript;
* automatic modification of productions;
* automated production deployment;
* full source-code security analysis;
* complete support for every legacy Ensemble pattern;
* unrestricted execution of dynamically discovered code;
* production-wide performance monitoring;
* a final polished frontend;
* sending production data to an external LLM.

Create extension points for these capabilities, but do not let them delay the MVP.

## Proposed architecture

Create the following logical layers.

### 1. Production discovery layer

Responsibilities:

* list productions in the active namespace;
* identify production class names;
* identify production state where available;
* return basic metadata.

Suggested service class:

`ProductionExplainer.Service.ProductionDiscovery`

### 2. Static analysis layer

Responsibilities:

* inspect a production definition;
* enumerate production items;
* classify each item as service, process, or operation;
* extract class name, item name, enabled state, pool size, settings, comments, and targets;
* inspect relevant class metadata;
* identify message classes and method signatures;
* identify adapters and transport protocols;
* identify routing rules, transformations, and BPL definitions;
* construct a graph of components and relationships.

Suggested service class:

`ProductionExplainer.Service.StaticAnalyzer`

### 3. Runtime trace analysis layer

Responsibilities:

* search recent interoperability messages;
* return message headers and summary metadata;
* load a selected message;
* identify related request and response messages;
* reconstruct the message path;
* identify component transitions;
* include timestamps, status, duration, errors, and responses;
* safely summarise payload metadata without exposing full payloads by default.

Suggested service class:

`ProductionExplainer.Service.TraceAnalyzer`

### 4. Intermediate representation

Create typed persistent or serializable model classes representing:

* production;
* component;
* connection;
* message type;
* transformation;
* rule;
* external endpoint;
* runtime trace;
* trace step;
* evidence;
* explanation;
* warning;
* confidence classification.

Suggested package:

`ProductionExplainer.Model`

Example conceptual model:

```json
{
  "production": {
    "name": "Hospital.Integration.Production",
    "namespace": "HOSPITAL",
    "summary": "Receives HL7 messages and routes them to clinical systems.",
    "components": [],
    "connections": [],
    "messageTypes": [],
    "externalSystems": [],
    "warnings": []
  }
}
```

### 5. Explanation layer

Generate deterministic explanations from the intermediate representation.

Responsibilities:

* produce a production-level summary;
* explain each component;
* explain each connection;
* explain each message type;
* explain a selected runtime trace;
* identify uncertainty;
* include supporting evidence references.

Suggested service class:

`ProductionExplainer.Service.ExplanationGenerator`

Example explanation object:

```json
{
  "text": "The ADT service receives HL7 messages over TCP and forwards them to the patient routing process.",
  "confidence": "confirmed",
  "evidence": [
    {
      "type": "production-setting",
      "source": "Hospital.Integration.Production",
      "component": "ADT Service",
      "field": "TargetConfigNames",
      "value": "Patient Routing Process"
    }
  ]
}
```

### 6. REST API layer

Create an API-first REST application.

Suggested package:

`ProductionExplainer.API`

The API must:

* return JSON;
* use consistent error responses;
* provide pagination for message searches;
* avoid returning sensitive message bodies by default;
* support configurable payload redaction;
* provide an OpenAPI 3 specification;
* avoid embedding UI-specific presentation logic.

## Suggested REST endpoints

### Health and metadata

`GET /api/explainer/v1/health`

Returns module health, version, namespace, and basic capability information.

`GET /api/explainer/v1/capabilities`

Returns supported analysis features for the current IRIS version and namespace.

### Productions

`GET /api/explainer/v1/productions`

Returns available interoperability productions.

`GET /api/explainer/v1/productions/{productionName}`

Returns production metadata.

`GET /api/explainer/v1/productions/{productionName}/analysis`

Returns the complete static analysis model.

`GET /api/explainer/v1/productions/{productionName}/summary`

Returns a deterministic plain-language production summary.

`GET /api/explainer/v1/productions/{productionName}/components`

Returns all production components.

`GET /api/explainer/v1/productions/{productionName}/components/{componentName}`

Returns detailed analysis and explanation of one component.

`GET /api/explainer/v1/productions/{productionName}/graph`

Returns nodes and edges suitable for rendering by a separate frontend.

### Messages and traces

`GET /api/explainer/v1/productions/{productionName}/messages`

Query parameters should include:

* `from`;
* `to`;
* `source`;
* `target`;
* `messageClass`;
* `status`;
* `limit`;
* `offset`.

`GET /api/explainer/v1/messages/{messageId}`

Returns safe message metadata. Do not return the full body unless specifically requested and authorised.

`GET /api/explainer/v1/messages/{messageId}/trace`

Returns the reconstructed runtime path.

`GET /api/explainer/v1/messages/{messageId}/explanation`

Returns a plain-language explanation of what happened to the selected message.

### OpenAPI

`GET /api/explainer/v1/openapi.json`

Returns the OpenAPI 3 document.

Optionally also expose:

`GET /api/explainer/v1/openapi.yaml`

## Graph response format

The graph endpoint should return frontend-neutral data.

Example:

```json
{
  "nodes": [
    {
      "id": "ADTService",
      "label": "ADT Service",
      "type": "business-service",
      "className": "Hospital.Service.ADT",
      "enabled": true,
      "protocol": "HL7 TCP"
    },
    {
      "id": "PatientRouter",
      "label": "Patient Router",
      "type": "business-process",
      "className": "Hospital.Process.PatientRouter",
      "enabled": true
    }
  ],
  "edges": [
    {
      "id": "ADTService-PatientRouter",
      "source": "ADTService",
      "target": "PatientRouter",
      "relationship": "sends",
      "messageTypes": [
        "EnsLib.HL7.Message"
      ],
      "confidence": "confirmed"
    }
  ]
}
```

## Confidence model

Use the following confidence values consistently:

* `confirmed`: directly present in production configuration, class metadata, rule definition, transformation definition, or explicit target configuration;
* `observed`: present in one or more runtime traces;
* `inferred`: derived from source-code inspection, naming, or indirect metadata;
* `unknown`: insufficient evidence.

Do not present inferred statements as confirmed facts.

## Evidence model

Every significant conclusion should support an evidence array.

Evidence types may include:

* `production-definition`;
* `production-setting`;
* `class-metadata`;
* `method-signature`;
* `routing-rule`;
* `dtl-transformation`;
* `bpl-process`;
* `runtime-message`;
* `runtime-trace`;
* `adapter-configuration`;
* `source-code-inference`.

Example:

```json
{
  "type": "runtime-trace",
  "source": "Ens.MessageHeader",
  "messageId": "18432",
  "component": "FHIR Operation",
  "observedAt": "2026-07-13T14:31:02Z"
}
```

## Security and privacy requirements

1. The module must operate read-only against analysed productions.
2. Message bodies must not be included in normal list endpoints.
3. Provide a configuration switch controlling whether message-body inspection is allowed.
4. Redact likely patient identifiers and sensitive fields by default.
5. Never send analysed code, configuration, or message data outside IRIS in the MVP.
6. Validate production names, message IDs, class names, and query parameters.
7. Prevent arbitrary class execution.
8. Prevent arbitrary SQL execution through request parameters.
9. Use IRIS authentication and application roles.
10. Define at least:

    * a read-only production-analysis role;
    * a runtime-message-analysis role;
    * an administrator role for module configuration.
11. Log analysis requests without logging sensitive payload contents.
12. Return a clear indication when access to a class, message, or payload is restricted.

## Configuration

Provide a module configuration class or persistent settings object supporting:

* whether runtime message analysis is enabled;
* whether payload inspection is enabled;
* maximum number of messages returned;
* maximum trace depth;
* default message lookback period;
* field-redaction patterns;
* class and package exclusions;
* production exclusions;
* whether source-code inference is enabled;
* explanation verbosity;
* optional future AI provider settings, disabled by default.

Suggested class:

`ProductionExplainer.Config.Settings`

## Optional future AI extension

Design an interface, but do not require an LLM implementation for the MVP.

Suggested interface:

`ProductionExplainer.AI.Provider`

Possible method:

```objectscript
Method Explain(input As %DynamicObject) As %DynamicObject
```

The AI provider must receive only the structured intermediate representation, not unrestricted raw production data.

The interface should allow future providers such as:

* local model;
* externally hosted model;
* rule-based explainer;
* no-AI deterministic implementation.

The deterministic explanation generator must remain the default.

## Initial implementation strategy

Implement the project in phases.

### Phase 1: Project skeleton

* create package structure;
* create module configuration;
* create REST application;
* create health endpoint;
* create OpenAPI document;
* add installation instructions;
* add sample configuration.

### Phase 2: Production discovery

* list productions;
* return production metadata;
* enumerate production items;
* classify components;
* expose production and component endpoints.

### Phase 3: Static graph

* identify component targets;
* construct nodes and edges;
* identify message classes;
* identify adapter types;
* expose graph endpoint;
* generate deterministic component summaries.

### Phase 4: Rules, DTL, and BPL

* inspect accessible routing-rule definitions;
* inspect accessible DTL transformations;
* inspect accessible BPL process definitions;
* attach findings and evidence to the graph;
* report unsupported or ambiguous constructs.

### Phase 5: Runtime trace analysis

* search message headers;
* retrieve a message family or session;
* reconstruct component transitions;
* expose trace endpoint;
* generate deterministic trace explanations.

### Phase 6: Testing and sample production

* create a small demonstration production;
* include at least one business service;
* include at least one business process;
* include at least two business operations;
* include a routing decision;
* include a transformation;
* include successful and failed trace examples;
* write unit and integration tests.

## Sample demonstration scenario

Create a sample production representing this flow:

1. Receive a simplified HL7-style patient event.
2. Determine whether the event is an admission, discharge, or update.
3. Transform the patient data into an internal request.
4. Route admissions and updates to a simulated FHIR operation.
5. Route discharges to a simulated notification operation.
6. Include an error path for an unavailable destination.

The explainer should be able to generate:

* a production overview;
* a component list;
* a graph;
* message-type explanations;
* an explanation of a successful admission event;
* an explanation of a failed outbound request.

## Testing requirements

Add automated tests for:

* production discovery;
* component classification;
* target extraction;
* graph construction;
* confidence classification;
* evidence creation;
* REST validation;
* error response consistency;
* restricted payload access;
* message pagination;
* trace reconstruction;
* explanation generation;
* OpenAPI validity.

Test against cases including:

* disabled components;
* missing target components;
* multiple targets;
* custom message classes;
* dynamic routing that cannot be resolved;
* failed messages;
* asynchronous messages;
* request-response interactions;
* productions with no stored runtime messages;
* inaccessible source definitions.

## Error response format

Use a consistent error schema:

```json
{
  "error": {
    "code": "PRODUCTION_NOT_FOUND",
    "message": "The requested interoperability production was not found.",
    "details": {},
    "requestId": "..."
  }
}
```

## Documentation requirements

Create:

* `README.md`;
* architecture overview;
* installation instructions;
* namespace and web-application configuration instructions;
* API usage examples;
* OpenAPI specification;
* security model;
* supported and unsupported analysis patterns;
* explanation confidence definitions;
* instructions for running the sample production;
* instructions for running tests;
* frontend integration notes.

## Frontend integration notes

The backend should allow an independent frontend to build:

* production selector;
* architecture graph;
* component detail panel;
* message search;
* trace timeline;
* plain-English explanation panel;
* evidence panel;
* warning and confidence indicators.

Do not generate server-side HTML as the primary interface.

Use stable JSON schemas and OpenAPI-generated client compatibility.

The frontend should not need direct access to IRIS internal tables or classes. All supported access should go through the REST API.

## Deliverables

Produce:

1. installable IRIS source code;
2. module/package manifest where appropriate;
3. REST API;
4. OpenAPI 3 specification;
5. structured analysis models;
6. deterministic explanation generator;
7. sample production;
8. tests;
9. documentation;
10. a concise backlog of post-MVP capabilities.

## Post-MVP backlog

Include, but do not implement unless the MVP is complete:

* chat interface over production metadata;
* impact analysis for proposed changes;
* comparison of two production versions;
* automatic documentation export;
* Mermaid diagram export;
* PDF report export;
* migration analysis from Ensemble to IRIS;
* semantic analysis of arbitrary ObjectScript;
* security and privacy data-flow analysis;
* detection of unused production components;
* detection of rarely used message routes;
* performance and bottleneck analysis;
* incident explanation;
* configurable external or local LLM support;
* natural-language questions such as:

  * “What happens to ADT^A08?”
  * “Which component calls this REST endpoint?”
  * “Where is the patient identifier transformed?”
  * “What happens when the FHIR server is unavailable?”
  * “Which messages contain patient information?”

## First Codex task

Start by inspecting the repository and determining:

* existing project structure;
* IRIS version assumptions;
* build and deployment mechanism;
* whether an interoperability production already exists;
* whether a REST framework or OpenAPI implementation already exists;
* available test infrastructure.

Then implement Phase 1 and Phase 2.

Do not attempt all phases in one large unreviewable change.

For the first implementation increment, deliver:

1. package structure;
2. configuration model;
3. REST application;
4. health endpoint;
5. production-list endpoint;
6. production-detail endpoint;
7. component-list endpoint;
8. initial OpenAPI specification;
9. tests for the implemented endpoints;
10. README instructions for installation and API invocation.

Before editing, provide a brief implementation plan based on the actual repository structure. After implementation, report:

* files created or changed;
* architectural decisions;
* commands used for testing;
* test results;
* limitations;
* recommended next increment.
