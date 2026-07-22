export type Warning = {
  code?: string;
  message?: string;
};

export type Evidence = {
  type?: string;
  source?: string;
  component?: string;
  field?: string;
  value?: string;
  confidence?: string;
};

export type CodeValue = {
  code: string;
  label: string;
  description?: string;
};

export type HealthResponse = {
  status?: string;
  namespace?: string;
  service?: string;
  version?: string;
};

export type ProductionSummary = {
  name: string;
  namespace?: string;
  description?: string;
  componentCount?: number;
  serviceCount?: number;
  processCount?: number;
  operationCount?: number;
  disabledComponentCount?: number;
  isRunning?: boolean;
  runtimeState?: string;
};

export type ProductionDetail = ProductionSummary & {
  summary?: string;
  runtime?: Record<string, unknown>;
  runtimeMetrics?: Record<string, unknown>;
  components?: Component[];
  summaryBullets?: string[];
  metrics?: Record<string, unknown>;
  evidence?: Evidence[];
};

export type Component = {
  name: string;
  className?: string;
  type?: string;
  enabled?: boolean;
  category?: string;
  poolSize?: number;
  comment?: string;
  adapterClass?: string;
  protocol?: string;
  settings?: Record<string, string>;
  targets?: string[];
};

export type GraphNode = {
  id: string;
  label?: string;
  type?: string;
  className?: string;
  enabled?: boolean;
  protocol?: string;
  adapterClass?: string;
};

export type GraphEdge = {
  id?: string;
  source?: string;
  target?: string;
  relationship?: string;
  kind?: string;
  messageTypes?: string[];
};

export type MessageHeader = {
  messageId: number;
  sessionId?: number | string;
  timeCreated?: string;
  timeProcessed?: string;
  sourceConfigName?: string;
  targetConfigName?: string;
  messageBodyClassName?: string;
  messageBodyId?: string;
  status?: string;
  statusLabel?: string;
  isError?: boolean;
  errorStatus?: string;
  type?: string;
  invocation?: string;
  priority?: string | number;
};

export type MessageFacetResponse = {
  totalCount?: number;
  errorCount?: number;
  statusNames?: string[];
  statusFacets?: Array<{ status?: string; statusLabel?: string; count?: number }>;
  metrics?: Record<string, unknown>;
  warnings?: Warning[];
};

export type ProductionLogEntry = {
  logId: number;
  timeLogged?: string;
  type?: string;
  typeLabel?: string;
  source?: string;
  sessionId?: string;
  job?: string;
  text?: string;
  productionName?: string;
  inProduction?: boolean;
};

export type MonitorMetricSample = {
  name: string;
  value?: string;
  numeric?: boolean;
  numericValue?: number;
  labels?: Record<string, string>;
};

export type PayloadMetadata = {
  messageId?: number;
  messageBodyClassName?: string;
  resolvedMessageBodyClassName?: string;
  messageBodyId?: string;
  payloadReturned?: boolean;
  payloadInspectionEnabled?: boolean;
  payloadMetadataEnabled?: boolean;
  bodyReferenceAvailable?: boolean;
  bodyClassExists?: boolean;
  restricted?: boolean;
  restrictionReason?: string;
  fields?: PayloadField[];
  warnings?: Warning[];
};

export type PayloadField = {
  name?: string;
  type?: string;
  kind?: string;
  scalar?: boolean;
  collection?: boolean;
  object?: boolean;
};

export type PayloadPreviewField = {
  name?: string;
  type?: string;
  value?: string;
  redacted?: boolean;
};

export type TraceStep = {
  sequence?: number;
  messageId?: number;
  sessionId?: number | string;
  timeCreated?: string;
  timeProcessed?: string;
  source?: string;
  target?: string;
  status?: string;
  statusLabel?: string;
  isError?: boolean;
  invocation?: string;
  messageBodyClassName?: string;
  explanation?: string;
};

export type SessionTimelineEvent = {
  sequence?: number;
  type?: string;
  timestamp?: string;
  messageId?: number;
  logId?: number;
  sessionId?: string;
  source?: string;
  target?: string;
  status?: string;
  statusLabel?: string;
  isError?: boolean;
  text?: string;
};

export type RAGChunk = {
  id?: string;
  kind?: string;
  title?: string;
  text?: string;
  source?: string;
  component?: string;
  confidence?: string;
  score?: number;
};

export type AIAnswerCitation = {
  chunkId?: string;
  originalCitation?: string;
  normalized?: boolean;
  kind?: string;
  title?: string;
  component?: string;
  source?: string;
  confidence?: string;
};

export type AIAskResponse = {
  generated?: boolean;
  answer?: string;
  provider?: string;
  model?: string;
  chunkCount?: number;
  totalChunkCount?: number;
  chunks?: RAGChunk[];
  citations?: AIAnswerCitation[];
  invalidCitationCount?: number;
  answerGrounded?: boolean;
  warnings?: Warning[];
};

export type AnalysisSettings = {
  runtimeMessageAnalysisEnabled?: boolean;
  payloadInspectionEnabled?: boolean;
  payloadMetadataEnabled?: boolean;
  requestSessionAnalysisEnabled?: boolean;
  requestTraceAnalysisEnabled?: boolean;
  messageResendEnabled?: boolean;
  maxMessagesReturned?: number;
  maxTraceDepth?: number;
  defaultMessageLookbackDays?: number;
  explanationVerbosity?: string;
  aiProviderEnabled?: boolean;
  aiSummaryEnabled?: boolean;
  aiProvider?: string;
  aiModel?: string;
  aiEndpoint?: string;
  ragRuntimeDataEnabled?: boolean;
  ragRuntimeLookbackHours?: number;
  ragRuntimeMaxMessages?: number;
  ragRuntimeMaxLogs?: number;
  ragPayloadIndexingEnabled?: boolean;
  ragPayloadMaxFields?: number;
  aiApiKeyConfigured?: boolean;
  aiApiKeySource?: string;
  openAIApiKey?: string;
  clearOpenAIApiKey?: boolean;
};

export type CopilotMessage = {
  id: string;
  role: "user" | "assistant";
  text: string;
  citations?: AIAnswerCitation[];
  schemaBased?: boolean;
};
