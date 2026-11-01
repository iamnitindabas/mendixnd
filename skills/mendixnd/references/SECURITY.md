# Security

**Purpose:** make security a designed property of the model and the server-side logic, not a
set of role names added to satisfy a build error. Common security defects are not exotic: an
over-granted stock admin role, demo users at Production, strict mode off, client-trusted
rights, writable audit entities, and pages granted to roles that cannot use them.

---

## 1. The security quartet

Treat these as one gate, not four independent checkboxes:

| Setting | Required state (for a production-level app) | Why |
|---|---|---|
| Security level | Production (or the project's intended level) | Enables the access model. |
| Strict mode | On where the project relies on XPath/entity access | Fails closed on constraint paths the platform flags. |
| Demo users | Off in any deployed environment | Demo credentials are not a secret store. |
| Guest access | Off unless explicitly required | Anonymous surface. |

Record the actual values and the reason for any exception. A PoC may accept a weaker setting,
but it must be labelled as such and must not be described as production-ready.

Additional checks:

- No committed password that is the only credential for a privileged role.
- Password policy appropriate to the environment.
- Admin account handled as environment configuration, not source.
- Authentication/provider configuration (SSO, MFA) recorded.

---

## 2. Roles are capabilities, not names

A user role is a bundle of module roles. A module role confers concrete capabilities: pages,
microflows, entities, XPath scope, create/read/write/delete. The name tells you nothing about
the capability.

For every user role, maintain a capability table:

```text
User role:        FunctionalAdmin
Module roles:     Module.FunctionalAdmin, Administration.Administrator, ...
Capabilities:     which pages, which actions, which entities, which rows, which fields
Why each role:    the business reason
Risk:             account administration? team membership? audit write? data export?
Review owner:     who approves changes
```

Treat a capability-bearing stock role (`Administration.Administrator`, `System.Administrator`,
`Encryption.Administrator`, etc.) as a red flag. Adding it to satisfy a build error is how a
functional admin becomes a platform admin.

Adding module roles is often additive and cannot be undone by re-running the script. After any
role change, read the role back and diff it against the table.

---

## 3. Entity access

### 3.1 Policy table

For every entity and role, specify:

- create / read / write / delete,
- XPath row scope,
- attribute-level lists where needed,
- whether the entity is system-owned or append-only,
- who may read audit/history,
- what happens when the rule matches no row.

Write the policy table before implementing. A matrix of CRUD letters is not enough if the
XPath is missing or the attribute list includes audit fields.

### 3.2 `read *` / `write *` is a snapshot

Mendix expands `*` when the grant is written. An attribute added later is **not** covered.
The page will show an empty column or the field will be read-only, with no error.

**Rule:** add the attribute and its grant in the same change. Re-run the entity's grant block
after any `ALTER ENTITY ... ADD ATTRIBUTE`.

### 3.3 Row scoping

- Team/tenant scope belongs in the entity access XPath, not only in a page filter.
- A page filter is a UX convenience; it is not authorization.
- Test a lower role against another team's row, not just against the menu.
- If a stored scope snapshot (for example `WorkItem_Team`) is not used by the authorization
  XPath, do not pretend it is the security boundary. Either use it or remove the claim.

### 3.4 Microflow bypass

Microflows bypass entity access unless the flow is marked to apply it. This means:

- A missing `create` grant can still "work" in a flow and fail later when access is applied.
- Grant `create` explicitly to the writing role even for system/audit tables, so the intent is
  in the model.
- Audit `@applyentityaccess` flows: every entity they write needs the right grant.

### 3.5 No insert-only rule

Mendix entity access is row-level XPath; it does not express "insert-only". For audit tables:

- grant create + read, not write, to business roles;
- do not expose an edit path;
- record the residual risk that a client with create/write could update rows if write is
  granted;
- prefer server-only writes and a read-only operator surface.

---

## 4. Server-side authorization

Never trust:

- a client-supplied rights object,
- a hidden button,
- a role label in the UI,
- a boolean computed on a previous page,
- an association the client could change,
- an unvalidated page parameter.

Every action that changes data must recompute the right from:

- the current user,
- the object being changed (retrieved server-side),
- the current state of the object,
- the applicable team/tenant/ownership rule.

The client copy may control button visibility; it must not be the authorization decision.

### 4.1 Direct invocation

Assume an attacker can call the microflow/service directly. Test the action without the page,
with a forged/absent rights object, and with a lower role. If it succeeds, the check is in the
wrong place.

---

## 5. Page, action, and entity triangle

A page grant alone is not enough. For each page:

- Which roles can view the page?
- Which roles can execute each action on it?
- Which roles can read/write the entity the page binds?
- Does a `show page` target grant match the source page's roles?
- Does a hidden action leave a visible field the role cannot save?

A page may be granted to a role that cannot execute its Save action; the result is an
editable-looking form with no Save button. A `show page` button is not hidden by the target's
page grant. Check all three sides, not just the page.

---

## 6. Grants

- Every page needs at least one view grant; every reachable action needs an execute grant.
- Do not grant `SUB_`, `VAL_`, `SE_`, `ASU_` to end users; they are reached through a granted
  action. `TST_` only to the System Manager, and ideally not at all in production.
- A new document (page/flow/nanoflow) must be granted in the same change; an ungranted
  document is unreachable.
- A grant is additive; removing a role may require an explicit revoke/alter, not just a
  re-run.
- Check grant coverage per role, not only per page.

---

## 7. Marketplace and platform pages

- Do not edit Marketplace module pages in place unless the edit is recorded as a fork with a
  re-apply/upgrade procedure.
- A Marketplace module may bring its own roles and pages. Review what they expose.
- Adding a platform page (accounts, scheduled events, sessions) requires the role to have
  access to the `System`/module entities the page reads; otherwise the build fails or the page
  is unusable.
- Treat the Settings menu as a security surface: every item is an escalation path for the
  role that can reach it.

---

## 8. Secrets and configuration

- Do not commit credentials, API keys, SMTP passwords, or demo passwords that are the only
  credential for a privileged account.
- Use environment/config constants or the platform's credential store.
- A safe default (mail disabled, integration disabled) is good; document how to enable it per
  environment.
- Remove dead configuration that looks like it controls a capability it no longer controls.

---

## 9. Negative testing

Positive tests are not enough. For each critical role boundary:

- A lower role must not see the menu item, page content, row, field, or action.
- A forbidden route in a single-page app may return HTTP 200; assert absent content/menu, not
  status code.
- A direct microflow/service call must be refused, not just the button hidden.
- A role with read-only entity access must not be able to save through a page that looks
  editable.
- An audit entity must not be writable by a business role.

---

## 10. Rules

### MND-SEC-01 — Build a capability table per user role

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** defining or changing roles.
- **Instruction:** Use the §2 table; name every module role and its capability. Treat stock
  admin roles as red flags. Read back the role after changes.
- **Verify:** `describe`/role inventory matches the table; no unexplained capability.

### MND-SEC-02 — Treat the security quartet as one gate

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** any deployment or security review.
- **Instruction:** Record security level, strict mode, demo users, guest access; fix deviations
  or record an accepted exception.
- **Verify:** `describe app security`/settings output in the evidence; a production config
  has demo users off, strict mode on where required, guest off.

### MND-SEC-03 — Write the entity access policy table

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** creating/changing an entity or attribute.
- **Instruction:** For each role: CRUD, XPath, attribute list, system/append-only. Add attribute
  + grant together.
- **Verify:** `describe entity`/matrix and a role-by-role negative test.

### MND-SEC-04 — Scope rows in entity access, not only in pages

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** data is team/tenant/owner-scoped.
- **Instruction:** Put the scope in the entity access XPath; test another team's row; do not
  rely on a page filter or a stored snapshot that authorization never reads.
- **Verify:** A lower role cannot retrieve/edit another team's row even via a direct call.

### MND-SEC-05 — Never trust a client-supplied authorization decision

- **Type:** Universal
- **Priority:** P0
- **Confidence:** `STRONGLY SUPPORTED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** an action receives a rights object, flag, role, or state from the client.
- **Instruction:** Recompute from the object and current user; client copy is display-only.
- **Verify:** Direct call with forged rights is refused.

### MND-SEC-06 — Keep audit entities append-only from the business perspective

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** an entity records corrections, limit changes, resets, or history.
- **Instruction:** Create + read, not write; no edit page; server-side writes; record the
  platform limitation if insert-only cannot be expressed.
- **Verify:** A business role cannot update an audit row; the UI has no edit path.

### MND-SEC-07 — Check the page × action × entity triangle

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** granting a page or adding an action.
- **Instruction:** For every role, verify page view, action execute, entity read/write. Add
  `Visible:` for `show page` targets or grant deliberately.
- **Verify:** Role-by-role reachability test; no dead-end button or editable-looking read-only
  form.

### MND-SEC-08 — Grant every new document deliberately

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** adding a page/flow/nanoflow.
- **Instruction:** Page → view grant; action → execute grant; `SUB_`/`VAL_`/`SE_`/`ASU_` no
  end-user grant; `TST_` only SM or none.
- **Verify:** A grant inventory per role; no ungranted reachable document.

### MND-SEC-09 — Do not edit Marketplace security/pages in place without a fork record

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** a Marketplace module page/role needs a change.
- **Instruction:** Wrap/copy into a project module or record the edit as a fork with re-apply
  after upgrade. Review the module's roles.
- **Verify:** Upgrade test or re-apply procedure; no silent loss.

### MND-SEC-10 — Keep secrets out of the model and repository

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** configuring mail, integrations, demo users, admin accounts.
- **Instruction:** Use environment configuration/credential store; no committed privileged
  password; safe defaults; document enablement.
- **Verify:** Secret scan; environment-specific config; demo users off in deployment.

### MND-SEC-11 — Test negative security by absence and direct invocation

- **Type:** Universal
- **Priority:** P1
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** validating a role boundary.
- **Instruction:** Assert absent menu/content/action for the lower role; call the action
  directly; do not rely on HTTP 403 in an SPA.
- **Verify:** Negative test evidence per role.

### MND-SEC-12 — Treat the Settings menu as a security surface

- **Type:** Universal
- **Priority:** P2
- **Confidence:** `VERIFIED`
- **Source:** Mendix platform and delivery experience
- **Applies when:** exposing platform/Marketplace administration pages.
- **Instruction:** Review every menu item and the role that can reach it; verify the role has
  access to the entities the page reads; remove items that are not needed.
- **Verify:** Role-by-role menu audit; no latent admin grant.
