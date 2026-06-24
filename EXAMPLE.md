# Worked example: one checkpoint run

A run of `/containuity:checkpoint` near the end of a thread, in a repo whose
`.checkpoint.config` sets `LIVING_DOC=docs/DESIGN.md`, `MEMORY_DIR=.claude/memory`,
`COMMIT_MODE=offer`. The user just finished wiring a retry layer onto an HTTP client.

---

**User:** `/checkpoint wrapped up the retry work`

**Claude** *(skill loads; config + git state auto-injected)*:

Config: `LIVING_DOC=docs/DESIGN.md`, `MEMORY_DIR=.claude/memory`, `COMMIT_MODE=offer`,
`COMMIT_CONVENTION=infer`. Running the four-step checkpoint.

### 1. Commit — *offer*

Outstanding: `src/http/client.ts`, `src/http/retry.ts`, `test/retry.test.ts`.
The log uses imperative subjects, scope prefixes, and **no** co-author trailer — I'll match that.

Proposed (not committed — `COMMIT_MODE=offer`):

```
http: add exponential backoff retry to client

Wrap request() in a retry layer (max 5, jittered backoff). Retries 429/503 only.
```

Approve and I'll commit as-is, or tell me to adjust. *(waits)*

### 2. Save memories

Wrote `.claude/memory/retry-backoff-choice.md` — a decision + why, not derivable from code:

```markdown
---
name: retry-backoff-choice
description: Why the HTTP client retries with jittered exponential backoff, 429/503 only
metadata: { type: project }
---
Decision: client retries use jittered exponential backoff, max 5 attempts, only on
429/503. Why: the upstream 429s in bursts; fixed-delay retries synchronized our
clients and made it worse. Jitter de-correlates. We deliberately do NOT retry 500 —
those were non-idempotent writes. See [[http-idempotency-rule]].
```

Added to `.claude/memory/MEMORY.md`:
`- [retry-backoff-choice](retry-backoff-choice.md) — why backoff is jittered + 429/503 only`

### 3. Refresh the living doc — *source-verified*

Before editing `docs/DESIGN.md` I **opened the source** rather than trusting memory:

- Claim: "retry layer wraps `request()`." → checked `src/http/client.ts:88` — confirmed, the
  retry wrapper is on `request()`, not on the lower-level `send()`. ✅ etched as fact.
- Claim: "circuit breaker trips after retries exhaust." → checked `src/http/retry.ts` — **no
  breaker exists yet**; it was only discussed. ✋ recorded as intent, not fact:

```markdown
## HTTP client
- **Decision:** `request()` retries 429/503 with jittered exponential backoff (max 5).
  **Why:** upstream bursts 429s; jitter de-correlates clients. (src/http/retry.ts)
- **Planned:** circuit breaker once retries exhaust. Not implemented yet.
```

(No transcript pasted in — just the labeled claims and the why. Disciplines A + B.)

### 4. Rehydrate go-block — *skipped*

Context is ~30% full; compaction is not near. Skipping step 4. (Had a PreCompact nudge fired,
I'd append a `## Rehydrate` go-block to the top of `docs/DESIGN.md` instead.)

---

**Checkpoint summary:** commit staged & proposed (awaiting your OK) · 1 memory written ·
DESIGN.md "HTTP client" section refreshed and source-verified (breaker corrected from
fact→planned) · go-block skipped (compaction not near).

---

## What a go-block looks like (step 4, when compaction *is* near)

Appended under `## Rehydrate` at the top of `LIVING_DOC`:

```markdown
## Rehydrate — go block (2026-06-24, before auto-compaction)
- **State now:** retry layer done & committed (`a1b9f2c`, branch `feat/retry`). Breaker NOT started.
- **Next action:** implement the circuit breaker in `src/http/retry.ts`, tripping after max retries.
- **Watch out:** retries are on `request()`, not `send()` — put the breaker at the same level.
- **Pointers:** `src/http/retry.ts`, memory `retry-backoff-choice`, DESIGN.md "HTTP client".
```

One read after compaction and the next session is back on its feet.
