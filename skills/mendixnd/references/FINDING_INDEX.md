# Finding Index

**Purpose:** preserve every source finding, its priority/confidence, its disposition, and the
MendixND rule(s) that carry its lesson. This is the traceability backbone. Detailed evidence
lives in the retrospective files; this index does not replace them.

**How to read**

- `Priority` is the source priority (P0–P3) from the consolidated retrospective. Where the area
  report differs, the note says so.
- `Confidence` uses the retrospective's classes: `Verified`, `Strongly Supported`, `Suspected`,
  `Unknown`. MendixND renders these as `VERIFIED`, `STRONGLY SUPPORTED`, `SUSPECTED`, `UNKNOWN`.
- `Disposition` says how the finding was converted:
  - **Universal** — applies to Mendix work generally.
  - **Conditional** — applies only under the stated condition (version/tool/deployment).
  - **Toolchain** — mxcli/MDL or another specific toolchain.
  - **Project-specific** — OSA architecture/decision retained as an example, not a rule.
  - **Unresolved** — preserved as a question, not a rule.
- `Rule(s)` are the stable MendixND IDs. A finding may map to more than one rule.
- The source `P-01…P-20` platform behaviours collide with the source `P-01…P-44` planning
  rules. This index uses `PLAT-P-0x` and `PLAN-P-0x` in the headings to disambiguate, while
  preserving the original numbers.

---

## 1. Domain model findings (DM-001…DM-019)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| DM-001 | Zero indexes on 34 entities while access XPaths/grid sorts scan | P2 | Verified structure / Strongly Supported consequence | Universal | MND-PERF-01, MND-DM-10 |
| DM-002 | `WorkItem.WorkDate` duplicates subtype dates and goes stale on edit | P2 | Verified | Universal | MND-U-07, MND-DM-03 |
| DM-003 | Two contradictory definitions of "in service" (status vs selection) | P2 (area report P1) | Verified | Universal | MND-DM-04 |
| DM-004 | `Expired` wins over `OutOfService`, so retired bottles still warn | P2 | Verified code / Suspected impact | Universal | MND-DM-04 |
| DM-005 | `MixtureComponent` has no unit of measure; reference value can cross units | P2 | Strongly Supported | Universal | MND-DM-05 |
| DM-006 | Duplicate `Calc*` limits and `DecimalPlaces` never reaches stored limits | P2 | Verified | Universal | MND-DM-05 |
| DM-007 | Business-key uniqueness only in validation flows; race-unsafe | P2 | Verified | Universal | MND-DM-06, MND-BL-08 |
| DM-008 | `read *`/`write *` is a snapshot; later attribute silently ReadOnly | P2 | Verified | Universal | MND-DM-08, MND-SEC-03 |
| DM-009 | `MailLog`/`JobRun` have no create grant; works only because flows bypass access | P2 | Verified | Universal | MND-DM-08, MND-SEC-03 |
| DM-010 | `LimitChange`/`VerificationCorrection` writable by least-privileged role, unscoped | P3 | Verified | Universal | MND-DM-08, MND-SEC-06 |
| DM-011 | `IsPreCalibration` duplicates the self-association with no refresh link | P3 | Strongly Supported | Universal | MND-U-07, MND-DM-03 |
| DM-012 | Self/duplicate-target associations carry no role names | P3 | Verified structure | Universal | MND-DM-12 |
| DM-013 | `AppSettings` singleton is a convention; defaults written three times | P3 | Verified | Universal | MND-DM-11 |
| DM-014 | `OpenCard` merges two card types with different mandatory fields; no validation | P3 | Strongly Supported | Universal | MND-DM-06, MND-DM-01 |
| DM-015 | Identity stored twice (association + name string) with no precedence | P3 | Verified | Universal | MND-U-07, MND-DM-03 |
| DM-016 | `StatsResult` duplicates `TrendFilter`; `BundleProposal.Info` is pre-formatted text | P3 | Verified | Universal | MND-U-06 |
| DM-017 | Date-only concepts modelled as DateTime with no normalization | P3 | Strongly Supported | Universal | MND-DM-07 |
| DM-018 | English UI with one Dutch enumeration; near-identical warning names | P3 | Verified | Universal | MND-DM-13 |
| DM-019 | `SyncPending` is a one-way flag with no interface | P3 | Verified | Universal | MND-DM-14 |

---

## 2. UI and navigation findings (UI-001…UI-019)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| UI-001 | Five `show page` buttons open pages the clicking role cannot view | P1 | Verified | Universal | MND-UI-04, MND-SEC-07 |
| UI-002 | Usability pass covered 10 pages; 8 pages never in any tier | P2 | Verified | Universal | MND-UI-06, MND-UI-16 |
| UI-003 | `ResultTag_Detail` has 46 unweighted columns and no empty state | P2 | Verified | Universal | MND-UI-06 |
| UI-004 | `Admin_RunNow` has 12 controls in two ungrouped rows; demo loader is Primary | P2 | Verified | Universal | MND-UI-08 |
| UI-005 | Four detail pages use four different header/action arrangements | P2 | Verified | Universal | MND-UI-08 |
| UI-006 | Empty-state copy asserts "nothing exists" when a filter hid everything | P2 | Verified | Universal | MND-UI-07 |
| UI-007 | `Config_Teams` Role column carries the filter defect repaired elsewhere | P2 | Strongly Supported | Universal | MND-UI-14 |
| UI-008 | `Selection: Multi` with no bulk action and a row onClick | P2 | Verified | Universal | MND-UI-09 |
| UI-009 | Three meanings of `$currentObject` on one page via nested association DataViews | P2 | Verified | Universal | MND-UI-02 |
| UI-010 | Three DataViews over optional associations have no guard container | P2 | Strongly Supported | Universal | MND-UI-03 |
| UI-011 | `11` and `12` define 51 of 52 pages as shells; replay reverts 33 pages | P1 | Verified | Universal | MND-U-10, MND-MX-02 |
| UI-012 | Zero dead classes, but four hand-written class idioms survive the rule | P3 | Verified | Universal | MND-UI-05, MND-UI-15 |
| UI-013 | Dead-class fix exists twice; sweep rewrites what owners already write | P3 | Verified | Universal | MND-U-10, MND-MX-02 |
| UI-014 | 34 group boxes, none conditional; empty section still shows title | P3 | Verified | Universal | MND-UI-10 |
| UI-015 | Navigation audit: 3 non-deep-linkable config pages, no role home, duplicate entry | P3 | Verified | Universal | MND-UI-12 |
| UI-016 | Soft-deleted overview: 9 unweighted columns, no band/empty state, `equal` date filters | P3 | Verified structure / Suspected filter | Universal | MND-UI-06, MND-UI-14 |
| UI-017 | Mobile chain is a desktop layout at phone width | P3 | Verified structure | Universal | MND-UI-13 |
| UI-018 | `OpenCard_Overview`: 9 columns summing 1,560 weight units; linked record printed twice | P3 | Verified | Project-specific example | MND-UI-06 |
| UI-019 | PagePlan claims an `OpenCard_Overview` column the page does not have | P3 | Verified | Universal | MND-V-11, MND-UI-11 |

---

## 3. Business logic findings (BL-001…BL-021)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| BL-001 | `ASU_OSA_Startup` ignores self-test result and always returns true | P2 | Verified | Universal | MND-BL-12 |
| BL-002 | Tolerance seed guarded by "any rule exists"; one stray rule disables all; re-run duplicates | P2 | Verified code / Suspected fresh-DB impact | Universal | MND-BL-07 |
| BL-003 | 10 flows do not round-trip `DESCRIBE` (tolerance, mail cadence, post-calibration) | P1 | Verified | Toolchain | MND-MX-06, MND-BL-09 |
| BL-004 | `ACT_ResultTag_Delete` hard-deletes open work items incl. malfunctions | P2 | Verified | Universal | MND-DM-09, MND-BL-02 |
| BL-005 | New result tag inherits `Analyzer.StartUpDate`; starts years overdue | P2 | Verified | Universal | MND-DM-07, MND-BL-02 |
| BL-006 | Get-or-create open verification is read-then-create with no constraint/lock | P2 | Strongly Supported | Universal | MND-BL-08, MND-DM-06 |
| BL-007 | Retrieve-inside-loop dominates nightly jobs/derived refresh | P2 | Verified | Universal | MND-PERF-02 |
| BL-008 | Failed scheduled run leaves unfinished `JobRun`; no retry/missed-run detection | P2 | Verified | Universal | MND-BL-04, MND-U-09 |
| BL-009 | Mail failure invisible above `MailLog`; jobs report success and advance `LastSentOn` | P2 | Verified | Universal | MND-BL-05, MND-U-09 |
| BL-010 | Manual run-now lacks scheduled error handler/overlap; Run A/C mail no per-day idempotency | P3 | Verified | Universal | MND-BL-15, MND-BL-06 |
| BL-011 | Team-scope auth implemented three times; stored `WorkItem_Team` never used | P2 | Verified | Universal | MND-SEC-05, MND-BL-10 |
| BL-012 | Derived values refreshed after the commit that makes them wrong; 2–4 commits | P2 | Verified | Universal | MND-BL-03, MND-DM-03 |
| BL-013 | `LastResult` and `LastVerificationDate` computed from different records | P3 | Verified | Universal | MND-DM-03 |
| BL-014 | Bundling has no cycle/status/same-analyzer guard; `SaveLink` no rights re-check | P2 | Verified | Universal | MND-BL-02, MND-SEC-05 |
| BL-015 | Validation feedback attached to fields not on the calling page | P3 | Suspected | Universal | MND-BL-11 |
| BL-016 | Critical logic untested; tests commit permanent rows; one test asserts its fixture | P2 | Verified | Universal | MND-V-06, MND-V-07, MND-V-09 |
| BL-017 | 27 identical export nanoflows swallow the result; grants live in page scripts | P3 | Verified | Universal | MND-BL-13, MND-U-06 |
| BL-018 | Real business services live in 40-activity `ACT_*` flows; not reusable/testable | P2 | Verified | Universal | MND-BL-09 |
| BL-019 | Six of eight mail constants are dead; delivery depends on out-of-model account | P2 | Verified | Universal | MND-DM-14, MND-SEC-10 |
| BL-020 | Statistics use mixed date basis and survive an empty deviation | P3 | Suspected | Universal | MND-DM-07, MND-BL-02 |
| BL-021 | Demo/test generators ship in production model with no un-seed path | P3 | Verified | Universal | MND-BL-14 |

---

## 4. mxcli/MDL findings (MX-001…MX-024)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| MX-001 | `check` does not type-check page template parameters; CE0117 passes | P0 | Verified check / Strongly Supported build | Toolchain | MND-MX-08, MND-MX-11 |
| MX-002 | `check` cannot see duplicate page declarations; 51/52 multi-owned | P0 | Verified | Toolchain | MND-MX-02 |
| MX-003 | `MDL-STUB01` warnings never fail; "all scripts passed" is vacuous | P1 | Verified | Toolchain | MND-MX-09 |
| MX-004 | `exec` transactionality documented both ways | P1 | Verified texts / Unknown behaviour | Toolchain | MND-MX-14 |
| MX-005 | `describe microflow` does not round-trip 10 flows | P1 | Verified | Toolchain | MND-MX-06 |
| MX-006 | `describe page` is exactly round-trippable (strength) | — | Verified | Toolchain | MND-MX-07 |
| MX-007 | Rule IDs promised by help are not the IDs emitted | P2 | Verified | Toolchain | MND-MX-09 |
| MX-008 | `check` points to nonexistent `show features` | P3 | Verified | Toolchain | MND-MX-10, MND-MX-19 |
| MX-009 | MDL cannot give an entity a folder | P3 | Verified | Toolchain | MND-MX-10 |
| MX-010 | `REFERENCESELECTOR` refused by build; ComboBox substitute named | P2 | Verified | Toolchain | MND-MX-10 |
| MX-011 | Reserved attribute names refused even quoted; `Owner` is a system attribute | P3 | Verified | Toolchain | MND-MX-10 |
| MX-012 | `SEND EMAIL` version-gated (11.13+; project 11.12.5) | P2 | Verified | Toolchain | MND-MX-10 |
| MX-013 | Page idempotency write-dependent; `Url:` dropped; `alter` always "Altered" | P1 | Strongly Supported | Toolchain | MND-MX-04 |
| MX-014 | `REPLACE <placeholder>` one-shot; `REPLACE <named widget>` idempotent | P2 | Strongly Supported | Toolchain | MND-MX-05 |
| MX-015 | `test --attach` leaves `MxTest` scaffolding; `--local` restores | P2 | Verified state / Strongly Supported cause | Toolchain | MND-MX-12 |
| MX-016 | No cross-cutting access view; grants appended to each describe | P2 | Verified | Toolchain | MND-MX-15 |
| MX-017 | Set check ~20–25 s/file; 90 files ~30 min | P2 | Verified | Toolchain | MND-MX-20 |
| MX-018 | `docker check` needs no Docker; runs local `mx.exe` | P2 | Verified | Toolchain | MND-MX-13 |
| MX-019 | Windows/PowerShell: no glob expansion, UTF-8 mangling, gitignored binaries | P2 | Verified | Toolchain/environment | MND-MX-10, MND-PLAT-20 |
| MX-020 | Trial session cap and HSQLDB default change how gates are read | P2 | Verified model / Strongly Supported runtime | Environment | MND-V-08, MND-PLAT-18 |
| MX-021 | Scored reports reproduce exactly; scores are policy deltas | P3 | Verified | Toolchain | MND-PERF-06, MND-MX-09 |
| MX-022 | `fmt --upgrade --header` safe mdl-0→mdl-1; strict check pair works | P3 | Verified | Toolchain | MND-MX-10 |
| MX-023 | `check` did not refuse a mid-loop insertion; `MDL-V1-REBUILD` narrower | P3 | Verified | Toolchain | MND-MX-10 |
| MX-024 | Diagnostic-text defects (inverted stub, empty reason, concatenated token) | P3 | Verified | Toolchain | MND-MX-19 |

---

## 5. Planning and AI-execution findings (PL-001…PL-021)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| PL-001 | Plan written for a toolchain not installed; 107/178 task blocks invalid | P0 | Verified | Universal | MND-MX-01, MND-U-02 |
| PL-002 | "Verified" baseline described a different project/starter; three design changes | P0 | Verified | Universal | MND-U-02, MND-MX-01 |
| PL-003 | No artifact ownership; 51/52 pages multi-owned; replay deletes 2,234 lines | P0 | Verified | Universal | MND-U-10, MND-MX-02 |
| PL-004 | D-40 silent revert is the ownership bug; fix left the gun loaded | P1 | Verified | Universal | MND-U-10, MND-MX-02 |
| PL-005 | "Built" means a task exists, not verified; two rows contradicted | P1 | Verified definition / Strongly Supported contradictions | Universal | MND-V-02, MND-V-11 |
| PL-006 | README, addendum, docs/brain absent; acceptance criterion silently replaced | P1 | Verified | Universal | MND-U-12, MND-V-12 |
| PL-007 | Visual correctness not in definition of done; all gates green while UI broken | P0 | Verified | Universal | MND-V-01, MND-V-03 |
| PL-008 | Dead CSS classes invented from memory; 31 widgets/22 pages no spacing | P0 | Verified | Universal | MND-UI-05, MND-N-03 |
| PL-009 | Spec contradicted itself on malfunction cancel; "Built" feature unclickable | P1 | Verified | Universal | MND-BL-02, MND-UI-04 |
| PL-010 | Four architecture-shaping decisions taken by executor, never fed back | P1 | Verified | Universal | MND-U-13 |
| PL-011 | Half of Part 2 decisions reconcile acceptance; one "platform limit" was a setting | P2 | Verified counts / Strongly Supported cost | Universal | MND-U-13, MND-N-05 |
| PL-012 | Plan states a precedence rule it does not follow | P2 | Verified | Universal | MND-U-13 |
| PL-013 | "One task = one change" failed; largest scripts concentrated rework | P2 | Verified | Universal | MND-U-06, MND-MX-02 |
| PL-014 | Test data not isolated; journeys encoded shared DB, rewritten three times | P2 | Verified | Universal | MND-V-05 |
| PL-015 | Status numbers drift; evidence artifact froze at "P16 closed" | P1 | Verified | Universal | MND-U-12, MND-V-12 |
| PL-016 | Script numbering diverged; README never updated | P2 | Verified | Toolchain/process | MND-MX-18, MND-U-14 |
| PL-017 | Plan frozen by checksum; correction additive; two truths coexist | P2 | Verified | Universal | MND-U-13 |
| PL-018 | Final self-audit written but never executed; thresholds stale | P2 | Verified | Universal | MND-V-12 |
| PL-019 | Version-control premise self-contradictory; all P9–P16 one commit | P2 | Verified / Unknown timing | Universal | MND-U-12, MND-V-12 |
| PL-020 | Decision ownership/probe-before-writing list missing | P2 | Strongly Supported | Universal | MND-U-05, MND-N-01 |
| PL-021 | Decisions log has gaps, ID collision, rows hidden in another cell | P3 | Verified | Universal | MND-U-11 |

---

## 6. Quality, security, and operations findings (QC-001…QC-020)

| ID | Finding | Priority | Confidence | Disposition | Rule(s) |
|---|---|---|---|---|---|
| QC-001 | `FunctionalAdmin` carries `Administration.Administrator`; can administer accounts | P1 | Verified | Universal | MND-SEC-01 |
| QC-002 | Stock `User` mapped to `Technician`; every account is a technician | P2 | Verified | Universal | MND-SEC-01 |
| QC-003 | Demo users enabled at Production; five shared passwords committed | P1 | Verified | Universal | MND-SEC-02, MND-SEC-10 |
| QC-004 | Production security with strict mode off | P1 | Verified | Universal | MND-SEC-02 |
| QC-005 | Authorization decisions in writable non-persistent entity, trusted by ACT | P2 | Strongly Supported | Universal | MND-SEC-05, MND-BL-10 |
| QC-006 | Audit entities unscoped and client-writable by technicians | P2 | Verified | Universal | MND-SEC-06, MND-DM-08 |
| QC-007 | Field write lists include audit/soft-delete columns; owner fallback widens scope | P2 | Verified | Universal | MND-SEC-03, MND-DM-08 |
| QC-008 | Pages granted to roles that cannot use them (page/action/entity triangle) | P3 | Verified | Universal | MND-SEC-07 |
| QC-009 | Team membership is the ACL; FunctionalAdmin can rewrite it for every team | P2 | Verified | Universal | MND-SEC-01, MND-SEC-04 |
| QC-010 | Seed/demo actions ship to Production; `TST_Demo_Seed` granted directly | P2 | Verified | Universal | MND-SEC-08, MND-BL-14 |
| QC-011 | Jobs record success while mail is failed | P2 | Verified | Universal | MND-BL-04, MND-BL-05 |
| QC-012 | Scheduled events run server time zone, overlap-delay, no failure alerting | P3 | Verified config / Suspected consequence | Universal | MND-BL-06 |
| QC-013 | Six of eight constants dead; no credential committed | P3 | Verified | Universal | MND-DM-14, MND-SEC-10 |
| QC-014 | "Stock Atlas restored" only half true; Signal tokens still live | P2 | Verified | Project-specific example | MND-UI-05, MND-U-11 |
| QC-015 | Marketplace `Administration.Account_Overview` edited by project script; upgrade loss | P2 | Verified | Universal | MND-MX-17, MND-SEC-09 |
| QC-016 | Documented rebuild order cannot reproduce delivered app | P2 | Verified | Universal | MND-MX-18, MND-U-12 |
| QC-017 | 20 tests/12 journeys cover calculation core, none of rights/scheduling/failure/export | P2 | Verified | Universal | MND-V-07 |
| QC-018 | Derive-refresh N+1 in one transaction; top production risk | P2 | Strongly Supported | Universal | MND-PERF-02, MND-PERF-04 |
| QC-019 | Unbounded retrieves/unbatched reads on growth paths | P3 | Verified code / Suspected volume | Universal | MND-PERF-03 |
| QC-020 | Gates numbers exact but scores/issue counts not health metrics; triage missing | P3 | Verified | Universal | MND-MX-09, MND-PERF-06, MND-V-01 |

---

## 7. Root causes (RC-01…RC-15)

| ID | Root cause | Rule(s) |
|---|---|---|
| RC-01 | Plan written for a toolchain that was not present | MND-MX-01, MND-U-02 |
| RC-02 | No artifact ownership; replay destructive | MND-U-10, MND-MX-02 |
| RC-03 | "Done" defined by commands, not outcomes | MND-V-01, MND-V-03 |
| RC-04 | Object context/expression semantics inferred from web intuition | MND-UI-02, MND-DM-01 |
| RC-05 | Requirements conflicts deferred to executor | MND-U-13 |
| RC-06 | Non-functional requirements absent | MND-PERF-04, MND-SEC-02, MND-DM-10 |
| RC-07 | Environment limits unknown/misdiagnosed | MND-V-08 |
| RC-08 | Visual design expressed as remembered CSS, not properties | MND-UI-05, MND-N-03 |
| RC-09 | Test harness/data not treated as production code | MND-V-05, MND-V-06, MND-V-08 |
| RC-10 | Lessons captured after the fact, not fed back | MND-U-11, MND-U-12 |
| RC-11 | Scope changed after "done" without change control | MND-U-12 |
| RC-12 | Security composed from role names, not capabilities | MND-SEC-01, MND-SEC-05 |
| RC-13 | Tool output fidelity assumed | MND-MX-08, MND-N-04 |
| RC-14 | Derived state/transaction boundaries afterthought | MND-DM-03, MND-BL-03 |
| RC-15 | Testing measured the wrong layer | MND-V-07, MND-V-09 |

---

## 8. Runtime/harness evidence (LEAD-04)

| ID | Finding | Rule(s) |
|---|---|---|
| LEAD-04 | Harness calls `/logout`, gets 404, sessions accumulate until login fails; trial cap ~5 | MND-V-08, MND-PLAT-18 |

---

## 9. Platform behaviours (source `P-01…P-20`, Section 10)

| Source | MendixND ID | Behaviour | Confidence | Scope |
|---|---|---|---|---|
| P-01 | MND-PLAT-01 | Object context lexical; grid XPath against nearest DataView | Verified | Stable |
| P-02 | MND-PLAT-02 | Page parameter is one object, not an association | Verified | Stable |
| P-03 | MND-PLAT-03 | Empty optional DataView still renders children | Verified | Stable |
| P-04 | MND-PLAT-04 | Base grid cannot reach subtype attributes | Documented/Verified in project | Stable |
| P-05 | MND-PLAT-05 | Entity access row-level; no insert-only; flows bypass unless marked | Verified | Stable |
| P-06 | MND-PLAT-06 | `read *`/`write *` expanded at write time | Verified | Stable |
| P-07 | MND-PLAT-07 | SPA may return 200 for forbidden route | Verified | Stable |
| P-08 | MND-PLAT-08 | No date-only type | Verified | Stable |
| P-09 | MND-PLAT-09 | Data Grid 2 enum column shows caption | Verified | Version-specific |
| P-10 | MND-PLAT-10 | Column `Size` is weight; no per-column phone hide | Verified | Version-specific |
| P-11 | MND-PLAT-11 | One empty placeholder for no-data/filtered | Verified | Stable |
| P-12 | MND-PLAT-12 | Chart line needs markers for point hits | Verified | Version-specific |
| P-13 | MND-PLAT-13 | OQL groups by joined attribute, not association | Verified | Stable |
| P-14 | MND-PLAT-14 | Scheduled event fields depend on repeat kind | Verified | Stable |
| P-15 | MND-PLAT-15 | Platform pages need System entity access | Verified | Stable |
| P-16 | MND-PLAT-16 | `show page` not hidden by page grant; call microflow is hidden | Verified | Stable |
| P-17 | MND-PLAT-17 | `show message` is a blocking modal | Verified | Stable |
| P-18 | MND-PLAT-18 | Trial session cap/max run time | Verified model/Strongly Supported runtime | Environment |
| P-19 | MND-PLAT-19 | Marketplace module/widget versions coupled | Verified | Toolchain/Marketplace |
| P-20 | MND-PLAT-20 | `check` static; build/runtime see more | Verified | Toolchain |

---

## 10. Planning rule provenance (source `P-01…P-44`, Section 16)

The source uses `P-01…P-44` for planning rules. They are listed here as `PLAN-P-xx` to avoid
colliding with the platform table.

| Source | Rule summary | MendixND rule(s) |
|---|---|---|
| PLAN-P-01 | Probe toolchain, plan against it | MND-MX-01 |
| PLAN-P-02 | Capability matrix with evidence | MND-MX-01 |
| PLAN-P-03 | Probe the uncertain 10% | MND-U-05, MND-MX-10 |
| PLAN-P-04 | Declare project shape once | MND-U-02 |
| PLAN-P-05 | Ownership manifest as deliverable | MND-U-10, MND-MX-02 |
| PLAN-P-06 | Declare test runner/cleanup contract | MND-MX-12 |
| PLAN-P-07 | Page/flow context before entities | MND-DM-01, MND-UI-01 |
| PLAN-P-08 | One fact, one home | MND-U-07 |
| PLAN-P-09 | Units/precision | MND-DM-05 |
| PLAN-P-10 | Derived enumeration precedence | MND-DM-04 |
| PLAN-P-11 | Required vs unique | MND-DM-06 |
| PLAN-P-12 | Entity access policy table | MND-DM-08, MND-SEC-03 |
| PLAN-P-13 | No audit write | MND-SEC-06 |
| PLAN-P-14 | Indexes from XPaths/sorts | MND-DM-10, MND-PERF-01 |
| PLAN-P-15 | Date-only normalization | MND-DM-07 |
| PLAN-P-16 | Association role names | MND-DM-12 |
| PLAN-P-17 | Derived write graph | MND-DM-03, MND-BL-03 |
| PLAN-P-18 | Pages as tree with contexts | MND-UI-01 |
| PLAN-P-19 | Translate prototype explicitly | MND-UI-16 |
| PLAN-P-20 | Design properties, not CSS | MND-UI-05 |
| PLAN-P-21 | Grid behavior | MND-UI-06 |
| PLAN-P-22 | Conditional action context/visibility | MND-UI-03, MND-UI-04 |
| PLAN-P-23 | Responsive contract | MND-UI-13 |
| PLAN-P-24 | Expression dialect per position | MND-MX-11 |
| PLAN-P-25 | Identity band/action placement | MND-UI-08 |
| PLAN-P-26 | Empty state for every list | MND-UI-07 |
| PLAN-P-27 | State machine, not verbs | MND-BL-02 |
| PLAN-P-28 | Transaction boundary | MND-BL-03 |
| PLAN-P-29 | Concurrency/duplicates | MND-BL-08, MND-DM-06 |
| PLAN-P-30 | Scheduling semantics | MND-BL-06 |
| PLAN-P-31 | Server-side authorization | MND-BL-10, MND-SEC-05 |
| PLAN-P-32 | Integration observable outcome | MND-BL-04, MND-BL-05 |
| PLAN-P-33 | Test data contract | MND-V-05 |
| PLAN-P-34 | Verification ladder | MND-V-02 |
| PLAN-P-35 | Assertions per critical flow | MND-V-07 |
| PLAN-P-36 | Resolve conflicts before task 1 | MND-U-13 |
| PLAN-P-37 | Size tasks by document | MND-U-06, MND-MX-02 |
| PLAN-P-38 | Observable acceptance | MND-V-01 |
| PLAN-P-39 | Environment limits/runtime profile | MND-V-08 |
| PLAN-P-40 | Change control after done | MND-U-12 |
| PLAN-P-41 | Operating rules are a deliverable | MND-U-12 |
| PLAN-P-42 | State out of scope | MND-U-11 |
| PLAN-P-43 | Machine-checkable close-out | MND-V-12 |
| PLAN-P-44 | Classify decisions by reversibility | MND-U-13 |

---

## 11. Execution rule provenance (source `E-01…E-40`, Section 17)

| Source | Rule summary | MendixND rule(s) |
|---|---|---|
| E-01 | Read the model, not the plan's memory | MND-U-02 |
| E-02 | Syntax before new construct | MND-MX-10 |
| E-03 | Quote identifiers; avoid reserved names | MND-MX-10 |
| E-04 | Check document owner before writing | MND-U-10, MND-MX-02 |
| E-05 | Dry-run/diff first | MND-MX-03 |
| E-06 | One script, one concern, `mdl 1;` | MND-MX-02 |
| E-07 | `check` is not build | MND-MX-08 |
| E-08 | Apply twice; require unchanged | MND-MX-03, MND-MX-04 |
| E-09 | Never replay an old page script | MND-U-10 |
| E-10 | Never whole-rewrite a large page for a small change | MND-MX-05 |
| E-11 | Optional association → guarded DataView | MND-UI-03 |
| E-12 | Keep template expressions simple | MND-MX-11 |
| E-13 | No client `round()`/`formatDecimal` | MND-MX-11 |
| E-14 | Design properties for spacing/flex/gap | MND-UI-05 |
| E-15 | DataGrid manual weights + minContent | MND-UI-06 |
| E-16 | Attribute + grant together | MND-DM-08 |
| E-17 | Grant every new document | MND-SEC-08 |
| E-18 | Recompute rights server-side | MND-SEC-05, MND-BL-10 |
| E-19 | Audit tables append-only | MND-SEC-06 |
| E-20 | Do not edit Marketplace modules/pages | MND-SEC-09, MND-MX-17 |
| E-21 | Restart runtime after structural change | MND-V-08 |
| E-22 | Real logout or restart | MND-V-08 |
| E-23 | Verify layout, not DOM presence | MND-V-03 |
| E-24 | Negative security by absence | MND-V-10 |
| E-25 | Verify downloads end to end | MND-V-04, MND-BL-13 |
| E-26 | Reopen page after microflow data source | MND-UI-14 |
| E-27 | Unique test data per run | MND-V-05 |
| E-28 | Handle browser widgets as they are | MND-V-08 |
| E-29 | Count console errors after login | MND-V-08 |
| E-30 | Back up before Marketplace update; verify bundle | MND-N-07 |
| E-31 | Treat report scores as coverage, not quality | MND-PERF-06 |
| E-32 | Check `MDL-FLOW01` before editing a complex flow | MND-MX-06 |
| E-33 | Quote counts, never "passed" | MND-MX-09 |
| E-34 | Record evidence at the moment of change | MND-V-11 |
| E-35 | Report deviations before working around | MND-U-13 |
| E-36 | Keep manifest/handoff/FINDINGS current | MND-U-12 |
| E-37 | Commit at coherent boundaries | MND-U-12 |
| E-38 | Do not claim built until ladder complete | MND-V-02 |
| E-39 | Tool message contradicts help → probe | MND-MX-19 |
| E-40 | Treat a test that cannot fail as a defect | MND-V-09 |

---

## 12. Reusable strengths (not defects)

The retrospective records these as things that worked. They are not rules by themselves, but
they are patterns worth reusing when the context fits.

| Strength | Source | Why it worked |
|---|---|---|
| Real `WorkItem` generalization | Section 5.4 | Shared status/reference/system members/associations declared once; subtypes add only their own. |
| Entity access in the same script as the entity, one rule per intent | Section 5.4 | The matrix reads as a policy; team/own/admin/system rules are separable. |
| Stored derived fields with Compute/Refresh split | Section 7.4 | Grids stay cheap; batch repair reuses the same computation. |
| Snapshot-plus-reference audit | Section 5.4 | Frozen limits/rule text/old values survive later rule changes. |
| Reference strings from autonumber | Section 5.4 | Human reference unique by construction, never typed. |
| Guarded delete in a microflow | Section 5.4 | No association cascade; explicit refusal/delete of children. |
| `SUB_`/`VAL_`/`DS_` separation | Section 7.4 | Testable business rules; validation returns Boolean + feedback. |
| Safe-by-default mail switch | Section 7.4 | Disabled by default; explicit failure reasons; on-error logging. |
| Idempotent seed by natural key | Section 7.4 | Re-run does not duplicate. |
| OQL assertions beside UI journeys | Section 7.4 | Caught a mis-bundling the UI hid. |
| Mutation checks on microflow tests | Section 4.4 | Strongest verification evidence in the project. |
| Append-only FINDINGS log with verification method | Section 4.4 | Made the retrospective reconstructable. |
| Probe-first PagePlan method | Section 4.4 | Throwaway probes before planning; measurable usability criteria. |
| Decision log with IDs | Section 4.4 | Every deviation traceable, even when applied inconsistently. |

---

## 13. Findings that were not converted into rules

These are preserved as project-specific knowledge, unresolved questions, or examples. They
must not be presented as universal Mendix rules.

| Finding / topic | Why not a universal rule | Where retained |
|---|---|---|
| OSA-specific module/entity/page names (`OSA`, `WorkItem`, `ResultTag`, `OpenCard`) | One project's domain vocabulary | Examples in `DOMAIN_MODEL.md`, `UI_AND_STYLING.md`; not mandatory |
| Mendix 11.12.5 / mxcli nightly build behaviours | Version/toolchain-specific | `MXCLI_MDL.md`, `KNOWN_LIMITATIONS.md` |
| DataWidgets 3.11.8 / Atlas 4.6.0 versions | Project dependency versions | `KNOWN_LIMITATIONS.md` as an example |
| HSQLDB vs PostgreSQL evidence | Environment-specific; production not measured | `KNOWN_LIMITATIONS.md`, `MND-UQ-06/07` |
| Trial licence session cap (~5) | Environment/licence-specific | `KNOWN_LIMITATIONS.md`, `MND-PLAT-18` |
| Signal theme/`custom-variables.scss` remainder | Project-specific theme drift | `TRACEABILITY.md`; example only |
| Exact 155-FR matrix / Jira IDs | Project-specific traceability | Example in `VALIDATION_AND_TESTING.md`; not a rule |
| PagePlan U-019 claim | Project documentation defect | Example in `UI_AND_STYLING.md`; not a rule |
| Whether `mxcli exec` is transactional | `UNKNOWN` | `MND-UQ-01` |
| Whether CE0117 probes fail mxbuild | Check side verified, build side not reproduced | `MND-UQ-02` |
| Whether `drop module` left `MxTest` | `SUSPECTED` cause | `MND-UQ-03` |
| Whether the OAuth callback is anonymous | `UNKNOWN` | `MND-UQ-04/05` |
| PostgreSQL performance/rounding | Not measured | `MND-UQ-06/07` |
| Upgrade compatibility | No Marketplace metadata | `MND-UQ-08` |
| Signal palette actual rendering | Not compared | `MND-UQ-09` |
| Date-only overdue comparison | Structural fact verified; runtime not | `MND-UQ-10` |
| Test scaffolding endpoint exposure | Not probed | `MND-UQ-11` |
| Duplicate business keys in demo data | Not queried | `MND-UQ-12` |
| Association-filter defect breadth | One instance strongly supported | `MND-UQ-13` |
| Whether grants can fix dead-end buttons without widening data | Not mapped | `MND-UQ-14` |
| CI cost of a 90-file check | Machine-specific | `MND-UQ-15` |
| Duplicate flow behavioural identity | Diffed today, future may diverge | `MND-UQ-16` |
| FR observation completeness | Not re-audited per row | `MND-UQ-17` |
| Marketplace edit preservation | Not upgrade-tested | `MND-UQ-18` |
| Demo user template passwords | Unknown | `MND-UQ-19` |
| Validation feedback on absent field | Suspected | `MND-UQ-20` |
| Vendorlib SLF4J binding | Suspected | `MND-UQ-21` |

---

## 13b. Unresolved question index (MND-UQ-01…21)

These are preserved as questions, not rules. Full detail is in `KNOWN_LIMITATIONS.md` §5 and
`TRACEABILITY.md` §6.

| ID | Question | Status |
|---|---|---|
| MND-UQ-01 | Is `mxcli exec` transactional on mid-script failure? | `UNKNOWN` |
| MND-UQ-02 | Do CE0117 probes actually fail mxbuild? | `STRONGLY SUPPORTED` build side |
| MND-UQ-03 | Did `drop module` leave `MxTest`, or did a test recreate it? | `SUSPECTED` |
| MND-UQ-04 | Authentication of the Email Connector OAuth callback? | `UNKNOWN` |
| MND-UQ-05 | Is the published REST service anonymously reachable? | `UNKNOWN` |
| MND-UQ-06 | PostgreSQL behaviour vs HSQLDB for decimal/XPath/conflicts? | `UNKNOWN` |
| MND-UQ-07 | Real performance at target volume? | `UNKNOWN` |
| MND-UQ-08 | Which Marketplace modules block an upgrade? | `UNKNOWN` |
| MND-UQ-09 | Does the Signal palette block affect rendering? | `SUSPECTED` |
| MND-UQ-10 | Is `WorkDate` overdue comparison wrong for date-only rows? | `SUSPECTED` |
| MND-UQ-11 | Does test scaffolding expose an endpoint when deployed? | `UNKNOWN` |
| MND-UQ-12 | Are there duplicate business keys in demo data? | `UNKNOWN` |
| MND-UQ-13 | Does the association-filter defect exist elsewhere? | `STRONGLY SUPPORTED` one instance |
| MND-UQ-14 | Can dead-end buttons be fixed by grants without widening data? | `UNKNOWN` |
| MND-UQ-15 | Real cost of a 90-file check in CI? | `UNKNOWN` (machine-specific) |
| MND-UQ-16 | Are duplicate flow declarations behaviourally identical? | `STRONGLY SUPPORTED` today |
| MND-UQ-17 | Does every "Built" FR have an observation? | `UNKNOWN` |
| MND-UQ-18 | Is the Marketplace page edit preserved on upgrade? | `UNKNOWN` |
| MND-UQ-19 | Are demo user template passwords still default? | `UNKNOWN` |
| MND-UQ-20 | Does validation feedback on an absent field still block? | `SUSPECTED` |
| MND-UQ-21 | Does a vendorlib SLF4J binding hijack runtime logging? | `SUSPECTED` |

---

## 14. High-impact conversion ledger

The full index above maps every finding. This ledger makes the conversion explicit for the
highest-impact findings across priorities: what went wrong, the root cause, the preventive
rule, and how compliance is verified.

| Finding | What went wrong | Root cause | Preventive rule(s) | Verify |
|---|---|---|---|---|
| PL-001 | Plan written for Studio Pro MCP/Concord; 107 task blocks invalid | Environment assumed, not probed (RC-01) | MND-MX-01, MND-U-02 | Capability matrix with observed commands/versions; no unproven tool named |
| PL-002 | "Verified" baseline described another project/starter | Baseline not re-verified at execution (RC-01) | MND-U-02, MND-MX-01 | Baseline generated from current project commands, dated/hashed |
| PL-003 | 51/52 pages multi-owned; replay deletes 2,234 lines | No artifact ownership model (RC-02) | MND-U-10, MND-MX-02 | Ownership grep + manifest; replay diff is empty |
| PL-004 | Silent revert of two pages; fix left the class | Ownership bug not removed (RC-02) | MND-U-10, MND-MX-02 | No document has two authoritative definitions |
| PL-005 | 151 FRs marked Built without observation; two contradicted | "Built" mapped to task, not evidence (RC-03/RC-15) | MND-V-02, MND-V-11 | Per-requirement observation in the acceptance matrix |
| PL-006 | README/addendum/brain absent; acceptance replaced | Narrative close-out, no mechanical checklist (RC-10) | MND-U-12, MND-V-12 | Close-out files exist; checklist output pasted |
| PL-007 | One-column grids/label concatenation passed all gates | Visual correctness absent from done (RC-03) | MND-V-01, MND-V-03 | Screenshots + measured layout at 3 viewports |
| PL-008 | 31 widgets/22 pages used dead CSS classes | Classes recalled, not verified (RC-08) | MND-UI-05, MND-N-03 | Class audit against compiled CSS; design-property usage |
| PL-009 | Cancel button could never render; spec contradicted itself | Requirement conflict deferred; no action coverage (RC-05) | MND-U-13, MND-BL-02, MND-UI-04 | Rights truth table + every specified action clicked |
| PL-010 | Four architecture-shaping decisions taken mid-execution | Decision ownership not classified (RC-01/RC-05) | MND-U-13 | Decision record with owner/reversibility; plan amended |
| PL-014 | Journeys encoded shared DB; rewritten three times | No test-data isolation (RC-09) | MND-V-05 | Unique run key; two consecutive runs pass |
| PL-015 | Handoff/status froze at "P16 closed" | Status tied to phases, no post-close change control (RC-11) | MND-U-12, MND-V-12 | Regenerated status/manifest from current model |
| MX-001 | CE0117 page expressions passed `check` | Check scope misunderstood (RC-13) | MND-MX-08, MND-MX-11 | `docker check` 0 errors + runtime render |
| MX-002 | Two scripts defined one page; check silent | Missing duplicate-page rule + no ownership (RC-02/RC-13) | MND-MX-02 | Ownership grep; no duplicate authoritative definition |
| MX-003 | 7 duplicate flows behind "all scripts passed" | Non-error warnings not counted (RC-13) | MND-MX-09 | `0 errors / N warnings` quoted and triaged |
| MX-005 | 10 flows do not round-trip `describe` | Tool fidelity assumed (RC-13) | MND-MX-06 | `MDL-FLOW01` checked; rebuild tested |
| MX-013 | `Url:` dropped; "Altered" false idempotency | Whole-document write semantics (RC-13) | MND-MX-04 | Diff after replay; property persists |
| UI-001 | Five `show page` buttons target pages the role cannot view | Page grants not joined to actions (RC-04/RC-12) | MND-UI-04, MND-SEC-07 | Role-by-role reachability test |
| UI-002 | 8 pages never received the usability pass | Tier list not enumerated; "done" lacked visual axis (RC-03) | MND-UI-06, MND-UI-16 | Per-page property coverage count; screenshots |
| UI-003 | Central detail page had 46 unweighted columns | "Don't rewrite" read as "don't conform" (RC-03) | MND-UI-06 | Every column manual + `minContent`; 3-viewport check |
| UI-011 | Replaying shell scripts reverted 33 pages | Multi-owner scripts (RC-02) | MND-U-10, MND-MX-02 | Ownership manifest; replay diff empty |
| BL-003 | Three core rules not round-trippable | Tool fidelity assumed (RC-13) | MND-MX-06, MND-BL-09 | `MDL-FLOW01` gate; test after rebuild |
| BL-004 | Soft-delete app hard-deleted open work items | Delete semantics not specified (RC-14) | MND-DM-09, MND-BL-02 | Dependant tests; audit/soft-delete state |
| BL-008 | Failed job left unfinished `JobRun`; no retry | Audit row created inside callee, error handler cannot close (RC-14) | MND-BL-04 | Forced failure closes row with failure status |
| BL-009 | Job said success while mail failed | Returned status ignored (RC-14) | MND-BL-05 | Failed mail produces failed job status |
| BL-012 | Derived counters stale after partial failure | Commit order/transaction boundary afterthought (RC-14) | MND-BL-03, MND-DM-03 | Forced failure leaves no unmarked stale record |
| BL-016 | Critical logic untested; tests commit rows; one test asserts fixture | Test coverage measured newest, not riskiest (RC-15) | MND-V-06, MND-V-07, MND-V-09 | Risk-ranked tests; mutation check; fixtures separate |
| DM-001 | Zero indexes on 34 entities | NFR absent/performance deferred (RC-06) | MND-DM-10, MND-PERF-01 | Index list from XPaths/sorts; volume measurement |
| QC-001 | FunctionalAdmin could administer accounts | Role name treated as capability (RC-12) | MND-SEC-01 | Capability table; role read-back diff |
| QC-003 | Demo users enabled at Production with shared passwords | Security quartet not a gate (RC-12) | MND-SEC-02, MND-SEC-10 | Production config: demo off; secret scan |
| QC-004 | Strict mode off | Security quartet not a gate (RC-12) | MND-SEC-02 | `describe app security`/settings evidence |
| QC-005 | Client-supplied rights trusted by ACT flows | Authorization crossed client boundary (RC-12) | MND-SEC-05, MND-BL-10 | Direct call with forged rights is refused |
| QC-016 | Rebuild order stopped at `41e`; later scripts absent | Manifest not maintained/regenerated (RC-10) | MND-MX-18, MND-U-12 | From-scratch rebuild matches current model |
| QC-018 | Derive-refresh N+1 (~10k queries at volume) | Per-row retrieve design; no query budget (RC-06) | MND-PERF-02, MND-PERF-04 | Query count/measurement at target volume |
| LEAD-04 | `/logout` 404; sessions accumulated; login looked broken | Runtime profile/harness lifecycle unknown (RC-07) | MND-V-08, MND-PLAT-18 | Real logout/restart; runtime.log reviewed |

---

## 15. Coverage check

| Prefix | Source count | Indexed here |
|---|---|---|
| DM | 19 | 19 |
| UI | 19 | 19 |
| BL | 21 | 21 |
| MX | 24 | 24 |
| PL | 21 | 21 |
| QC | 20 | 20 |
| RC | 15 | 15 |
| LEAD | 1 | 1 |
| Platform P | 20 | 20 (`MND-PLAT-01…20`) |
| Planning P | 44 | 44 (`PLAN-P-01…44`) |
| Execution E | 40 | 40 (`E-01…40`) |

If a future source adds a finding, append a row; do not renumber existing IDs.
