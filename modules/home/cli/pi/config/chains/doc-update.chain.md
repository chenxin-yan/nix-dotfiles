---
name: doc-update
description: Map documentation gaps from recent changes, then update docs to match implementation
---

## scout

Map documentation gaps relevant to: {task}

If no scope is given, derive it from recent changes. Detect VCS first: in jj
workspaces (`.jj/` exists or `jj root` exits 0) use `jj diff` against the trunk
bookmark and `jj log -n 10 --no-graph`; otherwise use `git diff main...HEAD` or
`git log --oneline -10`.

## worker

Update documentation based on the gap list. Documentation only — do not modify code.

Context: {task}
