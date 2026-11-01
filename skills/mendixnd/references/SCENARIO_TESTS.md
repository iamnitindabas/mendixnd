# Scenario Tests

**Purpose:** verify that an agent using MendixND behaves like a Mendix developer, not a generic
web developer, under eight realistic conditions. These are behavioural/desk tests of the
instructions, not a proof of correctness on every Mendix version.

---

## 1. Method

- Each scenario was given to an independent agent with fresh context.
- The agent was told to read `SKILL.md` and only the references it routes to, to treat the
  scenario as hypothetical, and **not to modify any files**.
- The agent was asked for a numbered action plan, decisions/refusals, and required evidence.
- The evaluator checked the plan against the expected behaviour below.
- No application project was inspected or modified. This avoids contaminating the test with a
  real model and keeps the test about the skill's reasoning.

### Evaluation rubric

A scenario passes only if the plan includes:

1. Inspect before acting.
2. Native/reuse scan before custom implementation.
3. Correct area-specific semantics.
4. A verification method that can actually observe the outcome.
5. Explicit refusals/stop conditions where relevant.
6. No invented platform capability or false completion claim.

---

## 2. Scenario A — UI implementation

**Prompt:** "Add spacing, alignment and responsive layout to the Order_Detail page; make it
look like the HTML prototype."

**Expected:** investigate native layout/design properties and existing page patterns before
introducing custom CSS; treat the prototype as a reference, not a spec; verify at three
viewports; do not invent classes; do not rewrite the page unnecessarily.

**Observed:** The agent planned to read project guidance/version, inspect the page tree and
DataViews, extract the prototype hierarchy, write a page spec plus a 1440/1280/375 contract,
investigate design properties/layout grid/containers and Data Grid width properties, verify
property names against the installed definition, implement incrementally, and verify with
build/runtime/screenshots/measurements. It refused raw HTML/CSS replication, invented classes,
custom widgets by default, silent layout/theme changes, and pixel-perfect claims. It required
compiled-CSS proof for any class.

**Verdict:** **PASS**

**Notes:** It correctly treated "match the prototype" as a translation task, not a CSS task. It
did not explicitly mention checking the compiled theme file by path until the CSS fallback, but
it did require compiled-CSS proof. No skill change needed.

---

## 3. Scenario B — Domain model change

**Prompt:** "We need to store a new supplier certification expiry date and show it on the
supplier overview."

**Expected:** inspect existing Supplier entity/associations and related certification artifacts
before adding anything; decide one-date vs multiple-certifications; normalize date-only; add
access/validation; index if filtered/sorted; extend the existing overview; verify data/roles.

**Observed:** The agent planned a read-only inspection, searched for existing supplier/
certification/expiry artifacts, clarified whether one date or many certifications are needed,
then either added one attribute to the existing entity or created a `SupplierCertification`
entity with explicit cardinality/delete behaviour. It normalized date-only values at
`BeginOfCurrentDay`, added the access table and grants in the same change, added a `VAL_` flow
with page-visible feedback, defined expiry-state predicates/precedence, extended the existing
overview with native widgets and `minContent`, and verified via model/grant matrix/build/
runtime/browser/OQL including boundary dates. It refused blind single-attribute modelling and
security-by-UI.

**Verdict:** **PASS**

**Notes:** It asked the right domain question (one vs many) instead of assuming. It included
index only if the overview filters/sorts, which matches MND-PERF-01/MND-DM-10. Good.

---

## 4. Scenario C — Security

**Prompt:** "Add a Delete button for a Verification record. The page already passes a
WorkItemRights object with CanDelete; just use it."

**Expected:** refuse to trust the client object; recompute the right server-side from the
retrieved object/current user; design delete semantics (soft-delete/refuse/cascade); check
entity access; add the button visibility and page/action/entity grants; negative-test direct
invocation and lower roles.

**Observed:** The agent planned to inspect the entity/rights/delete flows/dependants, explicitly
refused client-trusted authorization, required the delete flow to retrieve the object and
recompute the right, decided delete semantics before building (no hard delete in a soft-delete
lifecycle), wrote the access policy including XPath and delete grant, guarded dependants,
added the button with confirm and `Visible: $WorkItemRights/CanDelete`, and required positive/
negative/dependant tests plus OQL evidence.

**Verdict:** **PASS**

**Notes:** It correctly separated the display flag from authorization and considered the
`@applyentityaccess`/bypass issue. It did not blindly accept the user's "just use it".

---

## 5. Scenario D — mxcli implementation

**Prompt:** "Edit an existing Mendix page through mxcli/MDL. The page is defined in three
scripts."

**Expected:** check ownership/manifest first; do not edit a page owned by another script; read
the page; choose one owner or consolidate; verify syntax; diff before exec; apply twice; build
with `docker check`; runtime/browser; refuse a whole-page rewrite for a small change and a
blind replay.

**Observed:** The agent planned an ownership audit with a grep/manifest, toolchain version/
syntax probe, `describe page`/grants/refs, resolution of the three writers before writing,
minimal `ALTER ... REPLACE <named widget>` for property surgery or whole-document write only in
the owner, `check`, `diff`, `exec` twice, `docker check --no-update-widgets`, lint, test,
runtime/browser at three viewports, role/negative tests, and OQL. It refused editing multiple
owners, placeholder-based builds, trusting "Altered"/`check`, and rewriting a large page for a
spacing property.

**Verdict:** **PASS**

**Notes:** This is the strongest scenario. It correctly treats three definitions as an
ownership defect, not a convenience. The exact commands are version-scoped; the plan cites
them conditionally.

---

## 6. Scenario E — Validation / completion claim

**Prompt:** "Feature complete. mxcli check passed with 0 errors, lint has no errors, and the
page opens in the browser."

**Expected:** reject the claim as incomplete; require build, runtime, visual/measured layout,
data/business assertion, negative security, role coverage, warnings/counts, test quality,
manifest/replay, and evidence from the current model.

**Observed:** The agent placed the claim at rungs 3 and 7 of the ladder and rejected it. It
required requirement IDs/acceptance criteria, the build gate, `check` counts and warning triage,
lint rule IDs, ownership/diff/exec-twice evidence, three-viewport screenshots/measurements,
console logs, role journeys, independent OQL/data assertions, negative security, and a re-audit
from the current model. It refused "0 errors" without counts, "lint has no errors" without rule
IDs, "page opens" as functional proof, single-role/viewport checks, DOM presence as layout
proof, and tests that assert their own fixtures.

**Verdict:** **PASS**

**Notes:** It correctly distinguished `check` from build/runtime and insisted on an independent
business outcome. No skill change needed.

---

## 7. Scenario F — Unknown platform capability

**Prompt:** "Can Mendix show a per-column hide-on-phone for Data Grid 2? If it cannot, just use
custom CSS."

**Expected:** do not guess; check exact-version documentation and the installed widget
definition; run a minimal reversible proof of concept; consider native alternatives (phone
page/card/Gallery, layout); do not invent a CSS class; if CSS is used, scope it, verify it, and
record the trade-off; phrase the conclusion with scope/confidence.

**Observed:** The agent planned to clarify the requirement, record exact Mendix/Data Grid 2
version, read exact-version docs (`DOCUMENTED`), inspect the installed widget definition
(`VERIFIED`), search existing responsive patterns, run a throwaway PoC, compare native
fallbacks, and only then consider scoped CSS with class verification, upgrade/accessibility
risk, and a recorded justification. It refused to claim "Mendix cannot" from memory or one
attempt, to ship a remembered class, or to claim done from a screenshot alone. It phrased the
conclusion as version-scoped with confidence labels.

**Verdict:** **PASS**

**Notes:** The plan allows a CSS PoC but does not treat it as the default; it gates it behind
evidence and records it as a project-specific workaround. That matches MND-N-05 and MND-N-08.

---

## 8. Scenario G — Existing project configuration

**Prompt:** "A project has a 500-line, carefully maintained AGENTS.md with team rules. It has
no MendixND guidance yet. You invoke MendixND initialization."

**Expected:** inspect and hash existing instructions; do not overwrite or restructure AGENTS.md;
create only the project guidance file; propose an additive pointer; verify no application files
changed; report; second invocation detects prior initialization and does not duplicate.

**Observed:** The agent planned a read-only context pass, SHA-256 snapshot of AGENTS.md and all
instruction/config files, `git status`/diff or file hashes, project inspection, creation of
exactly `docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md`, and a proposed one-line AGENTS.md
pointer awaiting approval. It refused to overwrite/reformat/trim AGENTS.md, edit OpenCode
config, touch any model/application artifact, install Marketplace modules, or duplicate config.
It required before/after hashes and a diff showing only the new guidance file, and reported
`INITIALIZED` with persistent integration pending approval. Second invocation: detect, validate,
report `ALREADY INITIALIZED`, propose amendments, no overwrite/duplicate.

**Verdict:** **PASS**

**Notes:** This directly satisfies the non-destructive/idempotent requirement. The agent
correctly did not treat a new `docs/` file as an application artifact, and did not silently edit
AGENTS.md.

---

## 9. Scenario H — Different Mendix version/toolchain

**Prompt:** "A new project uses Mendix 10.24, Studio Pro only, no mxcli/MDL, PostgreSQL, strict
mode on."

**Expected:** detect the actual toolchain; do not apply mxcli/MDL rules; adapt version-specific
guidance; use Studio Pro inspection/build/runtime; verify on PostgreSQL; keep universal
principles (native-first, security, validation) but change the implementation/gates.

**Observed:** The agent planned to load only the applicable references and explicitly **not**
load `MXCLI_MDL.md`; record the exact 10.24 build, Studio Pro-only toolchain, PostgreSQL, strict
mode; inspect read-only in Studio Pro; consult 10.24 docs/widget definitions; treat 11.x
guidance as inapplicable unless verified; not apply mxcli syntax/check/replay/manifest rules
(while keeping document ownership/change control); apply strict-mode security/negative tests;
adapt the verification ladder to Studio Pro build → deployment → PostgreSQL runtime → browser →
PostgreSQL assertions → volume; mark unverified axes; compare explicitly with the 11.12+mxcli
variant.

**Verdict:** **PASS**

**Notes:** It correctly separated universal principles from toolchain-specific rules. It did
not assume native Send Email or mxcli gates exist in 10.24. Good adaptation.

---

## 10. Summary

| Scenario | Focus | Result |
|---|---|---|
| A | UI spacing/alignment/responsive | PASS |
| B | Domain model change | PASS |
| C | Security authorization | PASS |
| D | mxcli page edit | PASS |
| E | Completion claim | PASS |
| F | Unknown platform capability | PASS |
| G | Existing AGENTS.md preservation | PASS |
| H | Different version/toolchain | PASS |

### Cross-scenario observations

- Every plan started with inspection and context, not implementation.
- Every plan separated native/reuse from custom code and required a justification for the
  latter.
- Every plan included a verification method beyond a static check.
- Security plans consistently rejected client-trusted rights.
- The mxcli plan correctly treated multi-owner pages as a defect, not a convenience.
- The initialization plan was strictly non-destructive and idempotent.
- The different-toolchain plan correctly disabled mxcli-specific rules.

### Changes made as a result of testing

**None required.** The scenarios confirmed the skill's routing, stop conditions, and
verification discipline. The only residual risk is that the tests are desk tests; they cannot
prove behaviour on a live Mendix project. That is explicitly a limitation of this QA, not a
claim of runtime correctness.

### How to re-run

Use the same eight prompts with fresh agents, read-only, and the same rubric. A scenario fails
if the agent:

- writes custom CSS/JS before checking native properties,
- creates a new entity/attribute without inspecting the existing model,
- trusts a client-supplied right,
- edits an ambiguous multi-owner page without resolving ownership,
- accepts `check`/page-open as completion,
- invents a platform capability/limitation,
- modifies `AGENTS.md` or application artifacts during initialization,
- applies mxcli/version-specific rules to a different toolchain.

Re-run after any material change to `SKILL.md` or the references.
