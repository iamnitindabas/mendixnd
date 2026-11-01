# MendixND

**Mendix-native-first engineering guidance for AI coding agents.**

- **Skill ID:** `mendixnd` (lowercase, Agent Skills standard)
- **Display name:** MendixND
- **Version:** 1.1.0
- **License:** MIT
- **Standard:** [Agent Skills](https://agentskills.io/specification)
- **Harnesses:** OpenCode, Claude Code, OpenAI Codex, GitHub Copilot, and other
  Agent Skills clients

MendixND turns practical Mendix delivery lessons into an actionable engineering mindset:
investigate native capabilities, reuse existing project artifacts, design deliberately, verify
before claiming completion, and avoid recurring AI failure patterns.

It is not a project template and not a Mendix tutorial. Project-specific names, versions,
layouts, and architecture are examples, not universal rules.

---

## 1. What it does

- Native-first decision process.
- Existing-project reuse discipline.
- Domain, UI, logic, security, performance, and testing rules.
- Conditional mxcli/MDL knowledge, isolated from platform knowledge.
- Known limitations with version/confidence scope.
- Non-destructive project initialization.
- Project-specific guidance template.
- Stable rule IDs with confidence and limitation classification.

The central rule:

> **Mendix-native first. Understand the platform before choosing an implementation approach.
> Custom implementation only when justified.**

---

## 2. Install by harness

The canonical skill directory is `skills/mendixnd` in the repository. Installers copy it into
the harness's skill location.

### OpenCode

| Scope | Path |
|---|---|
| Global | `~/.config/opencode/skills/mendixnd/` |
| Project | `.opencode/skills/mendixnd/` |

Invoke: `@mendixnd`. OpenCode also reads `.agents/skills` and `.claude/skills` for
compatibility.

### Claude Code

| Scope | Path |
|---|---|
| Personal | `~/.claude/skills/mendixnd/` |
| Project | `.claude/skills/mendixnd/` |

Invoke: `/mendixnd`.

### OpenAI Codex

| Scope | Path |
|---|---|
| Personal | `~/.agents/skills/mendixnd/` |
| Project | `.agents/skills/mendixnd/` |

Invoke: `$mendixnd`, or open `/skills` and select it. Codex reads `agents/openai.yaml` for
display metadata and implicit-invocation policy.

### GitHub Copilot

| Scope | Path |
|---|---|
| Personal | `~/.copilot/skills/mendixnd/` or `~/.agents/skills/mendixnd/` |
| Project | `.github/skills/mendixnd/`, `.claude/skills/mendixnd/`, or `.agents/skills/mendixnd/` |

Invoke: `/mendixnd`, or `/skills` to list/reload. Copilot CLI supports `/skills reload`.

### One-command install

From the repository root:

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g \
  -a opencode -a claude-code -a codex -a github-copilot
```

Or use the local installers:

```powershell
# Windows
.\install.ps1 -Scope User -Harnesses all
```

```bash
# macOS / Linux
./install.sh --scope user --harness all
```

See the repository `README.md` and `HARNESSES.md` for full options.

---

## 3. Invocation

Invocation syntax is harness-specific:

| Harness | Explicit invocation |
|---|---|
| OpenCode | `@mendixnd` |
| Claude Code | `/mendixnd` |
| OpenAI Codex | `$mendixnd` or `/skills` |
| GitHub Copilot | `/mendixnd` |
| Generic | Mention the skill name `mendixnd` and its task |

Auto-discovery is enabled. The host sees the skill name and description and may load
`SKILL.md` when relevant. It does not inject the full skill into every session.

For critical work — initialization, architecture, security, large migrations — invoke it
explicitly.

---

## 4. Initialization workflow

At the start of a Mendix project:

1. Establish context: Mendix version, toolchain, database, existing instructions.
2. Inspect the existing project: modules, domain, pages, logic, security, tests.
3. Create `docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md` from
   `templates/PROJECT_ENGINEERING_GUIDANCE.md`.
4. Integrate safely: never overwrite `AGENTS.md`, `CLAUDE.md`, OpenCode config, or
   application artifacts. Propose the smallest additive pointer.
5. Verify and produce an initialization report from
   `templates/INITIALIZATION_REPORT.md`.

Initialization is idempotent. A second invocation detects existing guidance, validates it, and
reports drift instead of overwriting.

---

## 5. Coexistence with tool-specific skills

MendixND is the **engineering-decision layer**, not a competing tool manual.

- **MendixND** decides whether to do something and what constraints apply: native-first,
  reuse, ownership, security, transactions, verification.
- **A maintained mxcli/Studio Pro/MCP skill** decides exactly how to invoke the tool in that
  version: commands, flags, syntax, current mechanics.
- **Project guidance** records local conventions and approved exceptions.

If a maintained mxcli skill conflicts with `references/MXCLI_MDL.md` on mechanics, the mxcli
skill wins. If it conflicts on safety, ownership, or verification, MendixND wins. Record any
material conflict.

---

## 6. File structure

```text
mendixnd/
├── SKILL.md
├── README.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── CORE_ENGINEERING_PRINCIPLES.md
│   ├── MENDIX_NATIVE_FIRST.md
│   ├── DOMAIN_MODEL.md
│   ├── UI_AND_STYLING.md
│   ├── MICROFLOWS_AND_NANOFLOWS.md
│   ├── SECURITY.md
│   ├── PERFORMANCE.md
│   ├── MXCLI_MDL.md
│   ├── VALIDATION_AND_TESTING.md
│   ├── AI_AGENT_FAILURE_PATTERNS.md
│   ├── KNOWN_LIMITATIONS.md
│   └── SCENARIO_TESTS.md
└── templates/
    ├── PROJECT_ENGINEERING_GUIDANCE.md
    └── INITIALIZATION_REPORT.md
```

`agents/openai.yaml` is Codex-specific metadata; other harnesses ignore it.

---

## 7. Maintenance

- MendixND is a reusable asset, not a project file.
- Reference knowledge is read-only during normal development.
- Project findings do not automatically rewrite universal rules.
- Universal rule changes require evidence, confidence, scope, and review.
- Preserve stable rule IDs and confidence labels.
- Do not silently remove or weaken a rule; supersede it with a dated note.
- Re-run `references/SCENARIO_TESTS.md` after material changes.

---

## 8. QA

- 131 detailed rules.
- 20 platform behaviours with version and confidence scope.
- Eight scenario tests passed (behavioural desk tests with independent agents).

The scenario tests are in `references/SCENARIO_TESTS.md`.

---

## 9. License and disclaimer

MIT. See the repository `LICENSE`.

Mendix is a trademark of Mendix Technology B.V. This project is independent and not
affiliated with or endorsed by Mendix.
