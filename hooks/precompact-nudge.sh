#!/usr/bin/env bash
# PreCompact (matcher: auto) — nudge a checkpoint just before auto-compaction
# trims context. Blocks the FIRST auto-compaction per session and tells Claude
# to run /containuity:checkpoint; a sentinel makes it fire at most once per
# session, so the session can never get wedged unable to compact.
#
# Input: JSON on stdin (session_id, trigger, ...). Output: a block decision.
# PreCompact cannot inject additionalContext, so we use decision+reason.

input=$(cat 2>/dev/null || true)

# Extract session_id without requiring jq.
sid=$(printf '%s' "$input" \
  | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed 's/.*"\([^"]*\)"[[:space:]]*$/\1/')
[ -n "$sid" ] || sid="unknown"

sentinel="${TMPDIR:-/tmp}/containuity-nudged-${sid}"

if [ -e "$sentinel" ]; then
  # Already nudged this session — let compaction proceed normally.
  exit 0
fi

# Arm the sentinel so the next auto-compaction is not blocked.
touch "$sentinel" 2>/dev/null || true

cat <<'JSON'
{"decision":"block","reason":"Continuity: auto-compaction is imminent and context is about to be trimmed. Run /containuity:checkpoint now — commit outstanding work, save durable memories, source-verify and refresh the living doc, and emit a rehydrate go-block — then let compaction proceed. (This nudge fires once per session.)"}
JSON

exit 0
