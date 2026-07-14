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
          "type": "object"
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
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
          }
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
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
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
        "componentCount": {
          "type": "integer",
          "format": "int32"
        },
        "runtime": {
          "$ref": "#/definitions/ProductionRuntime"
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
        "warnings": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/Warning"
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
