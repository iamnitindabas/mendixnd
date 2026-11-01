# Microflows and Nanoflows

**Purpose:** design server-side behavior that is correct under failure, concurrency, and
volume; keep business rules reusable and testable; and choose microflow vs nanoflow for the
right reasons.

---

## 1. Microflow or nanoflow?

- **Microflow** — server-side. Use for business rules, data changes, security checks,
  integrations, scheduled work, validation, and anything that must be trusted.
- **Nanoflow** — client-side. Use for UI-only logic, offline actions (where supported), and
  client interactions that do not require server authority.
- **Never put authoritative business logic or authorization in a nanoflow.** The client can
  be bypassed.
- A nanoflow that calls a microflow is fine; the microflow remains the authority.
- A microflow that ends in `close page`/`show message` is a UI action, not a reusable service.
  Extract the business rule into a `SUB_` flow so it can be scheduled/tested.

---

## 2. A workable flow architecture

Use the project's conventions if they exist. A common, reusable shape is:

| Prefix | Role |
|---|---|
| `ACT_` | UI action adapter: check rights, call a `SUB_`, show message/close page. Thin. |
| `SUB_` | Reusable business logic; no UI-only activities; callable from ACT, scheduler, tests. |
| `VAL_` | Validation: returns Boolean, attaches `validation feedback` to the offending field. |
| `DS_` | Data source: returns an object/list for a page; no side effects. |
| `OCH_` | Object change/event handler (if the project uses them): react to a change. |
| `SE_` | Scheduled event entry: creates/closes the job audit, calls a `SUB_`, handles errors. |
| `ASU_` | After-startup: seed, configure, self-check; return a meaningful result. |
| `TST_` | Test/diagnostic only; never grants to end users. |

Do not follow prefixes blindly; follow the project's actual conventions. The principle is
**separation of UI adaptation, reusable business logic, validation, data access, and
scheduling**.

---

## 3. State machines, not verb lists

For each work item or business record, write:

```text
States:            Draft / Open / InProgress / Completed / Cancelled / Deleted
Transitions:       event, from, to, actor, guard
Stamps:            who/when, reference, completion date, cancel reason
Audit:             what is recorded, where, immutable?
Failure:           what happens if a step fails; retry/compensation
Concurrency:       what the second caller gets
```

A list of `ACT_*` names is not a state model. The retrospective's biggest logic defects were
semantic: a hard delete in a soft-delete app, a cancel button whose rights flag could never be
true, a status derivation that disagreed with selection, a job that reported success while mail
failed.

---

## 4. Transaction boundaries

Decide before implementing:

- What commits together as one business unit?
- Which steps are idempotent?
- Which may partially succeed?
- What does the user see on failure?
- What repair path exists for a partially applied unit?

Prefer **compute in memory → one commit**. Avoid commit-then-refresh unless a retrieve
genuinely needs to see the committed object; in that case, document why and add a staleness
marker/repair job if a later step can fail.

Do not scatter 2–4 commits across one business action without a reason. A record saved with
stale derived counters is worse than a failed transaction, because it looks successful.

### Created-without-commit

Creating an object without committing and rolling it back on cancel is a valid Mendix idiom
for a form. Use it deliberately; do not rely on an uncommitted object being visible to an
XPath retrieve in another context.

---

## 5. Derived values

For every derived attribute, follow `DOMAIN_MODEL.md` §3. In flow terms:

- `Compute*` — change the object without committing.
- `Refresh*` — commit and cascade to parents.
- `RefreshAll*` — bulk repair, bounded and resumable.
- Call the refresh from every write path that invalidates the value: create, edit, delete,
  cancel, complete, bulk import, scheduled repair.
- A batch refresh should not be an unbounded loop of per-row retrieves; see
  `PERFORMANCE.md`.

---

## 6. Error handling and observability

### 6.1 Job audit

For scheduled/background work:

- Create the audit row in the **entry** flow, in the same scope as the error handler.
- Close it on success **and** failure with a status, outcome, timestamp, and error message.
- A handler that cannot see the job object cannot close it. Pass it in or create it in the
  entry flow.
- Do not rely on "the flow finished" as success. Record the actual business outcome.

### 6.2 Returned status objects

If a helper returns a status object (mail log, import result, validation result), the caller
must read it. A variable assigned and never used is a smell. The job/mail/import status must
propagate to the operator surface.

### 6.3 Partial success

Define what "partial success" means and how it is recorded. Do not report a single boolean
when the operation has multiple independent outcomes.

### 6.4 Logging

Log at the level an operator can act on. A failure that only exists in a detail grid nobody
polls is invisible. A log line should include the job/record identifier and the error, without
secrets.

---

## 7. Scheduling

A scheduled event is not a specification by itself. Define:

- time zone (explicit, not "server" unless intended),
- frequency and repeat fields for the actual event kind,
- overlap policy,
- catch-up policy for missed periods,
- idempotency: one run per period/type,
- failure handling and alerting,
- missed-run detection,
- manual "run now" parity with the scheduled path,
- audit row and operator visibility.

Manual run-now actions should call the same entry flow as the scheduler, not a bare `SUB_`,
so they inherit error handling, idempotency, and audit behavior. If they intentionally differ,
record why.

---

## 8. Idempotency and concurrency

### 8.1 Seeds

A seed must be idempotent by the same key the factory uses. "Is the table non-empty" is a
table-level guard for a set of rows; one stray row can disable the whole catalogue, and a
re-run can duplicate it. Use a natural-key lookup per row or a count/version guard.

### 8.2 One-open-record invariants

Retrieve-then-create is not concurrency-safe. State how the second caller loses:

- a database unique constraint (if available),
- a lock/transaction strategy,
- a post-commit recheck that deletes the loser,
- or an explicitly accepted duplicate with a repair path.

### 8.3 Business keys

Uniqueness in a validation flow is a friendly message, not a guarantee. Add the constraint or
document the accepted race.

---

## 9. Retrieval and query shape

- Avoid retrieve-inside-loop when a list-level retrieve + in-memory computation would do.
- Prefer one list retrieve and a map/index over N single-object retrieves.
- Bound lists that are not deliberately full sets (`first`, `limit`, paging).
- Aggregate in the database (view entity/aggregate) where the platform supports it.
- Do not retrieve "all" for a picker or duplicate check on a table that grows with history.
- A microflow data source that returns a list is re-evaluated when the page loads; a
  button action may not refresh it. Design the page flow accordingly.

See `PERFORMANCE.md` for the index/query-budget discipline.

---

## 10. Validation

- `VAL_*` returns a Boolean and attaches feedback to the field the user can fix.
- If the same validation is reused from a different page, verify the field is on that page.
  Otherwise use `show message` or a page-specific validation.
- Required, unique, and conditional-mandatory are different rules; state them separately.
- Validate server-side even if the widget has client-side constraints.
- A validation that always returns true, or a startup flow that ignores its self-test result,
  is a false-confidence mechanism.

---

## 11. Nanoflows

- Keep nanoflows small and UI-focused.
- Do not duplicate business rules in a nanoflow and a microflow; call the microflow.
- If a nanoflow calls a JavaScript action, handle the return value and failure. A swallowed
  `false` is a "button does nothing" defect.
- If many nanoflows are near-identical (for example export wrappers), consider a parameterized
  nanoflow or a generator; do not create 27 copies by hand.
- Test the nanoflow's actual UI behavior; a server-side test does not cover it.

---

## 12. Testability

- The business rule must be callable without a UI context. Extract `SUB_` flows from `ACT_`
  flows that end in `close page`/`show message`.
- Name the callable seam in the task: "ACT checks rights, calls SUB_X; SUB_X is tested".
- A test that needs a page context is not a unit test of the rule.
- A test that asserts a value it just set is a fixture, not a test.

---

## 13. Rules

### MND-BL-01 — Put business logic in microflows, not nanoflows

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Section 7.7, BL-018
- **Applies when:** logic changes data or enforces a rule.
- **Instruction:** Server-side microflow for authority/business rules; nanoflow for UI only.
- **Verify:** A nanoflow cannot be the only enforcement of a business rule; a direct server
  call is still checked.

### MND-BL-02 — Write the state machine before the actions

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-004, BL-014, PL-009
- **Applies when:** a record has multiple statuses/transitions.
- **Instruction:** Use the §3 template; include actor, guard, stamps, audit, failure, and
  concurrency.
- **Verify:** Every transition has a test or a documented guard; no unreachable action.

### MND-BL-03 — State and enforce the transaction boundary

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-012, RC-14
- **Applies when:** a business action performs multiple writes.
- **Instruction:** Define what commits together; prefer compute-then-one-commit; document
  partial-failure behavior and repair.
- **Verify:** A forced failure does not leave an unmarked inconsistent record.

### MND-BL-04 — Close the job audit on every path

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-008, QC-011
- **Applies when:** scheduled/background work has an audit row.
- **Instruction:** Create/close it in the entry flow's error scope; record success, failure,
  and outcome.
- **Verify:** Force a failure and inspect the closed row and operator surface.

### MND-BL-05 — Consume returned status objects

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-009, QC-011
- **Applies when:** a helper returns a status/log/result object.
- **Instruction:** Read it and propagate failure; do not stamp success unconditionally.
- **Verify:** A failed mail/import produces a failed job status, not `Succeeded = true`.

### MND-BL-06 — Specify scheduling semantics, not just a time

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-008, BL-010, QC-012
- **Applies when:** adding a scheduled event.
- **Instruction:** Time zone, repeat fields, overlap, catch-up, idempotency, failure,
  missed-run detection, manual parity, audit.
- **Verify:** A duplicate/manual run does not double-send; a missed run is visible.

### MND-BL-07 — Make seeds idempotent by natural key

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** BL-002
- **Applies when:** seeding reference data/catalogue.
- **Instruction:** Guard and factory use the same key; a re-run must not duplicate or disable
  the set.
- **Verify:** Run twice; count and contents unchanged.

### MND-BL-08 — Design concurrency for one-open-record invariants

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** BL-006, DM-007
- **Applies when:** "exactly one open X" is required.
- **Instruction:** Use a constraint/lock/post-commit recheck; state the loser behavior.
- **Verify:** Concurrent test or documented accepted race.

### MND-BL-09 — Give every business rule a callable seam

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** BL-018
- **Applies when:** an `ACT_` flow contains substantial logic.
- **Instruction:** Thin the ACT to rights + call `SUB_` + message/close; test the SUB.
- **Verify:** The rule can be invoked by `mxcli test`/a scheduler without a page.

### MND-BL-10 — Recompute authorization in the action

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** QC-005, BL-011
- **Applies when:** an action takes a rights object/flag/role from the client.
- **Instruction:** Ignore client booleans; recompute from the object and current user.
- **Verify:** A forged request is refused; a lower role cannot perform the action.

### MND-BL-11 — Attach validation feedback to a field on the calling page

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `SUSPECTED`
- **Source:** BL-015
- **Applies when:** reusing a `VAL_` flow from a second page.
- **Instruction:** Verify the field is rendered; otherwise use a message or a page-specific
  validation.
- **Verify:** The error is visible on the page that invoked the action.

### MND-BL-12 — Do not let a startup/self-test contract lie

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** BL-001
- **Applies when:** an after-startup flow returns a Boolean/status.
- **Instruction:** Return the real result (for example `failCount = 0`); do not `return true`
  after ignoring the check.
- **Verify:** Force a failure; startup reports failure.

### MND-BL-13 — Do not swallow asynchronous/export results

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** BL-017
- **Applies when:** a JavaScript action/nanoflow returns success.
- **Instruction:** Read the result; show/log failure; do not discard it.
- **Verify:** Force a failed export; the user sees an error.

### MND-BL-14 — Keep demo/test generators out of the production path

- **Type:** Universal (conditional on deployment)
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** BL-021, QC-010
- **Applies when:** the model ships demo/test seed actions.
- **Instruction:** Separate module, constant-gated, environment-gated, and ideally with an
  un-seed path. Never grant a `TST_` flow directly.
- **Verify:** Production configuration cannot trigger the seed; a `TST_` grant scan is empty.

### MND-BL-15 — Make manual and scheduled paths share the entry contract

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** BL-010
- **Applies when:** a page offers "run now" for a scheduled job.
- **Instruction:** Call the same entry flow (`SE_`) so error handling/idempotency/audit apply.
- **Verify:** A manual failure produces the same audit/log behavior as a scheduled failure.
