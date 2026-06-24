# contAInuity

[![CI](https://github.com/vonargo/containuity/actions/workflows/ci.yml/badge.svg)](https://github.com/vonargo/containuity/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Stylized **contAInuity**; the package and command name are kebab-case `containuity`
> (install as `containuity`, invoke as `/containuity:checkpoint`).

A Claude Code plugin that codifies a **checkpoint workflow** — the discipline a Claude
working a long-running project runs at clean breakpoints to hold continuity across
sessions and compactions.

Invoke it on demand with `/containuity:checkpoint`, or let Claude run it automatically
at a natural breakpoint (a finished unit of work, before a compaction, the end of a
thread). It *performs* a four-step checklist — it doesn't just print it:

1. **Commit** outstanding work, matching the repo's existing convention (author, message
   style, co-author policy — inferred from `git log`, not imposed). Offers rather than
   auto-commits unless you've authorized commits for the repo.
2. **Save memories** — durable decisions and the *why*, the things not derivable from code.
3. **Refresh the living doc** — the source-verified "how" doc the project keeps current.
   Never left stale.
4. **Emit a rehydrate go-block** if a compaction is near — a post-compaction "go" anchored
   on current state.

The two disciplines that are the actual point — people skip these, so the skill bakes
them in:

- **Source-verify before you etch.** Before writing a claim into the living doc, check it
  against the real code, not memory. Mark intent as intent, never as fact. (A stale
  docstring once said a feature was "not wired" while the code wired it — and misled a
  whole debugging session. Verification is the fix.)
- **No chat in the doc.** Decisions enter as labeled claims, never as conversation transcript.

## What's in the box

```
containuity/
├── .claude-plugin/plugin.json     # manifest
├── skills/checkpoint/SKILL.md      # the checklist + the two disciplines (the core)
├── hooks/
│   ├── hooks.json                  # PreCompact + SessionStart wiring
│   ├── precompact-nudge.sh         # nudges a checkpoint before auto-compaction (once/session)
│   └── session-rehydrate.sh        # after compaction/resume, reminds you to rehydrate
├── checkpoint.config.example       # per-seat config template
├── EXAMPLE.md                      # one worked run of all four steps
└── README.md
```

The skill is the core and works standalone. The hooks are optional polish.

## Install

This is a local/marketplace-style plugin directory. Two common ways to load it:

**A) As a plugin (gives `/containuity:checkpoint` + the hooks).**
Point Claude Code at the directory as a plugin source (via your plugin marketplace config
or `/plugin` install flow), then enable `containuity`. After enabling, `/reload-plugins`
picks up the hooks. Verify with `/plugin` (should list `containuity`) and by typing
`/containuity:` — the `checkpoint` skill should autocomplete.

**B) As a bare personal skill (gives `/checkpoint`, no hooks).**
If you'd rather have the un-namespaced command and skip the hooks, copy just the skill:

```bash
cp -r containuity/skills/checkpoint ~/.claude/skills/checkpoint
```

Then restart Claude Code (a brand-new top-level skills dir needs a restart to be watched)
and use `/checkpoint`.

> Plugin skills are always namespaced as `/<plugin>:<skill>`, so the plugin command is
> `/containuity:checkpoint`. Option B is the way to get a plain `/checkpoint`.

## Per-seat configuration

Configure once per project ("seat"). Copy the template to your repo root and edit:

```bash
cp containuity/checkpoint.config.example .checkpoint.config
```

| Key | Default | What it controls |
|-----|---------|------------------|
| `LIVING_DOC` | `docs/DESIGN.md` | Which "how" doc is *yours* to keep non-stale. |
| `MEMORY_DIR` | `.claude/memory` | Where durable memories are written (one fact/file + `MEMORY.md` index). |
| `COMMIT_MODE` | `offer` | `offer` waits for your OK; `auto` commits using the inferred convention. |
| `COMMIT_CONVENTION` | `infer` | `infer` from `git log`, or a freeform override note. |

No config file is required — without one the skill uses these defaults and tells you so.
The skill reads `.checkpoint.config`, falling back to `.claude/checkpoint.config`.

## How the hooks behave

- **`PreCompact` (auto only):** just before an *automatic* compaction, the hook blocks it
  **once per session** and tells Claude to run `/containuity:checkpoint` first. A per-session
  sentinel guarantees it fires at most once, so a session can never get wedged unable to
  compact. Manual `/compact` is never blocked.
- **`SessionStart` (compact|resume):** after a compaction or on resume, injects a short
  reminder to read the Rehydrate go-block and to checkpoint at the next breakpoint.

Both hooks are plain `bash` and need no dependencies (no `jq`). If you don't want them,
delete `hooks/` — the skill is unaffected.

## Verifying it works

```bash
# hooks emit valid JSON and the nudge fires once:
printf '{"session_id":"demo","trigger":"auto"}' | hooks/precompact-nudge.sh   # -> block JSON
printf '{"session_id":"demo","trigger":"auto"}' | hooks/precompact-nudge.sh   # -> empty (allow)
printf '{"source":"compact"}'                   | hooks/session-rehydrate.sh   # -> additionalContext JSON
rm -f "${TMPDIR:-/tmp}/containuity-nudged-demo"
```

See [EXAMPLE.md](EXAMPLE.md) for a worked run of all four steps.

## Built with AI assistance

This plugin was designed and written collaboratively with **Claude** (Anthropic's Claude
Code), and that's reflected honestly in the history: commits carry a `Co-Authored-By: Claude`
trailer. A human (the author above) directed the work, made the decisions, and is
responsible for what ships here. The plugin format was verified against the live Claude Code
docs, and the source-verification discipline at its core was validated with adversarial
subagent pressure tests rather than asserted. If you build on it, that provenance carries
forward — please keep it accurate.
