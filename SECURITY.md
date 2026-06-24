# Security Policy

## Scope

This plugin runs inside Claude Code. Two parts execute on your machine:

- **Hook scripts** (`hooks/*.sh`) run automatically on `PreCompact` and `SessionStart`.
  They read hook JSON on stdin and write JSON to stdout. They do **not** make network
  calls, write outside a session-scoped sentinel file in `$TMPDIR`, or run untrusted input.
- **The `checkpoint` skill** can run `git` commands and edit files in your project when you
  invoke it. By default it **offers** commits rather than making them (`COMMIT_MODE=offer`)
  and never pushes.

As with any plugin, only install from a source you trust, and review the hook scripts
before enabling. See Claude Code's plugin security guidance for background.

For data handling, see [PRIVACY.md](PRIVACY.md) — the plugin collects nothing.

## Reporting a Vulnerability

Please report security issues privately to **william.ford.space@gmail.com** rather than
opening a public issue. Include steps to reproduce and the affected version. You can expect
an initial response within a few days.

## Supported Versions

This is an early-stage project; only the latest released version receives fixes.
