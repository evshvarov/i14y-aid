import type {
  AIAskResponse,
  AnalysisSettings,
  CodeValue,
  Component,
  GraphEdge,
  GraphNode,
  HealthResponse,
  MessageFacetResponse,
  MessageHeader,
  MonitorMetricSample,
  PayloadMetadata,
  PayloadPreviewField,
  ProductionDetail,
  ProductionLogEntry,
  ProductionSummary,
  SessionTimelineEvent,
  TraceStep,
} from "./types";

const DEFAULT_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "/i14y-aid/api";
const API_BASE_KEY = "i14y-aid.apiBaseUrl";
const API_USERNAME_KEY = "i14y-aid.apiUsername";
const API_PASSWORD_KEY = "i14y-aid.apiPassword";

export type ApiConnection = {
  baseUrl: string;
  username?: string;
  password?: string;
};

export type ApiConnectionTestResult = {
  ok: boolean;
  baseUrl: string;
  httpStatus?: number;
  statusText: string;
  namespace?: string;
};

type ListResponse<T> = {
  namespace?: string;
  items?: T[];
  count?: number;
  totalCount?: number;
  warnings?: unknown[];
};

type SamplesResponse = {
  namespace?: string;
  samples?: MonitorMetricSample[];
  warnings?: unknown[];
};

type GraphResponse = {
  nodes?: GraphNode[];
  edges?: GraphEdge[];
  warnings?: unknown[];
};

type PayloadMetadataResponse = {
  metadata?: PayloadMetadata;
  messageBodyClassName?: string;
  resolvedMessageBodyClassName?: string;
  messageBodyId?: string;
  bodyReferenceAvailable?: boolean;
  restricted?: boolean;
  restrictionReason?: string;
  payloadInspectionEnabled?: boolean;
  payloadMetadataEnabled?: boolean;
  warnings?: unknown[];
};

type PayloadPreviewResponse = {
  metadata?: PayloadMetadata;
  fields?: PayloadPreviewField[];
  restricted?: boolean;
  restrictionReason?: string;
  warnings?: unknown[];
};

function buildQuery(params: Record<string, string | number | boolean | undefined>) {
  const query = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== "") {
      query.set(key, String(value));
    }
  });
  const suffix = query.toString();
  return suffix ? `?${suffix}` : "";
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    Accept: "application/json",
    ...authHeader(),
  };
  if (init?.headers && !(init.headers instanceof Headers) && !Array.isArray(init.headers)) {
    Object.assign(headers, init.headers as Record<string, string>);
  }
  const response = await fetch(`${apiBaseUrl()}${path}`, {
    headers,
    ...init,
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || `Request failed: ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export function apiBaseUrl() {
  return getApiConnection().baseUrl;
}

export function getApiConnection(): ApiConnection {
  return {
    baseUrl: localStorage.getItem(API_BASE_KEY) || DEFAULT_BASE_URL,
    username: localStorage.getItem(API_USERNAME_KEY) || "",
    password: sessionStorage.getItem(API_PASSWORD_KEY) || "",
  };
}

export function saveApiConnection(connection: ApiConnection) {
  const baseUrl = normalizeBaseUrl(connection.baseUrl);
  if (baseUrl === DEFAULT_BASE_URL) localStorage.removeItem(API_BASE_KEY);
  else localStorage.setItem(API_BASE_KEY, baseUrl);

  const username = connection.username?.trim() ?? "";
  if (username) localStorage.setItem(API_USERNAME_KEY, username);
  else localStorage.removeItem(API_USERNAME_KEY);

  if (connection.password !== undefined) {
    if (connection.password) sessionStorage.setItem(API_PASSWORD_KEY, connection.password);
    else sessionStorage.removeItem(API_PASSWORD_KEY);
  }
}

export function clearApiPassword() {
  sessionStorage.removeItem(API_PASSWORD_KEY);
}

export async function testApiConnection(connection: ApiConnection): Promise<ApiConnectionTestResult> {
  const baseUrl = normalizeBaseUrl(connection.baseUrl);
  try {
    const response = await fetch(`${baseUrl}/health`, {
      headers: {
        Accept: "application/json",
        ...authHeader(connection),
      },
    });
    const text = await response.text();
    let payload: HealthResponse | null = null;
    try {
      payload = text ? JSON.parse(text) as HealthResponse : null;
    } catch {
      payload = null;
    }
    return {
      ok: response.ok,
      baseUrl,
      httpStatus: response.status,
      statusText: response.ok ? "Connection succeeded." : text || response.statusText || "Connection failed.",
      namespace: payload?.namespace,
    };
  } catch (err) {
    return {
      ok: false,
      baseUrl,
      statusText: err instanceof Error ? err.message : "Connection failed.",
    };
  }
}

function normalizeBaseUrl(value: string) {
  const trimmed = value.trim() || DEFAULT_BASE_URL;
  return trimmed.replace(/\/+$/, "");
}

function authHeader(connection: ApiConnection = getApiConnection()): Record<string, string> {
  if (!connection.username || !connection.password) return {};
  return {
    Authorization: `Basic ${btoa(`${connection.username}:${connection.password}`)}`,
  };
}

export function getHealth() {
  return request<HealthResponse>("/health");
}

export function getCodes() {
  return request<{
    namespace?: string;
    messageStatuses?: CodeValue[];
    logTypes?: CodeValue[];
  }>("/codes");
}

export async function listProductions() {
  const data = await request<ListResponse<ProductionSummary>>("/productions");
  return data.items ?? [];
}

export function getProduction(name: string) {
  return request<ProductionDetail>(`/productions/${encodeURIComponent(name)}`);
}

export function getProductionSummary(name: string) {
  return request<{
    summary?: string;
    summaryBullets?: string[];
    confidence?: string;
  }>(`/productions/${encodeURIComponent(name)}/summary`);
}

export function getProductionAISummary(name: string) {
  return request<{
    summary?: string;
    provider?: string;
    model?: string;
    confidence?: string;
    warnings?: unknown[];
  }>(`/productions/${encodeURIComponent(name)}/ai/summary`, {
    method: "POST",
    body: JSON.stringify({}),
  });
}

export async function getComponents(name: string) {
  const data = await request<ListResponse<Component>>(
    `/productions/${encodeURIComponent(name)}/components`,
  );
  return data.items ?? [];
}

export type ComponentSettingsUpdate = {
  enabled?: boolean;
  poolSize?: number;
  category?: string;
  comment?: string;
  settings?: Record<string, string>;
};

export function updateComponentSettings(name: string, componentName: string, update: ComponentSettingsUpdate) {
  return request<{
    component?: Component;
    settings?: Record<string, string>;
    updatedAttributes?: Array<{ name?: string; oldValue?: string; value?: string | number | boolean }>;
    updatedSettings?: Array<{ name?: string; oldValue?: string; value?: string }>;
    warnings?: unknown[];
  }>(`/productions/${encodeURIComponent(name)}/components/${encodeURIComponent(componentName)}/settings`, {
    method: "PUT",
    body: JSON.stringify(update),
  });
}

export function getGraph(name: string) {
  return request<GraphResponse>(`/productions/${encodeURIComponent(name)}/graph`);
}

export async function listMessages(
  productionName: string,
  params: {
    limit?: number;
    offset?: number;
    status?: string;
    errorsOnly?: boolean;
    startDate?: string;
    endDate?: string;
    messageId?: string;
    messageBodyClassName?: string;
    sourceOrTarget?: string;
  } = {},
) {
  const data = await request<ListResponse<MessageHeader>>(
    `/productions/${encodeURIComponent(productionName)}/messages${buildQuery(params)}`,
  );
  return data.items ?? [];
}

export function getMessageFacets(
  productionName: string,
  params: {
    status?: string;
    errorsOnly?: boolean;
    startDate?: string;
    endDate?: string;
  } = {},
) {
  return request<MessageFacetResponse>(
    `/productions/${encodeURIComponent(productionName)}/messages/facets${buildQuery(params)}`,
  );
}

export function getMessageDetail(productionName: string, messageId: number) {
  return request<{ message?: MessageHeader; payloadMetadata?: PayloadMetadata }>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}`,
  );
}

export function getMessageDetailDirect(messageId: number) {
  return request<{ message?: MessageHeader; payloadMetadata?: PayloadMetadata }>(`/messages/${messageId}`);
}

export function getMessageTrace(productionName: string, messageId: number) {
  return request<{ steps?: TraceStep[]; summary?: string }>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}/trace`,
  );
}

export function getMessageTraceDirect(messageId: number) {
  return request<{ steps?: TraceStep[]; summary?: string }>(`/messages/${messageId}/trace`);
}

export function getMessagePayload(productionName: string, messageId: number) {
  return request<PayloadMetadataResponse>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}/payload`,
  );
}

export function getMessagePayloadDirect(messageId: number) {
  return request<PayloadMetadataResponse>(`/messages/${messageId}/payload`);
}

export function getMessagePayloadPreview(productionName: string, messageId: number) {
  return request<PayloadPreviewResponse>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}/payload/preview`,
  );
}

export function getMessagePayloadPreviewDirect(messageId: number) {
  return request<PayloadPreviewResponse>(`/messages/${messageId}/payload/preview`);
}

export function getMessageExplanation(productionName: string, messageId: number) {
  return request<{
    summary?: string;
    explanation?: { summary?: string; explanation?: string; evidence?: unknown[] };
    confidence?: string;
    evidence?: unknown[];
  }>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}/explanation`,
  );
}

export function getMessageExplanationDirect(messageId: number) {
  return request<{
    summary?: string;
    explanation?: { summary?: string; explanation?: string; evidence?: unknown[] };
    confidence?: string;
    evidence?: unknown[];
  }>(`/messages/${messageId}/explanation`);
}

export function getSessionTimeline(productionName: string, sessionId: string | number) {
  return request<{ events?: SessionTimelineEvent[] }>(
    `/productions/${encodeURIComponent(productionName)}/sessions/${sessionId}/timeline`,
  );
}

export function resendMessage(productionName: string, messageId: number) {
  return request<Record<string, unknown>>(
    `/productions/${encodeURIComponent(productionName)}/messages/${messageId}/resend`,
    { method: "POST", body: JSON.stringify({}) },
  );
}

export async function listLogs(
  productionName: string,
  params: {
    limit?: number;
    offset?: number;
    type?: string;
    startDate?: string;
    endDate?: string;
  } = {},
) {
  const data = await request<ListResponse<ProductionLogEntry>>(
    `/productions/${encodeURIComponent(productionName)}/logs${buildQuery(params)}`,
  );
  return data.items ?? [];
}

export function getMonitorVolume(namespace?: string) {
  return request<SamplesResponse>(
    `/monitor/interop/volume${buildQuery({ namespace, period: "current" })}`,
  );
}

export function getMonitorMetrics(limit = 12) {
  return request<SamplesResponse>(`/monitor/metrics/interop${buildQuery({ limit })}`);
}

export function enableMonitorMetrics() {
  return request<Record<string, unknown>>("/monitor/metrics/interop/enable", {
    method: "POST",
    body: JSON.stringify({ enableSAM: true, enableActivityStats: false }),
  });
}

export function getSettings() {
  return request<{ settings?: AnalysisSettings }>("/settings");
}

export function updateSettings(settings: AnalysisSettings) {
  return request<{ settings?: AnalysisSettings }>("/settings", {
    method: "PUT",
    body: JSON.stringify(settings),
  });
}

export function rebuildRagIndex(productionName: string) {
  return request<Record<string, unknown>>(
    `/productions/${encodeURIComponent(productionName)}/rag/index`,
    { method: "POST", body: JSON.stringify({ includeRuntime: true }) },
  );
}

export function startProduction(productionName: string) {
  return request<Record<string, unknown>>(
    `/productions/${encodeURIComponent(productionName)}/start`,
    { method: "POST", body: JSON.stringify({}) },
  );
}

export function stopProduction(productionName: string) {
  return request<Record<string, unknown>>(
    `/productions/${encodeURIComponent(productionName)}/stop`,
    { method: "POST", body: JSON.stringify({}) },
  );
}

export function askAI(productionName: string, question: string) {
  return request<AIAskResponse>(
    `/productions/${encodeURIComponent(productionName)}/ai/ask`,
    {
      method: "POST",
      body: JSON.stringify({ question, maxChunks: 8 }),
    },
  );
}
