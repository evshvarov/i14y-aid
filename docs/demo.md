# Demo Workflow

This workflow exercises the explainer with the sample CSV interoperability production.

## Prerequisites

- IRIS container for this repository is running.
- Backend API is available at `http://localhost:57337/i14y-aid/api`.
- Optional UI is running from the sibling `i14y-aid-ui` project.

Start the backend container:

```sh
docker compose up -d
```

Install the sample CSV interoperability production:

```objectscript
zpm "install esh-i14y-csv"
```

If you are running that from the host shell against the local container:

```sh
printf 'zn "USER"\nzpm "install esh-i14y-csv"\nhalt\n' | docker compose exec -T iris iris session iris
```

## 1. Confirm The Explainer API

```sh
curl http://localhost:57337/i14y-aid/api/health
curl http://localhost:57337/i14y-aid/api/capabilities
curl http://localhost:57337/i14y-aid/api/settings
```

The responses should report namespace `USER`, Swagger `2.0`, and runtime trace support when `Ens.MessageHeader` is available.

## 2. Find The Sample Production

List productions:

```sh
curl http://localhost:57337/i14y-aid/api/productions
```

If the CSV sample is installed, select its production name from the response. The examples below use:

```text
esh.i14y.csv.F2CProduction
```

If your installed package uses a different production class, replace that value in the commands below.

## 3. Inspect Static Analysis

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/components"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/graph"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/analysis"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/summary"
```

For focused component detail, URL-encode the component name if it contains spaces:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/components/FileIn"
```

## 4. Start The Production

Check status:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/status"
```

Start it:

```sh
curl -X POST "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/start"
```

You can also use the UI production controls.

## 5. Drop A Test CSV File

Create a file under the sample production input folder:

```objectscript
Set dir = "/home/irisowner/irisdev/in/"
Set file = dir _ "data1.csv"

Do ##class(%File).CreateDirectoryChain(dir)

Set stream = ##class(%Stream.FileCharacter).%New()
Set stream.Filename = file

Do stream.WriteLine("day,fahrenheit")
Do stream.WriteLine("1,68")
Do stream.WriteLine("2,72")
Do stream.WriteLine("3,75")
Do stream.WriteLine("4,70")
Do stream.WriteLine("5,66")

Set sc = stream.%Save()
Write $System.Status.GetErrorText(sc), !
```

The same snippet is kept in `docs/examples.txt`.

## 6. Inspect Runtime Messages

List production-scoped messages:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages?limit=25"
```

List production-scoped event logs:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/logs?limit=25"
```

List message facets for filters:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/facets?limit=100"
```

Pick a `messageId` from the response, then inspect detail, trace, explanation, and payload metadata:

```sh
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1/trace"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1/session"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1/explanation"
curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1/payload"
```

Payload metadata is intentionally safe: the response reports body class/id and restriction flags, but does not return message body content.
Production-scoped trace responses also report how many reconstructed session steps belong to the selected production and mark each step as inside or outside that production.

To inspect redacted scalar payload fields, enable payload inspection and call the preview endpoint:

```sh
curl -X PUT http://localhost:57337/i14y-aid/api/settings \
  -H "Content-Type: application/json" \
  -d '{"payloadInspectionEnabled":1,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email"}'

curl "http://localhost:57337/i14y-aid/api/productions/esh.i14y.csv.F2CProduction/messages/1/payload/preview"
```

## 7. Use The UI

From the sibling UI project:

```sh
npm run dev -- --port 5174
```

If that port is occupied, Vite will choose the next available port.

Open the UI and confirm the API base is:

```text
http://localhost:57337/i14y-aid/api
```

Recommended UI path:

1. Select the CSV production from the left sidebar.
2. Review runtime state and start/stop controls.
3. Inspect the production graph.
4. Click graph nodes or component rows to load focused component detail.
5. Open the Messages window.
6. Select a runtime message to inspect trace, payload metadata, and payload preview when enabled.
7. Adjust Runtime Settings only when you want to change query limits or verbosity.

## 8. Reset Settings After Experiments

```sh
curl -X PUT http://localhost:57337/i14y-aid/api/settings \
  -H "Content-Type: application/json" \
  -d '{"runtimeMessageAnalysisEnabled":1,"payloadInspectionEnabled":0,"messageResendEnabled":0,"maxMessagesReturned":100,"maxTraceDepth":50,"defaultMessageLookbackDays":7,"fieldRedactionPatterns":"patient,ssn,mrn,dob,address,phone,email","classExclusions":"","productionExclusions":"","sourceCodeInferenceEnabled":0,"explanationVerbosity":"normal","aiProviderEnabled":0}'
```

## Known Limitations

- Analysis is scoped to the current namespace.
- Production definitions are read, not modified.
- Payload preview is settings-gated and returns scalar fields only, with configured redaction patterns applied.
- Full object graph payload inspection is not implemented in this increment.
- Static analysis depends on accessible compiled class metadata and XData.
