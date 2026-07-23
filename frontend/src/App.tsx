import { useEffect, useMemo, useRef, useState } from "react";
import type { FormEvent, ReactNode } from "react";
import {
  apiBaseUrl,
  askAI,
  clearApiPassword,
  enableMonitorMetrics,
  getApiConnection,
  getCodes,
  getComponents,
  getGraph,
  getHealth,
  getMessageDetail,
  getMessageDetailDirect,
  getMessageFacets,
  getMessagePayload,
  getMessagePayloadDirect,
  getMessagePayloadPreview,
  getMessagePayloadPreviewDirect,
  getMessageTrace,
  getMessageTraceDirect,
  getMonitorMetrics,
  getMonitorVolume,
  getProduction,
  getProductionAISummary,
  getProductionSummary,
  getSessionTimeline,
  getSettings,
  listLogs,
  listMessages,
  listProductions,
  rebuildRagIndex,
  resendMessage,
  startProduction,
  stopProduction,
  saveApiConnection,
  testApiConnection,
  updateComponentSettings,
  updateSettings,
} from "./api";
import type { ApiConnection, ApiConnectionTestResult } from "./api";
import type { ComponentSettingsUpdate } from "./api";
import type {
  AIAnswerCitation,
  AnalysisSettings,
  CodeValue,
  Component,
  CopilotMessage,
  GraphEdge,
  GraphNode,
  MessageFacetResponse,
  MessageHeader,
  MonitorMetricSample,
  PayloadField,
  PayloadMetadata,
  PayloadPreviewField,
  ProductionDetail,
  ProductionLogEntry,
  ProductionSummary,
  SessionTimelineEvent,
  TraceStep,
} from "./types";

type Section = "monitor" | "overview" | "graph" | "messages" | "logs" | "settings";
type ResendState = "idle" | "sending" | "done";
type MessageDatePreset = "all" | "today" | "yesterday" | "thisWeek" | "thisMonth" | "lastMonth" | "custom";

const messagePageSize = 50;

const navItems: Array<{ id: Section; label: string; icon: string }> = [
  { id: "overview", label: "Overview", icon: "◱" },
  { id: "monitor", label: "Monitor", icon: "▤" },
  { id: "graph", label: "Component graph", icon: "⊞" },
  { id: "messages", label: "Messages", icon: "✉" },
  { id: "logs", label: "Event log", icon: "≣" },
  { id: "settings", label: "Settings", icon: "⚙" },
];

const defaultStatusCodes: CodeValue[] = [
  { code: "1", label: "Created" },
  { code: "2", label: "Queued" },
  { code: "3", label: "Delivered" },
  { code: "4", label: "Discarded" },
  { code: "5", label: "Suspended" },
  { code: "6", label: "Deferred" },
  { code: "7", label: "Aborted" },
  { code: "8", label: "Error" },
  { code: "9", label: "Completed" },
];

const defaultLogCodes: CodeValue[] = [
  { code: "1", label: "Assert" },
  { code: "2", label: "Error" },
  { code: "3", label: "Warning" },
  { code: "4", label: "Info" },
  { code: "5", label: "Trace" },
  { code: "6", label: "Alert" },
];

const suggestions = [
  "What does this production do?",
  "Which data is moved by event messages?",
  "How are services connected to operations?",
  "What errors happened recently?",
];

function shortName(name?: string) {
  if (!name) return "No production";
  return name.split(".").filter(Boolean).slice(-1)[0] || name;
}

function formatTime(value?: string) {
  if (!value) return "--";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return value;
  return parsed.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function formatDateInput(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function dateInputToISO(value: string, endOfDay = false) {
  if (!value) return undefined;
  const date = new Date(`${value}T${endOfDay ? "23:59:59.999" : "00:00:00.000"}`);
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
}

function messageDateRange(preset: MessageDatePreset, customStart: string, customEnd: string) {
  if (preset === "all") return {};
  if (preset === "custom") {
    return {
      startDate: dateInputToISO(customStart),
      endDate: dateInputToISO(customEnd, true),
    };
  }

  const now = new Date();
  const start = new Date(now);
  const end = new Date(now);
  start.setHours(0, 0, 0, 0);
  end.setHours(23, 59, 59, 999);

  if (preset === "yesterday") {
    start.setDate(start.getDate() - 1);
    end.setDate(end.getDate() - 1);
  }
  if (preset === "thisWeek") {
    const mondayOffset = (start.getDay() + 6) % 7;
    start.setDate(start.getDate() - mondayOffset);
  }
  if (preset === "thisMonth") {
    start.setDate(1);
  }
  if (preset === "lastMonth") {
    start.setMonth(start.getMonth() - 1, 1);
    end.setDate(0);
    end.setHours(23, 59, 59, 999);
  }

  return {
    startDate: start.toISOString(),
    endDate: end.toISOString(),
  };
}

function statusLabel(message: MessageHeader, codes: CodeValue[]) {
  if (message.statusLabel) return message.statusLabel;
  const match = codes.find((item) => item.code === String(message.status));
  return match?.label ?? `Status ${message.status ?? "-"}`;
}

function logTypeLabel(log: ProductionLogEntry, codes: CodeValue[]) {
  if (log.typeLabel) return log.typeLabel;
  const match = codes.find((item) => item.code === String(log.type));
  return match?.label ?? `Type ${log.type ?? "-"}`;
}

function statusTone(label?: string, isError?: boolean) {
  const normalized = (label ?? "").toLowerCase();
  if (isError || normalized.includes("error") || normalized.includes("abort")) return "red";
  if (normalized.includes("complete") || normalized.includes("deliver")) return "green";
  if (normalized.includes("queue") || normalized.includes("defer")) return "amber";
  if (normalized.includes("suspend")) return "purple";
  return "gray";
}

function productionRunLabel(production?: Pick<ProductionSummary, "isRunning" | "runtimeState"> | null) {
  if (!production) return "stopped";
  return production.isRunning ? "running" : "stopped";
}

function logTone(label?: string) {
  const normalized = (label ?? "").toLowerCase();
  if (normalized.includes("error") || normalized.includes("alert")) return "red";
  if (normalized.includes("warn")) return "amber";
  if (normalized.includes("trace")) return "purple";
  return "green";
}

function componentKind(component: Component | GraphNode) {
  const raw = `${component.type ?? ""} ${"category" in component ? component.category ?? "" : ""}`.toLowerCase();
  if (raw.includes("service")) return "service";
  if (raw.includes("process")) return "process";
  if (raw.includes("operation")) return "operation";
  return "other";
}

function metricValue(samples: MonitorMetricSample[], includes: string) {
  const sample = samples.find((item) => item.name.toLowerCase().includes(includes));
  if (!sample) return "0";
  return sample.numericValue !== undefined ? sample.numericValue.toLocaleString() : sample.value ?? "0";
}

function normalizeText(value: unknown) {
  return typeof value === "string" && value.trim() ? value : "";
}

function makeId() {
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function normalizeMarkdown(value: string) {
  return value
    .replace(/\r\n/g, "\n")
    .replace(/\s*#\s+(Overview|Runtime Shape|Key Flows|Risks or Gaps)\s*-?\s*/gi, "\n\n# $1\n")
    .replace(/\s+(#{1,3}\s+)/g, "\n\n$1")
    .replace(/\s+-\s+(?=(?:\*\*|`|[A-Z0-9]))/g, "\n- ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function renderInlineMarkdown(text: string) {
  const parts = text.split(/(`[^`]+`|\*\*[^*]+\*\*)/g).filter(Boolean);
  return parts.map((part, index) => {
    if (part.startsWith("`") && part.endsWith("`")) {
      return <code key={`${part}-${index}`}>{part.slice(1, -1)}</code>;
    }
    if (part.startsWith("**") && part.endsWith("**")) {
      return <strong key={`${part}-${index}`}>{renderInlineMarkdown(part.slice(2, -2))}</strong>;
    }
    return <span key={`${part}-${index}`}>{part}</span>;
  });
}

function MarkdownBlock(props: { text?: string; fallback: string; className?: string }) {
  const source = normalizeMarkdown(props.text || props.fallback);
  const lines = source.split("\n");
  const elements: ReactNode[] = [];
  let listItems: string[] = [];

  function flushList() {
    if (!listItems.length) return;
    const index = elements.length;
    elements.push(
      <ul key={`list-${index}`}>
        {listItems.map((item, itemIndex) => <li key={`${item}-${itemIndex}`}>{renderInlineMarkdown(item)}</li>)}
      </ul>,
    );
    listItems = [];
  }

  lines.forEach((rawLine, index) => {
    const line = rawLine.trim();
    if (!line) {
      flushList();
      return;
    }
    const heading = line.match(/^(#{1,3})\s+(.+)$/);
    if (heading) {
      flushList();
      const level = heading[1].length;
      const content = renderInlineMarkdown(heading[2]);
      elements.push(level === 1 ? <h3 key={`h-${index}`}>{content}</h3> : <h4 key={`h-${index}`}>{content}</h4>);
      return;
    }
    const bullet = line.match(/^[-*]\s+(.+)$/);
    if (bullet) {
      listItems.push(bullet[1]);
      return;
    }
    flushList();
    elements.push(<p key={`p-${index}`}>{renderInlineMarkdown(line)}</p>);
  });
  flushList();

  return <div className={`markdown-report ${props.className ?? ""}`}>{elements}</div>;
}

export default function App() {
  const [activeSection, setActiveSection] = useState<Section>("monitor");
  const [productions, setProductions] = useState<ProductionSummary[]>([]);
  const [selectedProduction, setSelectedProduction] = useState("");
  const [production, setProduction] = useState<ProductionDetail | null>(null);
  const [components, setComponents] = useState<Component[]>([]);
  const [nodes, setNodes] = useState<GraphNode[]>([]);
  const [edges, setEdges] = useState<GraphEdge[]>([]);
  const [messages, setMessages] = useState<MessageHeader[]>([]);
  const [facets, setFacets] = useState<MessageFacetResponse>({});
  const [logs, setLogs] = useState<ProductionLogEntry[]>([]);
  const [volume, setVolume] = useState<MonitorMetricSample[]>([]);
  const [interopMetrics, setInteropMetrics] = useState<MonitorMetricSample[]>([]);
  const [summary, setSummary] = useState("");
  const [aiSummary, setAiSummary] = useState("");
  const [settings, setSettings] = useState<AnalysisSettings>({});
  const [apiConnection, setApiConnection] = useState<ApiConnection>(() => getApiConnection());
  const [messageCodes, setMessageCodes] = useState<CodeValue[]>(defaultStatusCodes);
  const [logCodes, setLogCodes] = useState<CodeValue[]>(defaultLogCodes);
  const [namespace, setNamespace] = useState("USER");
  const [apiHealthy, setApiHealthy] = useState(false);
  const [error, setError] = useState("");
  const [serverReadCount, setServerReadCount] = useState(0);
  const [serverReadLabel, setServerReadLabel] = useState("");
  const serverReadId = useRef(0);
  const activeServerReads = useRef<Set<number>>(new Set());
  const [messageFilter, setMessageFilter] = useState("All");
  const [messageOffset, setMessageOffset] = useState(0);
  const [messageDatePreset, setMessageDatePreset] = useState<MessageDatePreset>("all");
  const [messageCustomStart, setMessageCustomStart] = useState("");
  const [messageCustomEnd, setMessageCustomEnd] = useState("");
  const [messageNumberFilter, setMessageNumberFilter] = useState("");
  const [messageBodyClassFilter, setMessageBodyClassFilter] = useState("");
  const [messageSourceTargetFilter, setMessageSourceTargetFilter] = useState("");
  const [logFilter, setLogFilter] = useState("All");
  const [selectedMessage, setSelectedMessage] = useState<MessageHeader | null>(null);
  const [messageDetail, setMessageDetail] = useState<MessageHeader | null>(null);
  const [trace, setTrace] = useState<TraceStep[]>([]);
  const [timeline, setTimeline] = useState<SessionTimelineEvent[]>([]);
  const [payload, setPayload] = useState<PayloadMetadata | null>(null);
  const [previewFields, setPreviewFields] = useState<PayloadPreviewField[]>([]);
  const [explanation, setExplanation] = useState("");
  const [resendState, setResendState] = useState<ResendState>("idle");
  const [copilotOpen, setCopilotOpen] = useState(true);
  const [copilotInput, setCopilotInput] = useState("");
  const [copilotTyping, setCopilotTyping] = useState(false);
  const [thread, setThread] = useState<CopilotMessage[]>([
    {
      id: "hello",
      role: "assistant",
      text: "Ask about this production, its messages, logs, payload schemas, or runtime behavior. Answers cite retrieved RAG chunks when available.",
      citations: [],
    },
  ]);

  const activeProduction = production ?? productions.find((item) => item.name === selectedProduction);
  const productionName = activeProduction?.name ?? selectedProduction;
  const isRunning = Boolean(activeProduction?.isRunning);
  const isReadingServer = serverReadCount > 0;

  useEffect(() => {
    void bootstrap();
  }, []);

  useEffect(() => {
    if (!selectedProduction) return;
    void loadProductionData(selectedProduction);
  }, [selectedProduction]);

  useEffect(() => {
    if (!selectedProduction) return;
    void loadSectionData(selectedProduction, activeSection);
  }, [selectedProduction, activeSection, messageFilter, messageOffset, messageDatePreset, messageCustomStart, messageCustomEnd, messageNumberFilter, messageBodyClassFilter, messageSourceTargetFilter, logFilter]);

  useEffect(() => {
    if (!selectedMessage || !selectedProduction) return;
    void loadMessageDetail(selectedProduction, selectedMessage);
  }, [selectedMessage, selectedProduction]);

  function beginServerRead(label: string) {
    serverReadId.current += 1;
    const id = serverReadId.current;
    let completed = false;
    activeServerReads.current.add(id);
    setServerReadLabel(label);
    setServerReadCount(activeServerReads.current.size);
    const timeout = window.setTimeout(() => endServerRead(), 45000);

    function endServerRead() {
      if (completed) return;
      completed = true;
      window.clearTimeout(timeout);
      activeServerReads.current.delete(id);
      setServerReadCount(activeServerReads.current.size);
      if (activeServerReads.current.size === 0) {
        setServerReadLabel("");
      }
    }

    return endServerRead;
  }

  async function bootstrap() {
    const endServerRead = beginServerRead("initial data");
    setError("");
    try {
      const [health, codes, productionList, settingsResponse] = await Promise.all([
        getHealth().catch(() => null),
        getCodes().catch(() => null),
        listProductions(),
        getSettings().catch(() => null),
      ]);
      if (health?.namespace) setNamespace(health.namespace);
      setApiHealthy(Boolean(health));
      if (codes?.namespace) setNamespace(codes.namespace);
      if (codes?.messageStatuses?.length) setMessageCodes(codes.messageStatuses);
      if (codes?.logTypes?.length) setLogCodes(codes.logTypes);
      if (settingsResponse?.settings) setSettings(settingsResponse.settings);
      setProductions(productionList);
      if (productionList[0]?.name) setSelectedProduction(productionList[0].name);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load explorer data.");
    } finally {
      endServerRead();
    }
  }

  async function loadProductionData(name: string) {
    const endServerRead = beginServerRead("production data");
    setError("");
    try {
      const [detail, summaryResponse, componentList, graph] = await Promise.all([
        getProduction(name),
        getProductionSummary(name).catch(() => null),
        getComponents(name).catch(() => []),
        getGraph(name).catch(() => null),
      ]);
      setProduction(detail);
      setNamespace(detail.namespace ?? namespace);
      setSummary(summaryResponse?.summary ?? detail.summary ?? "");
      setComponents(componentList.length ? componentList : detail.components ?? []);
      setNodes(graph?.nodes ?? []);
      setEdges(graph?.edges ?? []);
      if (settings.aiProviderEnabled && settings.aiSummaryEnabled) {
        getProductionAISummary(name)
          .then((response) => setAiSummary(response.summary ?? ""))
          .catch(() => setAiSummary(""));
      } else {
        setAiSummary("");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load production.");
    } finally {
      endServerRead();
    }
  }

  async function loadSectionData(name: string, section: Section) {
    const endServerRead = beginServerRead(`${section} data`);
    try {
      if (section === "monitor") {
        const [monitorVolume, monitorSamples, recentMessages, recentLogs] = await Promise.all([
          getMonitorVolume(namespace).catch(() => ({ samples: [] })),
          getMonitorMetrics(12).catch(() => ({ samples: [] })),
          listMessages(name, { limit: 8 }).catch(() => []),
          listLogs(name, { limit: 8 }).catch(() => []),
        ]);
        setVolume(monitorVolume.samples ?? []);
        setInteropMetrics(monitorSamples.samples ?? []);
        setMessages(recentMessages);
        setLogs(recentLogs);
      }
      if (section === "messages") {
        const status = messageFilter === "All" ? undefined : messageFilter;
        const dateRange = messageDateRange(messageDatePreset, messageCustomStart, messageCustomEnd);
        const [messageList, facetData] = await Promise.all([
          listMessages(name, {
            limit: messagePageSize,
            offset: messageOffset,
            status,
            messageId: messageNumberFilter.trim(),
            messageBodyClassName: messageBodyClassFilter.trim(),
            sourceOrTarget: messageSourceTargetFilter.trim(),
            ...dateRange,
          }).catch(() => []),
          getMessageFacets(name, dateRange).catch(() => ({})),
        ]);
        setMessages(messageList);
        setFacets(facetData);
      }
      if (section === "logs") {
        const type = logFilter === "All" ? undefined : logFilter;
        setLogs(await listLogs(name, { limit: 80, type }).catch(() => []));
      }
      if (section === "settings") {
        const response = await getSettings().catch(() => null);
        if (response?.settings) setSettings(response.settings);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load section data.");
    } finally {
      endServerRead();
    }
  }

  async function loadMessageDetail(name: string, message: MessageHeader) {
    const endServerRead = beginServerRead(`message #${message.messageId}`);
    setResendState("idle");
    setMessageDetail(message);
    setTrace([]);
    setTimeline([]);
    setPayload(null);
    setPreviewFields([]);
    setExplanation("");
    try {
      const traceEnabled = Boolean(settings.requestTraceAnalysisEnabled);
      const sessionEnabled = Boolean(settings.requestSessionAnalysisEnabled);
      const [detail, traceResponse, payloadResponse, previewResponse] =
        await Promise.all([
          getMessageDetailDirect(message.messageId).catch(() => getMessageDetail(name, message.messageId).catch(() => null)),
          traceEnabled ? getMessageTraceDirect(message.messageId).catch(() => getMessageTrace(name, message.messageId).catch(() => null)) : Promise.resolve(null),
          getMessagePayloadDirect(message.messageId).catch(() => getMessagePayload(name, message.messageId).catch(() => null)),
          getMessagePayloadPreviewDirect(message.messageId).catch(() => getMessagePayloadPreview(name, message.messageId).catch(() => null)),
        ]);
      let effectivePayload = payloadResponse?.metadata ?? detail?.payloadMetadata ?? null;
      let effectivePreview = previewResponse;
      if (!effectivePayload?.fields?.length) {
        const directPayload = await getMessagePayloadDirect(message.messageId).catch(() => null);
        if (directPayload?.metadata?.fields?.length) {
          effectivePayload = directPayload.metadata;
        }
      }
      if (!(effectivePreview?.fields?.length || effectivePreview?.metadata?.fields?.length)) {
        effectivePreview = await getMessagePayloadPreviewDirect(message.messageId).catch(() => effectivePreview);
      }
      const fullMessage = detail?.message ?? message;
      setMessageDetail(fullMessage);
      if (traceEnabled) setTrace(traceResponse?.steps ?? []);
      setPayload(effectivePreview?.metadata ?? effectivePayload);
      setPreviewFields(effectivePreview?.fields ?? (effectivePreview?.metadata?.fields as PayloadPreviewField[] | undefined) ?? []);
      setExplanation("");
      if (sessionEnabled && fullMessage.sessionId) {
        const session = await getSessionTimeline(name, fullMessage.sessionId).catch(() => null);
        setTimeline(session?.events ?? []);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to load message detail.");
    } finally {
      endServerRead();
    }
  }

  async function handleToggleProduction() {
    if (!productionName) return;
    const endServerRead = beginServerRead(isRunning ? "stop production" : "start production");
    try {
      if (isRunning) await stopProduction(productionName);
      else await startProduction(productionName);
      await loadProductionData(productionName);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to change production state.");
    } finally {
      endServerRead();
    }
  }

  async function handleRebuildRag() {
    if (!productionName) return;
    const endServerRead = beginServerRead("RAG index rebuild");
    await sendQuestion(`Rebuild the RAG index for ${shortName(productionName)} and summarize what changed.`, true);
    try {
      await rebuildRagIndex(productionName);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to rebuild RAG index.");
    } finally {
      endServerRead();
    }
  }

  async function handleEnableMetrics() {
    const endServerRead = beginServerRead("monitor metrics");
    try {
      await enableMonitorMetrics();
      const response = await getMonitorMetrics(12);
      setInteropMetrics(response.samples ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to enable metrics.");
    } finally {
      endServerRead();
    }
  }

  function handleMessageFilter(filter: string) {
    setMessageOffset(0);
    setMessageFilter(filter);
  }

  function handleMessageDatePreset(preset: MessageDatePreset) {
    setMessageOffset(0);
    setMessageDatePreset(preset);
  }

  function handleMessageCustomStart(value: string) {
    setMessageOffset(0);
    setMessageCustomStart(value);
  }

  function handleMessageCustomEnd(value: string) {
    setMessageOffset(0);
    setMessageCustomEnd(value);
  }

  function handleMessageNumberFilter(value: string) {
    setMessageOffset(0);
    setMessageNumberFilter(value);
  }

  function handleMessageBodyClassFilter(value: string) {
    setMessageOffset(0);
    setMessageBodyClassFilter(value);
  }

  function handleMessageSourceTargetFilter(value: string) {
    setMessageOffset(0);
    setMessageSourceTargetFilter(value);
  }

  function handleSelectProduction(name: string) {
    setSelectedProduction(name);
    setSelectedMessage(null);
    setMessageOffset(0);
  }

  function handleAdjacentMessage(direction: -1 | 1) {
    if (!selectedMessage) return;
    const index = messages.findIndex((message) => String(message.messageId) === String(selectedMessage.messageId));
    if (index < 0) return;
    const nextMessage = messages[index + direction];
    if (nextMessage) setSelectedMessage(nextMessage);
  }

  async function handleSettingToggle(key: keyof AnalysisSettings) {
    const next = { ...settings, [key]: !settings[key] };
    setSettings(next);
    const endServerRead = beginServerRead("settings");
    try {
      const response = await updateSettings(next);
      if (response.settings) setSettings(response.settings);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to update settings.");
    } finally {
      endServerRead();
    }
  }

  async function handleSettingsSave(patch: AnalysisSettings) {
    const next = { ...settings, ...patch };
    setSettings(next);
    const endServerRead = beginServerRead("settings");
    try {
      const response = await updateSettings(next);
      if (response.settings) setSettings(response.settings);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to update settings.");
      throw err;
    } finally {
      endServerRead();
    }
  }

  async function handleComponentSettingsSave(componentName: string, update: ComponentSettingsUpdate) {
    if (!productionName) return;
    const endServerRead = beginServerRead(`${componentName} settings`);
    setError("");
    try {
      await updateComponentSettings(productionName, componentName, update);
      await loadProductionData(productionName);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to update component settings.");
      throw err;
    } finally {
      endServerRead();
    }
  }

  async function handleApiConnectionSave(connection: ApiConnection) {
    const endServerRead = beginServerRead("API connection");
    saveApiConnection(connection);
    setApiConnection(getApiConnection());
    setSelectedProduction("");
    setProduction(null);
    setComponents([]);
    setNodes([]);
    setEdges([]);
    setMessages([]);
    setLogs([]);
    setFacets({});
    try {
      await bootstrap();
    } finally {
      endServerRead();
    }
  }

  async function handleApiConnectionTest(connection: ApiConnection) {
    const endServerRead = beginServerRead("connection test");
    try {
      return await testApiConnection(connection);
    } finally {
      endServerRead();
    }
  }

  async function handleApiPasswordClear() {
    clearApiPassword();
    setApiConnection(getApiConnection());
  }

  async function handleResend() {
    if (!productionName || !messageDetail) return;
    const endServerRead = beginServerRead(`resend #${messageDetail.messageId}`);
    setResendState("sending");
    try {
      await resendMessage(productionName, messageDetail.messageId);
      setResendState("done");
    } catch (err) {
      setResendState("idle");
      setError(err instanceof Error ? err.message : "Unable to resend message.");
    } finally {
      endServerRead();
    }
  }

  async function sendQuestion(text = copilotInput, skipUserAppend = false) {
    const question = text.trim();
    if (!question || !productionName) return;
    const endServerRead = beginServerRead("AI answer");
    setCopilotOpen(true);
    setCopilotInput("");
    if (!skipUserAppend) {
      setThread((prev) => [...prev, { id: makeId(), role: "user", text: question }]);
    }
    setCopilotTyping(true);
    try {
      const response = await askAI(productionName, question);
      const citations = response.citations ?? [];
      const schemaBased =
        citations.some((item) => item.kind === "message-schema") ||
        (response.chunks ?? []).some((item) => item.kind === "message-schema");
      setThread((prev) => [
        ...prev,
        {
          id: makeId(),
          role: "assistant",
          text: response.answer ?? "No answer was returned.",
          citations,
          schemaBased,
        },
      ]);
    } catch (err) {
      setThread((prev) => [
        ...prev,
        {
          id: makeId(),
          role: "assistant",
          text: err instanceof Error ? err.message : "Unable to ask the copilot.",
          citations: [],
        },
      ]);
    } finally {
      setCopilotTyping(false);
      endServerRead();
    }
  }

  const messageCounts = useMemo(() => {
    const counts = new Map<string, number>();
    messages.forEach((message) => {
      const label = statusLabel(message, messageCodes);
      counts.set(label, (counts.get(label) ?? 0) + 1);
    });
    (facets.statusFacets ?? []).forEach((facet) => {
      if (facet.statusLabel && facet.count) counts.set(facet.statusLabel, facet.count);
    });
    return counts;
  }, [messages, facets, messageCodes]);

  const logCounts = useMemo(() => {
    const counts = new Map<string, number>();
    logs.forEach((log) => {
      const label = logTypeLabel(log, logCodes);
      counts.set(label, (counts.get(label) ?? 0) + 1);
    });
    return counts;
  }, [logs, logCodes]);

  const lanes = useMemo(() => {
    const graphComponents: Component[] = nodes.length
      ? nodes.map((node) => ({
          name: node.label ?? node.id,
          className: node.className,
          type: node.type,
          enabled: node.enabled,
          protocol: node.protocol,
          adapterClass: node.adapterClass,
          targets: edges.filter((edge) => edge.source === node.id).map((edge) => edge.target ?? "").filter(Boolean),
        }))
      : components;
    return {
      service: graphComponents.filter((item) => componentKind(item) === "service"),
      process: graphComponents.filter((item) => componentKind(item) === "process"),
      operation: graphComponents.filter((item) => componentKind(item) === "operation"),
    };
  }, [components, nodes, edges]);

  const volumeBars = useMemo(() => {
    const numeric = volume
      .map((item) => item.numericValue ?? (Number(item.value) || 0))
      .filter((item) => Number.isFinite(item));
    const fallback = [12, 18, 14, 25, 31, 22, 17, 36, 41, 28, 33, 42];
    const values = numeric.length ? numeric.slice(-24) : fallback;
    const max = Math.max(...values, 1);
    return values.map((value, index) => ({
      value,
      height: Math.max(4, Math.round((value / max) * 100)),
      active: index === values.length - 1,
    }));
  }, [volume]);

  const kpis = [
    { label: "Messages", value: String(facets.totalCount ?? messages.length), unit: "24h", delta: "live window" },
    { label: "Throughput", value: metricValue(interopMetrics, "messages"), unit: "/min", delta: "monitor metrics" },
    { label: "Avg processing", value: metricValue(interopMetrics, "duration"), unit: "ms", delta: "from iris_interop" },
    { label: "Queued", value: String(messageCounts.get("Queued") ?? 0), unit: "", delta: "current filter" },
    { label: "Errors", value: String(facets.errorCount ?? messages.filter((item) => item.isError).length), unit: "24h", delta: "needs review", danger: true },
    { label: "Active sessions", value: String(new Set(messages.map((item) => item.sessionId).filter(Boolean)).size), unit: "", delta: "recent messages" },
  ];

  const fieldList = (payload?.fields ?? []) as PayloadField[];
  const selectedMessageIndex = selectedMessage
    ? messages.findIndex((message) => String(message.messageId) === String(selectedMessage.messageId))
    : -1;
  const messageSearchActive = Boolean(messageNumberFilter.trim() || messageBodyClassFilter.trim() || messageSourceTargetFilter.trim());

  return (
    <div className="i14y-app">
      <header className="topbar">
        <div className="brand">
          <div className="brand-chip">i14</div>
          <div>
            <div className="brand-name">Interoperability Aid</div>
            <div className="brand-subtitle">IRIS Production Explainer</div>
          </div>
        </div>
        <div className="topbar-spacer" />
        <div className="mono-pill"><span>ns</span>{namespace}</div>
        <div className="api-path">{apiConnection.baseUrl || apiBaseUrl()}</div>
        {isReadingServer && <div className="server-read-pill"><span />Reading server: {serverReadLabel || "data"}</div>}
        <div className={apiHealthy ? "health-pill healthy" : "health-pill"}>
          <span />
          {apiHealthy ? "API healthy" : "API unknown"}
        </div>
        <button className="primary-btn" onClick={() => setCopilotOpen((open) => !open)}>✦ Copilot</button>
      </header>

      <div className="body-shell">
        <aside className="sidebar">
          <div className="side-section">
            <div className="side-label">Productions</div>
            {productions.length === 0 ? (
              <div className="empty-mini">No productions found</div>
            ) : (
              productions.map((item) => {
                const active = item.name === productionName;
                return (
                  <button
                    className={`production-card ${active ? "active" : ""}`}
                    key={item.name}
                    onClick={() => handleSelectProduction(item.name)}
                  >
                    <span className={item.isRunning ? "dot green" : "dot gray"} />
                    <strong>{shortName(item.name)}</strong>
                    <code>{item.name}</code>
                    <em className={item.isRunning ? "running" : "stopped"}>{productionRunLabel(item)}</em>
                  </button>
                );
              })
            )}
          </div>
          <div className="divider" />
          <nav className="nav">
            {navItems.map((item) => (
              <button
                className={activeSection === item.id ? "active" : ""}
                key={item.id}
                onClick={() => {
                  setActiveSection(item.id);
                  setSelectedMessage(null);
                }}
              >
                <span>{item.icon}</span>
                {item.label}
                {item.id === "messages" && <b>{messages.length}</b>}
                {item.id === "logs" && <b className="red">{logs.filter((log) => logTone(logTypeLabel(log, logCodes)) === "red").length}</b>}
              </button>
            ))}
          </nav>
          <div className="user-chip">
            <div>DV</div>
            <span><strong>dev.user</strong><small>read + control</small></span>
          </div>
        </aside>

        <main className="main">
          <div className="content">
            {error && <div className="alert">{error}</div>}
            {isReadingServer && <div className="server-read-banner"><span />Reading {serverReadLabel || "data"} from the IRIS server...</div>}
            <section className="context-header">
              <div>
                <div className="title-line">
                  <h1>{shortName(productionName)}</h1>
                  <span className={`run-pill ${isRunning ? "running" : "stopped"}`}>
                    <span />
                    {productionRunLabel(activeProduction)}
                  </span>
                </div>
                <code>{productionName || "Select a production"}</code>
              </div>
              <div className="header-actions">
                <button className={isRunning ? "outline danger-text" : "outline"} onClick={handleToggleProduction} disabled={!productionName}>
                  {isRunning ? "Stop production" : "Start production"}
                </button>
                <button className="outline" onClick={handleRebuildRag} disabled={!productionName}>Rebuild RAG index</button>
              </div>
            </section>

            {activeSection === "monitor" && (
              <MonitorView
                kpis={kpis}
                volumeBars={volumeBars}
                samples={interopMetrics}
                messages={messages}
                logs={logs}
                messageCodes={messageCodes}
                logCodes={logCodes}
                onMessages={() => setActiveSection("messages")}
                onLogs={() => setActiveSection("logs")}
                onOpenMessage={setSelectedMessage}
                onEnableMetrics={handleEnableMetrics}
              />
            )}

            {activeSection === "overview" && (
              <OverviewView production={production} summary={summary} aiSummary={aiSummary} components={components} settings={settings} />
            )}

            {activeSection === "graph" && <GraphView lanes={lanes} onSaveSettings={handleComponentSettingsSave} />}

            {activeSection === "messages" && (
              <MessagesView
                messages={messages}
                codes={messageCodes}
                activeFilter={messageFilter}
                counts={messageCounts}
                pageSize={messagePageSize}
                offset={messageOffset}
                datePreset={messageDatePreset}
                customStart={messageCustomStart}
                customEnd={messageCustomEnd}
                messageNumber={messageNumberFilter}
                messageBodyClass={messageBodyClassFilter}
                sourceOrTarget={messageSourceTargetFilter}
                totalCount={messageSearchActive ? messages.length : facets.totalCount}
                onFilter={handleMessageFilter}
                onPrevPage={() => setMessageOffset((value) => Math.max(0, value - messagePageSize))}
                onNextPage={() => setMessageOffset((value) => value + messagePageSize)}
                onDatePreset={handleMessageDatePreset}
                onCustomStart={handleMessageCustomStart}
                onCustomEnd={handleMessageCustomEnd}
                onMessageNumber={handleMessageNumberFilter}
                onMessageBodyClass={handleMessageBodyClassFilter}
                onSourceOrTarget={handleMessageSourceTargetFilter}
                onOpen={setSelectedMessage}
              />
            )}

            {activeSection === "logs" && (
              <LogsView logs={logs} codes={logCodes} activeFilter={logFilter} counts={logCounts} onFilter={setLogFilter} />
            )}

            {activeSection === "settings" && (
              <SettingsView
                settings={settings}
                connection={apiConnection}
                onToggle={handleSettingToggle}
                onSaveSettings={handleSettingsSave}
                onSaveConnection={handleApiConnectionSave}
                onTestConnection={handleApiConnectionTest}
                onClearPassword={handleApiPasswordClear}
              />
            )}
          </div>
        </main>

        {copilotOpen && (
          <CopilotPanel
            productionName={shortName(productionName)}
            thread={thread}
            input={copilotInput}
            typing={copilotTyping}
            onClose={() => setCopilotOpen(false)}
            onInput={setCopilotInput}
            onSend={() => void sendQuestion()}
            onSuggestion={(question) => void sendQuestion(question)}
          />
        )}
      </div>

      {selectedMessage && (
        <MessageDetail
          message={messageDetail ?? selectedMessage}
          payload={payload}
          previewFields={previewFields}
          fields={fieldList}
          trace={trace}
          timeline={timeline}
          showTrace={Boolean(settings.requestTraceAnalysisEnabled)}
          showSession={Boolean(settings.requestSessionAnalysisEnabled)}
          explanation={explanation}
          statusLabel={statusLabel(messageDetail ?? selectedMessage, messageCodes)}
          resendEnabled={Boolean(settings.messageResendEnabled)}
          resendState={resendState}
          hasPrevious={selectedMessageIndex > 0}
          hasNext={selectedMessageIndex > -1 && selectedMessageIndex < messages.length - 1}
          onClose={() => setSelectedMessage(null)}
          onPrevious={() => handleAdjacentMessage(-1)}
          onNext={() => handleAdjacentMessage(1)}
          onResend={handleResend}
          onAsk={() => {
            setSelectedMessage(null);
            void sendQuestion(`Explain message ${selectedMessage.messageId}, its payload schema, and the related trace.`);
          }}
        />
      )}
    </div>
  );
}

function MonitorView(props: {
  kpis: Array<{ label: string; value: string; unit: string; delta: string; danger?: boolean }>;
  volumeBars: Array<{ value: number; height: number; active: boolean }>;
  samples: MonitorMetricSample[];
  messages: MessageHeader[];
  logs: ProductionLogEntry[];
  messageCodes: CodeValue[];
  logCodes: CodeValue[];
  onMessages: () => void;
  onLogs: () => void;
  onOpenMessage: (message: MessageHeader) => void;
  onEnableMetrics: () => void;
}) {
  const noInteropMetrics = props.samples.length === 0;
  return (
    <div className="stack">
      <div className="kpi-grid">
        {props.kpis.map((kpi) => (
          <article className="kpi-card" key={kpi.label}>
            <span>{kpi.label}</span>
            <div><strong className={kpi.danger ? "danger-value" : ""}>{kpi.value}</strong><em>{kpi.unit}</em></div>
            <small className={kpi.danger ? "danger-value" : ""}>{kpi.delta}</small>
          </article>
        ))}
      </div>
      <div className="two-grid">
        <Panel title="Message volume" subtitle="monitor/interop/volume · last 24h" aside="per hour">
          <div className="bar-chart">
            {props.volumeBars.map((bar, index) => (
              <span key={`${bar.value}-${index}`} className={bar.active ? "active" : ""} style={{ height: `${bar.height}%` }} title={String(bar.value)} />
            ))}
          </div>
          <div className="axis"><span>12:00</span><span>06:00</span><span>12:00</span><span>18:00</span><span>now</span></div>
        </Panel>
        <Panel title="Interop metrics" subtitle="monitor/metrics/interop" aside={noInteropMetrics ? <button className="link-btn" onClick={props.onEnableMetrics}>Enable</button> : undefined}>
          {noInteropMetrics ? (
            <div className="empty-state">No iris_interop metrics returned. Enable namespace metrics and refresh.</div>
          ) : (
            props.samples.slice(0, 7).map((sample) => (
              <div className="metric-row" key={`${sample.name}-${JSON.stringify(sample.labels ?? {})}`}>
                <code>{sample.name}</code>
                <strong className={sample.name.toLowerCase().includes("error") ? "danger-value" : ""}>{sample.numericValue ?? sample.value ?? "0"}</strong>
              </div>
            ))
          )}
        </Panel>
      </div>
      <div className="two-grid">
        <Panel title="Recent messages" aside={<button className="link-btn" onClick={props.onMessages}>View all →</button>}>
          <div className="scroll-list">
            {props.messages.map((message) => {
              const label = statusLabel(message, props.messageCodes);
              return (
                <button className="message-row" key={message.messageId} onClick={() => props.onOpenMessage(message)}>
                  <code>#{message.messageId}</code>
                  <span><strong>{message.sourceConfigName || "--"} <em>→</em> {message.targetConfigName || "--"}</strong><small>{message.messageBodyClassName || "no body class"}</small></span>
                  <b className={`chip ${statusTone(label, message.isError)}`}>{label}</b>
                  <time>{formatTime(message.timeCreated)}</time>
                </button>
              );
            })}
          </div>
        </Panel>
        <Panel title="Event log" aside={<button className="link-btn" onClick={props.onLogs}>View all →</button>}>
          <div className="scroll-list log-list">
            {props.logs.map((log) => {
              const label = logTypeLabel(log, props.logCodes);
              return (
                <div className="log-row" key={log.logId}>
                  <span className={`square ${logTone(label)}`} />
                  <div><strong className={logTone(label)}>{label}</strong><time>{formatTime(log.timeLogged)}</time><p>{log.text || "--"}</p></div>
                </div>
              );
            })}
          </div>
        </Panel>
      </div>
    </div>
  );
}

function OverviewView(props: { production: ProductionDetail | null; summary: string; aiSummary: string; components: Component[]; settings: AnalysisSettings }) {
  const facts = [
    ["Namespace", props.production?.namespace ?? "USER"],
    ["Status", productionRunLabel(props.production)],
    ["Components", String(props.production?.componentCount ?? props.components.length)],
    ["Adapters", String(props.components.filter((item) => item.adapterClass).length)],
    ["Message classes", String(new Set(props.components.map((item) => item.className).filter(Boolean)).size)],
    ["RAG chunks", props.settings.ragRuntimeDataEnabled ? "enabled" : "not enabled"],
  ];
  return (
    <div className="overview-grid">
      <div className="stack">
        <Panel title="What this production does">
          <p className="body-copy">{props.summary || props.production?.description || "No deterministic summary returned yet."}</p>
          <div className="tag-row">
            {["deterministic", "runtime", "messages", "logs"].map((tag) => <code key={tag}>{tag}</code>)}
          </div>
        </Panel>
        <div className="ai-card">
          <div><span>✦</span><strong>AI production summary</strong><code>deterministic + OpenAI</code></div>
          <MarkdownBlock text={props.aiSummary} fallback="AI summary is not available or not enabled. The deterministic summary above remains available." />
          <small>grounded in retrieved analysis chunks · confidence depends on citations</small>
        </div>
      </div>
      <div className="stack">
        <Panel title="Composition">
          {[
            ["Business services", props.production?.serviceCount ?? 0, "blue"],
            ["Business processes", props.production?.processCount ?? 0, "purple"],
            ["Business operations", props.production?.operationCount ?? 0, "green"],
          ].map(([label, value, color]) => (
            <div className="fact-row" key={label}><span><i className={`square ${color}`} />{label}</span><strong>{value}</strong></div>
          ))}
        </Panel>
        <Panel title="Facts">
          {facts.map(([key, value]) => <div className="fact-row" key={key}><span>{key}</span><code>{value}</code></div>)}
        </Panel>
      </div>
    </div>
  );
}

function GraphView(props: {
  lanes: Record<"service" | "process" | "operation", Component[]>;
  onSaveSettings: (componentName: string, update: ComponentSettingsUpdate) => Promise<void>;
}) {
  const configs = [
    ["service", "Business Services", "blue"],
    ["process", "Business Processes", "purple"],
    ["operation", "Business Operations", "green"],
  ] as const;
  return (
    <Panel title="Component flow" subtitle="productions/{name}/graph · service → process → operation">
      <div className="lane-grid">
        {configs.map(([key, label, color]) => (
          <section className="lane" key={key}>
            <h3><i className={`square ${color}`} />{label}</h3>
            {props.lanes[key].length === 0 ? <div className="empty-state">No components discovered.</div> : props.lanes[key].map((component) => (
              <article className={`component-card ${color}`} key={component.name}>
                <strong>{component.name}</strong>
                <code>{component.className || "--"}</code>
                <div className="tag-row">
                  <span>{component.protocol || component.adapterClass || component.type || "component"}</span>
                  {Boolean(component.targets?.length) && <span>→ {component.targets?.join(", ")}</span>}
                </div>
                <ComponentSettingsEditor component={component} onSave={props.onSaveSettings} />
              </article>
            ))}
          </section>
        ))}
      </div>
      <footer className="panel-note">Targets come from static graph edges and TargetConfigNames where available.</footer>
    </Panel>
  );
}

function ComponentSettingsEditor(props: {
  component: Component;
  onSave: (componentName: string, update: ComponentSettingsUpdate) => Promise<void>;
}) {
  const componentKey = JSON.stringify({
    enabled: props.component.enabled,
    poolSize: props.component.poolSize,
    category: props.component.category,
    comment: props.component.comment,
    settings: props.component.settings ?? {},
  });
  const [draft, setDraft] = useState<ComponentSettingsUpdate>(() => normalizeComponentDraft(props.component));
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState("");

  useEffect(() => {
    setDraft(normalizeComponentDraft(props.component));
    setStatus("");
  }, [props.component.name, componentKey]);

  const settingsEntries = Object.entries(draft.settings ?? {});
  const original = normalizeComponentDraft(props.component);
  const dirty = componentDraftChanged(draft, original);

  async function handleSave(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!dirty || saving) return;
    setSaving(true);
    setStatus("");
    try {
      await props.onSave(props.component.name, draft);
      setStatus("Saved");
    } catch {
      setStatus("Save failed");
    } finally {
      setSaving(false);
    }
  }

  return (
    <form className="component-settings" onSubmit={handleSave}>
      <div className="component-settings-title">
        <span>Parameters</span>
        {status && <small>{status}</small>}
      </div>
      <label className="component-switch-row">
        <span>Enabled</span>
        <input
          checked={Boolean(draft.enabled)}
          type="checkbox"
          onChange={(event) => setDraft((current) => ({ ...current, enabled: event.target.checked }))}
        />
      </label>
      <label className="component-setting-row">
        <span>PoolSize</span>
        <input
          inputMode="numeric"
          min="0"
          type="number"
          value={String(draft.poolSize ?? 0)}
          onChange={(event) => setDraft((current) => ({ ...current, poolSize: Number(event.target.value) }))}
        />
      </label>
      <label className="component-setting-row">
        <span>Category</span>
        <input
          value={draft.category ?? ""}
          onChange={(event) => setDraft((current) => ({ ...current, category: event.target.value }))}
        />
      </label>
      <label className="component-setting-row">
        <span>Comment</span>
        <input
          value={draft.comment ?? ""}
          onChange={(event) => setDraft((current) => ({ ...current, comment: event.target.value }))}
        />
      </label>
      {settingsEntries.length === 0 && <div className="component-settings-empty">No component-specific settings discovered.</div>}
      {settingsEntries.map(([key, value]) => (
        <label className="component-setting-row" key={key}>
          <span>{key}</span>
          <input
            value={value}
            onChange={(event) => setDraft((current) => ({
              ...current,
              settings: { ...(current.settings ?? {}), [key]: event.target.value },
            }))}
          />
        </label>
      ))}
      <button className="mini-save" type="submit" disabled={!dirty || saving}>
        {saving ? "Saving" : "Save settings"}
      </button>
    </form>
  );
}

function normalizeComponentDraft(component: Component): ComponentSettingsUpdate {
  return {
    enabled: component.enabled !== false,
    poolSize: component.poolSize ?? 0,
    category: component.category ?? "",
    comment: component.comment ?? "",
    settings: normalizeComponentSettings(component.settings),
  };
}

function normalizeComponentSettings(settings?: Record<string, string>) {
  return Object.fromEntries(
    Object.entries(settings ?? {}).map(([key, value]) => [key, String(value ?? "")]),
  );
}

function componentDraftChanged(current: ComponentSettingsUpdate, original: ComponentSettingsUpdate) {
  if (Boolean(current.enabled) !== Boolean(original.enabled)) return true;
  if (Number(current.poolSize ?? 0) !== Number(original.poolSize ?? 0)) return true;
  if ((current.category ?? "") !== (original.category ?? "")) return true;
  if ((current.comment ?? "") !== (original.comment ?? "")) return true;
  const currentSettings = current.settings ?? {};
  const originalSettings = original.settings ?? {};
  const keys = new Set([...Object.keys(currentSettings), ...Object.keys(originalSettings)]);
  for (const key of keys) {
    if ((currentSettings[key] ?? "") !== (originalSettings[key] ?? "")) return true;
  }
  return false;
}

function MessagesView(props: {
  messages: MessageHeader[];
  codes: CodeValue[];
  activeFilter: string;
  counts: Map<string, number>;
  pageSize: number;
  offset: number;
  datePreset: MessageDatePreset;
  customStart: string;
  customEnd: string;
  messageNumber: string;
  messageBodyClass: string;
  sourceOrTarget: string;
  totalCount?: number;
  onFilter: (filter: string) => void;
  onPrevPage: () => void;
  onNextPage: () => void;
  onDatePreset: (preset: MessageDatePreset) => void;
  onCustomStart: (value: string) => void;
  onCustomEnd: (value: string) => void;
  onMessageNumber: (value: string) => void;
  onMessageBodyClass: (value: string) => void;
  onSourceOrTarget: (value: string) => void;
  onOpen: (message: MessageHeader) => void;
}) {
  const filters = ["All", "Completed", "Error", "Queued", "Suspended", "Discarded"];
  const dateFilters: Array<[MessageDatePreset, string]> = [
    ["all", "All time"],
    ["today", "Today"],
    ["yesterday", "Yesterday"],
    ["thisWeek", "This week"],
    ["thisMonth", "This month"],
    ["lastMonth", "Last month"],
    ["custom", "Custom"],
  ];
  const selectedTotal = props.activeFilter === "All" ? props.totalCount ?? props.messages.length : props.counts.get(props.activeFilter) ?? 0;
  const pageStart = selectedTotal === 0 ? 0 : props.offset + 1;
  const pageEnd = Math.min(props.offset + props.messages.length, selectedTotal);
  const canGoNext = props.offset + props.pageSize < selectedTotal;
  return (
    <Panel title="Messages">
      <FilterRow filters={filters} active={props.activeFilter} counts={props.counts} total={props.totalCount ?? props.messages.length} onSelect={props.onFilter} />
      <div className="message-tools">
        <div className="date-filter-row">
          {dateFilters.map(([preset, label]) => (
            <button className={props.datePreset === preset ? "active" : ""} key={preset} onClick={() => props.onDatePreset(preset)}>{label}</button>
          ))}
        </div>
        {props.datePreset === "custom" && (
          <div className="custom-date-row">
            <label><span>Start</span><input type="date" value={props.customStart} onChange={(event) => props.onCustomStart(event.target.value)} /></label>
            <label><span>End</span><input type="date" value={props.customEnd} onChange={(event) => props.onCustomEnd(event.target.value)} /></label>
          </div>
        )}
        <div className="message-search-row">
          <label><span>Message #</span><input inputMode="numeric" placeholder="1925750" value={props.messageNumber} onChange={(event) => props.onMessageNumber(event.target.value.replace(/[^\d]/g, ""))} /></label>
          <label><span>Body class / type</span><input placeholder="gc.outbox.msg.eventrequest" value={props.messageBodyClass} onChange={(event) => props.onMessageBodyClass(event.target.value)} /></label>
          <label><span>Source / target</span><input placeholder="OutboxAckOperation" value={props.sourceOrTarget} onChange={(event) => props.onSourceOrTarget(event.target.value)} /></label>
        </div>
        <div className="pager-row">
          <span>{pageStart}-{pageEnd} of {selectedTotal}</span>
          <div>
            <button className="outline" onClick={props.onPrevPage} disabled={props.offset === 0}>Previous</button>
            <button className="outline" onClick={props.onNextPage} disabled={!canGoNext}>Next</button>
          </div>
        </div>
      </div>
      <div className="message-table">
        <div className="table-head"><span>ID</span><span>Source</span><span>Target</span><span>Session</span><span>Status</span><span>Time</span></div>
        {props.messages.map((message) => {
          const label = statusLabel(message, props.codes);
          return (
            <button className="table-row" key={message.messageId} onClick={() => props.onOpen(message)}>
              <code>#{message.messageId}</code>
              <span>{message.sourceConfigName || "--"}</span>
              <span>{message.targetConfigName || "--"}</span>
              <code>{message.sessionId || "--"}</code>
              <b className={`chip ${statusTone(label, message.isError)}`}>{label}</b>
              <time>{formatTime(message.timeCreated)}</time>
            </button>
          );
        })}
        {props.messages.length === 0 && <div className="empty-state">No messages matched the selected filters.</div>}
      </div>
    </Panel>
  );
}

function LogsView(props: { logs: ProductionLogEntry[]; codes: CodeValue[]; activeFilter: string; counts: Map<string, number>; onFilter: (filter: string) => void }) {
  const filters = ["All", "Error", "Warning", "Info", "Trace", "Alert"];
  return (
    <Panel title="Event log">
      <FilterRow filters={filters} active={props.activeFilter} counts={props.counts} total={props.logs.length} onSelect={props.onFilter} />
      <div className="event-list">
        {props.logs.map((log) => {
          const label = logTypeLabel(log, props.codes);
          return (
            <article className="event-row" key={log.logId}>
              <i className={`square ${logTone(label)}`} />
              <strong className={logTone(label)}>{label}</strong>
              <span>{log.source || "--"}</span>
              <time>{formatTime(log.timeLogged)}</time>
              <p>{log.text || "--"}</p>
            </article>
          );
        })}
      </div>
    </Panel>
  );
}

function SettingsView(props: {
  settings: AnalysisSettings;
  connection: ApiConnection;
  onToggle: (key: keyof AnalysisSettings) => void;
  onSaveSettings: (patch: AnalysisSettings) => Promise<void>;
  onSaveConnection: (connection: ApiConnection) => Promise<void>;
  onTestConnection: (connection: ApiConnection) => Promise<ApiConnectionTestResult>;
  onClearPassword: () => Promise<void>;
}) {
  const [baseUrl, setBaseUrl] = useState(props.connection.baseUrl);
  const [apiUsername, setApiUsername] = useState(props.connection.username ?? "");
  const [apiPassword, setApiPassword] = useState(props.connection.password ?? "");
  const [connectionBusy, setConnectionBusy] = useState<"idle" | "saving" | "testing">("idle");
  const [connectionResult, setConnectionResult] = useState<ApiConnectionTestResult | null>(null);
  const [limitBusy, setLimitBusy] = useState(false);
  const [limitStatus, setLimitStatus] = useState("");
  const [limitValues, setLimitValues] = useState({
    maxTraceDepth: String(props.settings.maxTraceDepth ?? 50),
    defaultMessageLookbackDays: String(props.settings.defaultMessageLookbackDays ?? 7),
    maxMessagesReturned: String(props.settings.maxMessagesReturned ?? 100),
    ragRuntimeMaxMessages: String(props.settings.ragRuntimeMaxMessages ?? 100),
    ragPayloadMaxFields: String(props.settings.ragPayloadMaxFields ?? 50),
    explanationVerbosity: props.settings.explanationVerbosity ?? "normal",
  });

  useEffect(() => {
    setBaseUrl(props.connection.baseUrl);
    setApiUsername(props.connection.username ?? "");
    setApiPassword(props.connection.password ?? "");
  }, [props.connection.baseUrl, props.connection.username, props.connection.password]);

  useEffect(() => {
    setLimitValues({
      maxTraceDepth: String(props.settings.maxTraceDepth ?? 50),
      defaultMessageLookbackDays: String(props.settings.defaultMessageLookbackDays ?? 7),
      maxMessagesReturned: String(props.settings.maxMessagesReturned ?? 100),
      ragRuntimeMaxMessages: String(props.settings.ragRuntimeMaxMessages ?? 100),
      ragPayloadMaxFields: String(props.settings.ragPayloadMaxFields ?? 50),
      explanationVerbosity: props.settings.explanationVerbosity ?? "normal",
    });
  }, [
    props.settings.maxTraceDepth,
    props.settings.defaultMessageLookbackDays,
    props.settings.maxMessagesReturned,
    props.settings.ragRuntimeMaxMessages,
    props.settings.ragPayloadMaxFields,
    props.settings.explanationVerbosity,
  ]);

  const toggles: Array<[keyof AnalysisSettings, string]> = [
    ["aiProviderEnabled", "AI provider"],
    ["aiSummaryEnabled", "AI summaries"],
    ["payloadInspectionEnabled", "Payload inspection"],
    ["payloadMetadataEnabled", "Payload metadata"],
    ["requestSessionAnalysisEnabled", "Request session"],
    ["requestTraceAnalysisEnabled", "Request trace"],
    ["ragRuntimeDataEnabled", "Runtime RAG"],
    ["ragPayloadIndexingEnabled", "Payload RAG"],
  ];
  const limitFields: Array<{ key: keyof typeof limitValues; label: string; type: "number" | "select"; min?: number; max?: number }> = [
    { key: "maxTraceDepth", label: "Max trace depth", type: "number", min: 1, max: 500 },
    { key: "defaultMessageLookbackDays", label: "Lookback days", type: "number", min: 1, max: 365 },
    { key: "maxMessagesReturned", label: "Max messages", type: "number", min: 1, max: 5000 },
    { key: "ragRuntimeMaxMessages", label: "RAG messages", type: "number", min: 0, max: 5000 },
    { key: "ragPayloadMaxFields", label: "RAG payload fields", type: "number", min: 0, max: 500 },
    { key: "explanationVerbosity", label: "Verbosity", type: "select" },
  ];

  function connectionPayload(): ApiConnection {
    return {
      baseUrl: baseUrl.trim(),
      username: apiUsername.trim(),
      password: apiPassword,
    };
  }

  async function saveConnection() {
    setConnectionBusy("saving");
    setConnectionResult(null);
    try {
      await props.onSaveConnection(connectionPayload());
      setConnectionResult({ ok: true, baseUrl: baseUrl.trim(), statusText: "API connection saved. Data reloaded from this target." });
    } catch (err) {
      setConnectionResult({ ok: false, baseUrl: baseUrl.trim(), statusText: err instanceof Error ? err.message : "Unable to save API connection." });
    } finally {
      setConnectionBusy("idle");
    }
  }

  async function testConnection() {
    setConnectionBusy("testing");
    setConnectionResult(null);
    try {
      setConnectionResult(await props.onTestConnection(connectionPayload()));
    } catch (err) {
      setConnectionResult({ ok: false, baseUrl: baseUrl.trim(), statusText: err instanceof Error ? err.message : "API connection test failed." });
    } finally {
      setConnectionBusy("idle");
    }
  }

  async function clearPassword() {
    setConnectionBusy("saving");
    setConnectionResult(null);
    try {
      await props.onClearPassword();
      setApiPassword("");
      setConnectionResult({ ok: true, baseUrl: baseUrl.trim(), statusText: "Session password cleared." });
    } catch (err) {
      setConnectionResult({ ok: false, baseUrl: baseUrl.trim(), statusText: err instanceof Error ? err.message : "Unable to clear password." });
    } finally {
      setConnectionBusy("idle");
    }
  }

  function updateLimit(key: keyof typeof limitValues, value: string) {
    setLimitStatus("");
    setLimitValues((current) => ({ ...current, [key]: value }));
  }

  function numericLimit(key: keyof typeof limitValues, fallback: number) {
    const parsed = Number.parseInt(limitValues[key], 10);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  async function saveLimits() {
    setLimitBusy(true);
    setLimitStatus("");
    try {
      await props.onSaveSettings({
        maxTraceDepth: numericLimit("maxTraceDepth", props.settings.maxTraceDepth ?? 50),
        defaultMessageLookbackDays: numericLimit("defaultMessageLookbackDays", props.settings.defaultMessageLookbackDays ?? 7),
        maxMessagesReturned: numericLimit("maxMessagesReturned", props.settings.maxMessagesReturned ?? 100),
        ragRuntimeMaxMessages: numericLimit("ragRuntimeMaxMessages", props.settings.ragRuntimeMaxMessages ?? 100),
        ragPayloadMaxFields: numericLimit("ragPayloadMaxFields", props.settings.ragPayloadMaxFields ?? 50),
        explanationVerbosity: limitValues.explanationVerbosity,
      });
      setLimitStatus("Runtime limits saved.");
    } catch (err) {
      setLimitStatus(err instanceof Error ? err.message : "Unable to save runtime limits.");
    } finally {
      setLimitBusy(false);
    }
  }

  function resetLimits() {
    setLimitStatus("");
    setLimitValues({
      maxTraceDepth: String(props.settings.maxTraceDepth ?? 50),
      defaultMessageLookbackDays: String(props.settings.defaultMessageLookbackDays ?? 7),
      maxMessagesReturned: String(props.settings.maxMessagesReturned ?? 100),
      ragRuntimeMaxMessages: String(props.settings.ragRuntimeMaxMessages ?? 100),
      ragPayloadMaxFields: String(props.settings.ragPayloadMaxFields ?? 50),
      explanationVerbosity: props.settings.explanationVerbosity ?? "normal",
    });
  }

  return (
    <div className="settings-grid">
      <Panel title="Analysis & AI" subtitle="PUT /settings">
        {toggles.map(([key, label]) => (
          <button className="toggle-row" key={key} onClick={() => props.onToggle(key)}>
            <span>{label}</span>
            <i className={props.settings[key] ? "toggle on" : "toggle"}><b /></i>
          </button>
        ))}
      </Panel>
      <Panel title="Runtime limits" subtitle="PUT /settings">
        <div className="limits-form">
          {limitFields.map((field) => (
            <label className="limit-row" key={field.key}>
              <span>{field.label}</span>
              {field.type === "select" ? (
                <select value={limitValues[field.key]} onChange={(event) => updateLimit(field.key, event.target.value)}>
                  <option value="brief">brief</option>
                  <option value="normal">normal</option>
                  <option value="detailed">detailed</option>
                </select>
              ) : (
                <input
                  type="number"
                  min={field.min}
                  max={field.max}
                  value={limitValues[field.key]}
                  onChange={(event) => updateLimit(field.key, event.target.value)}
                />
              )}
            </label>
          ))}
          <div className="connection-actions">
            <button className="primary-btn" onClick={saveLimits} disabled={limitBusy}>{limitBusy ? "Saving..." : "Save limits"}</button>
            <button className="outline" onClick={resetLimits} disabled={limitBusy}>Reset</button>
          </div>
          {limitStatus && <div className="settings-status">{limitStatus}</div>}
        </div>
      </Panel>
      <Panel title="OpenAI key">
        <div className="key-state"><span className={props.settings.aiApiKeyConfigured ? "dot green" : "dot gray"} />{props.settings.aiApiKeyConfigured ? "Configured" : "Not configured"}</div>
        <p className="body-copy">source: {props.settings.aiApiKeySource || "none"}. The key value is never returned by the API.</p>
      </Panel>
      <Panel title="API connection" subtitle="browser setting">
        <div className="connection-form">
          <label>
            <span>API URL</span>
            <input value={baseUrl} onChange={(event) => setBaseUrl(event.target.value)} placeholder="https://iris.example.com/i14y-aid/api" />
          </label>
          <label>
            <span>Login</span>
            <input value={apiUsername} onChange={(event) => setApiUsername(event.target.value)} placeholder="iris user" />
          </label>
          <label>
            <span>Password</span>
            <input value={apiPassword} onChange={(event) => setApiPassword(event.target.value)} type="password" placeholder="session password" />
          </label>
          <div className="connection-actions">
            <button className="outline" onClick={saveConnection} disabled={connectionBusy !== "idle"}>{connectionBusy === "saving" ? "Saving..." : "Save and reload"}</button>
            <button className="primary-btn" onClick={testConnection} disabled={connectionBusy !== "idle"}>{connectionBusy === "testing" ? "Testing..." : "Test connection"}</button>
            {Boolean(props.connection.password) && <button className="link-btn" onClick={clearPassword} disabled={connectionBusy !== "idle"}>Clear password</button>}
          </div>
          <div className="key-state"><span className={props.connection.password ? "dot green" : "dot gray"} />{props.connection.password ? "Session password set" : "No session password"}</div>
          <p className="body-copy">URL and login are stored in this browser. Password is kept only in session storage and is sent directly from the browser to the selected API.</p>
          {connectionResult && (
            <div className={`test-result ${connectionResult.ok ? "ok" : "fail"}`}>
              <strong>{connectionResult.ok ? "Connection ok" : "Connection issue"}</strong>
              <span>{connectionResult.statusText || "--"}</span>
              {Boolean(connectionResult.httpStatus) && <code>HTTP {connectionResult.httpStatus}</code>}
              {connectionResult.namespace && <code>ns {connectionResult.namespace}</code>}
            </div>
          )}
        </div>
      </Panel>
    </div>
  );
}

function CopilotPanel(props: { productionName: string; thread: CopilotMessage[]; input: string; typing: boolean; onClose: () => void; onInput: (value: string) => void; onSend: () => void; onSuggestion: (value: string) => void }) {
  return (
    <aside className="copilot">
      <header><div className="ai-avatar">✦</div><div><strong>Production Copilot</strong><code>RAG over {props.productionName}</code></div><button onClick={props.onClose}>×</button></header>
      <div className="thread">
        {props.thread.map((message) => (
          <article className={`bubble ${message.role}`} key={message.id}>
            {message.role === "assistant" ? (
              <MarkdownBlock text={message.text} fallback="No answer was returned." className="compact" />
            ) : (
              <p>{message.text}</p>
            )}
            {message.schemaBased && <small className="schema-hint">schema-based evidence</small>}
            {Boolean(message.citations?.length) && <div className="citation-row">{message.citations?.slice(0, 5).map((citation, index) => <code key={`${citation.chunkId}-${index}`}>{citation.kind === "message-schema" ? "◇" : "▪"} {citation.title || citation.component || citation.chunkId}</code>)}</div>}
          </article>
        ))}
        {props.typing && <div className="typing"><span /><span /><span /></div>}
      </div>
      <footer>
        <div className="suggestions">{suggestions.map((item) => <button key={item} onClick={() => props.onSuggestion(item)}>{item}</button>)}</div>
        <div className="composer">
          <input value={props.input} onChange={(event) => props.onInput(event.target.value)} onKeyDown={(event) => { if (event.key === "Enter") props.onSend(); }} placeholder="Ask about this production" />
          <button onClick={props.onSend}>↑</button>
        </div>
        <small>answers cite retrieved chunks · never live payload values</small>
      </footer>
    </aside>
  );
}

function copyTextToClipboard(text: string) {
  if (navigator.clipboard?.writeText) {
    return navigator.clipboard.writeText(text);
  }
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "true");
  textarea.style.position = "fixed";
  textarea.style.left = "-9999px";
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand("copy");
  document.body.removeChild(textarea);
  return Promise.resolve();
}

function payloadCopyText(message: MessageHeader, payload: PayloadMetadata | null, fields: PayloadField[], previewFields: PayloadPreviewField[]) {
  const previewByName = new Map(previewFields.map((field) => [field.name, field]));
  return JSON.stringify(
    {
      messageId: message.messageId,
      sessionId: message.sessionId,
      sourceConfigName: message.sourceConfigName,
      targetConfigName: message.targetConfigName,
      messageBodyClassName: payload?.messageBodyClassName || message.messageBodyClassName || "",
      resolvedMessageBodyClassName: payload?.resolvedMessageBodyClassName || "",
      messageBodyId: payload?.messageBodyId || message.messageBodyId || "",
      restricted: Boolean(payload?.restricted),
      restrictionReason: payload?.restrictionReason || "",
      fields: fields.map((field) => {
        const preview = previewByName.get(field.name);
        return {
          name: field.name || "",
          type: field.type || "",
          kind: field.kind || (field.collection ? "collection" : field.object ? "object" : "scalar"),
          value: preview ? (preview.redacted ? "***REDACTED***" : preview.value ?? "") : undefined,
          redacted: Boolean(preview?.redacted),
        };
      }),
      previewOnlyFields: previewFields
        .filter((field) => !fields.some((item) => item.name === field.name))
        .map((field) => ({
          name: field.name || "",
          type: field.type || "",
          value: field.redacted ? "***REDACTED***" : field.value ?? "",
          redacted: Boolean(field.redacted),
        })),
      warnings: payload?.warnings ?? [],
    },
    null,
    2,
  );
}

function MessageDetail(props: {
  message: MessageHeader;
  payload: PayloadMetadata | null;
  previewFields: PayloadPreviewField[];
  fields: PayloadField[];
  trace: TraceStep[];
  timeline: SessionTimelineEvent[];
  showTrace: boolean;
  showSession: boolean;
  explanation: string;
  statusLabel: string;
  resendEnabled: boolean;
  resendState: ResendState;
  hasPrevious: boolean;
  hasNext: boolean;
  onClose: () => void;
  onPrevious: () => void;
  onNext: () => void;
  onResend: () => void;
  onAsk: () => void;
}) {
  const previewByName = new Map(props.previewFields.map((field) => [field.name, field]));
  const [copyState, setCopyState] = useState<"idle" | "copied" | "failed">("idle");
  async function copyPayload() {
    setCopyState("idle");
    try {
      await copyTextToClipboard(payloadCopyText(props.message, props.payload, props.fields, props.previewFields));
      setCopyState("copied");
      window.setTimeout(() => setCopyState("idle"), 1800);
    } catch {
      setCopyState("failed");
    }
  }
  return (
    <div className="scrim" onClick={props.onClose}>
      <aside className="detail" onClick={(event) => event.stopPropagation()}>
        <header>
          <div><strong>#{props.message.messageId}</strong><b className={`chip ${statusTone(props.statusLabel, props.message.isError)}`}>{props.statusLabel}</b><code>status {props.message.status ?? "-"}</code></div>
          <nav className="detail-nav" aria-label="Message navigation">
            <button aria-label="Previous message" title="Previous message" onClick={props.onPrevious} disabled={!props.hasPrevious}>‹</button>
            <button aria-label="Next message" title="Next message" onClick={props.onNext} disabled={!props.hasNext}>›</button>
            <button aria-label="Close message" title="Close" onClick={props.onClose}>×</button>
          </nav>
        </header>
        <div className="detail-body">
          <Panel title="Header">
            <div className="kv-grid">
              {[
                ["Message ID", props.message.messageId],
                ["Session", props.message.sessionId],
                ["Source", props.message.sourceConfigName],
                ["Target", props.message.targetConfigName],
                ["Body class", props.message.messageBodyClassName],
                ["Time created", props.message.timeCreated],
                ["Priority", props.message.priority ?? "--"],
                ["Status", `${props.statusLabel} (${props.message.status ?? "-"})`],
              ].map(([key, value]) => <div key={key}><span>{key}</span><code>{String(value ?? "--")}</code></div>)}
            </div>
          </Panel>
          {props.showSession && (
            <Panel title="Session timeline">
              <div className="timeline">
                {(props.timeline.length ? props.timeline : []).map((event) => (
                  <div className={event.isError ? "bad" : ""} key={`${event.type}-${event.sequence}-${event.timestamp}`}>
                    <strong>{event.source || event.target || event.type || "event"}</strong><time>{formatTime(event.timestamp)}</time><p>{event.text || event.statusLabel || event.status || "--"}</p>
                  </div>
                ))}
                {props.timeline.length === 0 && <div className="empty-state">No timeline events returned.</div>}
              </div>
            </Panel>
          )}
          {props.showTrace && (
            <Panel title="Trace">
              {props.trace.length === 0 ? <div className="empty-state">No trace steps returned.</div> : props.trace.map((step) => (
                <div className="trace-row" key={`${step.sequence}-${step.messageId}`}>
                  <code>{step.sequence ?? "-"}</code><span>{step.source || "--"} → {step.target || "--"}</span><strong>{step.invocation || step.statusLabel || "--"}</strong>
                </div>
              ))}
            </Panel>
          )}
          <Panel title="Payload metadata">
            <div className="payload-head">
              <code>{props.payload?.messageBodyClassName || props.message.messageBodyClassName || "--"}</code>
              {props.payload?.resolvedMessageBodyClassName && props.payload.resolvedMessageBodyClassName !== props.payload.messageBodyClassName && <span>resolved: <code>{props.payload.resolvedMessageBodyClassName}</code></span>}
              {props.payload?.restricted && <b className="chip amber">{props.payload.restrictionReason || "restricted"}</b>}
              <div className="payload-copy-actions">
                {copyState === "failed" && <span className="copy-failed">Copy failed</span>}
                <button className="outline" onClick={copyPayload}>{copyState === "copied" ? "Copied" : "Copy payload"}</button>
              </div>
            </div>
            <div className="field-list">
              {props.fields.map((field, index) => {
                const preview = previewByName.get(field.name);
                return (
                  <div key={`${field.name}-${index}`}>
                    <code>{field.name || "--"}</code>
                    <span>{field.type || "--"}</span>
                    <b>{field.kind || (field.collection ? "collection" : field.object ? "object" : "scalar")}</b>
                    <strong className={preview?.redacted ? "preview-value redacted" : "preview-value"}>{preview ? (preview.redacted ? "***REDACTED***" : preview.value ?? "") : "metadata only"}</strong>
                  </div>
                );
              })}
              {props.fields.length === 0 && <div className="empty-state">No field metadata returned.</div>}
            </div>
            {props.payload?.warnings?.map((warning, index) => <div className="preview-note" key={`${warning.code}-${index}`}>{warning.code}: {warning.message}</div>)}
            {props.previewFields.length > 0 && <div className="preview-note">Preview values shown inline above. Values can be redacted by configured patterns.</div>}
          </Panel>
          <div className="ai-card">
            <div><span>✦</span><strong>Deterministic explanation</strong><code>confidence medium</code></div>
            <MarkdownBlock text={props.explanation} fallback="No deterministic explanation returned for this message." />
          </div>
          <div className="detail-actions">
            <button className="primary-btn" onClick={props.onAsk}>✦ Ask copilot about this</button>
            {props.resendEnabled && <button className="outline" onClick={props.onResend} disabled={props.resendState === "sending" || props.resendState === "done"}>{props.resendState === "sending" ? "Resending..." : props.resendState === "done" ? "Queued ✓" : "Resend message"}</button>}
          </div>
        </div>
      </aside>
    </div>
  );
}

function FilterRow(props: { filters: string[]; active: string; counts: Map<string, number>; total: number; onSelect: (filter: string) => void }) {
  return (
    <div className="filter-row">
      {props.filters.map((filter) => (
        <button className={props.active === filter ? "active" : ""} key={filter} onClick={() => props.onSelect(filter)}>
          {filter} <code>{filter === "All" ? props.total : props.counts.get(filter) ?? 0}</code>
        </button>
      ))}
    </div>
  );
}

function Panel(props: { title: string; subtitle?: string; aside?: React.ReactNode; children: React.ReactNode }) {
  return (
    <section className="panel">
      <header className="panel-header">
        <div><h2>{props.title}</h2>{props.subtitle && <code>{props.subtitle}</code>}</div>
        {props.aside}
      </header>
      {props.children}
    </section>
  );
}
