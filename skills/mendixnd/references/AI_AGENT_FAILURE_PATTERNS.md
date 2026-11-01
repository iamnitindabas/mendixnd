# AI Agent Failure Patterns

**Purpose:** make the recurring AI failure modes explicit so an agent can recognize them in its
own work. This file is about **behaviour**, not Mendix features. The area references contain the
technical rules.

Field experience shows three gaps behind most mistakes:

1. **Environment gap** — the agent knew Mendix concepts but not *this* installation: version,
   toolchain, Marketplace state, runtime limits.
2. **Context gap** — the agent knew the requirement but not the Mendix object context: which
   DataView owns `$currentObject`, which association is optional, which page parameter is legal.
3. **Verification gap** — the agent treated a command exit code, DOM row count, or journey pass
   as proof of the property it cared about.

---

## 1. The failure matrix

| Pattern | What it looks like | Why it happens | Countermeasure |
|---|---|---|---|
| Inventing unsupported constructs | A command/widget/property that does not exist; a plan naming another toolchain | Generated from memory/another version without a probe | `MND-N-04`, `MND-N-06`, `MND-MX-10`; probe before plan |
| Assuming widget semantics | `Visible:` on a DataView button still renders; column `Size` treated as pixels; chart points assumed unclickable | Inferred from web/Bootstrap intuition or another widget | `MND-UI-03`, `MND-UI-06`; read the definition, render a probe |
| Writing dead CSS classes | `mx-spacing-*`, `gap-2`, `mb-3` — silently ignored | Pattern-matched names from memory; unknown class has no error | `MND-UI-05`; design properties + compiled-CSS audit |
| Rebuilding instead of altering | Whole page rewritten for a spacing change; many pages multi-owned | `ALTER ... REPLACE` one-shot; escalation to `create or modify` | `MND-MX-02/04/05`; one owner + surgical alter |
| Declaring done without looking | One-column grids, concatenated labels, 9-button bars pass every gate | Done defined by commands, not rendered output | `MND-V-01/03`; screenshot + measured layout |
| Treating `check` as proof | CE0117/CE0463 pass check, fail build/runtime | Static checker scope misunderstood | `MND-MX-08`; build + runtime gate |
| Partial requirement marked Built | A button that cannot render; a guard not implemented | Matrix maps FR→task, not FR→observation | `MND-V-02/11`; per-requirement evidence |
| Silently changing architecture | Layout/module/theme swapped mid-flight | Environment decisions taken during execution | `MND-U-13`; decision ownership/reversibility |
| Adding modules after the plan | Marketplace modules installed mid-project, version drift | Inventory assumed, not pinned | `MND-N-07`; version triple |
| Session/credential confusion | Login fails after ~5 runs; treated as bad password | Runtime session cap unknown; logout 404 | `MND-V-08`; restart/real logout, read runtime log |
| Demo-data pollution | Counts/duplicates change every run; assertions rewritten | Shared DB, absolute counts | `MND-V-05`; unique keys, relative assertions |
| Test asserts its own fixture | Sets a flag, asserts the flag | Cheapest way to green | `MND-V-06/09`; independent outcome |
| Discounting a real warning as noise | Hundreds of `CONV010` warnings; duplicate flows; `MDL-FLOW01` | High count/inconvenient rule | `MND-MX-09`; triage by rule ID |
| Trusting a plan's as-built claim | "Column added" but absent; handoff frozen | Claims not diffed against model | `MND-U-04`, `MND-V-12`; re-derive |
| Inventing a platform limitation | "Chart points not clickable" was a marker setting | One failed attempt generalized | `MND-N-04/05`; probe the property |
| Over-fitting one project | Project-specific module/page names become "the Mendix way" | Confusing example with principle | `MND-U-11`; classify knowledge |

---

## 2. The ten failures worth remembering

### 2.1 The plan for a ghost toolchain

A plan wrote 107 task blocks for Studio Pro MCP/Concord in an environment that had neither.
The executor had to write a second plan. **Lesson:** probe the environment and write the
capability matrix before the task blocks; keep tool recipes replaceable; do not embed a command
name in an acceptance criterion.

### 2.2 Multi-owner pages

Scripts were organized by phase/sitting, not by artifact. 122 page definitions covered 52 pages;
replaying one shell script reverted 33 pages. **Lesson:** one owner per document, a manifest,
and a diff-based replay gate. "Exec twice" only proves self-idempotency.

### 2.3 "Done" without rendering

Every grid rendered as one stacked column; detail pages concatenated label/value text. All
gates were green. **Lesson:** visual/structural acceptance is a separate axis; DOM presence and
row counts are layout-blind.

### 2.4 CSS classes from memory

31 widgets on 22 pages used classes that did not exist in the compiled theme. The browser
ignored them silently. **Lesson:** design properties first; if a class is used, verify the token
in the built stylesheet.

### 2.5 HTML nesting translated into widget nesting

A filter DataView inside a tab page was instantiated per tab; a grid XPath resolved against the
wrong object; an optional DataView rendered empty buttons. **Lesson:** model the Mendix object
context tree; bind optional associations in a guarded DataView.

### 2.6 Security by role name

A stock `User` role was mapped to `Technician`; `FunctionalAdmin` carried
`Administration.Administrator` to satisfy a build error. **Lesson:** roles are capabilities;
a capability table is an artifact; treat stock admin roles as red flags.

### 2.7 `check` as proof

Page expressions passed `check` and failed mxbuild/runtime. **Lesson:** the gate ladder is
check → build → runtime → browser/data; name what each gate proves.

### 2.8 Describe → edit → create/modify on an irreducible flow

Ten flows do not round-trip through `describe`; a future edit would silently change the rule.
**Lesson:** check `MDL-FLOW01` before editing a complex flow; rebuild deliberately and test, or
edit in Studio Pro.

### 2.9 A test harness that lies to itself

`/logout` 404ed; sessions accumulated; a text box sent on change; a list did not refresh; one
"test" asserted a flag it set. **Lesson:** treat the harness as production code: lifecycle,
isolation, diagnostics, meaningful assertions.

### 2.10 Documentation freeze and completion claims

After "P16 closed", five model waves added 5,244 script lines; the handoff still described the
old model; README/brain/addendum were missing. **Lesson:** change control after done; regenerate
status from the model; make close-out machine-checkable.

---

## 3. Blame classification

Do not misattribute a failure. Classify it before writing a rule:

| Class | Definition | Example | Response |
|---|---|---|---|
| **AI implementation mistake** | The agent wrote an incorrect construct/syntax/assumption | Enum compared to string; reserved name; wrong property | Fix the implementation; add a rule/probe. |
| **Incorrect implementation (human/agent)** | The model works but the business rule is wrong | Two definitions of "in service"; hard delete in a soft-delete app | Fix the design; add a test. |
| **Tooling defect** | The tool promises/reports something it does not do | `check` passes CE0117; `describe` drops a path; `alter` always says "Altered" | Work around; report; do not blame Mendix. |
| **Mendix platform limitation** | The platform genuinely cannot express it | No date-only type; no insert-only access; SPA 200 for forbidden route | Design around; record the limit. |
| **Environment limitation** | The runtime/licence/DB/host constrains it | Trial session cap; HSQLDB default; missing PostgreSQL | Document the runtime profile; verify on target. |
| **Architectural trade-off** | A deliberate choice with a cost | Wide inheritance table; status+microflows instead of Workflows | Record the trade-off; do not call it a defect. |
| **Unresolved/suspected** | Evidence incomplete | A suspected duplicate-key risk | Preserve as a question; do not mandate. |

A tool defect is not inferred from a wrong MDL statement. A platform limitation is not inferred
from a missing property that was never probed. An implementation mistake is not a reason to
distrust the platform.

---

## 4. Self-check before claiming completion

Ask these questions:

1. Did I inspect the actual project and version, or did I rely on memory?
2. Did I check native/reuse/Marketplace before writing custom code?
3. Did I verify the widget/property/command in this environment?
4. Did I read the warning counts, not just the exit code?
5. Did I build, run, and render the change?
6. Did I measure the layout at the target viewports?
7. Did I test a lower role and a direct action call?
8. Did I assert the stored business outcome, not just the UI?
9. Is my test capable of failing? Is it independent of its fixture?
10. Did I record deviations, unknowns, and residual risk?
11. Did I update the manifest/handoff/README if the model changed?
12. Am I about to call something "done" that I have not observed?

If any answer is "no", the task is not done.

---

## 5. Anti-patterns to refuse

- "I'll add a CSS class; it probably exists."
- "The checker passed, so the page is valid."
- "The page opens, so the layout is fine."
- "The test passed, so the feature works" (when the test asserts its own fixture).
- "The plan says it's built, so it's built."
- "I can't do this in Mendix" (without a probe).
- "I'll rewrite the page; altering is harder."
- "I'll grant the admin role to fix the build error."
- "I'll trust the rights object the page passed."
- "I'll run the old script; it should be idempotent."
- "The warning count is high; it's probably noise."
- "The marketplace update failed; I'll run it again."
- "I'll change the architecture and record it later."

Each of these has a concrete cost in real delivery.

---

## 6. Rules

### MND-AI-01 — Do not invent platform capabilities, commands, widgets, or properties

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** writing any implementation instruction.
- **Instruction:** Use only what you have verified in this environment or exact-version docs.
  If unknown, probe or say unknown.
- **Verify:** A source/probe exists for each non-obvious construct.

### MND-AI-02 — Do not infer Mendix semantics from web frameworks

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** reasoning about object context, DataViews, visibility, grids.
- **Instruction:** Model the Mendix context explicitly; read the widget definition; probe.
- **Verify:** The page context tree and a rendered check.

### MND-AI-03 — Do not write a CSS class from memory

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** styling.
- **Instruction:** Design property first; if a class, verify it in the compiled CSS.
- **Verify:** Class audit + screenshot.

### MND-AI-04 — Do not rebuild when a surgical change is possible

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** changing an existing page/flow.
- **Instruction:** Use targeted alter/replace with stable names; preserve structure; diff.
- **Verify:** Diff shows only the intended change; structure preserved.

### MND-AI-05 — Do not declare done from green static gates

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** reporting completion.
- **Instruction:** Apply the full definition of done; name what was observed.
- **Verify:** Evidence per axis.

### MND-AI-06 — Do not discount a warning without triage

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a lint/check warning is inconvenient.
- **Instruction:** Classify each material rule: defect, accepted by design, or false positive.
  Record the reason. Do not dismiss by count.
- **Verify:** A triage table with rule IDs and decisions.

### MND-AI-07 — Do not silently change architecture or acceptance criteria

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** the plan is impossible or a requirement conflicts.
- **Instruction:** Record the conflict/decision/owner; re-baseline affected tasks; escalate
  irreversible choices.
- **Verify:** A decision record and updated acceptance.

### MND-AI-08 — Do not trust tool output beyond its fidelity

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** using `describe`/`check`/`alter`/migration output.
- **Instruction:** Know what the command proves; diff/test after any write; treat a failed
  multi-statement write as unknown.
- **Verify:** A second observation (diff/build/runtime) confirms the state.

### MND-AI-09 — Do not write a test that asserts its own fixture

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** writing/reviewing tests.
- **Instruction:** Fixture ≠ assertion; assert an independent outcome; mutation-check it.
- **Verify:** The test fails when the behaviour is broken.

### MND-AI-10 — Do not over-generalize one project's architecture

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** turning a project finding into a rule/template.
- **Instruction:** Separate universal principle, conditional rule, toolchain, project-specific,
  unresolved. Do not copy module names, versions, or layout choices as universal.
- **Verify:** The rule has a scope and source; project examples are labelled.

### MND-AI-11 — Do not treat a passing journey as full coverage

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** using browser tests as acceptance.
- **Instruction:** Check what the journey asserts (page opens? row count? actual content?);
  add data/layout/role assertions.
- **Verify:** The journey can fail for the defect you care about.

### MND-AI-12 — Stop when the model and the plan disagree

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** an instruction names a document/name/rule that does not match the model.
- **Instruction:** Stop, record the disagreement, and resolve before writing. Do not "fix" the
  model to match a stale plan.
- **Verify:** The resolution is recorded; the model is the source of truth for what exists.
