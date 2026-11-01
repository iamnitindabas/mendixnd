# MendixND Initialization Report — <Project Name>

**Status:** <INITIALIZED | ALREADY INITIALIZED | BLOCKED — MANUAL ACTION REQUIRED>
**Date:** <YYYY-MM-DD>
**Invoked by:** <agent/human>
**Skill:** MendixND (`@MendixND`)
**Project root:** <path>

---

## 1. Context established

| Field | Value | Evidence |
|---|---|---|
| Mendix version | <...> | <command/Studio Pro> |
| MPR format | <...> | <...> |
| Development environment | <Studio Pro / mxcli / MCP / other> | <...> |
| Database local/target | <...> | <...> |
| Toolchain versions | <...> | <...> |
| Existing instructions | <AGENTS.md / CLAUDE.md / opencode.json / other> | <...> |
| Existing conventions | <naming/flow/UI/security> | <...> |
| Project state | <new/existing/delivered> | <...> |

### Conditional rule families in force

- [ ] mxcli/MDL
- [ ] Studio Pro only
- [ ] MCP
- [ ] Marketplace-heavy
- [ ] Production deployment
- [ ] Mobile/responsive
- [ ] Trial/licence-limited runtime
- [ ] Other: <...>

---

## 2. What was inspected

| Area | Method | Result / limitation |
|---|---|---|
| Modules | <...> | <...> |
| Domain model | <...> | <...> |
| Pages/navigation | <...> | <...> |
| Microflows/nanoflows | <...> | <...> |
| Security | <...> | <...> |
| Marketplace | <...> | <...> |
| Tests/build/runtime | <...> | <...> |
| Existing instructions | <...> | <...> |

**Could not inspect:** <...>

---

## 3. Artifacts created or changed

| Path | Action | Purpose |
|---|---|---|
| `docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md` | Created / already existed | Project-specific guidance |
| <...> | <...> | <...> |

**Application artifacts modified:** **No** (model, pages, microflows, domain model, security,
theme, widgets, Marketplace modules, deployment configuration).

---

## 4. Safety verification

| Check | Result |
|---|---|
| Existing `AGENTS.md` unchanged | <yes/no — hash/diff> |
| Existing `CLAUDE.md` unchanged | <yes/no — hash/diff> |
| Existing OpenCode config unchanged | <yes/no — hash/diff> |
| No duplicate config entries | <yes/no> |
| No Marketplace install/uninstall | <yes/no> |
| No model/application write | <yes/no> |
| Guidance file did not overwrite prior content | <yes/no> |
| No existing instruction deleted/restructured | <yes/no> |

### Hashes / diffs (if available)

```text
<before/after hash or diff for each instruction file>
```

---

## 5. Persistent integration

| Item | Status | Detail |
|---|---|---|
| Guidance file discoverable? | <yes/no> | <path> |
| Pointer added to project instructions? | <yes/no/not applied> | <exact line or manual step> |
| OpenCode config change? | <none/proposed/applied> | <...> |
| Manual action required? | <yes/no> | <exact steps> |

If no safe integration was possible, state exactly what the user must add and where. Do not
edit an existing instruction file without approval.

---

## 6. Verification of the skill

| Check | Result |
|---|---|
| `SKILL.md` present and readable | <yes/no> |
| Required references present | <list/count> |
| Templates present | <yes/no> |
| Skill loadable by ID (`@MendixND`) | <yes/no/not tested> |
| Project guidance matches inspected environment | <yes/no> |
| Future session discovery path exists | <yes/no — how> |

---

## 7. Open questions / residual risk

| ID | Question/risk | Owner | Next action |
|---|---|---|---|
| <...> | <...> | <...> | <...> |

---

## 8. Next steps

1. <...>
2. <...>
3. <...>

**Initialization is complete only when:** the guidance file exists, existing instructions are
unchanged, no application artifact was modified, and the discovery path is explicit.
