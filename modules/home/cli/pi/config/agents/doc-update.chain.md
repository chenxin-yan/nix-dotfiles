---
name: doc-update
description: Map documentation gaps from recent changes, then update docs to match implementation
---

## scout

Map documentation gaps relevant to: {task}

If no scope is given, derive it from `git diff main...HEAD` or `git log --oneline -10`.

## worker

Update documentation based on the gap list. Documentation only — do not modify code.

Context: {task}
