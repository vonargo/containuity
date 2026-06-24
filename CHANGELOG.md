# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-06-24

### Added
- `homepage` and `repository` fields in the plugin manifest for discoverability.
- `PRIVACY.md` privacy policy (the plugin collects no data), linked from `SECURITY.md`.

## [0.1.0] - 2026-06-24

### Added
- Initial release of the **contAInuity** (`containuity`) checkpoint-workflow plugin.
- `checkpoint` skill (`/containuity:checkpoint`) performing a four-step checkpoint:
  commit (matching the repo's inferred convention), save durable memories, refresh a
  source-verified living doc, and emit a post-compaction rehydrate go-block.
- Two disciplines baked into the skill: **source-verify before you etch** and
  **no chat in the doc**, with red-flags and a rationalization table.
- Optional hooks: `PreCompact` nudge (blocks auto-compaction once per session to
  prompt a checkpoint) and `SessionStart` rehydrate reminder.
- Per-seat configuration via `.checkpoint.config` (`checkpoint.config.example` template).
- README, worked EXAMPLE, MIT LICENSE, and a local validation script.

[Unreleased]: https://github.com/vonargo/containuity/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/vonargo/containuity/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/vonargo/containuity/releases/tag/v0.1.0
