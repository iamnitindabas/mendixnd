---
name: mendixnd
description: Use when starting or working in a Mendix project on planning, pages/UI, domain model, microflows/nanoflows, security, integrations, testing, or reviewing Mendix work. Establishes Mendix-native-first decisions, existing-project reuse, evidence-based verification, and known AI failure patterns. Not for generic non-Mendix tasks.
license: MIT
compatibility: Works with OpenCode, Claude Code, OpenAI Codex, GitHub Copilot, and other Agent Skills clients. Some mxcli/MDL guidance is conditional on the project using that toolchain.
metadata:
  version: "1.1.0"
  harnesses: "opencode,claude-code,codex,github-copilot"
---

# MendixND

**Mendix-native first. Understand the platform before choosing an implementation approach. Custom implementation only when justified.**

MendixND is a reusable engineering mindset and knowledge base derived from practical
Mendix delivery experience. It is not a project template and not a license to reproduce one
project's architecture. It exists to stop an AI agent from treating Mendix as a generic
React/HTML/CSS/JavaScript/SQL/backend project.

This skill is auto-discoverable and can also be invoked explicitly. Invocation syntax depends
on the harness:

| Harness | Invoke |
|---|---|
| OpenCode | `@mendixnd` |
| Claude Code | `/mendixnd` |
| OpenAI Codex | `$mendixnd` or `/skills` |
| GitHub Copilot | `/mendixnd` |
| Other Agent Skills clients | Use the skill name `mendixnd`, or the client's skill picker. |

The host may load it when a Mendix task matches its description; for critical or
initialization work, invoke it explicitly. It does not persist automatically across sessions.
A later session that has not loaded it does not inherit its instructions; create or point to
persistent project guidance.

---

## 1. Prime directive

For every Mendix requirement, decide in this order:

1. **Does Mendix provide a native capability for this?**
2. **Does an installed Marketplace module or an existing project component already solve it?**
3. **Can it be achieved through native configuration** — widget properties, design
   properties, domain model features, microflows/nanoflows, security, layouts, snippets,
   navigation, or platform settings?
4. **Is custom CSS, JavaScript, Java, a custom widget, SQL, or external infrastructure
   genuinely necessary?**
5. **What are the consequences** for maintainability, security, performance, upgradeability,
   and future Studio Pro editing?

Do not choose a familiar web-development pattern before completing this scan. Do not force
a native pattern when it genuinely cannot satisfy the requirement. The obligation is to
investigate, not to prefer native for its own sake.

**A custom implementation is justified only when it is recorded with:** the requirement it
serves, the native alternatives considered, why they were rejected, the maintenance owner,
and the upgrade/security implications.

---

## 2. Non-negotiables

- **Inspect before you create.** Never assume an empty project or a greenfield module.
- **Reuse before you rebuild.** Search modules, entities, associations, pages, snippets,
  microflows, Java/JavaScript actions, integrations, and Marketplace components.
- **Platform before framework.** Mendix object context, entity access, transactions,
  microflow/nanoflow engines, and widget semantics are not HTML, React, or SQL semantics.
- **Security is server-side.** Never trust a client-supplied right, role indicator, boolean,
  or object state to authorize a server action.
- **Evidence before completion.** A command exit code, DOM row count, or `check` pass is not
  proof that the requirement works. State what was verified, how, and what remains unknown.
- **Do not invent.** Never invent a command, widget, property, module, API, version feature,
  or file path. If you have not verified it in this environment, probe it or say it is unknown.
- **Do not silently change architecture.** Record the conflict, the decision, the owner, and
  the consequences before proceeding.
- **One owner per document.** When a tool writes whole documents, a second definition is a
  revert waiting to happen. This is conditional on the toolchain, but the principle of
  explicit artifact ownership is universal.
- **Do not weaken the knowledge base.** Project findings do not automatically become
  universal rules. Universal rule changes require review and evidence.

---

## 3. Evidence and confidence

Every nontrivial claim in this skill carries a confidence class. Use the same classes when
you report findings:

| Class | Meaning |
|---|---|
| `VERIFIED` | Reproduced by a read-only command, visible in the model/file, or observed at runtime. |
| `STRONGLY SUPPORTED` | Several independent artifacts agree, but the behaviour was not reproduced. |
| `SUSPECTED` | Plausible; evidence is incomplete. Never turn this into a mandatory rule. |
| `UNKNOWN` | Not established. Say so. |
| `DOCUMENTED` | Stated by official documentation, not experimentally verified here. |
| `PROJECT-SPECIFIC` | True of one project/environment; not a universal Mendix rule. |

Never conflate documentation with experimentally verified behaviour. Never present a
tooling defect as a Mendix platform limitation, or an implementation mistake as a tool
defect. `KNOWN_LIMITATIONS.md` records the distinctions and their version/environment scope.

---

## 4. Mandatory Mendix-native-first decision process

Before implementing, answer these questions in your working notes:

### 4.1 Requirement and context

- What is the actual business outcome, not just the requested widget or code?
- Which user roles perform it, and what data must they see or change?
- Which Mendix version, runtime, database, and deployment profile apply?
- Which toolchain is actually installed (Studio Pro, mxcli/MDL, MCP, custom scripts)?
- Is this a new project, an existing project, or a change to a delivered project?

### 4.2 Native capability scan

Check the relevant families, not just the obvious one:

- **UI:** layout, page templates, design properties, native widgets, Atlas/Marketplace
  widgets, snippets, responsive properties, conditional visibility, empty states.
- **Data:** entities, associations, inheritance, persistable/non-persistable, enumerations,
  calculated attributes, view entities, indexes, delete behaviour.
- **Logic:** microflows, nanoflows, native activities, sub-microflows, validation flows,
  scheduled events, task queues, error handling, transactions.
- **Security:** module roles, user roles, entity access, XPath constraints, page/microflow
  grants, strict mode, demo users, guest access.
- **Integration:** native connectors, REST/SOAP, published services, existing utilities,
  Java/JavaScript actions, Marketplace modules.
- **Operations:** configuration, constants, logging, job audit, environment limits.

### 4.3 Existing-project scan

Search for existing modules, documents, pages, snippets, widgets, flows, actions, constants,
and conventions that already solve the problem or a neighbouring problem. Prefer extending
the existing architecture over creating a parallel one. If you must add something, explain
why the existing artifact could not be extended.

### 4.4 Capability verification

For anything you have not seen work in this project:

- Read official documentation for the exact Mendix version.
- Inspect the installed widget/module definition and its properties.
- Run a minimal, reversible proof of concept on a copy or a throwaway document.
- Record the accepted syntax/semantics and the fallback.
- Do not convert one failed attempt into a claimed platform limitation.

### 4.5 Implementation choice

Choose the simplest solution that satisfies the requirement and fits the existing
architecture. Prefer native configuration over custom code; prefer an existing project
pattern over a new abstraction; prefer one clear artifact over duplicated logic.

### 4.6 Verification choice

Decide before implementation how you will prove each axis: model, access, build, runtime,
browser/UI, data, security, performance. A requirement is not "done" at the level of the
first green command. See `references/VALIDATION_AND_TESTING.md`.

---

## 5. Reference routing

Load only what the task needs. Do not mechanically read every file.

| Task | Read |
|---|---|
| Any new project or first invocation | This file, then `references/CORE_ENGINEERING_PRINCIPLES.md` and `references/MENDIX_NATIVE_FIRST.md` |
| Choosing an approach; native vs custom; version/toolchain questions | `references/MENDIX_NATIVE_FIRST.md`, `references/KNOWN_LIMITATIONS.md` |
| Entities, associations, inheritance, derived values, indexes | `references/DOMAIN_MODEL.md` |
| Pages, layouts, widgets, styling, grids, navigation, responsive design | `references/UI_AND_STYLING.md` |
| Microflows, nanoflows, transactions, scheduling, errors | `references/MICROFLOWS_AND_NANOFLOWS.md` |
| Access rules, roles, XPath, authorization, audit | `references/SECURITY.md` |
| Query volume, N+1, indexing, large data | `references/PERFORMANCE.md` |
| mxcli, MDL, script ownership, replay, build gates | `references/MXCLI_MDL.md` — only if the project uses mxcli/MDL |
| Testing, acceptance, evidence, completion claims | `references/VALIDATION_AND_TESTING.md` |
| Reviewing agent behaviour or diagnosing repeated mistakes | `references/AI_AGENT_FAILURE_PATTERNS.md` |
| Installing, invoking, maintaining the skill | `README.md` |

If the project does not use a tool, do not apply that tool's conditional rules. Toolchain
knowledge is not platform knowledge.

### 5.1 Coexistence with tool-specific skills

MendixND is the **engineering-decision layer**, not a replacement for a dedicated tool skill
(mxcli, Studio Pro, MCP, CI, or another maintained tool manual).

- Use the installed tool skill/manual for **exact command syntax, flags, version-specific
  mechanics, and current CLI behaviour**.
- Use MendixND for the **engineering constraints**: native-first choice, existing-project
  reuse, ownership, security, transaction/verification gates, and completion evidence.
- `references/MXCLI_MDL.md` is a distilled fallback and safety reference, **not a competing
  command manual**. If it conflicts with a maintained mxcli skill on syntax or mechanics, the
  mxcli skill wins for mechanics; MendixND still governs safety, ownership, and verification.
- A tool skill must not override a MendixND stop condition — destructive replay, client-trusted
  authorization, missing evidence, or an unapproved architectural change. If the conflict is
  material, stop and record it.

The intended division is:

```text
MendixND decides:     should we do this? is it native/safe/owned/verifiable?
Tool skill decides:   exactly how do we invoke the tool in this version?
Project guidance:     what are this project's local conventions and exceptions?
```

---

## 6. Initialization workflow

Invoke this workflow at the start of a Mendix project. It is **strictly non-destructive**.

### Step 1 — Establish context

Identify and record:

- Project root and `.mpr` file; Mendix version and MPR format.
- Development environment: Studio Pro, mxcli/MDL, MCP server, scripts, CI, database.
- Available inspection/build/runtime/test commands and their versions.
- Existing instructions: `AGENTS.md`, `CLAUDE.md`, `.opencode/`, project docs, coding
  conventions, team rules.
- Whether the project is new, existing, or delivered; whether it is under version control.
- Which conditional rule families apply (mxcli, Marketplace, deployment, mobile, etc.).

Use read-only inspection. If the version or toolchain cannot be established from the
project, ask the user; do not guess.

### Step 2 — Inspect the existing project

Do not assume an empty project. Inspect, as far as the available tooling allows:

- Modules, Marketplace modules and versions, project structure.
- Domain model: entities, associations, inheritance, enumerations, indexes, delete rules.
- Pages, layouts, snippets, navigation, widget usage.
- Microflows, nanoflows, scheduled events, constants, Java/JavaScript actions.
- Security: security level, strict mode, demo users, guest access, user/module roles,
  entity access, page and microflow grants.
- Existing tests, build scripts, runtime configuration, known issues.
- Existing conventions: naming, folder structure, error handling, styling, validation.

Record what you could **not** inspect. Absence of evidence is not evidence of absence.

### Step 3 — Create project-specific guidance

Create a concise project guidance document from
`templates/PROJECT_ENGINEERING_GUIDANCE.md`. Default destination:

```text
docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md
```

The document records the actual environment, applicable MendixND references, applicable
conditional rules, project-specific exceptions, open questions, and how future agents should
consult the knowledge base. It must not duplicate the entire skill.

If the file already exists, treat it as previous initialization: read it, validate it
against the current project, and report drift. Do not overwrite it. Propose changes and let
the user approve them.

### Step 4 — Integrate safely

This is the critical safety step.

- **Never overwrite an existing `AGENTS.md`** or any existing instruction file.
- **Never replace existing OpenCode configuration** (`opencode.json`, `opencode.jsonc`,
  `.opencode/`, permissions, MCP servers, providers).
- **Never delete or rewrite existing instructions, even if they look stale or AI-generated.**
- **Never modify Mendix application artifacts during initialization** — no model, pages,
  microflows, domain model, security, theme, widgets, Marketplace modules, or deployment
  configuration.
- **Never install or uninstall Marketplace modules.**
- **Never create duplicate configuration entries.**
- **Never assume a file is safe to modify because it is AI-related.**

If persistent instruction integration is needed, inspect the existing configuration and
propose the **smallest additive change** — for example, one line in `AGENTS.md`:

```text
Mendix work: load the MendixND skill and read docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md
before planning or changing the model.
```

Do not apply it without approval if there is any risk of conflict. If safe integration cannot
be guaranteed, leave the existing configuration untouched and explain the manual integration
required.

### Step 5 — Verify and report

Confirm:

- MendixND is loadable and the expected reference files are present.
- The project-specific guidance exists and records the actual environment.
- Existing instructions are byte-for-byte unchanged (record a hash or diff where possible).
- Future sessions have a reliable discovery path (a pointer, not an assumption).
- No application artifact was modified.
- Any integration that was not applied is listed with exact manual steps.

Produce an initialization report using `templates/INITIALIZATION_REPORT.md`. State
`INITIALIZED`, `ALREADY INITIALIZED`, or `BLOCKED — MANUAL ACTION REQUIRED`.

The workflow is idempotent: a second invocation detects the existing guidance, validates it,
and does not duplicate or overwrite content.

---

## 7. Behaviour during normal development

For every relevant task:

1. **Understand the requirement** — business outcome, roles, data, constraints.
2. **Inspect existing artifacts** — never start from a blank page if the project is not blank.
3. **Identify native Mendix capabilities** — scan the relevant families.
4. **Evaluate reusable project and Marketplace components** — reuse before rebuilding.
5. **Consult the relevant MendixND reference** — only what the task needs.
6. **Choose the simplest suitable implementation** — native first, custom only with a record.
7. **Verify unfamiliar platform or tooling behaviour** — docs, definition, probe.
8. **Implement within the existing architecture** — preserve conventions and load-bearing names.
9. **Validate the actual outcome** — model, access, build, runtime, browser, data, security.
10. **Report evidence, deviations, unresolved concerns, and residual risk.**

If the task is a review or audit, do not "fix while reviewing" unless asked. Report findings
with IDs, evidence, confidence, and recommended action.

---

## 8. Stop conditions — stop, do not improvise

Stop and ask, or record a blocked decision, when:

- A required command, widget, property, or module does not exist and no fallback is approved.
- The model and the plan/documentation disagree on a name, association, or security rule.
- A write would touch a document owned by another script or author.
- A replay or bulk operation would modify documents the task did not name.
- A security change would add a capability-bearing role without a reviewed capability table.
- A required gate cannot be run and the acceptance depends on it.
- The same finding has been "fixed" twice and reappeared.
- The only way forward is to silently change architecture, scope, or an acceptance criterion.

A blocked task is a valid outcome. A false "done" is not.

---

## 9. Session persistence

This skill's instructions apply to the session in which it is loaded. They do not
automatically persist into a new session. For continuity:

- Keep `docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md` current.
- Add a pointer from the project's instruction file if the user approves.
- Re-invoke MendixND in a new session when the work is substantial.
- Never claim the skill is active in a session that has not loaded it.

---

## 10. Maintenance

MendixND is a personal reusable engineering asset, not a project file.

- The canonical source is the repository `skills/mendixnd` directory. Installed copies are
  generated by the installer or the harness's skill CLI; do not edit them independently.
- Treat the reference knowledge as read-only during normal development.
- A project may generate candidate findings; it must not automatically rewrite MendixND.
- To promote a finding, require evidence, a confidence class, a scope statement, and review.
- Preserve original finding IDs and confidence classifications.
- Do not silently remove or weaken an existing rule. Supersede it with a dated note.
- Re-run the scenario tests in `references/SCENARIO_TESTS.md` after significant changes.

---

## 11. Reference map

| File | Purpose |
|---|---|
| `references/CORE_ENGINEERING_PRINCIPLES.md` | Universal decision principles and the rule schema |
| `references/MENDIX_NATIVE_FIRST.md` | Native-capability investigation and custom-code justification |
| `references/DOMAIN_MODEL.md` | Domain model, derived state, precision, indexes, delete behaviour |
| `references/UI_AND_STYLING.md` | Object context, pages, widgets, grids, design properties, responsive |
| `references/MICROFLOWS_AND_NANOFLOWS.md` | Logic architecture, transactions, scheduling, errors, validation |
| `references/SECURITY.md` | Roles, entity access, authorization, audit, negative testing |
| `references/PERFORMANCE.md` | Indexes, N+1, bounded queries, volume, measurement |
| `references/MXCLI_MDL.md` | Conditional toolchain rules for mxcli/MDL projects |
| `references/VALIDATION_AND_TESTING.md` | Definition of done, verification ladder, evidence, test design |
| `references/AI_AGENT_FAILURE_PATTERNS.md` | Recurring AI mistakes, causes, countermeasures, blame classification |
| `references/KNOWN_LIMITATIONS.md` | Platform/tool limitations with version and confidence scope |
| `references/SCENARIO_TESTS.md` | Eight realistic skill-behaviour tests and results |
| `templates/PROJECT_ENGINEERING_GUIDANCE.md` | Project-specific guidance template |
| `templates/INITIALIZATION_REPORT.md` | Initialization report template |
| `README.md` | Installation, invocation, operation, maintenance, QA summary |
