# mxcli and MDL

**Conditional reference.** Apply this file only when the project actually uses **mxcli** and
**MDL** (or a compatible headless Mendix model tool). Do not assume mxcli exists because a
retrospective used it. If the project uses Studio Pro, MCP, or another toolchain, use that
toolchain's inspection/build/runtime commands and treat the *principles* here as conditional.

The observed environment was **mxcli nightly-20261029-26c19dc21 (2026-10-29)** against
**Mendix 11.12.5**, MPR v2, on Windows/PowerShell. Behaviours may differ in other builds;
verify before relying on them.

**Coexistence with a maintained mxcli skill/manual:** use that skill for exact command syntax,
flags, and current CLI mechanics. This file supplies the distilled retrospective lessons and
the ownership/replay/verification gates; it is not a competing command manual. If they conflict
on mechanics, the maintained tool skill wins. If they conflict on safety, ownership, or
verification, MendixND wins. Record any material conflict.

---

## 1. Toolchain reconnaissance

Before writing a plan or a task block:

```text
mxcli version
mxcli help
mxcli help check
mxcli help exec
mxcli syntax <topic>
mxcli show modules
mxcli describe settings
mxcli describe app security
mxcli describe structure
```

Record:

- mxcli version/date and how it was invoked (path, extension),
- Mendix version and MPR format,
- JDK/runtime,
- database/configuration,
- modules and Marketplace versions,
- available commands (check, lint, report, diff, docker check, run, test),
- test runner cleanup contract (`--local` vs `--attach`),
- any command that is missing or behaves differently.

A command that has not been run is not a capability. It is an assumption.

---

## 2. What each command proves — and does not prove

| Command | Proves | Does **not** prove |
|---|---|---|
| `check` | MDL syntax, references, member names, microflow expression types, creation order, version gates | page template/ContentParam types, duplicate pages, widget loadability, build success |
| `exec` twice | the script is self-idempotent | another script will not overwrite the same document later |
| `describe page` | the page tree/properties, re-executable for small pages | translations, GUIDs, runtime behaviour |
| `describe microflow` | the flow for reducible graphs | irreducible graphs; it can drop a path |
| `lint` | rule findings with counts | that a clean score means quality; Performance 100 may have no N+1 rule |
| `report` | a reproducible policy score | defect count or runtime quality |
| `docker check` | the stored model builds with mxbuild (despite the name, no Docker required) | the page renders correctly |
| `run --local` | the app starts and a page loads | data correctness, visual quality, other roles |
| browser journey | the tested path works for the tested role/data | other roles, other data, layout at other widths |

**The gate ladder is: `check` → `docker check` → `run` → browser/data verification.** A green
`check` is not a build. A green build is not a rendered page. A rendered page is not a correct
business outcome.

### 2.1 `check` scope specifics (observed)

- It type-checks microflow expressions.
- It does **not** type-check page template parameters (`ContentParams`/`CaptionParams`):
  a Decimal in a String slot, `round()`, `formatDecimal`, an association comparison inside
  `if`, or a 3-segment path inside `if` can pass `check` and fail mxbuild with CE0117.
- It does **not** see duplicate page declarations (two scripts defining the same page). It
  does warn `MDL-STUB01` for duplicate microflow/nanoflow declarations, but warnings do not
  fail the run.
- It does not load widget definitions; a page can pass `check` and fail mxbuild/runtime with
  CE0463.

### 2.2 `docker check` specifics (observed)

- It runs the local `mx.exe` from the Mendix installation; Docker is not required.
- Use `--no-update-widgets` for the **as-stored** verdict. Without it, widget normalisation can
  hide a CE0463 that still fails runtime.
- It checks a temporary copy; the project on disk is not changed.
- It is the only practical gate for page-expression/build errors in this toolchain.

---

## 3. Artifact ownership and replay safety

This is the highest-leverage process control in an MDL project.

### 3.1 One owner per document

Maintain an ordered manifest:

```text
# mdlsource/MANIFEST.txt (illustrative)
01-foundation.mdl          owns: modules, settings, constants
02-domain-model.mdl        owns: entities/associations/enums (except late additions listed)
03-security.mdl            owns: roles, entity access, page/flow grants
...
17-pages-p6a.mdl           owns: StatusOverview, Analyzer_Detail, ...
39a-trend-tab.mdl          owns: ResultTag_Detail, NF_Export_dgTrendData
...
# Replay = execute the manifest in order; a document name may appear once.
```

A document may appear twice only as an explicit **stub → real** pair, and the plan must say
which statement is authoritative and why the stub will not be replayed after the real one.
`check` may warn `MDL-STUB01` for flows but it does not fail; pages have no equivalent warning.
A grep for `create or modify page` is the cheap ownership audit.

### 3.2 Replay is destructive when ownership is wrong

`create or modify page` is a **whole-document write**: anything the statement omits is removed.
A shell script that defines 18 pages as headings, replayed after later fill scripts, reverts
those pages. The second run of the *same* script can be unchanged while a *different* script
still overwrites it later.

**Safe replay protocol:**

1. Read the manifest; find every script that defines the target.
2. Edit only the latest owner, or deliberately consolidate ownership.
3. `mxcli diff <script> -p <project> -f struct --exec-output` — read what exec would write.
4. Apply; apply again; require `unchanged`.
5. After a failed/partial exec, `diff` again to prove the actual state.

`diff` is the convergence test, not "exec twice". "Altered" from `alter page` is not proof of
change.

### 3.3 Page editing patterns (observed)

- `create or modify page` — whole-document write; includes everything the statement declares.
  A separately-set `Url:` is dropped on replay. Put `url:` in the owning definition.
- `alter page ... set/insert/replace/drop` — targeted; preserves other content if widget names
  are stable. Always prints "Altered"; use `diff` for truth.
- `ALTER PAGE ... REPLACE <named widget>` — idempotent **if the replacement re-establishes the
  same widget name**.
- `ALTER PAGE ... REPLACE <placeholder>` — one-shot; the placeholder is gone after the first
  run, so a replay fails "widget not found". Do not build a page across scripts with
  placeholders.
- For a large structured page, prefer surgical `ALTER` on the smallest subtree for a property
  change. Do not rewrite a 600-line page for a spacing property. But remember: "don't rewrite"
  does not mean "don't conform properties" — a targeted `REPLACE column` can change width
  properties without touching structure.

### 3.4 Microflow fidelity

- `describe microflow` renders reducible graphs faithfully; for irreducible graphs it emits
  synthetic `join shared1`/`merge shared1` markers and can drop a path. `lint` reports
  `MDL-FLOW01` on these flows; the fact that it is info-level does not make it safe.
- Never run `describe → edit → create or modify` on a flow flagged `MDL-FLOW01`. Use
  `alter microflow` for property-level changes, rebuild deliberately and re-test, or edit in
  Studio Pro.
- A duplicate flow declaration is `MDL-STUB01` warning; it can still revert work. Treat it as
  an ownership defect, not noise.
- Creations are order-sensitive: callee before caller; a forward reference is a `check` error.
  Check the set as one script set when order matters, but budget for the cost (observed
  ~20–25 s/file for a large set).

### 3.5 `test --attach` cleanup

- `test --attach` only adds/removes its own test microflows; the endpoint/after-startup belong
  to the hosting app and may leave scaffolding (for example an empty `MxTest` module).
- `test --local` restores the project. Prefer it unless attach is required.
- After attach, run the documented drop/cleanup and re-read `list modules` + `describe settings`.
  Do not claim cleanup from "tests passed".

---

## 4. MDL syntax and semantics worth verifying

| Construct | Observed behaviour | Correct use |
|---|---|---|
| Reserved names (`Type`, `Context`, `Default`) | Refused even when quoted (`MDL021`/CE7247) | Rename (`DefaultRule`, `ChangeContext`, ...). |
| `Owner` | System-attribute conflict (`MDL020`) | Use `Owner: AutoOwner` only for the system audit field. |
| Entity `folder` | Parse error; entities have no folder in this grammar | Use `-- MARK:` comments and position; folders work for enums/flows/pages. |
| `REFERENCESELECTOR` | Refused by this build (built-in Forms widget) | ComboBox multi-select with a DataSource and CaptionAttribute; verify Studio Pro alternative if not using mxcli. |
| `SEND EMAIL` | Version-gated: requires 11.13+; project was 11.12.5 | Email Connector + MailLog; verify the current project's version. |
| ContentParam Decimal | `check` passes; mxbuild can reject with CE0117 | Wrap in `toString(...)`. |
| `round()`/`formatDecimal` in page expressions | `check` passes; build/runtime can fail | Use `toString()` or format server-side. |
| Association comparison inside `if` in ContentParam | `check` passes; build can reject | Two `dynamictext` widgets with complementary `Visible:`. |
| `if` around a 3-segment path | `check` passes; build can reject | Simplify; use two widgets or a helper attribute. |
| `url:` vs `Url:` | Both parse; drift hides intent | Normalise casing; keep `url:` in the owning definition. |
| `alter page` | Always prints "Altered" | Use `diff` to verify. |
| `create or modify page` | Whole-document write; drops omitted properties | Put every property in the owner; one owner. |
| `grant` | Additive; `read *`/`write *` expanded at write time | Add attribute + grant together; read back roles. |
| `alter user role ... add module roles` | Additive; cannot remove an over-grant | Review capability table; use explicit revoke/alter if needed. |
| `fmt --upgrade --header` | Safe mdl-0 → mdl-1 migration; preserves non-ASCII | Use `check --deprecations=error --v1=error` after. |
| `drop module` | May leave an empty module in some builds | Re-read `list modules`; use a cleanup script if needed. |

Always verify a construct with `mxcli syntax <topic>` and a 6-line probe + `check` before
designing around it. Do not infer from a different Mendix version or from generic MDL examples.

---

## 5. Expression dialect per position

MDL/Mendix expressions differ by where they are used. Do not use a microflow expression
unchanged in a page template or a client-side expression.

| Position | Safe pattern | Avoid |
|---|---|---|
| Microflow expression | Full expression language; enum values as `Module.ENUM.Value`; null/empty checks | Comparing enum to a string; bare identifiers as strings. |
| Page `ContentParams`/`CaptionParams` | At most two path segments; `toString()` for numbers/dates; simple `if` only where verified | Association comparison inside `if`; 3-segment path inside `if`; Decimal without `toString`. |
| Client-side expression | Simple string/boolean/format operations that the client engine supports | `round()`/`formatDecimal` (can fail or log "operator not supported"). |
| XPath/data source | Entity path from the nearest DataView; association paths as supported | Assuming `$currentObject` is the page parameter. |

When unsure, render a one-widget probe and run `docker check` plus a runtime check. `check`
alone is not enough.

---

## 6. Validation and build gates

Minimum per-change sequence for an MDL project:

```text
1. describe the target documents + refs/callers
2. write the script (one owner, callee-first, mdl 1;)
3. mxcli check <script>                  # syntax + references
4. mxcli diff <script> -f struct         # what exec would write; 0 on a converged replay
5. mxcli exec <script>                   # apply
6. mxcli exec <script>                   # must be unchanged
7. mxcli docker check --no-update-widgets # mxbuild: page expressions/widgets
8. mxcli lint                            # read warnings/counts, not the verdict
9. mxcli test tests/ --local             # behaviour
10. mxcli run --local + browser check    # render, console, layout, negative security
11. OQL/data assertion                   # stored result
```

For a page change, steps 7 and 10 are mandatory. For a security change, add a role-by-role
reachability check. For a Marketplace change, add the version-triple check.

### 6.1 Quote counts, not "passed"

`check` can print warnings and still say "All files passed" with exit 0. Report
`0 errors / N warnings / M info` and explain/triage warnings. Gate on the counts and rule IDs,
not the word "passed".

### 6.2 `lint` and `report` are not defect counts

- `lint` may have hundreds of warnings, dominated by policy rules the project accepted.
- `report` scores are policy-weighted; Security 0 may be dominated by accepted CONV rules, and
  Performance 100 may mean no N+1 rule exists.
- Triage by rule ID and specific finding. Quote the counts and the evidence.

---

## 7. Inspection sequence (cheapest → most expensive)

1. `show modules` — module set and Marketplace versions.
2. `describe settings` / `describe app security` — database, security, demo users, strict mode.
3. `describe module <X>` — module roles, documents.
4. `lint` — read warnings: `MDL-FLOW01`, `SEC010`, `MDL-WIDGET15`, etc.
5. `describe <type> <Doc>` — document as MDL; access grants included.
6. `refs <Doc>` / `callers <Flow>` — blast radius before editing.
7. `diff <script> -f struct --exec-output` — what exec would write.
8. `docker check --no-update-widgets` — build truth.

Skipping 4 and 8 is how page-expression, duplicate-flow, and widget-loadability defects reach
delivery.

---

## 8. Windows/PowerShell specifics (observed)

- PowerShell does **not** expand globs for a native binary. Pass explicit paths:
  `Get-ChildItem mdlsource\*.mdl | ForEach-Object FullName`.
- `mxcli`/`mxcli.exe` may be gitignored; a fresh clone may not have the binary. Pin the path and
  document installation.
- The console may mangle UTF-8; read files with a UTF-8-aware tool. Do not "fix" a caption based
  on mojibake in terminal output.
- Set `NO_COLOR=1` for machine parsing; ANSI escapes corrupt JSON/text greps.
- Check path lengths if the project is deep; this project was within MAX_PATH, but do not assume.

---

## 9. Marketplace/version alignment

The observed repair for a widget/module drift was a **version triple**:

```text
module version == themesource/<module>/.version == every widget package version
```

Also check `javascriptsource/<module>` exists and the expected file count. Back up before an
update; a failed update can bump the module and delete `themesource`/`javascriptsource`.
Extract the official package and run `mxcli fix widgets` rather than re-running the updater
blindly. Do not claim the repair from "build passed"; verify the rendered grid.

---

## 10. Rules

### MND-MX-01 — Probe the toolchain before writing the plan

- **Type:** Conditional (mxcli/MDL project)
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** PL-001, PL-002, RC-01
- **Applies when:** planning work in an mxcli project.
- **Instruction:** Run version/help/syntax and a capability matrix for every operation the plan
  uses. No task may name an unproven tool.
- **Verify:** Capability matrix with command, version, observed result, fallback.

### MND-MX-02 — Keep one owner per document and a manifest

- **Type:** Conditional
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** PL-003, PL-004, UI-011, MX-002
- **Applies when:** scripts write pages/flows/entities.
- **Instruction:** Use the §3 manifest; one owner; explicit stub→real only. Audit with a grep.
- **Verify:** No document appears in two authoritative `create or modify` statements; a
  manifest replay writes nothing on a converged project.

### MND-MX-03 — Diff before replay; diff after a failure

- **Type:** Conditional
- **Priority:** P0
- **Confidence:** `VERIFIED` (diff) / `UNKNOWN` (exec transactionality)
- **Source:** MX-004, MX-006, MX-013
- **Applies when:** replaying or editing an existing document.
- **Instruction:** Run `diff -f struct --exec-output` before exec. After a failed multi-statement
  exec, treat the state as unknown until diff proves it.
- **Verify:** Diff summary is expected (`0 new/modified/removed` on a converged replay).

### MND-MX-04 — `create or modify` is a whole-document write

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** MX-013, UI-011
- **Applies when:** writing a page/flow with `create or modify`.
- **Instruction:** Put every property that must survive in the owning statement. Never rely on
  a separate `alter` property surviving a replay.
- **Verify:** Diff after replay; the property is still present.

### MND-MX-05 — Use `ALTER` for property surgery, not a whole-page rewrite

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** MX-014, UI-003, FINDINGS 86
- **Applies when:** changing a property on a large existing page.
- **Instruction:** Use `ALTER PAGE ... REPLACE <named widget>` with the same name; keep the
  replacement idempotent. Do not use a placeholder for a later fill.
- **Verify:** Second run unchanged; structure preserved.

### MND-MX-06 — Treat `MDL-FLOW01` as a correctness warning

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `VERIFIED` (diagnostic) / `STRONGLY SUPPORTED` (consequence)
- **Source:** MX-005, BL-003
- **Applies when:** editing a microflow that lint flags.
- **Instruction:** Do not describe→edit→create/modify a flagged flow. Rebuild deliberately and
  test, or edit in Studio Pro.
- **Verify:** `lint` has 0 `MDL-FLOW01` on business-rule flows, or the flow was rebuilt/tested.

### MND-MX-07 — `describe page` is the page spec; `describe microflow` is not always faithful

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** MX-006, MX-005
- **Applies when:** using `describe` to edit.
- **Instruction:** For pages, use `describe page` as the source; diff before exec. For flows,
  check `MDL-FLOW01` first.
- **Verify:** Round-trip diff for pages; test after a flow rebuild.

### MND-MX-08 — Check is not build; build is not runtime

- **Type:** Conditional
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** MX-001, P-20, RC-13
- **Applies when:** any page or widget change.
- **Instruction:** Finish with `docker check --no-update-widgets` and then runtime/browser.
  `check` alone is insufficient.
- **Verify:** Build + runtime evidence; page expressions/widgets load.

### MND-MX-09 — Quote warning counts and rule IDs

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** MX-003, MX-007, MX-021
- **Applies when:** reporting a gate.
- **Instruction:** Report `0 errors / N warnings / M info`; explain each material warning. Gate
  on counts, not exit status alone.
- **Verify:** The report contains counts and triage.

### MND-MX-10 — Verify syntax and version gates with a probe

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** MX-009/010/011/012, PL-020
- **Applies when:** using a construct/widget/activity for the first time.
- **Instruction:** `mxcli syntax <topic>` + 6-line probe + `check`; record accepted spelling and
  fallback.
- **Verify:** Probe output exists.

### MND-MX-11 — Keep template expressions simple

- **Type:** Conditional (MDL/page expressions)
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** MX-001, E-12/E-13
- **Applies when:** writing `ContentParams`/`CaptionParams`/client expressions.
- **Instruction:** Two path segments; `toString()` for non-strings; no association comparison
  in `if`; no `round()`/`formatDecimal` on the client; two widgets with complementary
  `Visible:` for conditional text.
- **Verify:** `docker check` + runtime render.

### MND-MX-12 — Know the test runner's cleanup contract

- **Type:** Conditional
- **Priority:** P2
- **Confidence:** `VERIFIED` (state) / `STRONGLY SUPPORTED` (cause)
- **Source:** MX-015
- **Applies when:** running `mxcli test`.
- **Instruction:** Prefer `--local`; after `--attach`, run the cleanup/drop and re-read modules
  and settings. Do not claim cleanup from "tests passed".
- **Verify:** `list modules` and `describe settings` show no residue.

### MND-MX-13 — Use `docker check` unconditionally; the name is misleading

- **Type:** Conditional
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** MX-018
- **Applies when:** planning the build gate.
- **Instruction:** Run it as a local `mx.exe` process; no Docker required. Use
  `--no-update-widgets` for as-stored.
- **Verify:** Build output `0 errors`; a widget/runtime check after.

### MND-MX-14 — Treat a failed replay as an unknown state until diff proves otherwise

- **Type:** Conditional
- **Priority:** P1
- **Confidence:** `UNKNOWN` (exec transactionality) / `VERIFIED` (conflicting docs)
- **Source:** MX-004
- **Applies when:** a multi-statement exec fails.
- **Instruction:** Do not reason from the help text. Diff the project/script; if non-empty,
  recover deliberately and record what was applied.
- **Verify:** Diff summary; snapshot/backup.

### MND-MX-15 — Inspect access per document; there is no single access view

- **Type:** Conditional
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** MX-016
- **Applies when:** auditing roles/grants.
- **Instruction:** `describe module` + each page/flow/entity; combine with lint SEC rules. Do not
  expect `list access`.
- **Verify:** A role matrix assembled from describes, not assumed.

### MND-MX-16 — Normalize property casing and names in the style guide

- **Type:** Conditional
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** MX-013
- **Applies when:** writing MDL properties.
- **Instruction:** Pick one spelling (`url:`), one owner, one style; document it.
- **Verify:** A grep/audit finds no mixed spelling in new scripts.

### MND-MX-17 — Do not edit Marketplace content in place without a fork record

- **Type:** Conditional (toolchain/Marketplace)
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** QC-015
- **Applies when:** an MDL script alters a Marketplace page.
- **Instruction:** Prefer a project-owned copy/wrapper; if unavoidable, record and re-apply after
  upgrade.
- **Verify:** Upgrade/rebuild test; script is in the manifest.

### MND-MX-18 — Keep the manifest and script numbering current

- **Type:** Conditional
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** QC-016, PL-016
- **Applies when:** adding any script.
- **Instruction:** Claim the next free number in the README/manifest; include the script in the
  replay order; regenerate the map.
- **Verify:** A from-scratch rebuild reaches the current model; no gap/duplicate number.

### MND-MX-19 — Do not trust diagnostic text blindly

- **Type:** Conditional
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** MX-024, MX-007/008
- **Applies when:** a tool message contradicts help/observed behaviour.
- **Instruction:** Probe; cross-check; treat an empty reason or inverted causality as unknown.
- **Verify:** A minimal probe settles the behaviour; record it.

### MND-MX-20 — Budget for the set check

- **Type:** Conditional
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** MX-017
- **Applies when:** running `check` over many files.
- **Instruction:** Use per-file `check` during work (fast); run the set check at phase
  boundaries. Budget ~20–25 s/file in the observed build.
- **Verify:** The gate is scheduled, not skipped; warnings are read.
