# Domain Model

**Purpose:** design a Mendix domain model deliberately: entities, associations, inheritance,
persistence, derived state, precision, uniqueness, date semantics, access, indexes, and
delete behaviour. The domain model is not a database diagram; it is the contract that pages,
flows, security, and reports depend on.

---

## 1. Design the context before the entities

Before adding an entity, answer:

- Which page/flow owns the object context?
- Which association path reaches it, and is the association optional?
- Which user roles read/write it?
- Is it a persisted business record, a non-persistent view model, or a configuration row?
- What is its lifecycle: create, edit, complete, cancel, soft-delete, purge?
- What is the uniqueness rule, if any?
- What is the expected row count and growth rate?
- Which grids/sorts/XPaths will query it?

A domain model without page/flow contexts is not implementable. `$currentObject` is lexical,
not a URL; see `UI_AND_STYLING.md`.

---

## 2. Entity and association choices

### 2.1 Persistable vs non-persistable

- **Persistable:** business records that must survive the session, be auditable, be queried
  by other users, or be reported.
- **Non-persistable:** input forms, view models, computed result carriers, search filters,
  rights objects. They are not a substitute for a persisted business record.
- Do not persist a helper object merely because a page needs a shape. Do not keep a business
  record non-persistent because it is "temporary" if another user or a later session needs it.

### 2.2 Generalization

Use real inheritance when subtypes share identity, status, associations, and lifecycle. The
retrospective's `WorkItem → Verification/Malfunction` is a genuine generalization: shared
status, reference, number, cancel reason, soft-delete fields, system members, and
associations are declared once. The cost is a wide physical table; that is often the right
price.

Do **not** use inheritance when:

- The subtypes have different lifecycles and no shared behavior.
- A grid over the base entity cannot reach the subtype attributes the UI needs.
- The "shared" fields are only coincidentally named the same.

### 2.3 Associations

- State cardinality, ownership, and optionality explicitly.
- For optional associations used for drill-through, the page must bind a DataView and guard
  the container; see `UI_AND_STYLING.md`.
- For self-references and multiple associations to the same entity, name them by role. The
  reverse direction must be readable; if the tool cannot store role names, use explicit
  association names and document the direction.
- Do not rely on a self-association alone for a frequently filtered flag if the platform's
  XPath cannot express it efficiently. A denormalized flag is allowed **only** with a named
  writer and refresh trigger.
- Delete behaviour is not implied by an association unless the model actually defines it.
  State refuse / soft-delete / cascade per entity.

### 2.4 Helper entities

Non-persistent helpers are legitimate for:

- A page input/form object.
- A computed result or filter.
- A rights/visibility carrier (display only, never authoritative).
- A search result row when a view entity is not suitable.

Keep one helper per responsibility. Do not create two helpers that carry the same four
values, and do not store pre-formatted presentation text on a helper when a dynamic text can
format it.

---

## 3. Derived state and the write graph

For every stored derived attribute (`OpenWorkCount`, `HasOpenWork`, `LastResult`,
`NextScheduledDate`, status caches, warning flags), write the **write graph**:

```text
Attribute:        what is stored
Source of truth:  which entity/attributes/records it derives from
Writer(s):        which flows/events may change it
Triggers:         create, edit, delete, bulk import, scheduled repair
Transaction:      what commits with what; can it be partially applied?
Repair path:      how an operator/administrator recomputes it
Staleness marker: how a stale value is detected (or why none is needed)
Consumers:        grids, mails, reports, security decisions
```

Prefer **compute in memory → one commit** over commit-then-refresh. If a retrieve must see
a committed object, document the transaction boundary and add a `DerivedStale` marker plus a
repair job if a partial failure can leave the record saved with wrong counters.

Do not let a derived value become an authorization input unless the security model explicitly
treats it as such and it is recomputed server-side.

---

## 4. Semantics that cause silent defects

### 4.1 Derived enumeration precedence

If an entity can satisfy two states (for example `Expired` and `OutOfService`), specify:

- the exact predicate for each state,
- the precedence order,
- which consumers rely on which state,
- the boundary dates (today, end of day, future dates),
- what happens when a mandatory date is empty.

A prose sentence such as "status is derived" is not a specification. Write the expression
over named attributes and test the boundaries.

### 4.2 Units and precision

For every numeric attribute that is compared, stored, exported, or displayed:

- unit of measure on both sides of the comparison,
- decision precision vs display precision,
- where rounding happens (write, compute, render),
- whether stored limits are rounded or raw,
- what the audit string records.

A bare `Decimal` is not a specification. A reference value without a unit can be off by
orders of magnitude.

### 4.3 Date-only concepts

Mendix has no date-only type. For a date-only business concept:

- choose one normalization rule (for example, store at `BeginOfCurrentDay`),
- use `BeginOfCurrentDay` / `EndOfCurrentDay` for comparisons,
- never compare a DateTime with `=` when only the date matters,
- state the time zone for scheduled events and displays,
- test the boundary (today, tomorrow, future in-service date, past out-of-service date).

### 4.4 Required vs unique

- **Required** is a validation rule (`not null` + a validation microflow message).
- **Unique** needs a database constraint if the platform supports it, or an explicitly
  accepted race with a documented loser behavior.
- Retrieve-then-create is not a uniqueness guarantee. Two concurrent callers can both pass.
- For "exactly one open record" invariants, state how the second caller loses (constraint,
  lock, post-commit recheck, or accepted duplicate).

### 4.5 Identities

Do not store the same identity twice (association + name string) without stating which is
authoritative. A snapshot string is legitimate for audit/history; the live association is for
current data and sending. State the rule per pair.

### 4.6 Singletons

A singleton entity is a convention unless enforced. State:

- how many rows are allowed,
- how creation is guarded,
- what happens if a second row exists,
- which reader resolves the row,
- where defaults live (entity defaults, create literals, seed scripts).

---

## 5. Access, audit, and delete as domain concerns

Entity access is part of the domain model, not a later security pass.

- Write the access policy table with the entity: role × create/read/write/delete × XPath ×
  attribute list.
- `read *` / `write *` is expanded when written. An attribute added later is not covered.
  Add the attribute and its grant in the same change.
- Audit entities should be append-only from the business perspective. If Mendix cannot express
  insert-only, grant create + read and do not expose an edit path; record the residual risk.
- Grant create to the writing role even when a microflow bypasses entity access, so the
  intent is explicit and `@applyentityaccess` flows do not fail later.
- Delete behaviour: choose **refuse**, **soft-delete**, or **cascade** per entity. "Protect"
  is not a specification. A soft-delete entity must not have a hard-delete path for work items.
- A delete guard should check the right dependants (open and closed), not just one.

---

## 6. Indexes

Mendix does not automatically index every attribute or association column. Derive the index
list from:

- every attribute/association used in entity-access XPath,
- every grid sort and filter,
- every frequent lookup/business key,
- every join used by reporting/view entities.

Write the index list in the domain task, not in a later performance pass. Verify the actual
index creation mechanism for the project's Mendix version and database.

---

## 7. Naming, language, and documentation

- One UI language. Enumeration captions, validation messages, and audit snapshots must agree.
- Avoid near-identical names with different meanings (`ExpiryWarningText` vs
  `ExpiredWarningText`). Searchability matters.
- Do not shadow platform names (`System`, `User`) with business attributes.
- Audit snapshot text should use stable technical names or a documented format, not captions
  that may change.
- Document non-obvious invariants next to the entity/association, not only in a plan.
- Remove dead flags and dead configuration. A deferred integration should not expose a
  user-facing column that is always true/false.

---

## 8. Model changes

Before changing an existing model:

1. Find every definition and every consumer.
2. Check whether the change is additive or destructive.
3. Add the attribute and its grants in the same script/change.
4. Update indexes, XPaths, pages, flows, tests, and documentation in the same slice.
5. Migrate existing data if the attribute is required or its meaning changes.
6. Verify the model and the running behavior; a model change that compiles can still break
   a page binding or an access rule.

---

## 9. Rules

### MND-DM-01 — Draw the page/flow context before the entities

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** UI-009, P-01, RC-04
- **Applies when:** designing or changing a domain model.
- **Instruction:** Record the owning page/flow, object context, association path, optionality,
  and data sources before adding entities.
- **Verify:** The context map exists and every entity is reachable from a page/flow.

### MND-DM-02 — Use real generalization, not copy-paste

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Section 5.4, DM clean checks
- **Applies when:** two entities share identity, status, associations, and lifecycle.
- **Instruction:** Declare shared members once in a base entity. Do not create unrelated
  entities with copied columns.
- **Verify:** The base entity is queried/used as a base; subtypes add only their own members.
- **Exceptions:** Different lifecycles or a base grid that cannot reach needed subtype
  attributes; record the reason.

### MND-DM-03 — Write the derived-value write graph

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** DM-002, BL-012, RC-14
- **Applies when:** storing any derived attribute or counter.
- **Instruction:** Use the §3 template. Prefer compute-in-memory → one commit; add a repair
  path and staleness marker where a partial failure is possible.
- **Verify:** A test edits the source and checks the derived value; a forced failure does not
  leave an unmarked stale value.

### MND-DM-04 — Specify derived-enumeration predicates and precedence

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** DM-003, DM-004
- **Applies when:** an enumeration/status is derived from multiple attributes.
- **Instruction:** Write the expression and precedence; test the boundary dates and the
  both-true case. Ensure every consumer uses the same predicate.
- **Verify:** Unit tests at boundaries; the display and selection rules agree.

### MND-DM-05 — Specify units and decision/display precision

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** DM-005, DM-006
- **Applies when:** comparing or displaying numeric values.
- **Instruction:** Record the unit on both sides, decision precision, display precision, and
  the rounding point. Do not let a displayed limit disagree with an OK/NOK decision.
- **Verify:** A value at the boundary is tested; export, display, and decision agree.

### MND-DM-06 — Separate required, unique, and concurrency invariants

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** DM-007, BL-006
- **Applies when:** a business key or one-open-record invariant exists.
- **Instruction:** Required = validation; unique = constraint or accepted race; one-open =
  explicit concurrency design. State what the second caller gets.
- **Verify:** A concurrent/duplicate test or a documented accepted race.

### MND-DM-07 — Normalize date-only values

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** DM-017, P-08
- **Applies when:** an attribute represents a date, not a timestamp.
- **Instruction:** Store at `BeginOfCurrentDay`; compare with Begin/EndOfCurrentDay; never use
  `=` for a DateTime date filter; state the time zone.
- **Verify:** Boundary tests; a date filter returns the expected rows.

### MND-DM-08 — Treat entity access as part of the domain model

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** DM-008, DM-009, DM-010, QC-006
- **Applies when:** adding/changing an entity or attribute.
- **Instruction:** Write the access policy table; add attribute + grant together; grant
  create to the writer; keep audit entities append-only.
- **Verify:** A role-by-role access check and a negative test; `describe`/matrix shows the
  intended rules.

### MND-DM-09 — Make delete behaviour explicit per entity

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** BL-004, DM patterns
- **Applies when:** an entity has dependants or a soft-delete flag.
- **Instruction:** Choose refuse / soft-delete / cascade. Never hard-delete a work item that
  has a soft-delete lifecycle. Guard all dependants, not only closed ones.
- **Verify:** Tests for each dependant state; audit row/soft-delete fields present.

### MND-DM-10 — Derive indexes from access XPaths and grid sorts

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED` (structure) / `STRONGLY SUPPORTED` (consequence)
- **Source:** DM-001
- **Applies when:** designing entities and lists.
- **Instruction:** List the XPath/sort/filter/business-key columns and index them in the
  domain task. Verify the index mechanism for the target database.
- **Verify:** The index list exists and matches the access/sort paths; a query plan or
  measurement at volume where possible.

### MND-DM-11 — State the singleton and default invariants

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** DM-013
- **Applies when:** an entity is described as a singleton or has duplicated defaults.
- **Instruction:** State how one row is enforced, how it is read, and where defaults live.
- **Verify:** A second-row path is blocked or documented; the defaults have one home.

### MND-DM-12 — Name associations for both directions

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED` (structure) / `SUSPECTED` (UI impact)
- **Source:** DM-012
- **Applies when:** self-references or multiple associations target the same entity.
- **Instruction:** Name by role; document the reverse direction; if the tool cannot store
  role names, use explicit names and a comment.
- **Verify:** A reader can tell the direction from `describe` and the page/flow.

### MND-DM-13 — Keep one UI language and stable audit text

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** DM-018
- **Applies when:** enumerations, captions, validation messages, audit snapshots.
- **Instruction:** Choose one language; use stable technical names or a documented format in
  audit snapshots; do not let caption changes rewrite history.
- **Verify:** A caption inventory; an audit row remains readable after a caption change.

### MND-DM-14 — Do not ship dead flags or deferred-integration surfaces

- **Type:** Universal
- **Priority:** P3
- **Confidence:** `VERIFIED`
- **Source:** DM-019
- **Applies when:** an integration is deferred or a flag has no writer/reader.
- **Instruction:** Do not expose a user-facing filter/column for a flag that is always true or
  has no clear path. Hide the surface until the integration exists.
- **Verify:** Every flag has a writer and a reader; no "waiting for integration" banner is
  permanently on.
