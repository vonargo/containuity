# Privacy Policy

_Last updated: 2026-06-24_

**contAInuity (`containuity`) collects no data.**

This plugin runs entirely on your local machine inside Claude Code. It does not collect,
store, transmit, sell, or share any personal data or usage information.

## What the plugin does locally

- **Hook scripts** (`hooks/*.sh`) run on the `PreCompact` and `SessionStart` events. They
  read the hook payload Claude Code provides on stdin and write a small JSON response to
  stdout. The `PreCompact` hook writes a single empty marker file to your system temp
  directory (`$TMPDIR`) to avoid nudging more than once per session. Nothing leaves your
  machine.
- **The `checkpoint` skill** acts only within your project when you invoke it: it may run
  `git` commands, read source files, and write to your living doc and memory directory.
  By default it offers commits rather than making them, and it never pushes.

## No network, no telemetry, no third parties

The plugin makes no network requests, includes no analytics or telemetry, and bundles no
third-party services. Any data handling that happens during a session is performed by
Claude Code itself, governed by Anthropic's own privacy terms — not by this plugin.

## Contact

Questions about this policy: **william.ford.space@gmail.com**.

## Changes

If this ever changes (for example, if a future version adds an integration that sends
data anywhere), this document and the version history will be updated to say so explicitly.
