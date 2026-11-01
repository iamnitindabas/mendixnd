# Core Engineering Principles

**Purpose:** the cross-cutting rules that apply to Mendix work regardless of project,
version, industry, or toolchain. Area-specific rules are in the other references. Each rule
states its type, priority, confidence, source reference, applicability, verification, and
exceptions.

---

## 1. How to use this file

Read this file after `SKILL.md` at the start of a project, and again when a task crosses
areas (for example, a page change that also changes entity access). The rules here are
deliberately short; the detailed patterns and evidence notes live in the area references.

### Rule types

- **Universal (`MND-U-*`)** — applies to Mendix work generally. A project may have a
  documented exception, but the exception must be recorded.
- **Conditional (`MND-C-*` or area rule with a condition)** — applies only when the stated
  condition holds (toolchain, version, widget, deployment).
- **Toolchain** — mxcli/MDL, Studio Pro, MCP, CI. Kept separate in `MXCLI_MDL.md`.
- **Project-specific** — a project example or historical decision. Never a universal rule.
- **Unresolved** — preserved as a question, not converted into a rule.

### Rule schema

Every detailed rule uses this shape:

```text
### MND-<AREA>-<nn> — short imperative title
- Type:        Universal | Conditional (<condition>) | Toolchain | Project-specific
- Priority:    P0–P3
- Confidence:  VERIFIED | STRONGLY SUPPORTED | SUSPECTED | UNKNOWN | DOCUMENTED
- Source:      brief provenance note (optional)
- Applies when: the condition under which the rule is mandatory
- Instruction: what to do
- Why:         the failure/evidence it prevents
- Verify:      how compliance is observed
- Exceptions:  known legitimate exceptions, or "none known"
```

If a rule has no explicit `Exceptions` line, the default is: the rule does not apply when its
`Applies when` condition is false, or when a documented project exception exists. A project
exception must be recorded in `PROJECT_ENGINEERING_GUIDANCE.md` with an owner and a revisit
trigger.

### Confidence

Use the classes in `SKILL.md`: `VERIFIED`, `STRONGLY SUPPORTED`, `SUSPECTED`, `UNKNOWN`,
`DOCUMENTED`, `PROJECT-SPECIFIC`. A universal rule may rest on `STRONGLY SUPPORTED` evidence,
but the rule must say so. A `SUSPECTED` observation never becomes a mandatory rule.

---

## 2. The hierarchy of preference

Use this order unless a documented reason makes a lower level necessary:

1. **Native platform behaviour** that already satisfies the requirement.
2. **Existing project artifact** — module, entity, association, page, snippet, flow, action,
   constant, utility.
3. **Installed Marketplace module** that is supported on this Mendix version and fits the
   architecture.
4. **Native configuration** — widget property, design property, domain model feature,
   security rule, layout, navigation, setting.
5. **Low-code extension** — a small custom widget, Java action, JavaScript action, or
   connector wrapper around a native capability.
6. **Custom code / external system** — only with a recorded justification and owner.

A lower level does not require a higher level to be "perfect"; it requires the higher level
to be **suitable**. Do not force native when it cannot meet the requirement, and do not skip
the scan because custom code is faster to write.

---

## 3. Universal rules

### MND-U-01 — Complete the native/reuse scan before choosing an implementation

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** any new feature, page, logic, integration, or styling change.
- **Instruction:** Before writing code or MDL, record the native capability, the existing
  project artifact, and the Marketplace option you considered. If you choose custom code,
  state why the first three were unsuitable.
- **Why:** Large-scale rework often comes from generic implementations that ignore native
  widget properties and existing patterns.
- **Verify:** The task record names the alternatives considered and the reason for the choice.
- **Exceptions:** None. The depth of the scan scales with the change.

### MND-U-02 — Inspect the actual project before creating anything

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** starting work in any project that is not proven empty.
- **Instruction:** Read the model, modules, conventions, and security before the first write.
  If the plan/documentation and the model disagree, stop and record the disagreement; do not
  "fix" the model to match a stale sentence.
- **Why:** A plan written for a different project/toolchain invalidated 107 task blocks and
  forced a second plan.
- **Verify:** Inspection commands/output are in the task evidence; the chosen names and
  patterns exist in the project or are deliberately new.
- **Exceptions:** A genuinely empty project still requires version/toolchain inspection.

### MND-U-03 — Reuse before rebuilding

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a requirement resembles existing functionality.
- **Instruction:** Search for an existing module, entity, flow, page, snippet, widget, action,
  or utility that can be extended. Extend it rather than creating a parallel implementation.
- **Why:** Duplicated helpers and parallel pages increase maintenance and diverge silently.
- **Verify:** The reuse search and its result are recorded; any new artifact names why
  extension was not appropriate.
- **Exceptions:** Existing artifact is unsafe, deprecated, unmaintainable, or semantically
  different. Record the reason.

### MND-U-04 — Define "done" by observable outcomes, not by commands

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** reporting any task, phase, or feature complete.
- **Instruction:** Name the observable outcome per axis — model, access, build, runtime,
  browser/UI, data, security, performance — and attach evidence. A green static command is
  necessary, never sufficient.
- **Why:** One-column grids and concatenated label/value text passed `check`, `lint`,
  `report`, `docker check`, and 42/42 journeys.
- **Verify:** The completion report contains command, result, evidence artifact, and the
  unverified residual risk.
- **Exceptions:** If an axis cannot be observed in the environment, say so and mark the task
  partial; do not substitute a different gate.

### MND-U-05 — Verify unfamiliar platform and tooling behaviour before relying on it

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** using a widget, property, command, expression, version feature, or
  Marketplace module for the first time in this project.
- **Instruction:** Read the exact-version documentation, inspect the definition, and run a
  minimal probe. Record the accepted form and fallback. Do not infer from another framework
  or another Mendix version.
- **Why:** `check` accepted page expressions that mxbuild rejected; `describe microflow`
  misrepresented 10 flows; a "platform limit" was a widget setting.
- **Verify:** Probe file/command and observed output exist; the chosen form is the one that
  was observed to work.
- **Exceptions:** A documented, stable platform behaviour may be used without a local probe,
  but label it `DOCUMENTED`, not `VERIFIED`.

### MND-U-06 — Prefer the simplest maintainable solution

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** choosing between designs that both satisfy the requirement.
- **Instruction:** Prefer fewer artifacts, fewer commits, fewer duplicated rules, and fewer
  custom layers. Do not create an abstraction for a single use. Do not duplicate a document
  to avoid understanding it.
- **Why:** 27 near-identical export nanoflows, triple-implemented team authorization, and
  duplicated helper entities increased cost without adding capability.
- **Verify:** The design note explains why the simpler option was insufficient, if it was.
- **Exceptions:** A deliberate generalization is justified when it removes real duplication
  or matches a stable domain concept (see `DOMAIN_MODEL.md`, WorkItem pattern).

### MND-U-07 — One fact, one home

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** storing a date, name, status, counter, identity, or derived value.
- **Instruction:** Store each fact once. If denormalization is necessary, name every writer,
  the trigger that keeps copies synchronized, and which copy is authoritative. For derived
  values, write the write graph before implementing.
- **Why:** `WorkItem.WorkDate` went stale after `RegistrationDate` edits; identity was stored
  as both an association and a string with no precedence rule; derived counters could be
  saved stale.
- **Verify:** A grep for writers of each copy; a test that edits the source and checks the
  copy; a documented authority.
- **Exceptions:** Audit snapshots are deliberate copies. State that the snapshot is history,
  not live truth.

### MND-U-08 — Authorization is a server-side decision

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** any action changes data or exposes data based on a user right.
- **Instruction:** Recompute the right on the server from the object being changed and the
  current user. Treat client-side rights objects, hidden buttons, and role labels as display
  aids, not authorization.
- **Why:** A writable non-persistent `WorkItemRights` object was passed to ACT_ flows and
  trusted; five actions inherited the client's answer.
- **Verify:** A negative test calls the action directly with a forged/absent right and is
  refused; entity access still bounds the write.
- **Exceptions:** None. Even a "UI-only" action that changes data needs a server check.

### MND-U-09 — Make important state and failure observable

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** designing jobs, integrations, imports, background work, or multi-step
  business actions.
- **Instruction:** Record success, partial success, and failure in a place an operator can
  see. A status object returned by a helper must have a caller that reads it. An audit row
  must be closable on every path, including the error path.
- **Why:** Failed scheduled runs left `JobRun` unfinished; jobs reported `Succeeded = true`
  while `MailLog.Status = Failed`.
- **Verify:** Force a failure in a test and observe a visible failed state; inspect the audit
  row and the operator surface.
- **Exceptions:** None for business-critical jobs. Low-value diagnostics still need a log line.

### MND-U-10 — Model artifact ownership explicitly

- **Type:** Universal principle; toolchain-specific implementation
- **Priority:** P0 (when whole-document writers are used)
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** scripts, generators, or tools write whole documents; also when multiple
  people/agents edit the same artifact.
- **Instruction:** Maintain an ordered ownership manifest: one owner per page, flow, entity,
  nanoflow, and other document. A second definition is a revert unless it is an explicit,
  checked stub→real pair. Replay only the owner or the manifest in order.
- **Why:** 122 page definitions covered 52 pages; replaying one shell script reverted 33 pages;
  seven flows were declared twice behind a "passed" gate.
- **Verify:** A static ownership scan and a diff-based replay check (see `MXCLI_MDL.md`).
- **Exceptions:** Generated artifacts with a single generator and no hand edits; still record
  the generator as the owner.

### MND-U-11 — Classify knowledge before promoting it

- **Type:** Universal (method)
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** turning a project lesson into guidance, a lint rule, or a template.
- **Instruction:** Classify each finding as universal, conditional, toolchain, project-specific,
  or unresolved. Record the evidence and confidence. Do not promote a single-project
  observation, a version-specific bug, or a `SUSPECTED` cause into a universal rule.
- **Why:** MendixND distinguishes tool defects, platform limits, environment limits,
  implementation mistakes, and architectural trade-offs; conflating them produces bad rules.
- **Verify:** The rule has a source note, confidence, scope, and exception; a reviewer can see
  why it generalizes.
- **Exceptions:** None.

### MND-U-12 — Apply change control after "done"

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** new work follows a declared close-out, audit, or delivery.
- **Instruction:** Open a new slice with impact analysis, affected artifacts, regression
  checks, manifest update, and a new acceptance gate. Regenerate handoff/status/manifest
  numbers from the current model; do not hand-edit stale counts.
- **Why:** Five post-close waves added 5,244 script lines while the handoff still described
  the model as "P16 closed"; the rebuild order could not reproduce the app.
- **Verify:** The close-out artifacts are current, the manifest replays, and the new slice has
  its own evidence.
- **Exceptions:** A purely cosmetic documentation fix still updates the affected document.

### MND-U-13 — Stop on unresolved conflict or irreversible change

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** requirements conflict, the plan is impossible, or a decision changes
  toolchain, module topology, layout, theme, Marketplace versions, or security model.
- **Instruction:** Record the conflict, sources, decision, owner, and consequences. Escalate
  irreversible/cross-cutting decisions to the human owner. Do not silently pick a side and
  continue.
- **Why:** Four architecture-shaping decisions were taken during execution and never fed back;
  eight of sixteen Part 2 decisions reconciled contradictory acceptance sentences.
- **Verify:** A decision record exists with an owner and date; affected tasks are re-baselined.
- **Exceptions:** A local, reversible implementation detail (widget spelling, activity
  position) may be decided by the executor and recorded.

### MND-U-14 — Preserve conventions and load-bearing names

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** renaming pages, widgets, grids, flows, modules, or files.
- **Instruction:** Treat names used by exports, tests, navigation, grants, or documentation as
  interfaces. Search for references before renaming. Preserve the project's naming and folder
  conventions unless there is a recorded reason to change them.
- **Why:** 18 exports were bound by grid name; renaming a grid silently breaks the export.
  A README numbering map drifted, so a future script would collide.
- **Verify:** `refs`/search for the old name; regression test for the dependent behavior.
- **Exceptions:** A deliberate migration with a reference update in the same change.

---

## 4. Decision records

For any nontrivial choice, record:

```text
ID:            DEC-<n> or a project convention
Question:      what had to be decided
Options:       native / existing / marketplace / custom, with the reason each was rejected
Decision:      what was chosen
Owner:         who owns it
Evidence:      probe, doc, measurement, or model reference
Consequences:  maintenance, security, performance, upgrade, reversibility
Revisit when:  version, requirement, or environment changes
```

A decision without an owner and evidence is an opinion, not an engineering decision.

---

## 5. Working with uncertainty

- If you cannot verify a capability, say `UNKNOWN` and propose a probe. Do not invent a
  workaround and present it as the platform's behaviour.
- If a finding is `SUSPECTED`, keep it as a hypothesis in the task notes. Do not add a
  mandatory rule or a permanent workaround until it is confirmed.
- If a test cannot fail, it is not evidence. Replace it or mark it as a fixture.
- If a gate cannot be run, mark the affected acceptance criterion unverified. Do not use a
  weaker gate as a substitute without saying so.
