# Publication Checklist

Use this before making the repository public.

---

## 1. Decide the publication boundary

This workspace contains:

- `skills/mendixnd/` — the reusable skill (intended for publication).
- `README.md`, `HARNESSES.md`, installers — repository scaffolding.
- `MENDIX_AI_DEVELOPMENT_LEARNINGS.md` and `Retrospective/` — the source audit trail.

The `.gitignore` excludes the retrospective and the consolidated report. Keep it that way
unless you have reviewed them for client-sensitive information and have approval to publish.

**Recommended:** publish the skill repo separately from the retrospective. Keep the
retrospective in a private repo or local archive.

---

## 2. Review for sensitive content

Search the skill for:

- client/organization names and project names;
- real user names, email addresses, domains, or credentials;
- internal module/entity names that reveal business logic;
- security findings that could expose a live system;
- version numbers and deployment details;
- screenshots, logs, or database content.

Commands:

```bash
rg -n -i "osa|consult|client|internal|password|secret|token|@|https?://" skills/mendixnd
rg -n "MENDIX_AI_DEVELOPMENT_LEARNINGS|Retrospective" .
```

The skill intentionally uses OSA examples as illustrations. If OSA/client details are
sensitive, replace them with generic names such as `Example_Detail`, `WorkItem`, or
`Module.Entity` before publishing.

---

## 3. Choose a license

The repository includes MIT as a permissive default. Confirm that you own the work and that MIT
is appropriate. If the skill was created for an employer or client, check their IP and
open-source policy before publishing. Replace `LICENSE` if needed.

---

## 4. Validate the skill

### Agent Skills format

```bash
npx skills add ./skills/mendixnd --list
```

or validate with the reference library:

```bash
npx skills-ref validate ./skills/mendixnd
```

Check:

- `name: mendixnd` is lowercase and matches the directory;
- `description` is present and under 1024 characters;
- `SKILL.md` is directly inside `skills/mendixnd`;
- references use relative paths;
- no broken links;
- no duplicate skill IDs.

### Install tests

Test at least:

```bash
npx skills add <owner>/<repo> --skill mendixnd --list
npx skills add <owner>/<repo> --skill mendixnd -g -a opencode --copy -y
npx skills add <owner>/<repo> --skill mendixnd -g -a claude-code --copy -y
npx skills add <owner>/<repo> --skill mendixnd -g -a codex --copy -y
npx skills add <owner>/<repo> --skill mendixnd -g -a github-copilot --copy -y
```

Then verify in each harness:

- the skill appears;
- explicit invocation works;
- the model reads `SKILL.md`;
- a reference is loaded only when relevant;
- removing the skill works.

### GitHub CLI

```bash
gh skill preview <owner>/<repo> mendixnd
gh skill publish --dry-run
```

---

## 5. Repository hygiene

- [ ] `README.md` explains what, why, install, use, compatibility, security, license.
- [ ] `HARNESSES.md` covers OpenCode, Claude Code, Codex, Copilot.
- [ ] `install.ps1` and `install.sh` are reviewed and tested.
- [ ] `LICENSE` is present and correct.
- [ ] `.gitignore` excludes the retrospective and source analysis.
- [ ] No secrets, tokens, credentials, logs, or client data.
- [ ] No generated caches or editor files.
- [ ] `CHANGELOG.md` records the version.
- [ ] The skill version in `SKILL.md` metadata matches the release tag.

---

## 6. Create the GitHub repository

Start private:

```bash
git init
git add .
git commit -m "feat: add MendixND cross-harness skill"
gh repo create mendixnd --private --source=. --remote=origin --push
```

If the repository already exists:

```bash
git remote add origin https://github.com/<owner>/mendixnd.git
git branch -M main
git push -u origin main
```

After validation, make it public from the GitHub repository settings.

---

## 7. Tag and release

```bash
git tag -a v1.1.0 -m "MendixND 1.1.0: cross-harness Agent Skill"
git push origin v1.1.0
gh release create v1.1.0 --title "MendixND 1.1.0" --notes-from-tag
```

Use semantic versions:

- **Major:** breaking rule/knowledge changes or invocation changes.
- **Minor:** new references/rules/harness support.
- **Patch:** corrections, evidence updates, typo fixes.

---

## 8. Post-publication

- [ ] Verify the install commands in the README work from a clean machine.
- [ ] Test one explicit invocation per harness.
- [ ] Add repository topics: `mendix`, `agent-skills`, `opencode`, `claude-code`, `codex`,
      `github-copilot`, `ai-agents`.
- [ ] Add a short description and website link if desired.
- [ ] Watch issues for harness-specific path changes.
- [ ] Keep `skills/mendixnd` the single canonical copy.
- [ ] Review the skill when Mendix or a harness changes its skill format.

---

## 9. What not to publish

- The retrospective without review.
- Client names, internal findings, screenshots, logs, or database content.
- Credentials, API keys, tokens, or connection strings.
- Internal URLs, hostnames, or deployment details.
- Third-party Marketplace assets you do not have rights to redistribute.
