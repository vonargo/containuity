#!/usr/bin/env bash
# SessionStart (matcher: compact|resume) — after a compaction or on resume,
# inject a short reminder to rehydrate from the go-block and to checkpoint at
# the next breakpoint. SessionStart supports additionalContext injection.
#
# Input: JSON on stdin (source = "compact" | "resume" | ...).

input=$(cat 2>/dev/null || true)

src=$(printf '%s' "$input" \
  | grep -o '"source"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed 's/.*"\([^"]*\)"[[:space:]]*$/\1/')
[ -n "$src" ] || src="resumed"

msg="Continuity: this session ${src}. If a Rehydrate go-block exists in your living doc (see .checkpoint.config LIVING_DOC) or memory, read it now to recover current state before acting. At the next clean breakpoint, run /containuity:checkpoint."

# The message contains no quotes/newlines/backslashes, so it is JSON-safe as-is.
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$msg"

exit 0
