#!/usr/bin/env bash
# Install the MendixND Agent Skill for one or more coding agents.
#
# Default: user-wide copy. Use --scope project for a repository-local install.
# Existing different content is not overwritten unless --force is supplied; a backup is kept
# outside the skills directory.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO_ROOT/skills/mendixnd"
SCOPE="user"
HARNESSES=()
FORCE=0
LINK=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --scope user|project     Install scope (default: user)
  --harness NAME           opencode | claude | codex | copilot | all
                           Repeatable, or comma-separated. Default: all
  --force                  Replace different existing content (backs it up first)
  --link                   Try symlink, fall back to copy
  --dry-run                Show what would happen
  -h, --help               Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --harness|--harnesses)
      IFS=',' read -r -a _parts <<< "${2:-}"
      for p in "${_parts[@]}"; do HARNESSES+=("$p"); done
      shift 2 ;;
    --force) FORCE=1; shift ;;
    --link) LINK=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ ${#HARNESSES[@]} -eq 0 ]]; then HARNESSES=(all); fi
if [[ ! -f "$SOURCE/SKILL.md" ]]; then
  echo "Canonical skill not found at $SOURCE" >&2
  exit 1
fi
if [[ "$SCOPE" != "user" && "$SCOPE" != "project" ]]; then
  echo "--scope must be user or project" >&2
  exit 2
fi

PROJECT_ROOT="$(pwd)"
if [[ "$SCOPE" == "user" ]]; then
  BASE_ROOT="$HOME"
else
  BASE_ROOT="$PROJECT_ROOT"
fi

# Expand "all" and deduplicate harnesses.
EXPANDED=()
for h in "${HARNESSES[@]}"; do
  case "$h" in
    all) EXPANDED+=(opencode claude codex copilot) ;;
    opencode|claude|codex|copilot) EXPANDED+=("$h") ;;
    *) echo "Unknown harness: $h" >&2; exit 2 ;;
  esac
done

# Build target list: harness|target|invoke
TARGETS=()
declare -A SEEN=()
add_target() {
  local harness="$1" target="$2" invoke="$3"
  local key
  key="$(printf '%s' "$target" | tr '[:upper:]' '[:lower:]')"
  if [[ -z "${SEEN[$key]:-}" ]]; then
    SEEN[$key]="$harness"
    TARGETS+=("$harness|$target|$invoke")
  else
    # Shared Codex/Copilot target: merge labels.
    local i
    for i in "${!TARGETS[@]}"; do
      if [[ "${TARGETS[$i]}" == *"|$target|"* ]]; then
        TARGETS[$i]="${SEEN[$key]} + $harness|$target|$invoke"
        break
      fi
    done
  fi
}

for h in "${EXPANDED[@]}"; do
  case "$h" in
    opencode)
      if [[ "$SCOPE" == "user" ]]; then t="$BASE_ROOT/.config/opencode/skills/mendixnd"; else t="$BASE_ROOT/.opencode/skills/mendixnd"; fi
      add_target "OpenCode" "$t" "@mendixnd" ;;
    claude)
      if [[ "$SCOPE" == "user" ]]; then t="$BASE_ROOT/.claude/skills/mendixnd"; else t="$BASE_ROOT/.claude/skills/mendixnd"; fi
      add_target "Claude Code" "$t" "/mendixnd" ;;
    codex)
      if [[ "$SCOPE" == "user" ]]; then t="$BASE_ROOT/.agents/skills/mendixnd"; else t="$BASE_ROOT/.agents/skills/mendixnd"; fi
      add_target "OpenAI Codex" "$t" "\$mendixnd or /skills" ;;
    copilot)
      if [[ "$SCOPE" == "user" ]]; then t="$BASE_ROOT/.agents/skills/mendixnd"; else t="$BASE_ROOT/.agents/skills/mendixnd"; fi
      add_target "GitHub Copilot" "$t" "/mendixnd or /skills" ;;
  esac
done

echo "MendixND installer"
echo "  source: $SOURCE"
echo "  scope:  $SCOPE"
echo "  mode:   $([[ $LINK -eq 1 ]] && echo 'link (fallback: copy)' || echo 'copy')"
echo

for entry in "${TARGETS[@]}"; do
  IFS='|' read -r harness target invoke <<< "$entry"
  exists=0
  [[ -e "$target" ]] && exists=1

  if [[ $exists -eq 1 ]]; then
    if diff -qr "$SOURCE" "$target" >/dev/null 2>&1; then
      echo "[skip] $harness: already up to date at $target"
      continue
    fi
    if [[ $FORCE -ne 1 ]]; then
      echo "[exists] $harness: different content at $target" >&2
      echo "         Re-run with --force to replace it." >&2
      continue
    fi
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] $harness: $([[ $exists -eq 1 ]] && echo update || echo install) at $target"
    continue
  fi

  mkdir -p "$(dirname "$target")"

  if [[ $exists -eq 1 && $FORCE -eq 1 ]]; then
    backup_root="$HOME/.mendixnd-backups"
    mkdir -p "$backup_root"
    backup="$backup_root/mendixnd-$(date +%Y%m%d-%H%M%S)-$(printf '%s' "$harness" | tr -cs '[:alnum:]' '-')"
    mv "$target" "$backup"
    echo "[backup] $target -> $backup"
  fi

  linked=0
  if [[ $LINK -eq 1 ]]; then
    if ln -s "$SOURCE" "$target" 2>/dev/null; then
      linked=1
      echo "[link] $harness: $target -> $SOURCE"
    else
      echo "[link] $harness: symlink failed; falling back to copy" >&2
    fi
  fi

  if [[ $linked -eq 0 ]]; then
    cp -R "$SOURCE" "$target"
    echo "[copy] $harness: $target"
  fi
  echo "       invoke: $invoke"
done

echo
echo "Done. Restart or reload the harness if the skill does not appear immediately."
