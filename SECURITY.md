# Security

## Scope

MendixND is an instruction-only Agent Skill. It contains Markdown guidance and templates; it
does not execute code when the skill is loaded. The repository installers (`install.ps1`,
`install.sh`) only copy the skill directory.

## Reporting

If you find a security issue in the repository, use GitHub's private vulnerability reporting
for this repository (Security → Report a vulnerability). Do not open a public issue for a
vulnerability that could expose users.

## Using third-party skills safely

- Review `SKILL.md` and any referenced files before installing a skill from any source.
- Prefer `gh skill preview` or a manual repository review.
- Be cautious with skills that pre-approve shell tools or contain executable scripts.
- MendixND does not set `allowed-tools`; tool permissions remain under the host's control.
- Do not add credentials, tokens, client data, or internal URLs to the skill.

## Publication

Before publishing a fork, review `PUBLICATION_CHECKLIST.md` and remove any client-specific or
confidential material.
