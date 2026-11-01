# Project Engineering Guidance — <Project Name>

> **How to use this file.** This is the project-specific companion to the reusable **MendixND**
> skill. It records the actual environment, the conventions in force, the applicable
> conditional rules, and the exceptions. It is not a copy of the skill. Keep it current; do
> not turn it into a second copy of the skill.
>
> **Initialization status:** <INITIALIZED / ALREADY INITIALIZED / BLOCKED>
> **Last verified:** <YYYY-MM-DD>
> **Verified by:** <agent/human>
> **MendixND version:** <skill version/date>

---

## 1. Project identity

| Field | Value | Evidence |
|---|---|---|
| Project name | <name> | <path/command> |
| `.mpr` file | <path> | <path> |
| MPR format | <v1/v2/unknown> | <command/Studio Pro> |
| Mendix version | <x.y.z> | <command/Studio Pro About> |
| JDK / runtime | <version> | <command> |
| Database (local) | <type/version> | <settings> |
| Database (target) | <type/version> | <deployment docs> |
| Deployment target | <cloud/on-prem/unknown> | <docs> |
| Version control | <git/teamserver/none> | <command> |
| Project state | <new/existing/delivered> | <observation> |

**Do not guess a version.** If it cannot be established, write `UNKNOWN` and ask.

---

## 2. Toolchain inventory

| Tool | Present? | Version | Path / invocation | What it is used for |
|---|---|---|---|---|
| Studio Pro | <yes/no> | <version> | <path> | <model editing/build/run> |
| mxcli | <yes/no> | <version/date> | <path> | <inspect/check/diff/exec/run/test> |
| MDL source | <yes/no> | <mdl 0/1> | <folder> | <model source> |
| mxbuild / `mx.exe` | <yes/no> | <version> | <path> | <build gate> |
| MCP server(s) | <yes/no> | <name/version> | <config> | <capabilities> |
| Node/Playwright | <yes/no> | <version> | <path> | <browser tests> |
| Other | <...> | <...> | <...> | <...> |

### 2.1 What each gate proves in this project

| Gate | Command | Proves | Does not prove |
|---|---|---|---|
| Static check | <command> | <...> | <...> |
| Build | <command> | <...> | <...> |
| Runtime | <command> | <...> | <...> |
| Browser | <command> | <...> | <...> |
| Data assertion | <command> | <...> | <...> |

### 2.2 Toolchain limitations in force

<List the conditional limitations that apply, with evidence. Example: "This project uses mxcli
build X; `check` does not type-check page ContentParams. The page gate is `docker check`." If
the project does not use mxcli, say so and delete that section.>

---

## 3. Project inventory

| Area | Count / notes | Evidence |
|---|---|---|
| Modules (project) | <...> | <...> |
| Marketplace modules | <name/version list> | <...> |
| Entities | <count> | <...> |
| Associations | <count> | <...> |
| Enumerations | <count> | <...> |
| Pages | <count> | <...> |
| Microflows | <count> | <...> |
| Nanoflows | <count> | <...> |
| Scheduled events | <count> | <...> |
| Constants | <count> | <...> |
| Java/JS actions | <count/owner> | <...> |
| Tests | <count/type> | <...> |

### 3.1 Module responsibilities

| Module | Source (project/Marketplace) | Responsibility | Owner |
|---|---|---|---|
| <...> | <...> | <...> | <...> |

### 3.2 Existing conventions

- Naming: <prefixes, folders, casing>
- Page structure: <layout, header band, grid policy>
- Flow structure: <ACT/SUB/VAL/DS conventions>
- Error handling: <pattern>
- Validation: <pattern>
- Styling: <design properties, permitted classes>
- Localization: <language(s)>
- Documentation: <where decisions/findings live>

---

## 4. Architecture and domain

### 4.1 Domain model summary

<Entities, key associations, inheritance, persistable/non-persistable, delete behaviour. Link
to a model diagram or describe command; do not paste the whole model.>

### 4.2 Derived state

| Derived attribute | Source of truth | Writer(s) | Trigger(s) | Repair path | Staleness marker |
|---|---|---|---|---|---|
| <...> | <...> | <...> | <...> | <...> | <...> |

### 4.3 Indexes

| Entity | Attribute/path | Reason (access/sort/filter) | Present? |
|---|---|---|---|
| <...> | <...> | <...> | <yes/no> |

### 4.4 Uniqueness/concurrency

| Invariant | Enforcement | Loser behavior | Verified? |
|---|---|---|---|
| <...> | <constraint/lock/recheck/accepted race> | <...> | <...> |

---

## 5. Security

| Setting | Value | Required? | Evidence |
|---|---|---|---|
| Security level | <...> | <...> | <...> |
| Strict mode | <on/off> | <...> | <...> |
| Demo users | <on/off> | <...> | <...> |
| Guest access | <on/off> | <...> | <...> |
| Admin account | <configured how> | <...> | <...> |

### 5.1 User roles and capabilities

| User role | Module roles | Capabilities | Risk | Owner |
|---|---|---|---|---|
| <...> | <...> | <...> | <...> | <...> |

### 5.2 Entity access policy

<Link to the matrix or summarize. For each entity: role × CRUD × XPath × attribute list. Note
`read *`/`write *` snapshots and audit entities.>

### 5.3 Page/action/entity triangle

<Link to the reachability matrix. Note any known dead-end buttons, page grants wider than the
action grants, or role-home decisions.>

### 5.4 Negative tests

| Boundary | Test | Result |
|---|---|---|
| <...> | <...> | <...> |

---

## 6. UI conventions

- Layout(s): <...>
- Page template / identity band: <...>
- Action placement: <...>
- Grid policy: <...>
- Empty states: <...>
- Design properties: <...>
- Permitted classes: <...> (must exist in compiled CSS)
- Responsive contract: <1440/1280/375 behavior>
- Load-bearing names: <exports/tests/navigation>
- Navigation/home pages: <...>

---

## 7. Logic conventions

- Microflow vs nanoflow boundary: <...>
- Flow prefixes/roles: <...>
- Transaction boundary: <...>
- Derived refresh: <...>
- Scheduling: <...>
- Validation feedback: <...>
- Integration error/status: <...>
- Test seams: <...>

---

## 8. Validation gates for this project

| Change type | Required gates | Evidence to record |
|---|---|---|
| Domain model | <...> | <...> |
| Page/UI | <...> | <...> |
| Microflow | <...> | <...> |
| Security | <...> | <...> |
| Integration | <...> | <...> |
| Marketplace | <...> | <...> |
| Release | <...> | <...> |

### 8.1 Definition of done

<Project-specific axes and thresholds. Example: "Page: renders at 1440/1280/375; no horizontal
overflow; 7 columns at 1280; screenshot attached." Do not just say "tests pass".>

### 8.2 Test data and environment

- Test database: <...>
- Isolation strategy: <...>
- Runtime session/licence limits: <...>
- Logout/restart procedure: <...>
- Known environment quirks: <...>

---

## 9. Artifact ownership and replay

| Artifact type | Owner | Manifest/location | Replay rule |
|---|---|---|---|
| Pages | <...> | <...> | <...> |
| Microflows | <...> | <...> | <...> |
| Entities | <...> | <...> | <...> |
| Nanoflows | <...> | <...> | <...> |
| Security | <...> | <...> | <...> |
| Navigation | <...> | <...> | <...> |

If the project does not use scripts/generators, write "N/A — model edited in Studio Pro" and
describe the change-control convention instead. Do not invent a manifest requirement.

---

## 10. Applicable MendixND references

Check the ones that apply. Explain any that do not.

- [ ] `CORE_ENGINEERING_PRINCIPLES.md`
- [ ] `MENDIX_NATIVE_FIRST.md`
- [ ] `DOMAIN_MODEL.md`
- [ ] `UI_AND_STYLING.md`
- [ ] `MICROFLOWS_AND_NANOFLOWS.md`
- [ ] `SECURITY.md`
- [ ] `PERFORMANCE.md`
- [ ] `MXCLI_MDL.md` — only if mxcli/MDL is used
- [ ] `VALIDATION_AND_TESTING.md`
- [ ] `AI_AGENT_FAILURE_PATTERNS.md`
- [ ] `KNOWN_LIMITATIONS.md`

### 10.1 Conditional rules in force

| Condition | Rule(s) | Why it applies here |
|---|---|---|
| <mxcli/MDL> | <MND-MX-*> | <...> |
| <Marketplace> | <MND-N-07/SEC-09> | <...> |
| <Production> | <MND-SEC-02/10> | <...> |
| <Mobile> | <MND-UI-13> | <...> |
| <Trial runtime> | <MND-V-08> | <...> |

### 10.2 Conditional rules explicitly not in force

| Rule | Why not |
|---|---|
| <...> | <...> |

---

## 11. Project-specific exceptions

Record only real exceptions to a MendixND rule, with evidence and an owner.

| Rule | Exception | Reason | Owner | Revisit when |
|---|---|---|---|---|
| <...> | <...> | <...> | <...> | <...> |

---

## 12. Open questions and risks

| ID | Question/risk | Why it matters | Owner | Next action |
|---|---|---|---|---|
| <...> | <...> | <...> | <...> | <...> |

---

## 13. How future agents should use this file

1. Read this file before planning a Mendix change.
2. Load the MendixND skill if it is not already active in the session.
3. Read the specific MendixND reference for the task (see the routing table in `SKILL.md`).
4. Inspect the actual model; this file describes the environment, not every artifact.
5. If this file and the model disagree, the model wins for what exists; record the drift.
6. Update this file when the environment, conventions, exceptions, or ownership changes.
7. Do not overwrite it silently; append/amend with a dated note and an owner.

---

## 14. Initialization record

| Item | Value |
|---|---|
| Invoked by | <agent/human> |
| Date | <YYYY-MM-DD> |
| Existing instructions inspected | <AGENTS.md/CLAUDE.md/opencode.json/...> |
| Existing instructions modified? | <no / yes — exact additive change> |
| Guidance file created | <path> |
| Application artifacts modified? | **No** |
| Verification performed | <...> |
| Manual integration required | <...> |
