# MendixND

**Mendix-native-first engineering guidance for AI coding agents.**

MendixND is a reusable Agent Skill for Mendix projects. It helps an AI agent investigate the
Mendix platform and the existing project before writing custom CSS, JavaScript, Java, SQL, or a
custom widget. It also encodes the verification discipline that prevents "green gates, broken
app" delivery.

- **Skill ID:** `mendixnd`
- **Display name:** MendixND
- **Version:** 1.1.0
- **License:** MIT
- **Standard:** [Agent Skills](https://agentskills.io/specification)
- **Harnesses:** OpenCode, Claude Code, OpenAI Codex, GitHub Copilot, and other Agent Skills
  clients

> **Mendix-native first. Understand the platform before choosing an implementation approach.
> Custom implementation only when justified.**

---

## Why this exists

MendixND is distilled from practical Mendix delivery experience across domain modelling,
pages and widgets, microflows, security, performance, testing, mxcli/MDL, and AI-agent failure
patterns. It turns those lessons into:

- a native-first decision process,
- existing-project reuse discipline,
- domain/UI/logic/security/performance rules,
- conditional mxcli/MDL knowledge,
- verification and evidence gates,
- non-destructive project initialization,
- a project-specific guidance template.

It is not a project template and not a Mendix tutorial. Project-specific names, versions,
layouts, and architecture are examples, not universal rules.

---

## Install

### One command across harnesses

Requires Node.js 22.20 or later.

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g \
  -a opencode -a claude-code -a codex -a github-copilot
```

Use `-g` for a user-wide install, or omit it to install into the current project. Add
`--copy` if your environment does not support symlinks.

### Load from a link without installing

```bash
# Start an agent with the skill for one session
npx skills use iamnitindabas/mendixnd@mendixnd --agent opencode

# Or install directly from the skill folder in the repo
npx skills add https://github.com/iamnitindabas/mendixnd/tree/main/skills/mendixnd
```

### GitHub Copilot CLI

```bash
gh skill install iamnitindabas/mendixnd mendixnd
# or, for Claude Code:
gh skill install iamnitindabas/mendixnd mendixnd --agent claude-code --scope user
```

`gh skill` is in public preview and requires GitHub CLI 2.90.0+.

### Manual / offline

```powershell
# Windows
.\install.ps1 -Scope User -Harnesses all
```

```bash
# macOS / Linux
./install.sh --scope user --harness all
```

Or copy `skills/mendixnd` to the location for your harness:

| Harness | Global | Project | Invoke |
|---|---|---|---|
| OpenCode | `~/.config/opencode/skills/mendixnd/` | `.opencode/skills/mendixnd/` | `@mendixnd` |
| Claude Code | `~/.claude/skills/mendixnd/` | `.claude/skills/mendixnd/` | `/mendixnd` |
| OpenAI Codex | `~/.agents/skills/mendixnd/` | `.agents/skills/mendixnd/` | `$mendixnd` or `/skills` |
| GitHub Copilot | `~/.copilot/skills/mendixnd/` or `~/.agents/skills/mendixnd/` | `.github/skills/mendixnd/`, `.claude/skills/mendixnd/`, or `.agents/skills/mendixnd/` | `/mendixnd` or `/skills` |

See [HARNESSES.md](HARNESSES.md) for details and platform-specific notes.

---

## Use it

At the start of a Mendix project:

```text
@mendixnd
```

or, depending on the harness:

```text
/mendixnd
$mendixnd
```

Then ask the agent to initialize:

```text
Initialize MendixND for this project. Inspect the existing project, create the project
guidance, and do not modify AGENTS.md or any application artifact.
```

### What initialization does

1. Establishes Mendix version, MPR format, toolchain, database, and existing instructions.
2. Inspects modules, domain model, pages, logic, security, tests, and Marketplace modules.
3. Creates `docs/mendixnd/PROJECT_ENGINEERING_GUIDANCE.md` from the template.
4. Proposes the smallest additive pointer to that file; it does not overwrite `AGENTS.md`,
   `CLAUDE.md`, or OpenCode configuration.
5. Produces an initialization report and verifies that no application artifact changed.

It is idempotent: a second invocation detects existing guidance and reports drift instead of
overwriting it.

### During normal development

The agent should:

1. Understand the requirement.
2. Inspect existing project artifacts.
3. Scan native Mendix capabilities.
4. Evaluate reusable project and Marketplace components.
5. Consult the relevant MendixND reference.
6. Choose the simplest suitable implementation.
7. Verify unfamiliar platform/tooling behaviour.
8. Implement within the existing architecture.
9. Validate the actual outcome.
10. Report evidence, deviations, and residual risk.

The skill explicitly stops rather than improvising on destructive replay, client-trusted
authorization, ownership conflicts, unapproved architecture changes, or missing evidence.

---

## What is included

```text
skills/mendixnd/
├── SKILL.md
├── README.md
├── agents/openai.yaml
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

- 131 detailed rules across universal, conditional, toolchain, and AI-behaviour areas.
- 20 platform behaviours with version and confidence scope.
- Eight scenario tests passed (behavioural desk tests with independent agents).

---

## Cross-harness compatibility

The skill follows the Agent Skills standard: a directory with a lowercase `name`, a
`description`, and a `SKILL.md` body. Optional `references/` and `templates/` are read only
when needed.

| Feature | OpenCode | Claude Code | Codex | GitHub Copilot |
|---|---|---|---|---|
| Auto-discovery | Yes | Yes | Yes | Yes |
| Explicit invocation | `@mendixnd` | `/mendixnd` | `$mendixnd` / `/skills` | `/mendixnd` |
| Supporting files | Yes | Yes | Yes | Yes |
| `disable-model-invocation` | No | Yes | via `agents/openai.yaml` | Yes |
| `context: fork` | No | Yes | No | Experimental |

MendixND does not use harness-specific features that would break portability. `agents/openai.yaml`
adds Codex display metadata but is ignored by the other harnesses.

---

## Coexistence with mxcli and other tool skills

MendixND is the **engineering-decision layer**, not a competing tool manual.

- MendixND decides *whether* and *what constraints apply*: native-first, reuse, ownership,
  security, transactions, verification.
- A maintained mxcli/Studio Pro/MCP skill decides *exactly how* to invoke the tool: syntax,
  flags, version mechanics.
- Project guidance records local conventions and approved exceptions.

If a tool skill conflicts with `references/MXCLI_MDL.md` on mechanics, the tool skill wins.
If it conflicts on safety, ownership, or verification, MendixND wins. Record material
conflicts.

---

## Repository

Published at <https://github.com/iamnitindabas/mendixnd>.

To fork or republish, use GitHub's **Fork** button and replace `iamnitindabas/mendixnd` in the
install commands with your own `owner/repo`.

---

## Security

- The skill itself is Markdown; it contains no executable skill scripts.
- The repository installers only copy files. Review them before running.
- Skills are instructions, not verified code. Use `gh skill preview` or read the repository
  before installing from any source.
- See [SECURITY.md](SECURITY.md) for reporting and third-party skill safety.

---

## License

MIT. See [LICENSE](LICENSE).

Mendix is a trademark of Mendix Technology B.V. This project is independent and not
affiliated with or endorsed by Mendix.
