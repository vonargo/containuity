---
name: checkpoint
description: Use at a clean breakpoint in long-running work — a finished unit of work, before a compaction, or the end of a thread — to preserve continuity across sessions and compactions. Also when the user types /checkpoint, or asks to checkpoint, save progress, snapshot state, or wrap up before context fills.
argument-hint: "[optional note about what this checkpoint covers]"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

# Checkpoint

Run this checklist at a clean breakpoint to hold continuity across sessions and compactions. **Perform each step — do not just print the checklist.** Create one todo per step (1–4) and work them in order.

## Seat configuration (auto-loaded)

```
!`cat .checkpoint.config 2>/dev/null || cat .claude/checkpoint.config 2>/dev/null || echo "NO_CONFIG"`
```

Resolve these keys from the block above (fall back to the defaults, and tell the user which you used):

| Key | Default | Meaning |
|-----|---------|---------|
| `LIVING_DOC` | `docs/DESIGN.md` | The source-verified "how" doc *you* keep non-stale. |
| `MEMORY_DIR` | `.claude/memory` | Where durable memories live (one fact per file + `MEMORY.md` index). |
| `COMMIT_MODE` | `offer` | `offer` = propose the commit and wait for OK. `auto` = commit without asking. |
| `COMMIT_CONVENTION` | `infer` | `infer` from git log, or a freeform note overriding it. |

If `NO_CONFIG`: use the defaults, name them to the user, and mention they can run the worked example in the plugin README to create `.checkpoint.config` once per seat.

## Current state (auto-collected)

Outstanding work:
```
!`git status --short 2>/dev/null || echo "not a git repo"`
```
Recent commits — infer author, message style, and co-author policy from these (do not impose your own):
```
!`git log -8 --pretty='format:%an <%ae> | %s' 2>/dev/null || echo "no git history"`
```

## The checklist

### 1. Commit outstanding work
- If there is nothing to commit, say so and skip.
- Match the repo's existing convention inferred from the log above: author, message style (imperative vs. scoped vs. conventional-commits), and co-author trailer policy. If the log shows no co-author trailers, do not add one; if it shows them, match the form.
- **`COMMIT_MODE=offer` (default):** stage the relevant changes, show the exact message you propose, and wait for approval. Do **not** commit until the user authorizes commits for this repo (in this session or via `COMMIT_MODE=auto`).
- **`COMMIT_MODE=auto`:** commit directly using the inferred convention.
- Never `git push` unless the user explicitly asks.

### 2. Save durable memories
- Write the **decisions and the why** — things not derivable from the code: why an approach was chosen over the alternative, a constraint discovered, a dead end ruled out, a non-obvious gotcha.
- Do **not** save what the repo already records (code structure, what a function does, git history).
- Write to `MEMORY_DIR`: one fact per file with a short slug name, then add a one-line pointer to `MEMORY_DIR/MEMORY.md` (the index). If a memory already covers the fact, update that file instead of duplicating. Convert relative dates ("yesterday") to absolute.

### 3. Refresh the living doc (`LIVING_DOC`)
Update it so it is **not stale**. This step is governed by the two disciplines below — apply them before writing anything.

### 4. Emit a rehydrate go-block — only if compaction is near
Skip if compaction is not imminent. If it is (context is filling, or a PreCompact nudge fired), append a fenced **GO BLOCK** anchored on *current* state so a post-compaction you can resume in one read. Put it where the next session will see it — top of `LIVING_DOC` under a `## Rehydrate` heading, or a memory file. Include:
- **State now:** what is done, what is in flight, the current branch/commit.
- **Next action:** the single next concrete step.
- **Watch out:** the one thing that will trip up a fresh context.
- **Pointers:** paths to the files and memories that matter.

Keep it short — it is a launch pad, not a transcript.

---

## The two disciplines (this is the actual point — bake them in)

### Discipline A — Source-verify before you etch
Before writing any claim into `LIVING_DOC`, **open the real code and confirm it — do not write from memory, from a docstring, or from a comment.** A docstring or comment is *not* source of truth; it is the exact thing that rots. Verify against the **code body**: the wire-up, the default, the call site, as you're about to describe it.

- **Opening the file is the required action, even under pressure.** "We're out of time", "don't open any more files", "you wrote it yesterday", "just use the docstring", "we're over budget" are *precisely* the moments stale claims get etched. Open it anyway — one Read is cheap; a lie in the doc costs a debugging session.
- Mark intent as intent, never as fact. A planned thing is "**Planned:** …" or "**Intended:** …", never a present-tense statement that it works.
- "Unverified" is a **last resort for genuinely unreachable source — not an excuse to skip a Read you could have done.** If you truly cannot reach the source, you may *not* state the claim as fact and you may *not* assert its direction. Attribute and label it: "**Unverified (per docstring, not confirmed against code):** …", or leave it out.

> Motivating failure: a stale docstring said a feature was "not wired" while the code wired it. A whole debugging session chased the wrong thing. Docs rot and mislead; verification is the fix.

### Discipline B — No chat in the doc
Decisions enter `LIVING_DOC` as **labeled claims**, never as conversation transcript.

- ✅ "**Decision:** retries use exponential backoff (max 5). **Why:** the upstream 429s in bursts."
- ❌ "I suggested backoff and you agreed it was better than a fixed delay, so then I…"

Pasting the back-and-forth in is the failure. Distill it to the claim and the why.

## Red flags — STOP

- "I'm pretty sure the code does X" → you didn't open the file. Open it (Discipline A).
- "I wrote this yesterday / the docstring says so / we're told not to open files" → that's the exact pressure that etches lies. Open the code body anyway.
- "I'll write it as done; it basically works" → intent dressed as fact. Label it Planned/Unverified.
- "Let me capture how we got here" → that's transcript. Distill to a labeled claim (Discipline B).
- "The doc's a bit off but close enough" → stale is the failure mode this whole skill exists to prevent. Fix it now.
- "Nothing to commit, so I'll skip the rest" → memories and the living doc are independent of commits. Do all four steps.

## Rationalization table

| Excuse | Reality |
|--------|---------|
| "I just read that code, I remember it" | Memory is what rots docs. Re-open the source before etching. |
| "I wrote this yesterday, I remember it" | Same trap. The docstring's author "remembered" too — and it was wrong. Re-open it. |
| "The docstring/comment says so" | Docstrings are the thing that goes stale — the motivating failure was a lying docstring. Verify the code body. |
| "I was told not to open files / we're over budget" | Then you may not state it as fact. Open it anyway, or label Unverified without asserting the claim's direction. |
| "It's obviously wired, no need to check" | The motivating failure was an "obvious" claim that was false. Check. |
| "Intent and fact are basically the same here" | They are not. A reader acts on present-tense claims. Label intent as intent. |
| "The conversation explains it best" | The reader doesn't have the conversation. A labeled claim + why survives compaction; a transcript doesn't. |
| "Compaction probably isn't that close" | If unsure, emit the go-block. It's cheap; losing state isn't. |
| "User didn't say I could commit" | Then `offer`, don't commit. Steps 2–4 still run. |

## When you finish
Report what you did per step (committed / memories written / doc sections refreshed and source-verified / go-block emitted or skipped) so the user can see the checkpoint actually ran.
