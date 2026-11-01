# Performance

**Purpose:** make performance a design property, not a late optimization pass. The
retrospective's performance risk was invisible at demo volume: zero indexes on 34 entities,
retrieve-inside-loop jobs, and one admin refresh on the order of 10,000 sequential queries.

**Important:** performance findings in the source are model-based, not measured at production
volume. Treat the direction as strongly supported and measure before claiming a number.

---

## 1. Design-time performance questions

For every entity, page, and job:

- How many rows now, in one year, at the stated business volume?
- Which attributes/associations are used in access XPath, sorts, filters, and lookups?
- Which lists are deliberately full sets, and which need paging/limits?
- Which operations are per-row that could be per-list?
- Which aggregates are computed in a loop that could be computed in the database?
- Which jobs run in one transaction, and how long can that transaction be?
- What is the query budget per user action / per job?
- What is the target response time for the busiest page?

Write the answers in the non-functional requirements. "It works on the demo database" is not a
performance requirement.

---

## 2. Indexes

Mendix does not automatically index every attribute or association column. Derive indexes
from:

- entity-access XPath paths (team/tenant/owner joins),
- grid sorts and filters,
- business-key lookups,
- reporting/view-entity joins,
- scheduled job scans.

Add the index list to the domain model task. Verify the actual index creation mechanism for the
Mendix version/database; an index that exists only in a plan does not exist.

**Warning:** an index on every column is not a strategy. Index the paths that are actually
used; too many indexes slow writes and increase storage.

---

## 3. N+1 and retrieve-inside-loop

### 3.1 The shape

```text
retrieve list of parents
for each parent:
  retrieve children / related object / count
  change / commit
```

This is O(rows) round-trips. It is often invisible on a local file database and painful on a
networked PostgreSQL deployment.

### 3.2 Preferred shapes

- Retrieve the list once, compute in memory, commit once.
- Use a list-level retrieve with the same XPath and build a map/index by key.
- Use an aggregate/view entity for counts/max/min/sum.
- Use a task queue or batched job for large refreshes, with per-record transactions if needed.
- Make the batch resumable and bounded; do not hold one transaction for the entire table.

### 3.3 Counts

Do not retrieve all rows just to count them if the platform can aggregate. A `count` in the
database is cheaper than loading objects. If the Mendix expression language forces an object
list, state the volume and measure.

---

## 4. Unbounded retrieves

Every retrieve that is not deliberately a full set should have a bound:

- `first` for a single expected row,
- `limit`/paging for a list,
- a filter that uses an indexed key,
- a date window for history,
- a scope (team/tag/analyzer) for a picker.

A picker that retrieves "all open records" grows with history. A baseline statistics query that
retrieves "every completed verification since the last reset" grows forever. State the bound
and the fallback when the bound is exceeded.

---

## 5. Transactions and jobs

- Keep transactions short. A long batch that commits at the end holds locks and risks timeout.
- A per-record transaction is often better for a repair job; make it idempotent and resumable.
- A job audit row should be committed early enough to survive, but closed in the same scope as
  the error handler.
- Do not run an unbounded refresh inside a user action; move it to a background/task queue or
  make it batchable.
- For exports, chunk large result sets; a single workbook with every row may exceed memory or
  the widget's limit.

---

## 6. Page-level performance

- A grid's data source query runs on page load. Avoid a microflow data source that performs
  heavy work per row or per page load.
- A non-persistent helper that triggers a retrieve per row is an N+1 in the UI.
- A filter DataView that is instantiated per tab can multiply queries; place it deliberately.
- An unbounded list on a detail page is a performance defect even if it looks like a small
  panel.
- Sorting on an unindexed attribute is a scan; check the sort columns against the index list.

---

## 7. Measurement and evidence

- Measure query counts per user action and per job, not just wall-clock on a laptop.
- Use a representative data volume: the business's expected rows, not the demo seed.
- Test on the target database (HSQLDB vs PostgreSQL can differ materially).
- Record the measurement method, dataset size, and result. A score is not a measurement.
- `report`/lint performance scores may have no rule for N+1 or unbounded retrieves. A
  Performance 100 can mean "no rule covers this", not "fast".

---

## 8. Rules

### MND-PERF-01 — Derive indexes from access XPaths and grid sorts

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED` (structure) / `STRONGLY SUPPORTED` (consequence)
- **Source:** DM-001
- **Applies when:** designing the domain model or a list.
- **Instruction:** Write the index list from the actual XPath/sort/filter/business-key paths;
  add it to the domain task, not a later pass.
- **Verify:** The list matches the model; a query plan/measurement at volume where possible.

### MND-PERF-02 — Avoid retrieve-inside-loop for batch work

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-007, QC-018
- **Applies when:** a job/refresh processes many records.
- **Instruction:** Retrieve once, compute in memory or aggregate in the database; batch and
  make resumable. State a query budget independent of row count.
- **Verify:** Query count at 1×, 10×, 100× rows; it should not grow linearly per row for the
  same batch.

### MND-PERF-03 — Bound every non-deliberate list retrieve

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED` (code) / `SUSPECTED` (volume)
- **Source:** QC-019
- **Applies when:** a retrieve feeds a picker, detail panel, export, or statistics.
- **Instruction:** Add `first`, `limit`, paging, a date window, or a scope. Document why a full
  set is required.
- **Verify:** The list has a bound; the volume assumption is recorded.

### MND-PERF-04 — Write a query/response budget for critical actions

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** QC-018, PL-014
- **Applies when:** a page/job is business-critical or grows with history.
- **Instruction:** State the expected volume, query count, and response target; measure on the
  target database.
- **Verify:** Measurement recorded; budget met or exception accepted.

### MND-PERF-05 — Use aggregation/view entities/task queues where appropriate

- **Type:** Universal (conditional on version/project)
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** QC-018, Section 7.4
- **Applies when:** counts/aggregates or large background refreshes are needed.
- **Instruction:** Prefer a view entity/aggregate query for read-only aggregates; prefer a task
  queue/batched job for large writes. Verify the feature exists in the project's Mendix version.
- **Verify:** The aggregate returns the same result as the loop; the job is bounded/resumable.

### MND-PERF-06 — Do not trust a performance score as evidence

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** MX-021, QC-018/020
- **Applies when:** a report/lint score is cited.
- **Instruction:** Quote rule counts and specific findings; measure the actual query/response.
  A Performance 100 may mean no N+1 rule exists.
- **Verify:** A measurement exists for the claim; the score is labelled advisory.

### MND-PERF-07 — Keep transactions short and jobs resumable

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** BL-012, QC-018
- **Applies when:** a batch writes many rows.
- **Instruction:** Batch/commit per chunk; avoid one long transaction; make the job idempotent
  and resumable.
- **Verify:** A mid-job failure does not leave a lock or an unmarked partial state.

### MND-PERF-08 — Check page data sources for hidden N+1

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** BL-007, QC-018/019
- **Applies when:** a page uses a microflow data source, non-persistent helper, or nested list.
- **Instruction:** Trace the data source: does it retrieve per row? Does it load an unbounded
  list? Move heavy work out of page load.
- **Verify:** Query count for the page load at realistic volume.
