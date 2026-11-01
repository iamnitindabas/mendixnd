# Harness Setup

MendixND follows the [Agent Skills](https://agentskills.io/specification) standard. The canonical
skill directory is `skills/mendixnd`. Installers copy that directory into each harness's
discovery path.

The **skill ID is `mendixnd`** — lowercase, matching the directory name. The display name is
**MendixND**.

---

## Quick comparison

| Harness | Discovery | Explicit invocation | Auto-load | Reload |
|---|---|---|---|---|
| OpenCode | `~/.config/opencode/skills/`, `.opencode/skills/`, plus `.agents/skills/` / `.claude/skills/` compatibility | `@mendixnd` | Yes | Config reload / restart |
| Claude Code | `~/.claude/skills/`, `.claude/skills/` | `/mendixnd` | Yes | Automatic file watch; `/reload-skills` if directory is new |
| OpenAI Codex | `~/.agents/skills/`, `.agents/skills/` | `$mendixnd` or `/skills` | Yes | Automatic; restart if not detected |
| GitHub Copilot | `~/.copilot/skills/`, `~/.agents/skills/`; project `.github/skills/`, `.claude/skills/`, `.agents/skills/` | `/mendixnd` or `/skills` | Yes | `/skills reload` in CLI |
| Other Agent Skills clients | Usually `.agents/skills/` or a client-specific path | Client's skill picker / mention | Varies | See client docs |

---

## OpenCode

### Install

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g -a opencode
```

Or copy manually:

```text
Global:  ~/.config/opencode/skills/mendixnd/
Project: .opencode/skills/mendixnd/
```

OpenCode also reads these compatibility locations:

```text
Global:  ~/.claude/skills, ~/.agents/skills
Project: .claude/skills, .agents/skills
```

`npx skills add` may install to `.agents/skills` for project scope; OpenCode discovers it as a
compatibility source. A native `.opencode/skills` copy is also valid.

### Invoke

```text
@mendixnd
```

### Notes

- OpenCode advertises the skill's name and description; the model loads `SKILL.md` when relevant.
- The `skills` array in `opencode.json` can register additional local or HTTP catalog sources.
- Do not set `metadata.opencode/autoinvoke: false` if you want auto-discovery.

---

## Claude Code

### Install

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g -a claude-code
```

Or copy manually:

```text
Personal: ~/.claude/skills/mendixnd/
Project:  .claude/skills/mendixnd/
```

### Invoke

```text
/mendixnd
```

### Notes

- Claude Code follows the same Agent Skills standard and adds optional features such as
  `context: fork`, hooks, and `disable-model-invocation`.
- MendixND uses only standard frontmatter, so it remains portable.
- Claude Code watches skill directories; if you create a new top-level skills directory during
  a session, run `/reload-skills`.
- Project skills should be committed so the team gets them.

---

## OpenAI Codex

### Install

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g -a codex
```

Or copy manually:

```text
Personal: ~/.agents/skills/mendixnd/
Project:  .agents/skills/mendixnd/
```

### Invoke

```text
$mendixnd
```

or open `/skills` and select MendixND.

### Notes

- Codex reads `agents/openai.yaml` for display metadata and invocation policy.
- `policy.allow_implicit_invocation: true` lets Codex choose the skill when the task matches.
  Set it to `false` if you want explicit `$mendixnd` invocation only.
- Codex scans `.agents/skills` from the current directory up to the repository root.
- Restart Codex if a newly installed skill does not appear.

---

## GitHub Copilot

### Install

```bash
gh skill install iamnitindabas/mendixnd mendixnd
```

Or use `npx skills`:

```bash
npx skills add iamnitindabas/mendixnd --skill mendixnd -g -a github-copilot
```

Or copy manually:

```text
Personal: ~/.copilot/skills/mendixnd/   (or ~/.agents/skills/mendixnd/)
Project:  .github/skills/mendixnd/      (or .claude/skills/, .agents/skills/)
```

### Invoke

```text
/mendixnd
```

or:

```text
Use the /mendixnd skill to inspect this Mendix project.
```

### Notes

- Copilot CLI supports `/skills list`, `/skills info`, `/skills reload`, and `/skills add`.
- `gh skill` is a public preview; update GitHub CLI to 2.90.0 or later.
- `gh skill preview iamnitindabas/mendixnd mendixnd` lets you inspect before installing.
- Copilot cloud agent and code review also read project skills from supported locations.
- Personal skills in `~/.copilot/skills` or `~/.agents/skills` are not automatically available in
  every cloud surface; check the surface's setup guide.

---

## Other Agent Skills clients

The skill should work with any client that implements the Agent Skills standard:

- Cursor
- Gemini CLI
- Windsurf
- Cline
- Roo Code
- Kiro CLI
- Amp
- OpenHands
- and others

Most use `.agents/skills/` for project skills. Use the client's own documentation for the
personal path and invocation syntax. The frontmatter deliberately uses only standard fields so
the skill remains portable.

---

## One canonical copy

Do not maintain four hand-edited copies. Edit:

```text
skills/mendixnd/
```

Then install or sync it to the harnesses. If you use symlinks, keep one canonical source and link
each harness directory to it. On Windows, copying is often safer unless Developer Mode or
administrator privileges are available.

---

## Validation checklist

For each harness:

1. Install the skill.
2. Confirm it appears in the skill list.
3. Invoke it explicitly.
4. Ask a Mendix page/domain question and check that it uses the native-first reasoning.
5. Confirm it reads a reference file only when relevant.
6. Remove/reinstall and verify the update.

If a harness silently ignores the skill, check:

- `name` is lowercase and matches the directory name;
- `SKILL.md` is directly inside the skill directory;
- the description is present and under the client's limit;
- the skill is in a supported location;
- the harness has been reloaded;
- for Copilot, `name` contains only lowercase letters, numbers, and hyphens.
