Class esh.interoperability.aid.api.spec Extends %REST.Spec
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

Parameter ExposeServerExceptions = 1;

XData OpenAPI [ MimeType = application/json ]
{
{
  "swagger": "2.0",
  "info": {
    "title": "IRIS Interoperability Production Explainer API",
    "version": "0.1.0",
    "description": "Discover and explain InterSystems IRIS interoperability productions in the current namespace."
  },
  "basePath": "/i14y-aid/api",
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "paths": {
    "/_spec": {
      "get": {
        "summary": "Get OpenAPI spec",
        "operationId": "GetSpec",
        "responses": {
          "200": {
            "description": "Swagger spec JSON",
            "schema": { "type": "object" }
          }
        }
      }
    },
    "/health": {
      "get": {
        "summary": "Get module health and capabilities",
        "operationId": "Health",
        "responses": {
          "200": {
            "description": "Module health",
            "schema": {
              "$ref": "#/definitions/HealthResponse"
            }
          }
        }
      }
    },
    "/capabilities": {
      "get": {
        "summary": "Get supported analysis capabilities",
        "operationId": "Capabilities",
        "responses": {
          "200": {
            "description": "Supported analysis capabilities",
            "schema": {
              "$ref": "#/definitions/CapabilitiesResponse"
            }
          }
        }
      }
    },
    "/settings": {
      "get": {
        "summary": "Get module analysis settings",
        "operationId": "GetSettings",
        "responses": {
          "200": {
            "description": "Module analysis settings",
            "schema": {
              "$ref": "#/definitions/SettingsResponse"
            }
          }
        }
      },
      "put": {
        "summary": "Update module analysis settings",
        "operationId": "UpdateSettings",
        "parameters": [
          {
            "name": "settings",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/AnalysisSettings"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Updated module analysis settings",
            "schema": {
              "$ref": "#/definitions/SettingsUpdateResponse"
            }
          },
          "400": {
            "description": "Invalid settings payload",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Settings update failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions": {
      "get": {
        "summary": "List interoperability productions in the current namespace",
        "operationId": "ListProductions",
        "responses": {
          "200": {
            "description": "Production list",
            "schema": {
              "$ref": "#/definitions/ProductionListResponse"
            }
          }
        }
      }
    },
    "/messages": {
      "get": {
        "summary": "List recent interoperability message headers",
        "operationId": "ListMessages",
        "parameters": [
          {
            "name": "productionName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 50
          },
          {
            "name": "offset",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 0
          },
          {
            "name": "sourceConfigName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "targetConfigName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "messageBodyClassName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "sessionId",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "errorsOnly",
            "in": "query",
            "required": false,
            "type": "boolean",
            "default": false
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for TimeCreated. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for TimeCreated. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent message headers",
            "schema": {
              "$ref": "#/definitions/MessageHeaderListResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message headers or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/facets": {
      "get": {
        "summary": "List recent message filter facets",
        "operationId": "ListMessageFacets",
        "parameters": [
          {
            "name": "productionName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 500
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for TimeCreated. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for TimeCreated. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent message filter facets",
            "schema": {
              "$ref": "#/definitions/MessageFacetResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message headers or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/logs": {
      "get": {
        "summary": "List recent interoperability production logs",
        "operationId": "ListLogs",
        "parameters": [
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 50
          },
          {
            "name": "offset",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 0
          },
          {
            "name": "type",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "source",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "contains",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for the log timestamp. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for the log timestamp. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent production logs",
            "schema": {
              "$ref": "#/definitions/ProductionLogListResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Production log query failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages": {
      "get": {
        "summary": "List recent interoperability message headers for a production",
        "operationId": "ListProductionMessages",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 50
          },
          {
            "name": "offset",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 0
          },
          {
            "name": "sourceConfigName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "targetConfigName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "messageBodyClassName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "sessionId",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "errorsOnly",
            "in": "query",
            "required": false,
            "type": "boolean",
            "default": false
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for TimeCreated. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for TimeCreated. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent production message headers",
            "schema": {
              "$ref": "#/definitions/MessageHeaderListResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message headers or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/logs": {
      "get": {
        "summary": "List recent interoperability logs for a production",
        "operationId": "ListProductionLogs",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 50
          },
          {
            "name": "offset",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 0
          },
          {
            "name": "type",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "source",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "contains",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for the log timestamp. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for the log timestamp. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent production logs",
            "schema": {
              "$ref": "#/definitions/ProductionLogListResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Production log query failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/facets": {
      "get": {
        "summary": "List recent message filter facets for a production",
        "operationId": "ListProductionMessageFacets",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 500
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive lower bound for TimeCreated. Accepts ISO 8601."
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "description": "Inclusive upper bound for TimeCreated. Accepts ISO 8601."
          }
        ],
        "responses": {
          "200": {
            "description": "Recent production message filter facets",
            "schema": {
              "$ref": "#/definitions/MessageFacetResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message headers or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}": {
      "get": {
        "summary": "Get production-scoped message header metadata",
        "operationId": "GetProductionMessage",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped message header metadata",
            "schema": {
              "$ref": "#/definitions/MessageDetailResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Message resend failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/payload": {
      "get": {
        "summary": "Get production-scoped safe payload metadata for a message",
        "operationId": "GetProductionMessagePayloadMetadata",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped safe payload metadata without body content",
            "schema": {
              "$ref": "#/definitions/MessagePayloadMetadataResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/payload/preview": {
      "get": {
        "summary": "Get production-scoped redacted payload preview for a message",
        "operationId": "GetProductionMessagePayloadPreview",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped redacted payload preview",
            "schema": {
              "$ref": "#/definitions/MessagePayloadPreviewResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/trace": {
      "get": {
        "summary": "Get production-scoped runtime trace for a message header",
        "operationId": "GetProductionMessageTrace",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped message trace",
            "schema": {
              "$ref": "#/definitions/MessageTraceResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/session": {
      "get": {
        "summary": "Get production-scoped message session summary",
        "operationId": "GetProductionMessageSessionSummary",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped message session summary",
            "schema": {
              "$ref": "#/definitions/MessageSessionSummaryResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/sessions/{sessionId}/timeline": {
      "get": {
        "summary": "Get production-scoped session timeline from messages and logs",
        "operationId": "GetProductionSessionTimeline",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "sessionId",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 100
          },
          {
            "name": "startDate",
            "in": "query",
            "required": false,
            "type": "string",
            "format": "date-time"
          },
          {
            "name": "endDate",
            "in": "query",
            "required": false,
            "type": "string",
            "format": "date-time"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped session timeline",
            "schema": {
              "$ref": "#/definitions/SessionTimelineResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/resend": {
      "post": {
        "summary": "Request production-scoped message resend",
        "operationId": "ResendProductionMessage",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Message resend request status",
            "schema": {
              "$ref": "#/definitions/MessageResendResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/messages/{messageId}/explanation": {
      "get": {
        "summary": "Get production-scoped deterministic explanation for a message trace",
        "operationId": "GetProductionMessageExplanation",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Production-scoped message trace explanation",
            "schema": {
              "$ref": "#/definitions/MessageExplanationResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message or production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/{messageId}": {
      "get": {
        "summary": "Get message header metadata",
        "operationId": "GetMessage",
        "parameters": [
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Message header metadata",
            "schema": {
              "$ref": "#/definitions/MessageDetailResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/{messageId}/payload": {
      "get": {
        "summary": "Get safe payload metadata for a message",
        "operationId": "GetMessagePayloadMetadata",
        "parameters": [
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Safe payload metadata without body content",
            "schema": {
              "$ref": "#/definitions/MessagePayloadMetadataResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/{messageId}/payload/preview": {
      "get": {
        "summary": "Get redacted payload preview for a message",
        "operationId": "GetMessagePayloadPreview",
        "parameters": [
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Redacted payload preview",
            "schema": {
              "$ref": "#/definitions/MessagePayloadPreviewResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/{messageId}/trace": {
      "get": {
        "summary": "Get runtime trace for a message header",
        "operationId": "GetMessageTrace",
        "parameters": [
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Message trace",
            "schema": {
              "$ref": "#/definitions/MessageTraceResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/messages/{messageId}/explanation": {
      "get": {
        "summary": "Get deterministic explanation for a message trace",
        "operationId": "GetMessageExplanation",
        "parameters": [
          {
            "name": "messageId",
            "in": "path",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "Message trace explanation",
            "schema": {
              "$ref": "#/definitions/MessageExplanationResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Message not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}": {
      "get": {
        "summary": "Get production metadata",
        "operationId": "GetProduction",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production metadata",
            "schema": {
              "$ref": "#/definitions/ProductionDetailResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/components": {
      "get": {
        "summary": "List production components",
        "operationId": "ListComponents",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production components",
            "schema": {
              "$ref": "#/definitions/ComponentListResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/components/{componentName}": {
      "get": {
        "summary": "Get production component detail",
        "operationId": "GetComponentDetail",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "componentName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production component detail",
            "schema": {
              "$ref": "#/definitions/ComponentDetailResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production or component not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/analysis": {
      "get": {
        "summary": "Get static production analysis model",
        "operationId": "GetProductionAnalysis",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Static production analysis model",
            "schema": {
              "$ref": "#/definitions/ProductionAnalysisResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/summary": {
      "get": {
        "summary": "Get deterministic production summary",
        "operationId": "GetProductionSummary",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Deterministic production summary",
            "schema": {
              "$ref": "#/definitions/ProductionSummaryResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/graph": {
      "get": {
        "summary": "Get frontend-neutral production graph",
        "operationId": "GetProductionGraph",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production graph",
            "schema": {
              "$ref": "#/definitions/ProductionGraphResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/ai/summary": {
      "post": {
        "summary": "Generate AI-assisted production summary",
        "operationId": "GetProductionAISummary",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "AI-assisted production summary",
            "schema": {
              "$ref": "#/definitions/ProductionAISummaryResponse"
            }
          },
          "400": {
            "description": "Invalid request or AI configuration",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "403": {
            "description": "AI provider or summary generation disabled",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "502": {
            "description": "AI provider request failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/rag/context": {
      "get": {
        "summary": "Get deterministic production RAG chunks and retrieval results",
        "operationId": "GetProductionRAGContext",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "question",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "componentName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "maxChunks",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 12
          }
        ],
        "responses": {
          "200": {
            "description": "Deterministic production RAG context",
            "schema": {
              "$ref": "#/definitions/ProductionRAGContextResponse"
            }
          },
          "400": {
            "description": "Invalid production name",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/rag/index": {
      "get": {
        "summary": "Get persisted deterministic production RAG index status",
        "operationId": "GetProductionRAGIndexStatus",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Persisted RAG index status",
            "schema": {
              "$ref": "#/definitions/RAGIndexStatusResponse"
            }
          },
          "400": {
            "description": "Invalid production name",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      },
      "post": {
        "summary": "Rebuild persisted deterministic production RAG chunk index",
        "operationId": "RebuildProductionRAGIndex",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "request",
            "in": "body",
            "required": false,
            "schema": {
              "$ref": "#/definitions/RAGIndexRebuildRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Persisted RAG index rebuild result",
            "schema": {
              "$ref": "#/definitions/RAGIndexRebuildResponse"
            }
          },
          "400": {
            "description": "Invalid production name",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "RAG index rebuild failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/rag/chunks": {
      "get": {
        "summary": "List persisted deterministic production RAG chunks",
        "operationId": "ListProductionRAGChunks",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "limit",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 50
          },
          {
            "name": "offset",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 0
          },
          {
            "name": "kind",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "componentName",
            "in": "query",
            "required": false,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Persisted RAG chunks",
            "schema": {
              "$ref": "#/definitions/RAGChunkListResponse"
            }
          },
          "400": {
            "description": "Invalid production name",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "RAG chunk query failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/rag/search": {
      "get": {
        "summary": "Search persisted deterministic production RAG chunks",
        "operationId": "SearchProductionRAGChunks",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "question",
            "in": "query",
            "required": true,
            "type": "string"
          },
          {
            "name": "componentName",
            "in": "query",
            "required": false,
            "type": "string"
          },
          {
            "name": "maxChunks",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 12
          }
        ],
        "responses": {
          "200": {
            "description": "Persisted RAG chunk search result",
            "schema": {
              "$ref": "#/definitions/RAGChunkSearchResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/ai/ask": {
      "post": {
        "summary": "Ask an AI-assisted question grounded in production analysis chunks",
        "operationId": "AskProductionAI",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "request",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/ProductionAIAskRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "AI-assisted production answer",
            "schema": {
              "$ref": "#/definitions/ProductionAIAskResponse"
            }
          },
          "400": {
            "description": "Invalid request or AI configuration",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "403": {
            "description": "AI provider disabled",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "502": {
            "description": "AI provider request failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/status": {
      "get": {
        "summary": "Get production runtime status",
        "operationId": "GetProductionStatus",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production runtime status",
            "schema": {
              "$ref": "#/definitions/ProductionRuntimeResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/start": {
      "post": {
        "summary": "Start production",
        "operationId": "StartProduction",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          }
        ],
        "responses": {
          "200": {
            "description": "Production start result",
            "schema": {
              "$ref": "#/definitions/ProductionActionResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "409": {
            "description": "Production conflict",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Start failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    },
    "/productions/{productionName}/stop": {
      "post": {
        "summary": "Stop production",
        "operationId": "StopProduction",
        "parameters": [
          {
            "name": "productionName",
            "in": "path",
            "required": true,
            "type": "string"
          },
          {
            "name": "timeout",
            "in": "query",
            "required": false,
            "type": "integer",
            "format": "int32",
            "default": 10
          },
          {
            "name": "force",
            "in": "query",
            "required": false,
            "type": "boolean",
            "default": false
          }
        ],
        "responses": {
          "200": {
            "description": "Production stop result",
            "schema": {
              "$ref": "#/definitions/ProductionActionResponse"
            }
          },
          "400": {
            "description": "Invalid request",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "404": {
            "description": "Production not found",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "409": {
            "description": "Production conflict",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          },
          "500": {
            "description": "Stop failed",
            "schema": {
              "$ref": "#/definitions/ErrorResponse"
            }
          }
        }
      }
    }
  },
  "definitions": {
    "HealthResponse": {
      "type": "object",
      "properties": {
        "status": {
          "type": "string"
        },
        "module": {
          "type": "string"
        },
        "version": {
          "type": "string"
        },
        "namespace": {
          "type": "string"
        },
        "capabilities": {
          "$ref": "#/definitions/CapabilitiesResponse"
        }
      }
    },
    "CapabilitiesResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "interoperabilityAvailable": {
          "type": "boolean"
        },
        "currentNamespaceOnly": {
          "type": "boolean"
        },
        "productionDiscovery": {
          "type": "boolean"
        },
        "productionXDataAnalysis": {
          "type": "boolean"
        },
        "productionControl": {
          "type": "boolean"
        },
        "runtimeTraceAnalysis": {
          "type": "boolean"
        },
        "payloadInspection": {
          "type": "boolean"
        },
        "payloadPreview": {
          "type": "boolean"
        },
        "productionLogs": {
          "type": "boolean"
        },
        "aiProvider": {
          "type": "boolean"
        },
        "aiSummary": {
          "type": "boolean"
        },
        "openapiVersion": {
          "type": "string"
        }
      }
    },
    "SettingsResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "settings": {
          "$ref": "#/definitions/AnalysisSettings"
        },
        "metrics": {
          "$ref": "#/definitions/SettingsMetrics"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "SettingsUpdateResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "changed": {
          "type": "boolean"
        },
        "settings": {
          "$ref": "#/definitions/AnalysisSettings"
        },
        "metrics": {
          "$ref": "#/definitions/SettingsMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "SettingsMetrics": {
      "type": "object",
      "properties": {
        "featureFlagCount": {
          "type": "integer",
          "format": "int32"
        },
        "enabledFeatureFlagCount": {
          "type": "integer",
          "format": "int32"
        },
        "limitSettingCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "AnalysisSettings": {
      "type": "object",
      "properties": {
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "payloadInspectionEnabled": {
          "type": "boolean"
        },
        "payloadMetadataEnabled": {
          "type": "boolean"
        },
        "messageResendEnabled": {
          "type": "boolean"
        },
        "maxMessagesReturned": {
          "type": "integer",
          "format": "int32"
        },
        "maxTraceDepth": {
          "type": "integer",
          "format": "int32"
        },
        "defaultMessageLookbackDays": {
          "type": "integer",
          "format": "int32"
        },
        "fieldRedactionPatterns": {
          "type": "string"
        },
        "classExclusions": {
          "type": "string"
        },
        "productionExclusions": {
          "type": "string"
        },
        "sourceCodeInferenceEnabled": {
          "type": "boolean"
        },
        "explanationVerbosity": {
          "type": "string"
        },
        "aiProviderEnabled": {
          "type": "boolean"
        },
        "aiSummaryEnabled": {
          "type": "boolean"
        },
        "aiProvider": {
          "type": "string"
        },
        "aiModel": {
          "type": "string"
        },
        "aiEndpoint": {
          "type": "string"
        },
        "ragRuntimeDataEnabled": {
          "type": "boolean"
        },
        "ragRuntimeLookbackHours": {
          "type": "integer",
          "format": "int32"
        },
        "ragRuntimeMaxMessages": {
          "type": "integer",
          "format": "int32"
        },
        "ragRuntimeMaxLogs": {
          "type": "integer",
          "format": "int32"
        },
        "ragPayloadIndexingEnabled": {
          "type": "boolean"
        },
        "ragPayloadMaxFields": {
          "type": "integer",
          "format": "int32"
        },
        "aiApiKeyConfigured": {
          "type": "boolean"
        },
        "aiApiKeySource": {
          "type": "string"
        },
        "openAIApiKey": {
          "type": "string",
          "description": "Write-only OpenAI API key. Accepted by UpdateSettings and never returned by GetSettings."
        },
        "clearOpenAIApiKey": {
          "type": "boolean"
        }
      }
    },
    "ProductionListResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ProductionSummary"
          }
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/ProductionListMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "ProductionListMetrics": {
      "type": "object",
      "properties": {
        "productionCount": {
          "type": "integer",
          "format": "int32"
        },
        "runningProductionCount": {
          "type": "integer",
          "format": "int32"
        },
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledComponentCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "ProductionSummary": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "namespace": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledComponentCount": {
          "type": "integer",
          "format": "int32"
        },
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
        },
        "runtimeMetrics": {
          "$ref": "#/definitions/ProductionRuntimeMetrics"
        },
        "isRunning": {
          "type": "boolean"
        },
        "runtimeState": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionDetailResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "summary": {
          "type": "string"
        },
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledComponentCount": {
          "type": "integer",
          "format": "int32"
        },
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
        },
        "runtimeMetrics": {
          "$ref": "#/definitions/ProductionRuntimeMetrics"
        },
        "isRunning": {
          "type": "boolean"
        },
        "runtimeState": {
          "type": "string"
        },
        "components": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Component"
          }
        },
        "summaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/ProductionMetrics"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ComponentListResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Component"
          }
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/ComponentListMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "ComponentListMetrics": {
      "type": "object",
      "properties": {
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledComponentCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "ComponentDetailResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "component": {
          "$ref": "#/definitions/Component"
        },
        "explanation": {
          "$ref": "#/definitions/ComponentExplanation"
        },
        "summaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/ComponentMetrics"
        },
        "connections": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Connection"
          }
        },
        "connectionExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ConnectionExplanation"
          }
        },
        "externalSystems": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ExternalSystem"
          }
        },
        "externalSystemExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ExternalSystemExplanation"
          }
        },
        "artifacts": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/AnalysisArtifact"
          }
        },
        "artifactExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ArtifactExplanation"
          }
        },
        "rules": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleDetail"
          }
        },
        "ruleExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleExplanation"
          }
        },
        "messageTypes": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageType"
          }
        },
        "messageTypeExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageTypeExplanation"
          }
        },
        "transformations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TransformationDetail"
          }
        },
        "transformationExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TransformationExplanation"
          }
        },
        "businessProcesses": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/BusinessProcessDetail"
          }
        },
        "businessProcessExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/BusinessProcessExplanation"
          }
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "ComponentMetrics": {
      "type": "object",
      "properties": {
        "connectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "externalSystemCount": {
          "type": "integer",
          "format": "int32"
        },
        "artifactCount": {
          "type": "integer",
          "format": "int32"
        },
        "ruleCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageTypeCount": {
          "type": "integer",
          "format": "int32"
        },
        "transformationCount": {
          "type": "integer",
          "format": "int32"
        },
        "businessProcessCount": {
          "type": "integer",
          "format": "int32"
        },
        "explanationCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "MessageHeaderListResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageHeader"
          }
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "limit": {
          "type": "integer",
          "format": "int32"
        },
        "offset": {
          "type": "integer",
          "format": "int32"
        },
        "sourceConfigName": {
          "type": "string"
        },
        "targetConfigName": {
          "type": "string"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "sessionId": {
          "type": "string"
        },
        "errorsOnly": {
          "type": "boolean"
        },
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "hasMore": {
          "type": "boolean"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "maxMessagesReturned": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/MessageListMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "MessageHeader": {
      "type": "object",
      "properties": {
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "timeCreated": {
          "type": "string"
        },
        "timeProcessed": {
          "type": "string"
        },
        "sourceConfigName": {
          "type": "string"
        },
        "targetConfigName": {
          "type": "string"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "messageBodyId": {
          "type": "string"
        },
        "status": {
          "type": "string"
        },
        "isError": {
          "type": "boolean"
        },
        "errorStatus": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "invocation": {
          "type": "string"
        },
        "correspondingMessageId": {
          "type": "integer",
          "format": "int64"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "MessageFacetResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "limit": {
          "type": "integer",
          "format": "int32"
        },
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "totalCount": {
          "type": "integer",
          "format": "int32"
        },
        "errorCount": {
          "type": "integer",
          "format": "int32"
        },
        "hasMore": {
          "type": "boolean"
        },
        "sourceConfigNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "targetConfigNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "messageBodyClassNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "sessionIds": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "componentNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "maxMessagesReturned": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/MessageListMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "MessageListMetrics": {
      "type": "object",
      "properties": {
        "itemCount": {
          "type": "integer",
          "format": "int32"
        },
        "totalCount": {
          "type": "integer",
          "format": "int32"
        },
        "errorCount": {
          "type": "integer",
          "format": "int32"
        },
        "hasMore": {
          "type": "boolean"
        },
        "sourceFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "targetFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageBodyClassFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "sessionFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "componentFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "ProductionLogListResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ProductionLogEntry"
          }
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "totalCount": {
          "type": "integer",
          "format": "int32"
        },
        "limit": {
          "type": "integer",
          "format": "int32"
        },
        "offset": {
          "type": "integer",
          "format": "int32"
        },
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "hasMore": {
          "type": "boolean"
        },
        "type": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "contains": {
          "type": "string"
        },
        "sourceNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "typeNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "logClassName": {
          "type": "string"
        },
        "metrics": {
          "$ref": "#/definitions/ProductionLogMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "ProductionLogEntry": {
      "type": "object",
      "properties": {
        "logId": {
          "type": "integer",
          "format": "int64"
        },
        "timeLogged": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "sessionId": {
          "type": "string"
        },
        "job": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "inProduction": {
          "type": "boolean"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionLogMetrics": {
      "type": "object",
      "properties": {
        "itemCount": {
          "type": "integer",
          "format": "int32"
        },
        "totalCount": {
          "type": "integer",
          "format": "int32"
        },
        "hasMore": {
          "type": "boolean"
        },
        "sourceFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "typeFacetCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "SessionTimelineResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "sessionId": {
          "type": "string"
        },
        "limit": {
          "type": "integer",
          "format": "int32"
        },
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "messages": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageHeader"
          }
        },
        "logs": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ProductionLogEntry"
          }
        },
        "events": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/SessionTimelineEvent"
          }
        },
        "messageCount": {
          "type": "integer",
          "format": "int32"
        },
        "logCount": {
          "type": "integer",
          "format": "int32"
        },
        "eventCount": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/SessionTimelineMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "SessionTimelineEvent": {
      "type": "object",
      "properties": {
        "sequence": {
          "type": "integer",
          "format": "int32"
        },
        "type": {
          "type": "string"
        },
        "timestamp": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "logId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "target": {
          "type": "string"
        },
        "status": {
          "type": "string"
        },
        "isError": {
          "type": "boolean"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "SessionTimelineMetrics": {
      "type": "object",
      "properties": {
        "messageCount": {
          "type": "integer",
          "format": "int32"
        },
        "logCount": {
          "type": "integer",
          "format": "int32"
        },
        "eventCount": {
          "type": "integer",
          "format": "int32"
        },
        "errorCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "MessageDetailResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "message": {
          "$ref": "#/definitions/MessageHeader"
        },
        "payloadMetadata": {
          "$ref": "#/definitions/PayloadMetadata"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "metrics": {
          "$ref": "#/definitions/MessageDetailMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "MessageDetailMetrics": {
      "type": "object",
      "properties": {
        "payloadReturned": {
          "type": "boolean"
        },
        "payloadInspectionSupported": {
          "type": "boolean"
        },
        "bodyReferenceAvailable": {
          "type": "boolean"
        },
        "messageEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "payloadEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "MessagePayloadMetadataResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "message": {
          "$ref": "#/definitions/MessageHeader"
        },
        "metadata": {
          "$ref": "#/definitions/PayloadMetadata"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "messageBodyId": {
          "type": "string"
        },
        "bodyReferenceAvailable": {
          "type": "boolean"
        },
        "restricted": {
          "type": "boolean"
        },
        "restrictionReason": {
          "type": "string"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "payloadInspectionEnabled": {
          "type": "boolean"
        },
        "payloadMetadataEnabled": {
          "type": "boolean"
        },
        "payloadInspectionSupported": {
          "type": "boolean"
        },
        "metrics": {
          "$ref": "#/definitions/PayloadMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "PayloadMetadata": {
      "type": "object",
      "properties": {
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "messageBodyId": {
          "type": "string"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "payloadInspectionEnabled": {
          "type": "boolean"
        },
        "payloadMetadataEnabled": {
          "type": "boolean"
        },
        "payloadInspectionSupported": {
          "type": "boolean"
        },
        "bodyReferenceAvailable": {
          "type": "boolean"
        },
        "bodyClassExists": {
          "type": "boolean"
        },
        "restricted": {
          "type": "boolean"
        },
        "restrictionReason": {
          "type": "string"
        },
        "fields": {
          "type": "array",
          "items": {
            "type": "object"
          }
        },
        "metrics": {
          "$ref": "#/definitions/PayloadMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "MessagePayloadPreviewResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "message": {
          "$ref": "#/definitions/MessageHeader"
        },
        "metadata": {
          "$ref": "#/definitions/PayloadMetadata"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "messageBodyId": {
          "type": "string"
        },
        "bodyReferenceAvailable": {
          "type": "boolean"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "bodyContentReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "payloadInspectionEnabled": {
          "type": "boolean"
        },
        "payloadInspectionSupported": {
          "type": "boolean"
        },
        "restricted": {
          "type": "boolean"
        },
        "restrictionReason": {
          "type": "string"
        },
        "fields": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/PayloadPreviewField"
          }
        },
        "metrics": {
          "$ref": "#/definitions/PayloadMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "PayloadMetrics": {
      "type": "object",
      "properties": {
        "fieldCount": {
          "type": "integer",
          "format": "int32"
        },
        "redactedFieldCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "PayloadPreviewField": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "redacted": {
          "type": "boolean"
        }
      }
    },
    "MessageTraceResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "selectedMessage": {
          "$ref": "#/definitions/MessageHeader"
        },
        "summary": {
          "type": "string"
        },
        "traceOverview": {
          "$ref": "#/definitions/TraceOverview"
        },
        "traceExplanation": {
          "$ref": "#/definitions/TraceExplanation"
        },
        "metrics": {
          "$ref": "#/definitions/TraceMetrics"
        },
        "steps": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TraceStep"
          }
        },
        "stepCount": {
          "type": "integer",
          "format": "int32"
        },
        "productionScoped": {
          "type": "boolean"
        },
        "productionStepCount": {
          "type": "integer",
          "format": "int32"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "maxTraceDepth": {
          "type": "integer",
          "format": "int32"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "TraceMetrics": {
      "type": "object",
      "properties": {
        "stepCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "MessageSessionSummaryResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "selectedMessage": {
          "$ref": "#/definitions/MessageHeader"
        },
        "stepCount": {
          "type": "integer",
          "format": "int32"
        },
        "productionStepCount": {
          "type": "integer",
          "format": "int32"
        },
        "outsideProductionStepCount": {
          "type": "integer",
          "format": "int32"
        },
        "errorCount": {
          "type": "integer",
          "format": "int32"
        },
        "firstSeen": {
          "type": "string"
        },
        "lastSeen": {
          "type": "string"
        },
        "origin": {
          "type": "string"
        },
        "finalTarget": {
          "type": "string"
        },
        "path": {
          "type": "string"
        },
        "participants": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "payloadPolicy": {
          "type": "object",
          "properties": {
            "payloadReturned": {
              "type": "boolean"
            },
            "payloadInspectionEnabled": {
              "type": "boolean"
            },
            "payloadInspectionSupported": {
              "type": "boolean"
            },
            "bodyContentReturned": {
              "type": "boolean"
            },
            "summary": {
              "type": "string"
            }
          }
        },
        "staticContext": {
          "$ref": "#/definitions/TraceStaticContext"
        },
        "metrics": {
          "$ref": "#/definitions/TraceMetrics"
        },
        "text": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "MessageResendResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "action": {
          "type": "string"
        },
        "requested": {
          "type": "boolean"
        },
        "allowed": {
          "type": "boolean"
        },
        "executed": {
          "type": "boolean"
        },
        "dryRun": {
          "type": "boolean"
        },
        "supported": {
          "type": "boolean"
        },
        "changed": {
          "type": "boolean"
        },
        "reason": {
          "type": "string"
        },
        "statusText": {
          "type": "string"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "messageResendEnabled": {
          "type": "boolean"
        },
        "selectedMessage": {
          "$ref": "#/definitions/MessageHeader"
        },
        "metrics": {
          "$ref": "#/definitions/RuntimeActionMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RuntimeActionMetrics": {
      "type": "object",
      "properties": {
        "requested": {
          "type": "boolean"
        },
        "allowed": {
          "type": "boolean"
        },
        "executed": {
          "type": "boolean"
        },
        "changed": {
          "type": "boolean"
        },
        "dryRun": {
          "type": "boolean"
        },
        "supported": {
          "type": "boolean"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "MessageExplanationResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "explanation": {
          "$ref": "#/definitions/TraceExplanation"
        },
        "summary": {
          "type": "string"
        },
        "stepCount": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/TraceMetrics"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "runtimeMessageAnalysisEnabled": {
          "type": "boolean"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "TraceOverview": {
      "type": "object",
      "properties": {
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "stepCount": {
          "type": "integer",
          "format": "int32"
        },
        "errorCount": {
          "type": "integer",
          "format": "int32"
        },
        "firstSeen": {
          "type": "string"
        },
        "lastSeen": {
          "type": "string"
        },
        "origin": {
          "type": "string"
        },
        "finalTarget": {
          "type": "string"
        },
        "path": {
          "type": "string"
        },
        "participants": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "TraceStep": {
      "type": "object",
      "properties": {
        "sequence": {
          "type": "integer",
          "format": "int32"
        },
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "timeCreated": {
          "type": "string"
        },
        "timeProcessed": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "target": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "sourceInProduction": {
          "type": "boolean"
        },
        "targetInProduction": {
          "type": "boolean"
        },
        "inProduction": {
          "type": "boolean"
        },
        "staticConnectionKind": {
          "type": "string"
        },
        "staticConnectionConfidence": {
          "type": "string"
        },
        "staticRuleName": {
          "type": "string"
        },
        "staticTransformNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "staticProcessClass": {
          "type": "string"
        },
        "messageBodyClassName": {
          "type": "string"
        },
        "status": {
          "type": "string"
        },
        "isError": {
          "type": "boolean"
        },
        "invocation": {
          "type": "string"
        },
        "correspondingMessageId": {
          "type": "integer",
          "format": "int64"
        },
        "payloadReturned": {
          "type": "boolean"
        },
        "explanation": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "TraceStaticContext": {
      "type": "object",
      "properties": {
        "connectionKinds": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "ruleNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "transformNames": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "processClasses": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "matchedStepCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "AnalysisCoverage": {
      "type": "object",
      "properties": {
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "connectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageTypeCount": {
          "type": "integer",
          "format": "int32"
        },
        "externalSystemCount": {
          "type": "integer",
          "format": "int32"
        },
        "artifactCount": {
          "type": "integer",
          "format": "int32"
        },
        "ruleCount": {
          "type": "integer",
          "format": "int32"
        },
        "transformationCount": {
          "type": "integer",
          "format": "int32"
        },
        "businessProcessCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "componentAnalysisAvailable": {
          "type": "boolean"
        },
        "targetAnalysisAvailable": {
          "type": "boolean"
        },
        "messageSignatureAnalysisAvailable": {
          "type": "boolean"
        },
        "routingRuleAnalysisAvailable": {
          "type": "boolean"
        },
        "transformationAnalysisAvailable": {
          "type": "boolean"
        },
        "businessProcessAnalysisAvailable": {
          "type": "boolean"
        },
        "warningCodes": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "limitations": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "TraceExplanation": {
      "type": "object",
      "properties": {
        "messageId": {
          "type": "integer",
          "format": "int64"
        },
        "sessionId": {
          "type": "integer",
          "format": "int64"
        },
        "productionName": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionAnalysisResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "production": {
          "$ref": "#/definitions/ProductionDetailResponse"
        },
        "summary": {
          "type": "string"
        },
        "summaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/ProductionMetrics"
        },
        "analysisCoverage": {
          "$ref": "#/definitions/AnalysisCoverage"
        },
        "components": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Component"
          }
        },
        "connections": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Connection"
          }
        },
        "externalSystems": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ExternalSystem"
          }
        },
        "artifacts": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/AnalysisArtifact"
          }
        },
        "artifactExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ArtifactExplanation"
          }
        },
        "rules": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleDetail"
          }
        },
        "ruleExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleExplanation"
          }
        },
        "messageTypes": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageType"
          }
        },
        "transformations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TransformationDetail"
          }
        },
        "businessProcesses": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/BusinessProcessDetail"
          }
        },
        "businessProcessExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/BusinessProcessExplanation"
          }
        },
        "componentExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ComponentExplanation"
          }
        },
        "connectionExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ConnectionExplanation"
          }
        },
        "externalSystemExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/ExternalSystemExplanation"
          }
        },
        "messageTypeExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/MessageTypeExplanation"
          }
        },
        "transformationExplanations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TransformationExplanation"
          }
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "ProductionMetrics": {
      "type": "object",
      "properties": {
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledComponentCount": {
          "type": "integer",
          "format": "int32"
        },
        "connectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "targetConfigConnectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "routingRuleConnectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "bplCallConnectionCount": {
          "type": "integer",
          "format": "int32"
        },
        "externalSystemCount": {
          "type": "integer",
          "format": "int32"
        },
        "artifactCount": {
          "type": "integer",
          "format": "int32"
        },
        "ruleCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageTypeCount": {
          "type": "integer",
          "format": "int32"
        },
        "transformationCount": {
          "type": "integer",
          "format": "int32"
        },
        "businessProcessCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningCount": {
          "type": "integer",
          "format": "int32"
        },
        "explanationCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "ProductionSummaryResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "summary": {
          "type": "string"
        },
        "summaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/ProductionMetrics"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        }
      }
    },
    "ProductionAISummaryResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "provider": {
          "type": "string"
        },
        "model": {
          "type": "string"
        },
        "generated": {
          "type": "boolean"
        },
        "summary": {
          "type": "string"
        },
        "deterministicSummary": {
          "type": "string"
        },
        "deterministicSummaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/ProductionMetrics"
        },
        "aiProviderEnabled": {
          "type": "boolean"
        },
        "aiSummaryEnabled": {
          "type": "boolean"
        },
        "aiApiKeyConfigured": {
          "type": "boolean"
        },
        "aiApiKeySource": {
          "type": "string"
        },
        "rawUsage": {
          "type": "object"
        },
        "confidence": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionAIAskRequest": {
      "type": "object",
      "properties": {
        "question": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "maxChunks": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "RAGChunk": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "title": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "score": {
          "type": "integer",
          "format": "int32"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RAGContextMetrics": {
      "type": "object",
      "properties": {
        "chunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "retrievedChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "componentChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "connectionChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "ruleChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageTypeChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "externalSystemChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "transformationChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "businessProcessChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "messageChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "logChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "payloadChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "runtimeChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "warningChunkCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "ProductionRAGContextResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "question": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "maxChunks": {
          "type": "integer",
          "format": "int32"
        },
        "chunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "retrievedChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "chunks": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RAGChunk"
          }
        },
        "retrievedChunks": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RAGChunk"
          }
        },
        "metrics": {
          "$ref": "#/definitions/RAGContextMetrics"
        },
        "confidence": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RAGIndexStatusResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "indexed": {
          "type": "boolean"
        },
        "stale": {
          "type": "boolean"
        },
        "status": {
          "type": "string"
        },
        "runId": {
          "type": "integer",
          "format": "int64"
        },
        "runTimestamp": {
          "type": "string"
        },
        "chunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "statusText": {
          "type": "string"
        },
        "latestSourceChangedAt": {
          "type": "string"
        },
        "latestSourceClassName": {
          "type": "string"
        },
        "sourceClassCount": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/RAGContextMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RAGIndexRebuildRequest": {
      "type": "object",
      "properties": {
        "includeRuntime": {
          "type": "boolean",
          "description": "Include recent message and log chunks in the persisted RAG index."
        },
        "lookbackHours": {
          "type": "integer",
          "format": "int32"
        },
        "startDate": {
          "type": "string",
          "description": "Inclusive runtime lower bound. Accepts ISO 8601."
        },
        "endDate": {
          "type": "string",
          "description": "Inclusive runtime upper bound. Accepts ISO 8601."
        },
        "maxMessages": {
          "type": "integer",
          "format": "int32"
        },
        "maxLogs": {
          "type": "integer",
          "format": "int32"
        },
        "includePayload": {
          "type": "boolean",
          "description": "Include redacted scalar payload preview chunks for indexed messages. Requires payload inspection to be enabled."
        },
        "maxPayloadFields": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "RAGIndexRebuildResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "runId": {
          "type": "integer",
          "format": "int64"
        },
        "status": {
          "type": "string"
        },
        "chunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "includeRuntime": {
          "type": "boolean"
        },
        "runtimeStartDate": {
          "type": "string"
        },
        "runtimeEndDate": {
          "type": "string"
        },
        "runtimeMaxMessages": {
          "type": "integer",
          "format": "int32"
        },
        "runtimeMaxLogs": {
          "type": "integer",
          "format": "int32"
        },
        "includePayload": {
          "type": "boolean"
        },
        "payloadMaxFields": {
          "type": "integer",
          "format": "int32"
        },
        "runtimeChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "metrics": {
          "$ref": "#/definitions/RAGContextMetrics"
        },
        "confidence": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RAGChunkListResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "runId": {
          "type": "integer",
          "format": "int64"
        },
        "limit": {
          "type": "integer",
          "format": "int32"
        },
        "offset": {
          "type": "integer",
          "format": "int32"
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "totalCount": {
          "type": "integer",
          "format": "int32"
        },
        "hasMore": {
          "type": "boolean"
        },
        "kind": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "items": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RAGChunk"
          }
        },
        "metrics": {
          "$ref": "#/definitions/RAGContextMetrics"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RAGChunkSearchResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "runId": {
          "type": "integer",
          "format": "int64"
        },
        "question": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "maxChunks": {
          "type": "integer",
          "format": "int32"
        },
        "count": {
          "type": "integer",
          "format": "int32"
        },
        "totalChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "chunks": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RAGChunk"
          }
        },
        "metrics": {
          "$ref": "#/definitions/RAGContextMetrics"
        },
        "confidence": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionAIAskResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "question": {
          "type": "string"
        },
        "componentName": {
          "type": "string"
        },
        "provider": {
          "type": "string"
        },
        "model": {
          "type": "string"
        },
        "generated": {
          "type": "boolean"
        },
        "answer": {
          "type": "string"
        },
        "runId": {
          "type": "integer",
          "format": "int64"
        },
        "chunkSource": {
          "type": "string"
        },
        "chunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "totalChunkCount": {
          "type": "integer",
          "format": "int32"
        },
        "chunks": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RAGChunk"
          }
        },
        "citations": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/AIAnswerCitation"
          }
        },
        "citationCount": {
          "type": "integer",
          "format": "int32"
        },
        "invalidCitationIds": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "invalidCitationCount": {
          "type": "integer",
          "format": "int32"
        },
        "uncitedChunkIds": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "answerGrounded": {
          "type": "boolean"
        },
        "aiProviderEnabled": {
          "type": "boolean"
        },
        "aiApiKeyConfigured": {
          "type": "boolean"
        },
        "aiApiKeySource": {
          "type": "string"
        },
        "rawUsage": {
          "type": "object"
        },
        "confidence": {
          "type": "string"
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "AIAnswerCitation": {
      "type": "object",
      "properties": {
        "chunkId": {
          "type": "string"
        },
        "originalCitation": {
          "type": "string"
        },
        "normalized": {
          "type": "boolean"
        },
        "kind": {
          "type": "string"
        },
        "title": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "ProductionGraphResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "summaryBullets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "metrics": {
          "$ref": "#/definitions/GraphMetrics"
        },
        "nodes": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/GraphNode"
          }
        },
        "edges": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/GraphEdge"
          }
        },
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "GraphMetrics": {
      "type": "object",
      "properties": {
        "nodeCount": {
          "type": "integer",
          "format": "int32"
        },
        "edgeCount": {
          "type": "integer",
          "format": "int32"
        },
        "serviceCount": {
          "type": "integer",
          "format": "int32"
        },
        "processCount": {
          "type": "integer",
          "format": "int32"
        },
        "operationCount": {
          "type": "integer",
          "format": "int32"
        },
        "disabledNodeCount": {
          "type": "integer",
          "format": "int32"
        },
        "targetConfigEdgeCount": {
          "type": "integer",
          "format": "int32"
        },
        "routingRuleEdgeCount": {
          "type": "integer",
          "format": "int32"
        },
        "bplCallEdgeCount": {
          "type": "integer",
          "format": "int32"
        },
        "evidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "confirmedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "observedEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "inferredEvidenceCount": {
          "type": "integer",
          "format": "int32"
        },
        "unknownEvidenceCount": {
          "type": "integer",
          "format": "int32"
        }
      }
    },
    "GraphNode": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "label": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "className": {
          "type": "string"
        },
        "enabled": {
          "type": "boolean"
        },
        "protocol": {
          "type": "string"
        },
        "adapterClass": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "GraphEdge": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "target": {
          "type": "string"
        },
        "relationship": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "messageTypes": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "ruleName": {
          "type": "string"
        },
        "processClass": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "Connection": {
      "type": "object",
      "properties": {
        "from": {
          "type": "string"
        },
        "to": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "ruleName": {
          "type": "string"
        },
        "processClass": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ExternalSystem": {
      "type": "object",
      "properties": {
        "component": {
          "type": "string"
        },
        "componentType": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ExternalSystemExplanation": {
      "type": "object",
      "properties": {
        "component": {
          "type": "string"
        },
        "componentType": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "AnalysisArtifact": {
      "type": "object",
      "properties": {
        "kind": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ArtifactExplanation": {
      "type": "object",
      "properties": {
        "kind": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "label": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RuleDetail": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "conditions": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleCondition"
          }
        },
        "sends": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleSend"
          }
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RuleExplanation": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "conditionCount": {
          "type": "integer",
          "format": "int32"
        },
        "targets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "transforms": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "targetCount": {
          "type": "integer",
          "format": "int32"
        },
        "transformCount": {
          "type": "integer",
          "format": "int32"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RuleCondition": {
      "type": "object",
      "properties": {
        "condition": {
          "type": "string"
        },
        "comment": {
          "type": "string"
        },
        "sends": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/RuleSend"
          }
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "RuleSend": {
      "type": "object",
      "properties": {
        "target": {
          "type": "string"
        },
        "transform": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "MessageType": {
      "type": "object",
      "properties": {
        "component": {
          "type": "string"
        },
        "componentType": {
          "type": "string"
        },
        "className": {
          "type": "string"
        },
        "method": {
          "type": "string"
        },
        "parameter": {
          "type": "string"
        },
        "direction": {
          "type": "string"
        },
        "messageClass": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "TransformationDetail": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "sourceKind": {
          "type": "string"
        },
        "sourceClass": {
          "type": "string"
        },
        "targetClass": {
          "type": "string"
        },
        "create": {
          "type": "string"
        },
        "language": {
          "type": "string"
        },
        "actions": {
          "type": "object"
        },
        "assignments": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/TransformationAssignment"
          }
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "TransformationExplanation": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "sourceKind": {
          "type": "string"
        },
        "sourceClass": {
          "type": "string"
        },
        "targetClass": {
          "type": "string"
        },
        "assignmentCount": {
          "type": "integer",
          "format": "int32"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "TransformationAssignment": {
      "type": "object",
      "properties": {
        "property": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "action": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "BusinessProcessDetail": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "requestClass": {
          "type": "string"
        },
        "responseClass": {
          "type": "string"
        },
        "contextClass": {
          "type": "string"
        },
        "actions": {
          "type": "object"
        },
        "calls": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/BusinessProcessCall"
          }
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "BusinessProcessExplanation": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "requestClass": {
          "type": "string"
        },
        "responseClass": {
          "type": "string"
        },
        "contextClass": {
          "type": "string"
        },
        "callTargets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "callCount": {
          "type": "integer",
          "format": "int32"
        },
        "assignCount": {
          "type": "integer",
          "format": "int32"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "BusinessProcessCall": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "target": {
          "type": "string"
        },
        "async": {
          "type": "boolean"
        },
        "timeout": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ComponentExplanation": {
      "type": "object",
      "properties": {
        "component": {
          "type": "string"
        },
        "componentType": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "MessageTypeExplanation": {
      "type": "object",
      "properties": {
        "component": {
          "type": "string"
        },
        "componentType": {
          "type": "string"
        },
        "className": {
          "type": "string"
        },
        "method": {
          "type": "string"
        },
        "parameter": {
          "type": "string"
        },
        "direction": {
          "type": "string"
        },
        "messageClass": {
          "type": "string"
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ConnectionExplanation": {
      "type": "object",
      "properties": {
        "from": {
          "type": "string"
        },
        "to": {
          "type": "string"
        },
        "kind": {
          "type": "string"
        },
        "ruleName": {
          "type": "string"
        },
        "processClass": {
          "type": "string"
        },
        "messageClasses": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "text": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "ProductionRuntime": {
      "type": "object",
      "properties": {
        "requestedProduction": {
          "type": "string"
        },
        "currentProduction": {
          "type": "string"
        },
        "state": {
          "type": "integer",
          "format": "int32"
        },
        "stateLabel": {
          "type": "string"
        },
        "isCurrent": {
          "type": "boolean"
        },
        "isRunning": {
          "type": "boolean"
        },
        "statusText": {
          "type": "string"
        }
      }
    },
    "ProductionRuntimeResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
        },
        "metrics": {
          "$ref": "#/definitions/ProductionRuntimeMetrics"
        },
        "isRunning": {
          "type": "boolean"
        },
        "runtimeState": {
          "type": "string"
        }
      }
    },
    "ProductionActionResponse": {
      "type": "object",
      "properties": {
        "namespace": {
          "type": "string"
        },
        "productionName": {
          "type": "string"
        },
        "action": {
          "type": "string"
        },
        "changed": {
          "type": "boolean"
        },
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
        },
        "metrics": {
          "$ref": "#/definitions/ProductionRuntimeMetrics"
        }
      }
    },
    "ProductionRuntimeMetrics": {
      "type": "object",
      "properties": {
        "state": {
          "type": "integer",
          "format": "int32"
        },
        "isRunning": {
          "type": "boolean"
        },
        "isCurrent": {
          "type": "boolean"
        },
        "hasActiveProduction": {
          "type": "boolean"
        },
        "changed": {
          "type": "boolean"
        },
        "hasError": {
          "type": "boolean"
        }
      }
    },
    "Component": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "className": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "enabled": {
          "type": "boolean"
        },
        "category": {
          "type": "string"
        },
        "poolSize": {
          "type": "integer",
          "format": "int32"
        },
        "comment": {
          "type": "string"
        },
        "adapterClass": {
          "type": "string"
        },
        "protocol": {
          "type": "string"
        },
        "settings": {
          "type": "object"
        },
        "targets": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "confidence": {
          "type": "string"
        },
        "evidence": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Evidence"
          }
        }
      }
    },
    "Evidence": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string"
        },
        "source": {
          "type": "string"
        },
        "component": {
          "type": "string"
        },
        "field": {
          "type": "string"
        },
        "value": {
          "type": "string"
        },
        "confidence": {
          "type": "string"
        }
      }
    },
    "Warning": {
      "type": "object",
      "properties": {
        "code": {
          "type": "string"
        },
        "message": {
          "type": "string"
        }
      }
    },
    "ErrorResponse": {
      "type": "object",
      "properties": {
        "error": {
          "type": "object",
          "properties": {
            "code": {
              "type": "string"
            },
            "message": {
              "type": "string"
            },
            "details": {
              "type": "object"
            },
            "requestId": {
              "type": "string"
            }
          }
        }
      }
    }
  }
}
}

}
