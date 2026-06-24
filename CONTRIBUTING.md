# Contributing to contAInuity

Thanks for your interest in improving this plugin. It's small on purpose — the value is
the checklist plus the two disciplines, parameterized by "which doc is yours." Changes
that keep it lean are the most welcome.

## Ground rules

- **The two disciplines are the point.** Don't weaken "source-verify before you etch" or
  "no chat in the doc." If you change the `checkpoint` skill, preserve the red-flags and
  rationalization table that make those disciplines hold under pressure.
- **Keep it dependency-free.** The hooks are plain POSIX-ish `bash` with no `jq`/Python
  requirement. Please keep them that way so the plugin runs anywhere.
- **Keep the manifest name kebab-case** (`containuity`). The stylized `contAInuity` is for
  prose only.

## Local development

Load the plugin without installing it:

```bash
claude --plugin-dir .
# then: /containuity:checkpoint
```

Run `/reload-plugins` after edits to pick up changes.

## Before opening a PR

Run the checks CI will run:

```bash
./scripts/validate.sh        # structure + JSON + frontmatter + exec bits
shellcheck hooks/*.sh scripts/*.sh
claude plugin validate .     # if you have the Claude Code CLI
```

Then:

1. Update `CHANGELOG.md` under `[Unreleased]`.
2. Bump `version` in `.claude-plugin/plugin.json` (and `marketplace.json`) if the change
   is user-visible. See [SemVer](https://semver.org/).
3. Describe what you changed and why in the PR, and how you verified it.

## Testing skill behavior

The disciplines were validated with RED/GREEN subagent pressure tests (a stale docstring
that contradicts the code, under "don't open files" pressure). If you change Discipline A,
please re-run an equivalent pressure scenario and report baseline-vs-skill results in the PR.

## Reporting bugs / ideas

Use the issue templates. Include your Claude Code version (`claude --version`), OS, and the
relevant `.checkpoint.config` (redact anything private).
