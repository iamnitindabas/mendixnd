# Validation and Testing

**Purpose:** define "done" in a way that cannot be satisfied by a broken UI, a false-positive
test, or a static checker. The retrospective's core verification failure was a green gate set
over a visibly broken application.

---

## 1. Definition of done per axis

A change is not done because a command exited 0. Define acceptance per axis:

| Axis | What to prove | Example evidence |
|---|---|---|
| Model | The intended documents/attributes/associations exist with the intended properties | `describe`, model diff, build |
| Access | The intended roles can read/write; others cannot | Role matrix, negative test |
| Build | The stored model compiles with the target builder | mxbuild/Studio Pro/build log |
| Runtime | The app starts and the page/widget loads without errors | runtime log, browser console |
| Behaviour | The business transition produces the intended result | microflow test, journey |
| Data | The stored result is correct, not just displayed | OQL/database assertion |
| UI/UX | Layout, spacing, labels, columns, empty states are usable | screenshot + measured layout |
| Security | Direct invocation/negative role is refused | forged request test |
| Performance | Query/response within budget at representative volume | query count/timing |
| Documentation | Handoff/manifest/README match the model | generated diff/check |

If an axis cannot be observed, mark it **unverified** and say why. Do not replace it with a
different axis that happens to be green.

---

## 2. The verification ladder

For each requirement, climb as far as the acceptance needs:

```text
1. Model present
2. Access granted
3. Static check / lint
4. Build (mxbuild / Studio Pro)
5. Unit/integration test (microflow)
6. Runtime start
7. Browser/UI render
8. Business outcome observed
9. Data assertion (OQL/database)
10. Negative role / direct-call security
11. Performance/volume (where relevant)
```

A requirement is "built" only at the level the plan names. "Model present" is not "access
granted"; "check passed" is not "build passed"; "build passed" is not "runtime works"; "page
opens" is not "the user can complete the task".

---

## 3. Gate matrix

Use the gates the project actually has. A typical Mendix gate set:

| Gate | Proves | Common false positive |
|---|---|---|
| Model inspection | shape, names, grants | document exists but is not bound |
| Static check (`check`/IDE) | syntax/references/types (partial) | page expressions, widget loadability |
| Build (mxbuild/Studio Pro) | compiles | runtime/visual correctness |
| Lint/report | rule findings | policy score mistaken for quality |
| Microflow tests | rule behaviour | tests that assert fixtures/self-test counters |
| Runtime start | app boots | page render/data correctness |
| Browser journey | path works for one role/data | other roles, layout, data |
| OQL/data assertion | stored result | UI display only |
| Screenshot/measured layout | visual/structural acceptance | DOM presence |
| Negative security test | authorization boundary | HTTP status in an SPA |
| Performance measurement | query/time at volume | demo-volume timing |

**A gate that cannot fail is not a gate.** If a test asserts a value it just set, or a self-test
counter, it proves nothing.

---

## 4. Visual and structural validation

DOM presence and row counts pass on a one-column grid. Validate:

- computed `grid-template-columns` / column count,
- bounding boxes / label-value separation,
- no horizontal overflow at 1440/1280/375,
- tab visibility and nesting,
- action placement and visibility per role,
- empty states (no data, filtered, no permission),
- screenshots at the three viewports,
- console errors after login (expected pre-login 401 excluded).

A screenshot is evidence only if someone reads it. Attach it to the task record and compare
against the acceptance criteria, not just "the page opened".

---

## 5. Business outcome and data assertions

A browser journey proves the path; it does not prove the stored result. Add an independent
data assertion where the business outcome matters:

```sql
SELECT COUNT(*) AS n
FROM Module.Verification v
JOIN Module.ResultTag r ON v/Module.WorkItem_ResultTag = r/id
WHERE r.Tag = 'RUN-<unique>' AND v/Status = 'Cancelled'
```

Use OQL/database assertions for:

- status transitions,
- calculated/derived values,
- audit rows,
- duplicate/uniqueness checks,
- counts that the UI may hide,
- cleanup/isolation.

A data assertion must be independent of the UI and of the fixture that created the data.

---

## 6. Test-data isolation

Assume the database is reused. Never assume it is empty.

- Give each run a unique key (run id, timestamp, random suffix) and use it in natural keys.
- Filter assertions by that key; prefer relative assertions where absolute counts are unstable.
- Clean up or isolate fixtures; do not commit permanent `TST-*` rows into a shared database.
- Do not let a test create a fake integration account that later affects real behavior.
- For a full suite, consider a fresh database or a documented reset procedure.
- Record the isolation strategy in the test plan.

---

## 7. Fixtures vs assertions

A **fixture** sets up state. An **assertion** observes an independent outcome.

Bad:

```text
set isOutgoingEmailConfigured = true
assert isOutgoingEmailConfigured = true
```

This cannot fail. It is a fixture, not a test.

Good:

```text
create a mail account with a deliberate failure/no account
call the send path
assert MailLog.Status = Failed and the job records failure
```

Separate fixture files from test assertions. A test that needs a real page/role should say so.

---

## 8. Meaningful tests for critical flows

Name the riskiest behaviours and require a test each. In a typical Mendix app:

- authorization/rights (positive and negative per role),
- state transitions and guards,
- scheduling/idempotency/catch-up,
- mail/integration success/failure/partial,
- calculation/precision boundaries,
- concurrency/one-open-record,
- import/export contents (not just download exists),
- empty/filtered/no-permission UI states.

Mutation checks are strong evidence: change a rule intentionally and confirm the intended test
fails. If no test fails, the suite is not covering the rule.

---

## 9. Browser/harness lifecycle

Treat the harness as production code:

- A real logout or app restart between sessions; a 404 logout leaves sessions open.
- Know the session/licence cap; a login failure after N runs may be a session cap, not a bad
  password.
- Clear console buffers after login; the pre-login 401 is expected.
- Handle widget interaction quirks (focus before typing in a combo box, blur before Apply,
  sticky cells intercepting clicks, modal dialogs).
- Reopen a page after a microflow-data-source action; the list may not refresh in place.
- Assert absent content for a forbidden route, not HTTP 403 (an SPA may return 200).
- Use unique data and relative assertions.
- Capture screenshots and console logs on failure.

---

## 10. Evidence and completion claims

For each completed item, record:

```text
Requirement ID:
Change:
Gates run (command, version, result counts):
Evidence (path/screenshot/OQL result/log line):
Roles/data/viewports covered:
Unverified/residual risk:
Deviations/decisions:
```

Rules:

- Quote counts, not "passed".
- A handoff/status number must be generated from the current model, not copied.
- A completion claim needs the same evidence standard as a finding.
- If a requirement is partial, say partial; do not mark "Built" from a task link.
- A test that cannot fail is a defect in the test suite.

---

## 11. Independent audit

The author of a page/flow is not the only certifier. An independent pass should:

- re-run the gates from the current model,
- inspect the rendered UI at the target viewports,
- test a lower role and a direct action call,
- compare the acceptance matrix to observations,
- look for stale documentation and missing rebuild artifacts.

The audit may be a different agent, a different session, or a human. The point is independence,
not ceremony.

---

## 12. Rules

### MND-V-01 — Define done per axis

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** PL-007, RC-03
- **Applies when:** any task/phase close-out.
- **Instruction:** Use §1; state which axes apply and which are unverified.
- **Verify:** The completion report has evidence per axis.

### MND-V-02 — Climb the verification ladder to the named level

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** PL-005, E-38
- **Applies when:** claiming a requirement built.
- **Instruction:** Use §2. "Model present" is not "access granted"; "check" is not "build";
  "build" is not "runtime"; "page opens" is not "business outcome".
- **Verify:** The evidence level matches the claim.

### MND-V-03 — Validate visual/structural behaviour, not DOM presence

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** PL-007, UI-002/003/017
- **Applies when:** any page is declared done.
- **Instruction:** Use §4: computed layout, overflow, label/value separation, 3 viewports,
  screenshots.
- **Verify:** Measurements/screenshots in the evidence.

### MND-V-04 — Assert the stored business outcome

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Section 14.12, D-30
- **Applies when:** a journey changes data.
- **Instruction:** Add an OQL/database assertion independent of the UI.
- **Verify:** The assertion can fail if the data is wrong.

### MND-V-05 — Isolate test data

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** PL-014, FINDINGS 26/70
- **Applies when:** any browser/microflow test uses shared data.
- **Instruction:** Unique run key, filter assertions, cleanup, relative counts.
- **Verify:** Two consecutive runs pass without cross-contamination.

### MND-V-06 — Separate fixtures from assertions

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-016
- **Applies when:** writing a test.
- **Instruction:** A fixture sets state; an assertion observes an independent outcome. A test
  that asserts what it set is not a test.
- **Verify:** The assertion can fail when the behaviour is broken.

### MND-V-07 — Cover the riskiest flows, not the newest

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-016, QC-017
- **Applies when:** planning tests.
- **Instruction:** Rights, state transitions, scheduling, integrations, calculations,
  concurrency, exports, negative security.
- **Verify:** A risk-ranked test plan; a mutation check on a critical rule.

### MND-V-08 — Make the harness lifecycle explicit

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** LEAD-04, FINDINGS 12/24/71
- **Applies when:** browser tests share a runtime.
- **Instruction:** Real logout/restart, session cap awareness, console buffer after login,
  unique data, screenshots on failure.
- **Verify:** A clean suite run without session-cap artifacts.

### MND-V-09 — Treat a test that cannot fail as a defect

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-016, RC-15
- **Applies when:** reviewing a test.
- **Instruction:** Ask: what would make this fail? If nothing, replace it or label it a fixture.
- **Verify:** Mutation check or a deliberate break makes the test fail.

### MND-V-10 — Verify negative security by absence/direct call

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** P-07, UI-001, QC-005
- **Applies when:** testing a role boundary.
- **Instruction:** Assert absent menu/content/action; call the action directly; do not rely on
  HTTP 403 in an SPA.
- **Verify:** Negative evidence per role.

### MND-V-11 — Record evidence at the moment of the change

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** PL-005, E-34
- **Applies when:** completing any slice.
- **Instruction:** Command, result counts, log line, screenshot, OQL result, data set size.
- **Verify:** Evidence is reproducible and tied to the current model.

### MND-V-12 — Re-audit from the current model, not the handoff

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** PL-015, PL-004
- **Applies when:** closing a phase or accepting a handoff.
- **Instruction:** Re-derive the top facts from the model; do not trust an older checkpoint's
  evidence. Independent audit for high-risk work.
- **Verify:** The audit's evidence is generated after the last write.
