# Mendix-Native-First

**Purpose:** teach the agent to investigate Mendix's own capabilities, and the project's
existing capabilities, before introducing custom CSS, JavaScript, Java, SQL, a custom widget,
or external infrastructure. Also teaches when native is genuinely insufficient.

---

## 1. What "native-first" means — and does not mean

Native-first means **investigate before choosing**. It does not mean:

- Native is always sufficient.
- Every requirement must be forced into a standard widget.
- Marketplace modules are automatically safe.
- A platform limitation may be assumed without a probe.
- A tooling limitation is a platform limitation.

The correct posture is:

> Understand the requirement, inspect the project, enumerate native and existing options,
> verify the uncertain ones, then choose the simplest suitable implementation. If custom code
> wins, record why.

---

## 2. The capability scan

Run the relevant checklist. Do not skip a family because the request sounds like "just a
small UI change" or "just a quick integration".

### 2.1 UI and styling

- Layouts and page templates: does an existing layout already provide the structure?
- Layout grid, container, group box, tab container, snippet, page template.
- Widget design properties: spacing, padding, margin, flex, item gap, alignment, wrap,
  typography, background, border, width.
- Native widget properties: caption, render mode, button style, visibility, data source,
  selection, paging, empty placeholder, column width, filter, sort.
- Atlas/Core and installed Marketplace widgets: does one already solve this?
- Responsive properties: phone/tablet/desktop layout, hide/show, column behaviour, wrap.
- Conditional visibility and empty states.
- Existing page patterns and snippets in the project.

**Do not** start with a CSS class because the target looks like a web layout. Mendix object
context and widget semantics are not HTML nesting.

### 2.2 Data and domain model

- Entity, attribute, association, inheritance, generalization.
- Persistable vs non-persistable; when a helper object is appropriate.
- Enumeration and caption; calculated attribute vs stored derived attribute.
- View entity for aggregation/read-only projection.
- Entity access, XPath constraints, attribute-level grants.
- Indexes, delete behaviour, unique constraints (or the absence of a native one).
- System attributes (`owner`, `createdDate`, `changedDate`, `changedBy`).

### 2.3 Business logic

- Microflow vs nanoflow: server-side vs client-side execution.
- Native activities: retrieve, create, change, commit, delete, rollback, call, loop, decision,
  merge, error handling, validation feedback, show message, close page.
- Sub-microflow for reusable logic; validation microflow for field-level rules.
- Scheduled event for periodic work; task queue for asynchronous/background work (if the
  Mendix version and project support it).
- Event handlers, before/after startup, entity events (if used).
- Existing utility flows and Java/JavaScript actions.

### 2.4 Security

- Security level, strict mode, demo users, guest access.
- User roles and module roles; capability composition, not role names.
- Entity access (create/read/write/delete, XPath row scope, attribute lists).
- Page and microflow/nanoflow grants.
- Server-side re-check in actions.
- Audit/append-only patterns.
- Negative tests per role.

### 2.5 Integration

- Native REST/SOAP call activities, published REST/SOAP services, OData, business events.
- Installed connectors: Email Connector, Encryption, Community Commons, etc.
- Existing integration utilities and error/log patterns.
- Java/JavaScript action only when the native activity or connector cannot do it.
- External database/SQL only when the Mendix data layer genuinely cannot express it.

### 2.6 Operations

- Constants and configuration; environment-specific values.
- Logging, job audit, error surfaces, health checks.
- Scheduled event time zone, overlap, catch-up, missed-run detection.
- Marketplace version alignment and upgrade path.
- Runtime session/licence limits, database, ports.

---

## 3. Existing-project reuse scan

Before creating a new artifact, search for:

| Artifact | Search for |
|---|---|
| Module | existing module with a related responsibility; avoid a new module for one page |
| Entity / association | existing entity that already holds the fact or relationship |
| Page / layout / snippet | existing page pattern, header band, form layout, grid policy |
| Microflow / nanoflow | existing `SUB_`, `VAL_`, `DS_`, `OCH_`, export, integration helper |
| Java / JavaScript action | existing action that already wraps the capability |
| Widget | installed widget with the required property; existing project usage |
| Constant / setting | existing config rather than a new hard-coded value |
| Security rule | existing role/XPath pattern rather than a parallel rule |
| Test / fixture | existing test helper or seed by natural key |

Record the result: `reused <name>`, `extended <name>`, or `new <name> because <reason>`.

---

## 4. Custom implementation justification gate

Custom CSS, JavaScript, Java, a custom widget, SQL, or external infrastructure is justified
only when all of the following are true:

1. **The requirement is real** and cannot be met by native configuration or an existing
   project/Marketplace artifact.
2. **The native alternatives were tested or documented**, not merely assumed unsuitable.
3. **The custom artifact has an owner and a maintenance path** (source location, build,
   version compatibility, upgrade procedure).
4. **Security and performance implications are understood** (trust boundary, injection,
   data access, query cost, bundle size, runtime behaviour).
5. **The future Studio Pro editing experience is acceptable** — a custom widget that cannot
   be configured or a script that overwrites model changes is a long-term cost.
6. **The decision is recorded** with the alternatives, reason, owner, and revisit trigger.

If any of these is missing, go back to the native scan or ask for a decision.

### 4.1 Custom code is appropriate when

- A native widget genuinely lacks a required behaviour and no Marketplace widget fits.
- A complex algorithm or protocol is impractical in microflows and a Java action is the
  maintainable boundary.
- A connector/module is the supported integration path for a version where the native
  activity does not exist.
- A small JavaScript action fills a client-side gap that Mendix does not expose.
- Performance requires a set-based database operation that the Mendix data layer cannot
  express efficiently — and the trade-off is documented.

### 4.2 Custom code is usually not appropriate when

- A design property already provides the spacing/flex/alignment.
- A native widget property already provides the behaviour.
- An existing page pattern or snippet already solves the layout.
- A microflow expression or validation flow can enforce the rule.
- A CSS class is being used to imitate a layout that Mendix already models.
- A custom SQL query duplicates a view entity or a retrieve.
- A custom widget is introduced only because the agent has not inspected the installed
  widget's properties.

---

## 5. Native alternatives worth checking first

The following are patterns from the retrospective. Treat the **principle** as reusable; treat
the exact widget/property/version as conditional and verify it in the current project.

| Need | Check first | Conditional note |
|---|---|---|
| Spacing, margins, padding, flex, gap, alignment | Widget design properties (`Spacing`, `Flex container`, `Item gap`, `Align items X/Y`, `Disable row wrap`) | Exact property names and compound-value support depend on the widget/Mendix version. Verify in the widget definition; a class name from memory is not evidence. |
| Page structure | Layout, layout grid, container, group box, tab container, snippet | A snippet may not accept arbitrary child content; do not promise it without checking. |
| Grid column widths | Data Grid 2 `Width: manual` + `Size` weights + `MinWidth: minContent` | `Size` is a weight, not pixels. No per-column "hide on phone" property. Verify on the installed widget version. |
| Optional association drill-through | DataView bound to the association, wrapped in a container with `Visible: <assoc> != empty` | A button inside an empty DataView still renders; guard the container, not only the button. |
| Conditional text with an association | Two `dynamictext` widgets with complementary `Visible:` | Avoid association comparisons inside `ContentParams`; verify the expression dialect. |
| Reference-set editing | ComboBox multi-select with `selectionMethod: checkbox`, `selectedItemsStyle: boxes`, `CaptionAttribute` | This was an mxcli substitution for the built-in reference selector. In Studio Pro, the native reference selector may be available. |
| Email on Mendix 11.12.x | Email Connector + a mail log/status | Native `SEND EMAIL` requires 11.13+ in the observed environment. Verify the project's actual version; do not assume. |
| File export | Data Grid 2 export / `Export_To_Excel` JavaScript action | Bound by grid name; renaming the grid breaks the export. Check the return value. |
| Aggregation | View entity / aggregate retrieve / database aggregation | OQL group-by needs a joined attribute, not an association itself. |
| Periodic work | Scheduled event | Time zone, overlap, catch-up, missed-run, and failure audit are part of the design. |
| Long-running/async work | Task queue if available in the version/project | Do not assume the project has one; verify. |
| Validation | Validation microflow + `validation feedback` | Feedback must target a field on the calling page; otherwise use a message. |
| Row-level security | Entity access XPath + server-side re-check | Mendix has no insert-only access rule; microflows bypass entity access unless marked. Verify the exact behaviour. |

---

## 6. Version and Marketplace awareness

### 6.1 Version

Never assume a feature exists because a newer Mendix version has it. Record the exact version
and check the feature's floor. Examples from the retrospective:

- Native `SEND EMAIL` was unavailable at 11.12.5.
- `REFERENCESELECTOR` was refused by the mxcli build, not by Mendix itself.
- A widget property that exists in a newer Data Grid 2 may not exist in the installed one.
- `describe microflow` fidelity and `check` scope are toolchain/version specific.

### 6.2 Marketplace modules

Before adopting or upgrading:

- Confirm the module version is supported on the Mendix version.
- Confirm widget package versions match the module (`module version == themesource/.version
  == widget package version`).
- Check whether the project already edits Marketplace content (an upgrade hazard).
- Check the module's roles and capabilities; a stock `Administrator` role is a red flag.
- Back up before an update; a failed update can leave a half-installed module.
- Do not edit Marketplace pages in place unless the edit is recorded as a fork with a
  re-apply procedure.

---

## 7. Rules

### MND-N-01 — Scan native capability families before choosing custom code

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** PL-007, PL-008, UI-002, UI-012
- **Applies when:** any implementation choice.
- **Instruction:** Use the checklist in §2. Record the native options considered.
- **Verify:** Task notes name the native options and why they were accepted/rejected.

### MND-N-02 — Search the existing project before creating a parallel artifact

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** DM patterns, PL-003
- **Applies when:** adding a page, entity, flow, widget, or utility.
- **Instruction:** Run the §3 search. Extend the existing artifact or record why not.
- **Verify:** The reuse result is recorded; no duplicate helper with the same responsibility.

### MND-N-03 — Prefer configuration and design properties over CSS/JavaScript

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** UI-012, PL-008, RC-08
- **Applies when:** spacing, alignment, flex, typography, layout, visibility, or widget
  behaviour is requested.
- **Instruction:** Use the widget's design properties/properties. If a class is genuinely
  needed, verify the token exists in the compiled theme; never write a class from memory.
- **Verify:** A property/class audit: every class token is defined in the built stylesheet;
  computed layout/screenshot confirms the effect.
- **Exceptions:** Official utility classes when no design property exists; record the reason.

### MND-N-04 — Do not treat a tool limitation as a platform limitation

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** MX-010, MX-012, MX-009, Section 11.4
- **Applies when:** a command/widget/property is refused or missing.
- **Instruction:** Determine whether the limitation is Mendix, the toolchain, the installed
  version, the project configuration, or your own syntax. Probe or consult exact-version docs.
- **Verify:** The limitation is stated with its scope and evidence; a fallback is recorded.
- **Exceptions:** A clearly documented platform limit may be accepted without a probe, but
  label it `DOCUMENTED`.

### MND-N-05 — Do not force native when it cannot satisfy the requirement

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Section 11.4, D-37/D-42, PL-011
- **Applies when:** the native option is unsuitable, unsafe, or materially more complex.
- **Instruction:** Choose the justified alternative and record the trade-off. Do not contort
  the domain model or the UI to avoid a custom component.
- **Verify:** The decision record names the native attempt and the concrete failure.
- **Exceptions:** None; "native" is not an acceptance criterion by itself.

### MND-N-06 — Verify the exact version and installed widgets before relying on a feature

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** MX-012, MX-001, P-19, PL-002
- **Applies when:** using a version-gated activity, a Marketplace module, or a widget property.
- **Instruction:** Record Mendix version, module version, widget package version, and the
  observed property/behaviour. Do not rely on a memory of another version.
- **Verify:** Version output and a probe/definition are in the evidence.
- **Exceptions:** Stable core language features may be used from documentation; label them.

### MND-N-07 — Treat Marketplace additions as architecture decisions

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** D-20, D-24, QC-015, P-19
- **Applies when:** installing, upgrading, or editing a Marketplace module.
- **Instruction:** Pin the version, verify compatibility and the version triple, review the
  roles/capabilities, and prefer wrapping/copying over editing Marketplace content.
- **Verify:** Version triple, module inventory, and any local edits are recorded; upgrade
  procedure exists.
- **Exceptions:** A module explicitly designed as a project extension point.

### MND-N-08 — Record the custom-code justification

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Section 11.3, PL-020, RC-08
- **Applies when:** adding CSS, JavaScript, Java, a custom widget, SQL, or external infra.
- **Instruction:** Use the §4 gate. Record alternatives, owner, maintenance, security,
  performance, upgrade impact.
- **Verify:** A decision record exists and is referenced by the implementation.
- **Exceptions:** A throwaway probe that is deleted before delivery; still note the probe.
