# Traceability and Conversion Report

**Purpose:** show how the retrospective's findings became MendixND rules, what was generalized,
what was kept conditional, what remains project-specific, and what is still unresolved. This is
the audit trail for the skill itself.

---

## 1. Method

1. Read the consolidated retrospective and all six area reports, plus the probe corpus and
   brief. Do not rely on the executive summary.
2. Extract every finding with an ID (`DM-`, `UI-`, `BL-`, `MX-`, `PL-`, `QC-`, `RC-`, `LEAD-`).
3. Separate the **incident** from the **lesson**:
   - the incident may be project-specific,
   - the lesson may be universal, conditional, or toolchain-specific.
4. Assign a stable MendixND rule ID and a confidence.
5. State applicability, verification, and exceptions.
6. Preserve unresolved/uncertain findings as questions, not rules.
7. Check every finding ID is indexed (`FINDING_INDEX.md` §14).
8. Test the resulting skill against eight realistic scenarios (`SCENARIO_TESTS.md`).

A rule was not created when the evidence was too project-specific, too uncertain, or already
fully expressed by a platform limitation/workaround.

---

## 2. Rule inventory

| Prefix | Area | Count | Typical type |
|---|---|---|---|
| `MND-U-` | Core universal principles | 14 | Universal |
| `MND-N-` | Native-first / custom justification | 8 | Universal |
| `MND-DM-` | Domain model | 14 | Universal |
| `MND-UI-` | UI and styling | 16 | Universal |
| `MND-BL-` | Microflows/nanoflows | 15 | Universal |
| `MND-SEC-` | Security | 12 | Universal |
| `MND-PERF-` | Performance | 8 | Universal |
| `MND-MX-` | mxcli/MDL | 20 | Conditional/toolchain |
| `MND-V-` | Validation/testing | 12 | Universal |
| `MND-AI-` | Agent behaviour | 12 | Universal |
| `MND-PLAT-` | Platform behaviours | 20 | Conditional/version-scoped |
| `MND-UQ-` | Unresolved questions | 21 | Not rules |

Rules are intentionally grouped. A single rule may carry several findings; a finding may map
to several rules. The mapping is in `FINDING_INDEX.md`.

---

## 3. Converted into universal rules

These findings produced rules that apply to Mendix work generally. The incident may be
project-specific, but the lesson is not.

### 3.1 Native-first, reuse, and project context

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| PL-001, PL-002, RC-01 | MND-U-02, MND-MX-01 | Inspect/probe the actual environment before planning. |
| PL-007, PL-008, UI-002, UI-012, RC-03, RC-08 | MND-U-01, MND-N-01, MND-N-03, MND-UI-05 | Native/reuse scan before custom; design properties before CSS. |
| DM clean checks, PL-003 | MND-U-03 | Reuse existing artifacts before rebuilding. |
| PL-005, PL-007, RC-15 | MND-U-04, MND-V-01/02/03 | Define done by observable outcomes. |
| MX-001/005, PL-020, RC-13 | MND-U-05, MND-N-06 | Verify unfamiliar platform/tool behaviour. |
| DM-016, BL-017/018, RC-14 | MND-U-06 | Simplest maintainable solution; no duplicate helpers. |
| DM-002/011/015, BL-012 | MND-U-07, MND-DM-03 | One fact, one home; derived write graph. |
| QC-005, BL-011, RC-12 | MND-U-08, MND-SEC-05, MND-BL-10 | Server-side authorization. |
| BL-008/009, QC-011 | MND-U-09, MND-BL-04/05 | Observable state/failure. |
| PL-003/004, UI-011, MX-002, RC-02 | MND-U-10, MND-MX-02 | Artifact ownership and replay safety. |
| PL-021, retrospective method | MND-U-11 | Classify knowledge before promoting it. |
| PL-015, RC-11, QC-016 | MND-U-12 | Change control after done. |
| PL-010/012, RC-05 | MND-U-13 | Stop on unresolved conflict/irreversible change. |
| UI-019, PL-016, BL-017 | MND-U-14 | Preserve conventions/load-bearing names. |

### 3.2 Domain model

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| UI-009, P-01, RC-04 | MND-DM-01 | Context before entities. |
| Section 5.4, DM clean checks | MND-DM-02 | Real generalization, not copy-paste. |
| DM-002, BL-012, RC-14 | MND-DM-03, MND-BL-03 | Derived write graph and transaction boundary. |
| DM-003/004 | MND-DM-04 | Derived enum predicates/precedence. |
| DM-005/006 | MND-DM-05 | Units and decision/display precision. |
| DM-007, BL-006 | MND-DM-06, MND-BL-08 | Required vs unique vs concurrency. |
| DM-017, P-08 | MND-DM-07 | Date-only normalization. |
| DM-008/009/010, QC-006 | MND-DM-08, MND-SEC-03/06 | Access is part of the domain; read* snapshot; append-only audit. |
| BL-004 | MND-DM-09 | Delete behavior explicit. |
| DM-001 | MND-DM-10, MND-PERF-01 | Indexes from access/sorts. |
| DM-013 | MND-DM-11 | Singleton invariant/defaults. |
| DM-012 | MND-DM-12 | Association role names. |
| DM-018 | MND-DM-13 | One UI language/stable audit text. |
| DM-019 | MND-DM-14 | No dead flags/deferred surfaces. |

### 3.3 UI and pages

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| UI-009, PL-007, RC-04 | MND-UI-01/02 | Page context tree; lexical `$currentObject`. |
| UI-010, P-02/03 | MND-UI-03 | Guarded association DataView. |
| UI-001, P-16 | MND-UI-04, MND-SEC-07 | `show page` reachability. |
| UI-012, PL-008 | MND-UI-05/15 | Design properties; class audit. |
| UI-002/003/018, P-10 | MND-UI-06 | Grid width policy. |
| UI-006, P-11 | MND-UI-07 | Three empty-state cases. |
| UI-004/005 | MND-UI-08 | Action placement/identity band. |
| UI-008 | MND-UI-09 | No affordance without action. |
| UI-014 | MND-UI-10 | Empty conditional sections. |
| UI-019, BL-017 | MND-UI-11 | Load-bearing names. |
| UI-015 | MND-UI-12 | Navigation/deep links. |
| UI-017, PL-007 | MND-UI-13 | Responsive verification. |
| UI-007/016, P-01 | MND-UI-14 | Filter/data-source placement. |
| PagePlan/UI-002/005 | MND-UI-16 | Page hierarchy before widgets. |

### 3.4 Logic

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| Section 7.7, BL-018 | MND-BL-01/09 | Microflow authority; callable SUB seam. |
| BL-004/014, PL-009 | MND-BL-02 | State machine/guards. |
| BL-012, RC-14 | MND-BL-03 | Transaction boundary. |
| BL-008, QC-011 | MND-BL-04/05 | Job audit/status consumption. |
| BL-008/010/012, QC-012 | MND-BL-06/15 | Scheduling semantics/manual parity. |
| BL-002 | MND-BL-07 | Natural-key seed idempotency. |
| BL-006, DM-007 | MND-BL-08 | Concurrency/one-open. |
| QC-005, BL-011 | MND-BL-10 | Server-side rights recheck. |
| BL-015 | MND-BL-11 | Validation feedback target. |
| BL-001 | MND-BL-12 | Startup/self-test contract. |
| BL-017 | MND-BL-13 | Do not swallow export result. |
| BL-021, QC-010 | MND-BL-14 | Demo/test generators out of production. |

### 3.5 Security

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| QC-001/002, RC-12 | MND-SEC-01 | Capability table, not role names. |
| QC-003/004 | MND-SEC-02 | Security quartet gate. |
| DM-008/009/010, QC-006/007 | MND-SEC-03/06 | Entity access policy; read* snapshot; append-only audit. |
| DM-001, QC-006/009, BL-011 | MND-SEC-04 | Row scoping in entity access. |
| QC-005, BL-011 | MND-SEC-05 | No client-trusted authorization. |
| QC-008, UI-001 | MND-SEC-07 | Page/action/entity triangle. |
| MX-016, QC-010 | MND-SEC-08 | Grant every document. |
| QC-015 | MND-SEC-09 | Marketplace edit risk. |
| QC-003/013 | MND-SEC-10 | Secrets/configuration. |
| P-07, UI-001, QC-005 | MND-SEC-11 | Negative security by absence/direct call. |
| QC-001, FINDINGS 64 | MND-SEC-12 | Settings menu as security surface. |

### 3.6 Validation and AI behaviour

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| PL-007, RC-03 | MND-V-01/03 | Done per axis; visual/structural validation. |
| PL-005, E-38 | MND-V-02 | Verification ladder. |
| Section 14.12, D-30 | MND-V-04 | Stored-data assertion. |
| PL-014, FINDINGS 26/70 | MND-V-05 | Test-data isolation. |
| BL-016 | MND-V-06/09 | Fixtures vs assertions; tests must fail. |
| BL-016, QC-017 | MND-V-07 | Risk-ranked coverage. |
| LEAD-04, FINDINGS 12/24/71 | MND-V-08 | Harness lifecycle/session cap. |
| P-07, UI-001, QC-005 | MND-V-10 | Negative security. |
| PL-005, E-34 | MND-V-11 | Evidence at the moment of change. |
| PL-015, PL-004 | MND-V-12 | Re-audit from current model. |
| Section 11 | MND-AI-01…12 | Behavioural failure patterns. |

### 3.7 Performance

| Finding(s) | Universal rule(s) | What was generalized |
|---|---|---|
| DM-001 | MND-PERF-01 | Indexes from access/sorts. |
| BL-007, QC-018 | MND-PERF-02 | Avoid N+1. |
| QC-019 | MND-PERF-03 | Bound retrieves. |
| QC-018, PL-014 | MND-PERF-04 | Query/response budget. |
| QC-018, Section 7.4 | MND-PERF-05 | Aggregation/view entity/task queue. |
| MX-021, QC-020 | MND-PERF-06 | Score ≠ measurement. |
| BL-012, QC-018 | MND-PERF-07 | Short transactions/resumable jobs. |
| BL-007, QC-018/019 | MND-PERF-08 | Page data-source N+1. |

---

## 4. Converted into conditional rules

These rules apply only when the condition is true. The condition is part of the rule.

| Condition | Findings | Rule(s) |
|---|---|---|
| Project uses **mxcli/MDL** | MX-001…024, BL-003, PL-003/004/016/019, QC-016 | MND-MX-01…20 |
| Mendix version lacks a feature (e.g. native Send Email before 11.13) | MX-012, D-05 | MND-N-06, MND-MX-10, `KNOWN_LIMITATIONS` |
| Installed widget/version has specific semantics (Data Grid 2 weights, chart markers, enum captions) | P-09/10/12 | MND-UI-06, MND-PLAT-09/10/12 |
| Marketplace module is installed/upgraded/edited | D-20/24, QC-015, P-19 | MND-N-07, MND-SEC-09, MND-MX-17 |
| Deployment is Production-level | QC-003/004, BL-021 | MND-SEC-02/10, MND-BL-14 |
| Runtime is a trial/licence-limited environment | P-18, LEAD-04 | MND-V-08, MND-PLAT-18 |
| Target database differs from local (HSQLDB vs PostgreSQL) | QC-018/019, MND-UQ-06/07 | MND-PERF-04/06, `KNOWN_LIMITATIONS` |
| Project is mobile/responsive | UI-017, P-10 | MND-UI-13, MND-UI-06 |
| Project uses a specific widget with no per-column hide | P-10 | MND-UI-06 |
| A page uses an irreducible microflow | MX-005, BL-003 | MND-MX-06 |
| Page expression position is `ContentParams`/client-side | MX-001 | MND-MX-11 |
| Test runner is `--attach` | MX-015 | MND-MX-12 |

**Rule:** do not apply a conditional rule when its condition is false. Do not cite a toolchain
limitation as a Mendix limitation. Do not cite an environment limit as an application defect.

---

## 5. Retained as project-specific knowledge (not rules)

These are examples, not mandatory Mendix behavior. They are useful for illustrating a rule, but
copying them as architecture is a mistake.

| Item | Why project-specific | Where retained |
|---|---|---|
| OSA module names, entity names (`WorkItem`, `ResultTag`, `OpenCard`, `MixtureComponent`), page names | One domain's vocabulary | Examples in `DOMAIN_MODEL.md`, `UI_AND_STYLING.md` |
| Single-module OSA architecture | A project decision; not a universal topology | `TRACEABILITY.md`; not a rule |
| `WorkItem` generalization | A good pattern for this domain; not every domain needs it | `DOMAIN_MODEL.md` §2.2 as an example |
| Atlas_Core layout / `Atlas_Default` | Project theme choice | `KNOWN_LIMITATIONS.md`/examples; not a rule |
| Mendix 11.12.5, Mendix 11.13 Send Email | Version-specific | `KNOWN_LIMITATIONS.md`, `MXCLI_MDL.md` |
| DataWidgets 3.11.8 / Atlas 4.6.0 / other module versions | Project dependency versions | `KNOWN_LIMITATIONS.md`; example only |
| HSQLDB local / PostgreSQL target | Environment | `KNOWN_LIMITATIONS.md`; verify |
| Trial session cap ~5 | Licence/environment | `KNOWN_LIMITATIONS.md`; verify |
| Exact 155-FR matrix / Jira keys | Project traceability | `VALIDATION_AND_TESTING.md` as an example |
| PagePlan claims / UI-019 | Project documentation defect | `UI_AND_STYLING.md` as an example |
| Signal theme tokens / `custom-variables.scss` remainder (QC-014) | Project theme drift | Example; the rule is "name the file, not the theme" (MND-U-11/MND-UI-05) |
| Exact `OpenCard_Overview` weight sum (UI-018) | Project page measurement | Example; the rule is MND-UI-06 |
| Exact counts (34 entities, 52 pages, 252 flows) | Project inventory | Retrospective only; not rules |

**Why this matters:** the retrospective's own warning is that OSA-specific architecture,
module names, versions, and implementation decisions must not become universal Mendix rules.
The universal lesson is the *method* (context, ownership, evidence), not the OSA model.

---

## 6. Kept as unresolved questions

These are preserved in `KNOWN_LIMITATIONS.md` §5 and are not rules.

| ID | Question | Why unresolved |
|---|---|---|
| MND-UQ-01 | Is `mxcli exec` transactional on mid-script failure? | Conflicting help texts; not reproduced. |
| MND-UQ-02 | Do CE0117 probes actually fail mxbuild? | Check side verified; build side from findings. |
| MND-UQ-03 | Did `drop module` leave `MxTest`, or did a test recreate it? | Model/script disagreement; cause suspected. |
| MND-UQ-04 | Authentication of Email Connector OAuth callback? | Not exposed by the CLI. |
| MND-UQ-05 | Is the published REST service anonymously reachable? | Deployment not tested. |
| MND-UQ-06 | PostgreSQL behaviour vs HSQLDB? | No production data set. |
| MND-UQ-07 | Real performance at 2k tags / 300 analyzers? | Model-based estimate only. |
| MND-UQ-08 | Which Marketplace modules block an upgrade? | No PAT/metadata. |
| MND-UQ-09 | Does the Signal palette block affect rendering? | Not compared in a browser. |
| MND-UQ-10 | Is `WorkDate` overdue comparison wrong for date-only? | Structural fact, runtime not tested. |
| MND-UQ-11 | Does test scaffolding expose an endpoint? | Not deployed/probed. |
| MND-UQ-12 | Duplicate business keys in demo data? | Not queried. |
| MND-UQ-13 | Does the association-filter defect exist elsewhere? | One instance strongly supported. |
| MND-UQ-14 | Can dead-end buttons be fixed by grants without widening data? | Security mapping not done. |
| MND-UQ-15 | Real cost of 90-file check in CI? | Machine-specific. |
| MND-UQ-16 | Are duplicate flow declarations behaviourally identical? | Diffed today; future edits may diverge. |
| MND-UQ-17 | Does every "Built" FR have an observation? | Not re-audited per row. |
| MND-UQ-18 | Is the Marketplace page edit preserved on upgrade? | Not upgrade-tested. |
| MND-UQ-19 | Are demo user template passwords still default? | Unknown. |
| MND-UQ-20 | Does validation feedback on absent field block the action? | Suspected. |
| MND-UQ-21 | Does vendorlib SLF4J binding hijack logging? | Suspected, not tested. |

---

## 7. Findings that could not be reliably converted

These are not rules, or only partially converted, because the evidence is incomplete or the
lesson is inseparable from the project. They are retained with their uncertainty.

| Finding(s) | Why not fully converted | What remains |
|---|---|---|
| DM-003 | Two status definitions verified, but the business-intended precedence is a product decision, not a platform fact. | Rule MND-DM-04 says "specify precedence", not which precedence. |
| DM-004 | `Expired` winning is verified code; user-visible impact is suspected. | Rule MND-DM-04 requires a both-true test; the specific OSA precedence is an example. |
| DM-005 | Missing unit is verified structure; whether any real mixture crosses units is unknown. | Rule MND-DM-05 is universal; the OSA omission is an example. |
| DM-017 | Non-normalized DateTimes are verified; the `equal` filter failure is suspected/platform-dependent. | Rule MND-DM-07 says normalize; the exact filter behavior must be probed. |
| BL-015 | Flow-side feedback target verified; page binding not inspected; `SUSPECTED`. | Rule MND-BL-11 is conditional "verify the field is on the page". |
| BL-020 | Mixed date basis verified; aggregate-null behavior is version-dependent/suspected. | Rule MND-DM-07/MND-BL-02; the exact empty-deviation behavior needs a test. |
| MX-004 | Conflicting docs verified; actual transactionality unknown. | Rule MND-MX-14 says treat as unknown and diff; does not assert rollback. |
| MX-006 | A strength, not a defect; used as a rule for page round-tripping. | Rule MND-MX-07; not a universal claim about all tools. |
| MX-013/014 | Strongly supported write-side semantics, not re-verified read-only. | Rules MND-MX-04/05 with "verify in your build" caveat. |
| UI-007 | Structural identity with a known defect; not observed on `Config_Teams`. | Rule MND-UI-14; mark `SUSPECTED` until rendered. |
| UI-010 | Strongly supported from `DESCRIBE`; not rendered. | Rule MND-UI-03 with a runtime check. |
| QC-005 | Read from flows; not exercised at runtime. | Rule MND-SEC-05/BL-10; negative test required. |
| QC-018 | Model-based N+1 estimate; not measured at production volume. | Rule MND-PERF-02/04; measure before quoting a number. |
| QC-019 | Code verified; volume impact suspected. | Rule MND-PERF-03; bound + measure. |
| PL-019 | Commit graph verified; whether the repo existed when Part 2 was drafted is unknown. | Rule MND-U-12/V-12; no claim about intent. |
| PL-021 | Log gaps/ID collision verified; no general rule for log schema beyond discipline. | Rule MND-U-11; a project-specific log schema is not universal. |
| QC-014 | Signal tokens in `custom-variables.scss` verified; actual rendering not compared. | Example; rule "name the file, not the theme" (MND-U-11). |
| UI-018 | Exact weight sum is project-specific; the general grid rule is universal. | Rule MND-UI-06; the 1,560 example is not a rule. |
| UI-019 | A documentation claim mismatch; the general rule is evidence-based claims. | Rule MND-V-11/UI-11; the specific column is not a rule. |
| BL-005 | Specific `StartUpDate` default is a project requirement interpretation. | Rule MND-DM-07/BL-02; the "late-created child" decision needs product input. |
| DM-018 | One Dutch caption is project content; the rule is one-language consistency. | Rule MND-DM-13; language choice is project-specific. |
| Platform P-18 | Trial session cap is licence/environment-specific. | `MND-PLAT-18` is conditional/environment; not a universal Mendix rule. |
| Platform P-19 | Marketplace version coupling is a general risk, but exact versions are project-specific. | `MND-PLAT-19`/MND-N-07; verify versions. |
| All `MND-UQ-*` | Evidence incomplete. | Preserved as questions; no rule. |

---

## 8. Conversion quality notes

- **No finding was silently dropped.** Every ID is indexed; unconverted/uncertain items are
  listed above.
- **No `SUSPECTED` observation became a mandatory rule.** Where a rule depends on it, the rule
  says "verify" and the finding is marked partially converted.
- **No tool defect was mislabeled as a Mendix platform limitation.** Toolchain rules are
  isolated under `MND-MX-*` and `KNOWN_LIMITATIONS.md` §2.
- **No project-specific architecture was universalized.** OSA examples are labelled; the
  reusable pattern is the method, not the module names.
- **The exact severity/priority can differ between the consolidated report and an area report.**
  The index records the consolidated value and notes the difference where material (e.g.
  DM-003).
- **Rules are not a substitute for evidence.** A rule tells you what to check; it does not
  prove the current project behaves that way.

---

## 9. Maintenance

When a new project produces a candidate finding:

1. Add it to that project's FINDINGS log with evidence and confidence.
2. Classify it: universal / conditional / toolchain / project-specific / unresolved.
3. If it changes a universal rule, require independent evidence and review.
4. Add a new rule ID; do not renumber or delete existing IDs.
5. Update `FINDING_INDEX.md` and this traceability report.
6. Re-run `SCENARIO_TESTS.md`.
7. If a rule is superseded, keep the old text with a dated "superseded by" note.

The skill is a living asset, but it must not drift into a collection of one-project opinions.
