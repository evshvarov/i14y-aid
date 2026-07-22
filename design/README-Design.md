# Handoff: Interoperability Aid — IRIS Production Explorer UI

## Overview
A developer-facing UI layer for **InterSystems IRIS Interoperability productions**. It lets a developer understand, at a glance, **what a production does**, **how it works** (component flow), **its live metrics/messages/logs**, and **ask AI questions** about the production, its messages, and its logs — grounded in the backend's RAG index with citations.

The backend is the `esh-i14y-aid` IRIS module, which exposes a REST API at `/i14y-aid/api`. This UI is the frontend for that API. Backend + API contract: https://github.com/evshvarov/i14y-aid (see `README.md` and `api/i14y-openapi20.json`).

## About the Design Files
The file in this bundle — `i14y-aid Explorer.dc.html` — is a **design reference created in HTML**. It is a prototype that shows the intended look, layout, and behavior. It is **not production code to copy directly**, and it runs on a bespoke "Design Component" runtime, not a standard React/Vue setup.

The task is to **recreate this design in your target codebase** using its established framework, component library, and patterns (React, Vue, Angular, etc.). If no frontend exists yet, choose an appropriate stack — the design maps naturally to React + a data-fetching layer (React Query/SWR) against the `/i14y-aid/api` endpoints. All sample data in the prototype should be replaced with real API calls (see "Data & API mapping" below).

## Fidelity
**High-fidelity.** Final colors, typography, spacing, and interactions are specified below and should be reproduced faithfully, adapted to your component system. The one caveat: the AI copilot answers in the prototype are **scripted samples** to demonstrate the interaction — real answers come from `POST /productions/{name}/ai/ask`.

---

## Layout Shell

Full-viewport (`100vh`), no page scroll; regions scroll independently.

- **Top bar** — fixed height `54px`, background `#0e2350`, light text `#eaf0fb`.
  - Left: logo chip (`26×26`, radius `6px`, bg `#2b5cd6`, text "i14") + product name "Interoperability Aid" (`14px/600`) with subtitle "IRIS Production Explainer" (`10.5px`, IBM Plex Mono, `#8ea3ce`).
  - Right group: namespace pill (`ns` label + `USER`), API base path `/i14y-aid/api`, a health pill (green dot `#2ec478` with pulse animation + "API healthy" on a `rgba(46,196,120,.14)` bg), and a primary **Copilot** button (bg `#2b5cd6`, radius `7px`) that toggles the copilot panel.
- **Body** — flex row filling remaining height:
  - **Left sidebar** — fixed `258px`, white, right border `#dde2ea`. Contains the production selector list (top) and the section nav (below a divider), plus a user chip pinned to the bottom.
  - **Main** — flexible, `overflow:auto`, bg `#eef1f5`, content max-width `1180px`, padding `20px 24px`. Holds the section header + active section.
  - **Copilot panel** — fixed `372px`, white, left border `#dde2ea`; conditionally rendered when open. Header / scrolling thread / input composer.
- **Message detail** — a right-anchored slide-over (`560px`, max `92vw`) over a `rgba(14,35,80,.28)` scrim; `z-index:40`; enter animation `translateX(24px)→0` + fade, `.22s ease`.

### Sidebar — production selector
Section label "PRODUCTIONS" (`10.5px/600`, uppercase, letter-spacing `.7px`, `#8792a3`). Each production is a button card (radius `9px`, padding `10px 11px`, `7px` gap between):
- Status dot `7px` (`#1a7f52` running, `#a2abb8` stopped) + short name (`12.5px/600`, ellipsis).
- Full class name (`10px`, IBM Plex Mono, `#8792a3`, ellipsis).
- Status word (`10px/600`, colored by status).
- **Active** card: bg `#eef3fc`, border `#c3d3f0`, title `#12327a`. Inactive: bg `#fff`, border `#e6eaf1`, title `#33405a`. Hover border `#b9c6de`.

### Sidebar — section nav
Buttons (radius `8px`, padding `9px 11px`, `13px` text) with a leading glyph column (`18px`), label, and optional right badge pill (`10.5px` mono). Active item: bg `#eef3fc`, text `#12327a`, weight `600`. Inactive: transparent, `#4b5568`, weight `500`; hover bg `#f1f4f9`. Items: Overview, Monitor, Component graph, Messages (badge "10"), Event log (badge "2", red `#c0392b`/`#fbeae7`), Settings.

### Section header (above every section)
Production short name (`22px/700`, letter-spacing `-.3px`) + a status pill (dot + word, colored). Below: full class name (`12px` mono, `#8792a3`). Right: **Stop/Start production** button (outlined, red text when running) and **Rebuild RAG index** button (outlined, neutral).

---

## Screens / Views

### 1. Monitor (default landing)
Purpose: live health at a glance. Top-to-bottom:
- **KPI cards** — responsive grid `repeat(auto-fit, minmax(158px,1fr))`, gap `12px`. Card: white, border `#dde2ea`, radius `11px`, padding `14px 15px`. Label (`11px`, `#8792a3`), value (`25px/700`, letter-spacing `-.5px`), unit (`12px`, `#8792a3`), delta line (`11px/500`, colored). Six cards: Messages (24h) `1,284` ▲6.2%; Throughput `42 /min`; Avg processing `118 ms` ▼9ms; Queued `3` (1 suspended, amber); Errors (24h) `7` (red value + red delta); Active sessions `5`.
- **Volume + Interop row** — grid `repeat(auto-fit, minmax(300px,1fr))`, gap `16px`.
  - *Message volume* card: title + subtitle "monitor/interop/volume · last 24h". A 24-bar column chart, container height `130px`, bars `flex:1`, gap `4px`, radius `3px 3px 0 0`, `min-height:3px`; bars `#c3d3f0` except the last `#2b5cd6`; hover `filter:brightness(.9)`. Axis labels below in mono `#a2abb8`.
  - *Interop metrics* card: title + subtitle "monitor/metrics/interop". Rows of `iris_interop_*` name (mono `#5a6577`) + value (`15px/700`; error count value red). Row divider `#f1f4f9`.
- **Recent messages + Event log row** — grid `repeat(auto-fit, minmax(300px,1fr))`, gap `16px`. Panel headers use `flex-wrap` so the "View all →" link (`#2b5cd6`) never clips.
  - *Recent messages* (max-height `290px`, scroll): rows are clickable (hover bg `#f7f9fc`) → open message detail. Columns: `#id` (mono `#8792a3`), source → target (`12px/500` ellipsis) with mono body-class subtitle, status chip, time (mono).
  - *Event log* (max-height `290px`): each row a `7px` square colored by type + type label (`10px/700` uppercase, colored) + time (mono) + message text (`11.5px`, `#4b5568`).

### 2. Overview
Purpose: what the production does + AI summary. Grid `repeat(auto-fit, minmax(300px,1fr))`, gap `16px`.
- Left column: **"What this production does"** card (plain summary paragraph `14px/1.6` + mono tag chips). **AI production summary** card on a blue gradient (`#f4f7fd→#eef3fc`, border `#d6e0f2`): ✦ header + "deterministic + OpenAI" mono chip + summary + "grounded in 14 analysis chunks · confidence high".
- Right column: **Composition** card (services 2 / processes 2 / operations 3, each with a colored square) and **Facts** card (Namespace, Status, Components, Adapters, Message classes, RAG chunks) as key/value rows (value in mono).

### 3. Component graph
Purpose: how it works. Single card. Title + subtitle "productions/{name}/graph · service → process → operation". Three lanes in grid `repeat(auto-fit, minmax(200px,1fr))`, gap `14px`:
- Lane header: colored square + uppercase title (`11px/700`). Lane accent colors: Business Services `#2b5cd6`, Business Processes `#7c4dd6`, Business Operations `#1a7f52`.
- Component card per item: border/tint from lane, radius `10px`, padding `12px 13px`. Name (`13px/600`), class (`10.5px` mono, ellipsis), then chips: protocol chip (white, `#4b5568`) and, when the component has targets, a "→ Target, Target" chip (`#eef3fc`/`#d6e0f2`/`#3a5aa0`). Footer note explains targets come from `TargetConfigNames`.

### 4. Messages
Purpose: browse/filter all messages. Single card:
- Filter chips row (wrap): All, Completed, Error, Queued, Suspended, Discarded — each shows a count. Active chip: bg `#12327a`, white. Inactive: white, `#4b5568`, border `#dde2ea`.
- Table header + rows on grid `56px 1fr 1fr 90px 108px 62px`: ID (mono `#2b5cd6/600`), Source, Target (`#4b5568`), Session (mono `#8792a3`), Status chip, Time (mono, right). Rows clickable → detail; hover `#f7f9fc`.

### 5. Event log
Purpose: browse/filter logs. Filter chips: All, Error, Warning, Info, Trace, Alert (with counts, same active styling). Rows: colored `9px` square + type label (`10.5px/700` uppercase) + source (`11.5px/600` `#33405a`) + time (mono) + text (`12.5px`, `#4b5568`).

### 6. Message detail (slide-over)
Purpose: full drill-down. Sticky dark header (`#0e2350`) with `#id` (mono), status chip, "status {code}" (mono), and a close ×. Body padding `18px`, stacked white cards (border `#dde2ea`, radius `11px`):
- **Header** — 2-col grid of key/value pairs (value mono `12.5px/600`): Message ID, Session, Source, Target, Body class, Time created, Priority, Status (label + code).
- **Session timeline** — vertical timeline (2px rail `#e3e9f1`); each event: `10px` dot (green `#1a7f52` ok / red `#c0392b` error), component name (`12.5px/600`), time (mono), label (`11.5px`, `#5a6577`).
- **Trace** — rows: seq (mono), from → to, action (`SendRequestAsync`/`SendRequestSync`), duration (mono, green ok / red fail).
- **Payload metadata** — body-class chip; rows of field name (mono `#33405a`) + type (mono `#8792a3`) + kind chip (scalar green / object blue / collection purple). **No values.** Footer: redacted scalar preview box ("scalars only", values redacted as `***REDACTED***`).
- **Deterministic explanation** — blue-gradient card: ✦ header + confidence chip (colored: high green, medium amber). Explanation paragraph + "Evidence" list (each `›`-bulleted).
- **Actions** — "✦ Ask copilot about this" (closes detail, sends a question to the copilot) and, gated by `showResendControls`, a **Resend message** button (states: Resend → "Resending…" → "Queued ✓").

### 7. Settings
Grid `repeat(auto-fit, minmax(300px,1fr))`, max-width `860px`.
- **Analysis & AI** card ("PUT /settings"): toggle rows for aiProviderEnabled, aiSummaryEnabled, payloadInspection, redactedPreview, ragRuntime, ragPayload. Toggle: `38×22` track (on `#2b5cd6`, off `#cdd4de`), `16px` knob sliding `3px↔19px`, `.15s` transition. Whole row clickable.
- **Runtime limits** card: key/value rows — maxTraceDepth 25, lookbackHours 24, maxMessages 100, maxPayloadFields 50, explanationVerbosity standard.
- **OpenAI key** card: green dot + "Configured" + "source: environment", with note that the key value is never returned by the API.

### Persistent AI Copilot (right panel, any section)
- Header: gradient ✦ avatar + "Production Copilot" + "RAG over {production}" (mono) + close ×.
- Thread (scroll): user bubbles right-aligned (bg `#12327a`, white, radius `12px 12px 4px 12px`); AI bubbles left-aligned (bg `#f4f6f9`, border `#e6eaf1`, radius `4px 12px 12px 12px`). Under AI messages: optional **"schema-based evidence"** hint chip (shown when retrieved chunks include `kind=message-schema`) and citation chips (mono; `◇` for schema chunks, `▪` otherwise, e.g. `▪ EMR Operation`, `▪ log:12:03:41`).
- Typing indicator: three `7px` dots with staggered `i14yblink` animation.
- Composer: suggestion chips (wrap) + a bordered input row with a `↑` send button (`32×32`, `#2b5cd6`). Enter submits. Footer note: "answers cite retrieved chunks · never live payload values".

---

## Interactions & Behavior
- **Section nav** sets the active section and closes any open message detail.
- **Production selector** switches the active production (re-scopes header, copilot label, and — in the real app — all data).
- **Copilot toggle** from the top-bar button or the panel ×.
- **Message row click** (Monitor recent list or Messages table) opens the detail slide-over; scrim click or × closes it.
- **Ask flow**: clicking a suggestion, typing + Enter/↑, "Ask copilot about this", or "Rebuild RAG index" appends a user message, shows the typing indicator, then appends an AI answer with citations (in the prototype this is a scripted `answer()` map; in production call the API).
- **Resend**: optimistic 3-state button.
- **Responsive**: desktop-first. All multi-column grids use `auto-fit / minmax` so they collapse to one column when the main area is narrow (e.g. copilot open on a ~900px viewport). KPI grid, volume/interop, messages/logs, overview, settings, and graph lanes all reflow. Panel headers wrap to prevent clipping.
- **Animations**: `i14ypulse` (health dot), `i14yblink` (typing dots), `i14yslide` (slide-over enter). Keep durations as specified.

## State Management
- `activeSection` (overview | monitor | graph | messages | logs | settings)
- `selectedProductionId`
- `copilotOpen` (bool)
- `messageStatusFilter`, `logTypeFilter`
- `selectedMessageId` (null = detail closed)
- `resendState` (idle | sending | done)
- `copilotThread` (array of {role, text, citations[], schemaBased})
- `copilotTyping` (bool)
- `settings` (the six feature flags)

Data fetching: one query per active section/production; the copilot posts questions and renders returned chunks/citations.

## Data & API mapping (replace the prototype's mock data)
| UI area | Endpoint |
|---|---|
| Health pill | `GET /health` |
| Production list | `GET /productions` |
| Section header status + Start/Stop | `GET /productions/{name}/status`, `POST .../start`, `POST .../stop` |
| Overview summary / AI summary | `GET .../summary`, `POST .../ai/summary` |
| Component graph | `GET .../graph`, `GET .../components`, `GET .../components/{name}` |
| KPI + charts | `GET /monitor/interop/volume`, `GET /monitor/metrics/interop`, `GET /monitor/interop/range` |
| Messages + filters | `GET .../messages`, `GET .../messages/facets` |
| Event log + filters | `GET .../logs` |
| Message detail | `GET .../messages/{id}`, `/trace`, `/session`, `/payload`, `/payload/preview`, `/explanation`; `GET .../sessions/{id}/timeline` |
| Resend | `POST .../messages/{id}/resend` |
| Copilot ask | `POST .../ai/ask` (returns answer + retrieved chunks + citations); RAG index via `GET/POST .../rag/index`, `.../rag/chunks`, `.../rag/search` |
| Status/type code labels | `GET /codes` |
| Settings | `GET /settings`, `PUT /settings` |

Status codes: 1 Created, 2 Queued, 3 Delivered, 4 Discarded, 5 Suspended, 6 Deferred, 7 Aborted, 8 Error, 9 Completed. Log types: 1 Assert, 2 Error, 3 Warning, 4 Info, 5 Trace, 6 Alert. Prefer `GET /codes` at runtime rather than hardcoding.

## Design Tokens
**Colors**
- Chrome: dark navy `#0e2350`; on-navy text `#eaf0fb`, muted `#8ea3ce`.
- Surfaces: page `#eef1f5`; card `#fff`; borders `#dde2ea` / `#e6eaf1` / `#eceff4` / row dividers `#f1f4f9`,`#f4f6f9`.
- Text: primary `#16202e`; body `#2c3648` / `#33405a` / `#4b5568`; muted `#8792a3` / `#a2abb8`.
- Primary blue (deep) `#12327a`; interactive blue `#2b5cd6` (hover `#3a6ae0`); tint bg `#eef3fc`, border `#c3d3f0`/`#d6e0f2`.
- Status: green `#1a7f52` (bg `#e5f4ec`); blue `#2b5cd6` (bg `#e8eefb`); amber `#b7791f` (bg `#fdf3e2`); red `#c0392b` (bg `#fbeae7`); gray `#6b7686` (bg `#eef1f5`); process purple `#7c4dd6` (bg `#f0e9fb`); health green `#2ec478`.

**Typography**: `IBM Plex Sans` (UI), `IBM Plex Mono` (ids, codes, class names, metric names). Sizes used: 22 / 25 (numeric) / 15 / 14 / 13 / 12.5 / 12 / 11.5 / 11 / 10.5 / 10 / 9.5px. Weights 400/500/600/700.

**Radius**: 5–6px (chips), 7–9px (buttons/cards small), 10–12px (cards/panels), pill 11–20px.
**Spacing**: 4-based rhythm — common gaps 12/14/16px; card padding 14–20px; row padding 8–11px.
**Shadows**: slide-over `-6px 0 24px rgba(14,35,80,.15)`; toggle knob `0 1px 2px rgba(0,0,0,.25)`.

## Assets
No external images or icon libraries. Glyphs are Unicode characters (✦ ▤ ⊞ ✉ ≣ ⚙ ◱ → ↑ ›). If your codebase has an icon set (e.g. Lucide/Phosphor), swap these for equivalents. No brand logo asset — the "i14" chip is text.

## Files
- `i14y-aid Explorer.dc.html` — the complete high-fidelity design (all screens, states, and the copilot). Open in a browser to interact with every state; read the source for exact inline styles, sample data shapes, and the copilot answer logic.
