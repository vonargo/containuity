#!/usr/bin/env bash
# Lightweight, dependency-free structural validation for the containuity plugin.
# Mirrors the checks CI runs. Does not replace `claude plugin validate` (run that too
# if you have the CLI) — this works without it.
#
# Usage: ./scripts/validate.sh   (run from the repo root)

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
err()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }

# Pick a JSON validator: prefer python3, fall back to jq.
json_check() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$1" 2>/dev/null
  elif command -v jq >/dev/null 2>&1; then
    jq empty "$1" >/dev/null 2>&1
  else
    echo "no JSON validator (python3 or jq) available" >&2
    return 2
  fi
}

echo "Required files:"
for f in \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  skills/checkpoint/SKILL.md \
  hooks/hooks.json \
  hooks/precompact-nudge.sh \
  hooks/session-rehydrate.sh \
  README.md LICENSE
do
  [ -f "$f" ] && ok "$f" || err "missing $f"
done

echo "Valid JSON:"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  if json_check "$f"; then ok "$f"; else err "invalid JSON: $f"; fi
done

echo "Plugin name is kebab-case:"
name="$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' .claude-plugin/plugin.json | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  ok "name = $name"
else
  err "name \"$name\" is not kebab-case (lowercase letters, digits, hyphens)"
fi

echo "SKILL.md has YAML frontmatter:"
if head -1 skills/checkpoint/SKILL.md | grep -qx -- '---'; then
  ok "frontmatter present"
else
  err "SKILL.md must start with '---' frontmatter"
fi

echo "Hook scripts are executable:"
for f in hooks/precompact-nudge.sh hooks/session-rehydrate.sh scripts/validate.sh; do
  [ -x "$f" ] && ok "$f" || err "$f is not executable (chmod +x)"
done

echo "Hook scripts emit valid JSON:"
if printf '{"session_id":"ci","trigger":"auto"}' | ./hooks/precompact-nudge.sh | json_check /dev/stdin; then
  ok "precompact-nudge.sh"
else
  err "precompact-nudge.sh did not emit valid JSON"
fi
rm -f "${TMPDIR:-/tmp}/containuity-nudged-ci"
if printf '{"source":"compact"}' | ./hooks/session-rehydrate.sh | json_check /dev/stdin; then
  ok "session-rehydrate.sh"
else
  err "session-rehydrate.sh did not emit valid JSON"
fi

echo
if [ "$fail" -eq 0 ]; then
  printf '\033[32mAll checks passed.\033[0m\n'
else
  printf '\033[31mValidation failed.\033[0m\n'
fi
exit "$fail"
