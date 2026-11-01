# Changelog

All notable changes to MendixND are recorded here.

## 1.1.0 — 2026-11-02

### Added

- Cross-harness packaging for the Agent Skills standard.
- Canonical lowercase skill ID `mendixnd` and directory `skills/mendixnd`.
- Harness setup for OpenCode, Claude Code, OpenAI Codex, and GitHub Copilot.
- `install.ps1` and `install.sh` for local/offline installation.
- `agents/openai.yaml` for Codex display metadata and implicit-invocation policy.
- `HARNESSES.md` with per-harness paths, invocation, reload, and validation.
- `PUBLICATION_CHECKLIST.md` for safe GitHub publication.
- Root repository README with `npx skills add` and `gh skill install` commands.

### Changed

- Skill metadata now uses the standard lowercase `name: mendixnd`.
- Frontmatter includes `license`, `compatibility`, and version metadata.
- Invocation examples are harness-specific:
  - OpenCode: `@mendixnd`
  - Claude Code: `/mendixnd`
  - Codex: `$mendixnd` or `/skills`
  - GitHub Copilot: `/mendixnd`
- README and skill README updated for cross-harness use.

### Preserved

- All 131 rules, 124 indexed findings, 15 root causes, 20 platform behaviours, 44 planning
  rules, 40 execution rules, and 21 unresolved questions.
- Original finding IDs and confidence classifications.
- The eight scenario test results.

## 1.0.0 — 2026-11-02

### Added

- Initial MendixND skill.
- Core principles, native-first guidance, domain, UI, logic, security, performance, mxcli/MDL,
  validation, AI failure patterns, known limitations, finding index, traceability, and scenario
  tests.
- Project engineering guidance template and initialization report template.
