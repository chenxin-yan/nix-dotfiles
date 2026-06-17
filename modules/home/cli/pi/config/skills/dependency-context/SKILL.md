---
name: dependency-context
description: Ground facts about a third-party dependency by reading its actual source at the installed version, instead of recalling it from memory. Clones the upstream repo into .agent-sources/ (git-excluded), checks out the tag matching the installed version, then delegates read-only subagents to trace exact behavior. Use proactively while building — before calling an unfamiliar dependency API, relying on a signature/default/return type, or explaining how a library works — and whenever debugging behavior that originates inside a dependency. Prefer this over training knowledge, which drifts from the version a project actually has installed and invents APIs that don't exist.
---

# Dependency Context

Answer from the dependency's real source at the *installed* version, not from
memory. Training knowledge drifts between versions and invents plausible-looking
APIs that don't exist — so when the source is available, trace it; treat your
recollection of a library's internals as a guess to verify, never as fact.

When the source isn't available (can't clone, package not installed), fall back
to web search or official docs — but the actual code, when you can get it, wins.

## When to reach for this

- About to call a dependency API you're not 100% certain of — confirm the
  signature, defaults, return type, and errors against source before writing it.
- "How does `<library>` implement X?" / "Why does `<library>` do Y?"
- Debugging behavior that comes from inside a dependency, not your own code.

## Workflow

### 1. Identify the package and repo

Get the exact package name from context or `package.json`. The helper resolves
the upstream repo from package metadata. **If the repo can't be resolved or you're
unsure which one backs the package (forks, monorepos, renames), ask the user
before cloning** — the wrong repo grounds facts in the wrong code.

### 2. Set up the source at the matching version

Run from the project root:

```bash
bash <skill-dir>/scripts/setup-source.sh <package-name>
# optional: explicit repo URL and/or ref
bash <skill-dir>/scripts/setup-source.sh <package-name> <repo-url> --ref <git-ref>
```

It clones into `.agent-sources/<repo>/` (only if missing), adds `.agent-sources/`
to `.git/info/exclude`, reads the installed version, and checks out the matching
tag. Act on the first output line:

- `READY: <pkg> @ <ref> -> <dir>` — at the right version. Proceed.
- `ASK_REPO:` — repo unknown. Ask the user for the URL, rerun with it as arg 2.
- `ASK_REF:` — no tag matched the installed version (nearby tags are listed).
  Ask the user which ref to use, rerun with `--ref`. Don't default to `main`;
  a version mismatch is the staleness this skill exists to prevent.

### 3. Trace with read-only subagents

Don't read the whole repo into the main context. Delegate focused tracing to
read-only subagents (`pi-subagents` skill, e.g. `scout`), briefing each one:

- **Scope**: the one fact to ground (a behavior, default, type, edge case).
- **Where**: the checked-out path, e.g. `.agent-sources/<repo>/src/...`.
- **Read-only**: read/grep only; never edit under `.agent-sources/`.
- **Output**: the answer with file:line citations, so you can verify it.

Example: *Read-only. In `.agent-sources/<repo>/src`, trace how `<package>`'s
`<function>` handles `<edge case>`. Report control flow and the exact signature
with file:line citations. Do not edit any files.*

### 4. Synthesize and cite

Combine findings into the answer, citing source paths and the checked-out
version. If a fact is missing or subagents disagree, trace it yourself or say
so — don't fill the gap from memory.
