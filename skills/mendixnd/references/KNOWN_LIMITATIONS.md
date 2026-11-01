# Known Limitations

**Purpose:** preserve verified platform, tooling, and environment limitations with their scope
and confidence, so an agent does not re-discover them as "bugs" or invent a workaround.

**Read this as evidence, not as permanent truth.** A limitation may be version-specific,
toolchain-specific, or environment-specific. Re-verify in the current project before relying
on it. Do not turn a `SUSPECTED` item into a mandatory design rule.

---

## 1. Platform behaviours (Mendix)

These are **platform behaviours**, not planning rules. The `MND-PLAT-01`-`MND-PLAT-20` IDs are
stable.

| ID | Behaviour | Consequence / correct use | Confidence | Scope |
|---|---|---|---|---|---|
| MND-PLAT-01 | Object context is lexical, not URL-based. A Data Grid XPath evaluates against the nearest enclosing DataView; `$currentObject` means that DataView's entity. | Draw the context tree. Hoisting a filter DataView can change the type. Comment re-binding DataViews. | `VERIFIED` | Mendix page model; stable concept |
| MND-PLAT-02 | A page parameter is a single object, not an association. Passing `$currentObject/Assoc` to `show page` can pass a checker and fail the build (CE1571). | Bind the association in a DataView and pass the DataView object. | `VERIFIED` | Page parameters |
| MND-PLAT-03 | A DataView over an empty optional association still renders its children. | Guard the container with `Visible: <assoc> != empty`, not only the button. | `VERIFIED` | DataView/visibility |
| MND-PLAT-04 | Inheritance works, but a grid over the base entity cannot reach subtype-only attributes. | Put shared columns on the base, use a view entity, or use a subtype grid. | `DOCUMENTED`/`VERIFIED` in project | Data grids |
| MND-PLAT-05 | Entity access is row-level XPath; there is no insert-only rule. Microflows bypass entity access unless marked `@applyentityaccess`. | Grant create to the writer; audit apply-access flows; accept/document append-only limits. | `VERIFIED` | Mendix security |
| MND-PLAT-06 | `read *` / `write *` is expanded when written; a later attribute is not covered. | Add attribute + grant in the same change. | `VERIFIED` | Entity access |
| MND-PLAT-07 | A single-page app may answer a forbidden route with HTTP 200; the shell loads and an access page replaces the content. | Assert absent content/menu, not status code. | `VERIFIED` | SPA/security testing |
| MND-PLAT-08 | There is no date-only type. Date fields are DateTime; comparisons/displays are conventions. | Store at `BeginOfCurrentDay`; compare with Begin/EndOfCurrentDay; never `=` for date-only. | `VERIFIED` | Date handling |
| MND-PLAT-09 | A Data Grid 2 enum column shows the enumeration caption, not its name. | Assert captions in UI; use names in logic. | `VERIFIED` | Data Grid 2 |
| MND-PLAT-10 | Data Grid 2 column `Size` is a weight, not pixels; `MinWidth: minContent` is the phone guard; there is no per-column "hide on phone". | Every column manual with weights; test 375 px; choose another widget if hiding is required. | `VERIFIED` | Data Grid 2 version-specific |
| MND-PLAT-11 | One empty placeholder serves "no data" and "filtered to nothing". | Write copy for both (and no permission); capability-aware CTA. | `VERIFIED` | Grids |
| MND-PLAT-12 | A chart series takes one datasource; a line chart draws SVG paths, not per-point hit targets unless markers are enabled. | Choose the marker style deliberately if a point action is required. | `VERIFIED` | Charts |
| MND-PLAT-13 | OQL can group by a joined attribute, not by an association itself. | Join then group; exclude NULL dates. | `VERIFIED` | OQL |
| MND-PLAT-14 | Scheduled events take only the fields of their repeat kind. | Read the version's scheduled-event syntax/docs before writing. | `VERIFIED` | Scheduled events |
| MND-PLAT-15 | Platform pages read System entities; a role needs access to those entities to open the page. | Check the page's entity reads for every role that can reach it; do not expose a page you cannot grant. | `VERIFIED` | Navigation/security |
| MND-PLAT-16 | A `call microflow` button is hidden when the user cannot execute the microflow; a `show page` button is not hidden when the user cannot view the page. | Add `Visible:` for page targets or grant the page; check reachability. | `VERIFIED` | Page actions |
| MND-PLAT-17 | `show message` is a modal dialog that blocks the page. | Treat dialogs as steps in the harness; read/dismiss. | `VERIFIED` | Browser testing |
| MND-PLAT-18 | The trial runtime caps concurrent sessions (~5) and has a maximum run time. | Restart between journeys; use a real logout; budget run time; read runtime.log. | `VERIFIED` model/`STRONGLY SUPPORTED` runtime | Trial/licence |
| MND-PLAT-19 | Marketplace module version and widget package version are coupled. | Triple check module == themesource/.version == widget package; back up before update. | `VERIFIED` | Marketplace |
| MND-PLAT-20 | `check` is static; mxbuild and runtime see more. | Ladder: check -> build -> runtime -> browser. | `VERIFIED` | mxcli/tooling |

### Additional platform properties

- **No partial/conditional uniqueness.** "One open verification per tag" is a convention unless
  a database constraint or concurrency strategy enforces it. State how the second caller loses.
- **Static types are stricter than some page syntax.** Enum-to-string comparisons,
  Decimal-in-String positions, and association comparisons may be rejected by the build, not by
  a static checker. State expression types; let the build arbitrate.

---

## 2. Tooling limitations (mxcli/MDL)

These are **conditional on the toolchain** and observed on a specific build. They are not
Mendix platform limitations.

| ID | Observed limitation | Workaround / correct use | Confidence |
|---|---|---|---|
| MND-MX-L01 | `check` does not type-check page `ContentParams`/`CaptionParams`; CE0117 can pass. | `docker check` after every page change; `toString()`; two-widget pattern. | `VERIFIED` check / `STRONGLY SUPPORTED` build |
| MND-MX-L02 | `check` does not see duplicate page declarations; 51/52 pages multi-owned. | One owner per page; manifest; grep/audit; diff replay. | `VERIFIED` |
| MND-MX-L03 | `MDL-STUB01` duplicate flow warning does not fail; "all files passed" can hide 7 duplicates. | Quote counts; fix ownership; gate on warnings. | `VERIFIED` |
| MND-MX-L04 | `exec` transactionality is documented contradictorily. | Treat a failed multi-statement exec as unknown; diff to prove state. | `VERIFIED` texts / `UNKNOWN` behaviour |
| MND-MX-L05 | `describe microflow` does not round-trip irreducible flows; `MDL-FLOW01`. | Do not describe→edit→create/modify; rebuild deliberately + test, or Studio Pro. | `VERIFIED` |
| MND-MX-L06 | `describe page` is faithful/re-executable; omits translations/GUIDs and prints system paths in lower-camel. | Use as page spec; diff before exec. | `VERIFIED` |
| MND-MX-L07 | Rule IDs in help differ from emitted IDs (`MDL-ORDER01` vs `MDL-REF`). | Gate on observed `ruleId` via JSON; do not grep prose IDs. | `VERIFIED` |
| MND-MX-L08 | `check` points to `show features`, which does not exist. | Use `mxcli syntax <topic>`. | `VERIFIED` |
| MND-MX-L09 | MDL cannot give an entity a folder. | Use `-- MARK:` comments; folders for enums/flows/pages. | `VERIFIED` |
| MND-MX-L10 | `REFERENCESELECTOR` refused by the build; ComboBox substitute named. | ComboBox multi-select with a DataSource/CaptionAttribute; verify Studio Pro alternative. | `VERIFIED` |
| MND-MX-L11 | Reserved names refused even quoted; `Owner` is a system attribute. | Rename; use `Owner: AutoOwner` only for the audit field. | `VERIFIED` |
| MND-MX-L12 | `SEND EMAIL` requires 11.13+; project was 11.12.5. | Email Connector + MailLog; verify version. | `VERIFIED` |
| MND-MX-L13 | `create or modify page` drops a separately-set `Url:`; `alter` always says "Altered". | Put `url:` in the owning definition; use diff. | `STRONGLY SUPPORTED` |
| MND-MX-L14 | `REPLACE <placeholder>` is one-shot; `REPLACE <named widget>` is idempotent. | Single owner; replace with the same widget name. | `STRONGLY SUPPORTED` |
| MND-MX-L15 | `test --attach` leaves scaffolding; `--local` restores. | Prefer `--local`; run cleanup; re-read modules/settings. | `VERIFIED` state |
| MND-MX-L16 | No cross-cutting `list access`; grants are appended to each describe. | Describe module + documents + lint SEC rules. | `VERIFIED` |
| MND-MX-L17 | Set check ~20–25 s/file; 90 files ~30 min. | Per-file check during work; set check at phase boundaries. | `VERIFIED` |
| MND-MX-L18 | `docker check` needs no Docker; uses local `mx.exe`. | Run unconditionally; `--no-update-widgets` for as-stored. | `VERIFIED` |
| MND-MX-L19 | PowerShell does not expand globs; console may mangle UTF-8; binaries may be gitignored. | Explicit paths; UTF-8-aware reads; pin binary; `NO_COLOR=1`. | `VERIFIED` |
| MND-MX-L20 | Trial session cap and HSQLDB default affect gate reading. | Restart between journeys; verify on target DB; record settings. | `VERIFIED` model / `STRONGLY SUPPORTED` runtime |
| MND-MX-L21 | `report` scores are policy-weighted, not defect counts; Performance 100 can mean no rule. | Quote counts/rule IDs; measure performance. | `VERIFIED` |
| MND-MX-L22 | `MDL-V1-REBUILD` is narrower than described (mid-loop insertion passed). | Probe with `check`; read the "no flow change exec would refuse" line. | `VERIFIED` |
| MND-MX-L23 | Diagnostic text defects (inverted stub causality, empty reason, concatenated token). | Cross-check help + probe; treat empty reason as unknown. | `VERIFIED` |

---

## 3. Environment limitations

| Limitation | Effect | Correct use | Confidence |
|---|---|---|---|
| Trial runtime session cap (~5) | Login fails after several browser runs; looks like bad credentials | Restart/real logout; read `runtime.log`; do not change passwords. | `VERIFIED` |
| Trial runtime max run time | Runtime terminates after a budget | Restart; budget long suites. | `VERIFIED` |
| `/logout` 404 in the harness | Sessions accumulate | Use a real logout URL or restart; assert logout succeeded. | `VERIFIED` |
| Local HSQLDB vs target PostgreSQL | Performance/concurrency/rounding may differ | Verify on PostgreSQL for production claims; do not extrapolate. | `VERIFIED` model / `SUSPECTED` consequences |
| PostgreSQL auth failure (28P01) | DB unavailable | Fix credentials/configuration; do not treat as app defect. | `VERIFIED` |
| Windows console/UTF-8 | Captions appear corrupted | Read files UTF-8-aware; do not "fix" based on console. | `VERIFIED` |
| Marketplace metadata unavailable (no PAT) | Upgrade compatibility unknown | Record `UNKNOWN`; test an upgrade branch. | `UNKNOWN` |

---

## 4. What is **not** a workaround

- Adding a CSS class you have not seen in the compiled stylesheet — it is a silent no-op.
- Re-running the Marketplace updater after a half-install — it can repeat the deletion; extract
  the official package and run `fix widgets`.
- Adding `IsDeleted`/`DeletedByName` and then hard-deleting — that is not a soft delete.
- Using `[%CurrentDateTime%]` in a date-only field — that is a timestamp that breaks `equal`
  filters.
- Treating a `check` pass as a build — it is not.
- Treating "the page opens" as "the page works" — it is not.
- Treating a `SUSPECTED` cause as a platform limitation — it is not.
- Treating one failed attempt as "Mendix cannot do this" — probe the property/version first.

---

## 5. Unresolved questions to preserve

These are deliberately left unresolved. Do not convert them into rules; use
them as investigation prompts when the relevant work appears.

| ID | Question | Why it matters | Resolution |
|---|---|---|---|
| MND-UQ-01 | Is `mxcli exec` transactional on a mid-script failure? | Recovery after a failed replay depends on it. | Fail a 2-statement script on a scratch copy; diff. |
| MND-UQ-02 | Do the CE0117 probe pages actually fail mxbuild? | Check side verified; build side from findings. | Exec on a copy; docker check; record exact CE. |
| MND-UQ-03 | Did `drop module` leave an empty module, or did a later test recreate it? | Reproducibility. | Replay drop on a copy; inspect. |
| MND-UQ-04 | What is the authentication of the Email Connector OAuth callback? | A public surface in Production. | Read the service auth tab in Studio Pro. |
| MND-UQ-05 | Is the published REST service anonymously reachable? | OAuth callback may be open by design. | Deployment test. |
| MND-UQ-06 | Does PostgreSQL behave like HSQLDB for decimal scale/XPath/conflicts? | All functional evidence was HSQLDB. | Provision PostgreSQL; run journeys/OQL. |
| MND-UQ-07 | What is the real performance at target volume? | N+1 estimate is model-based. | Seed at volume; measure. |
| MND-UQ-08 | Which Marketplace modules block an upgrade? | Native Send Email/Administration edit. | Query metadata with a PAT; test upgrade branch. |
| MND-UQ-09 | Does the Signal palette block affect rendering? | Emitted but possibly inert. | Compare computed styles with/without. |
| MND-UQ-10 | Is `WorkDate`'s overdue comparison wrong for date-only rows? | Today's item may be overdue. | Store a known midnight date; inspect. |
| MND-UQ-11 | Does test scaffolding expose an endpoint when deployed? | Potential surface. | Deploy a copy without the module; probe. |
| MND-UQ-12 | Are there duplicate business keys in demo data? | Uniqueness only in validation. | OQL group-by; fix/accept. |
| MND-UQ-13 | Does the association-column filter defect exist elsewhere? | One instance suggests a broader pattern. | Audit every association-path dropdown filter. |
| MND-UQ-14 | Can dead-end `show page` buttons be fixed by grants without widening data? | Security model impact. | Map target entity access; prefer `Visible:`. |
| MND-UQ-15 | What is the real cost of a 90-file check in CI? | Phase vs per-commit gate. | Time on target machine; parallelize. |
| MND-UQ-16 | Are duplicate flow declarations behaviourally identical? | Future edits may diverge. | Diff pairs; keep one owner. |
| MND-UQ-17 | Does every "Built" FR have an observation? | False completion claims. | Re-audit each row; downgrade unsupported. |
| MND-UQ-18 | Is a Marketplace page edit preserved on upgrade? | Silent loss. | Wrap/copy; test upgrade. |
| MND-UQ-19 | Are demo users' passwords still the template default? | Account takeover. | Inspect/reset deployment users. |
| MND-UQ-20 | Does validation feedback on an absent field still block the action? | Confusing UX. | Reproduce on the calling page. |
| MND-UQ-21 | Does a vendorlib SLF4J binding hijack runtime logging? | Hidden errors. | Remove on a branch; compare logs. |

---

## 6. Using this file correctly

1. Find the behaviour in the table.
2. Check its **scope** and **confidence**.
3. Verify it in the current project/version before designing around it.
4. If it is `SUSPECTED` or `UNKNOWN`, run the investigation prompt; do not make it a rule.
5. If it is a platform limitation, record the workaround and residual risk.
6. If it is a tooling limitation, keep it in the toolchain reference, not the platform rules.
