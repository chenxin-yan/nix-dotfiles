---
description: Find documentation discrepancies from code changes
agent: build
model: anthropic/claude-haiku-4-5
subtask: true
---

Analyze code changes and identify any documentation that is out of sync. **Report findings only — do NOT edit any files.**

## Current state

Git status:
!`git status`

Unstaged changes:
!`git diff`

Staged changes:
!`git diff --cached`

Last commit diff:
!`git diff HEAD~1 HEAD`

Recent commits (for context):
!`git log --oneline -5`

## Scope

The user may specify a scope via arguments: **$ARGUMENTS**

If arguments are provided, run `git diff $ARGUMENTS` to get the relevant changes and use that as your primary diff to analyze instead of the defaults above. Examples:
- `/sync-docs` — use the unstaged diff shown above
- `/sync-docs --cached` — staged changes
- `/sync-docs HEAD~3` — last 3 commits
- `/sync-docs main..HEAD` — changes since diverging from main
- `/sync-docs abc123` — changes since a specific commit

If no arguments are given, default to the unstaged diff. If there are no unstaged changes, fall back to the last commit.

## Steps

1. **Understand the changes** — read the relevant diff carefully. Identify what changed: functions, APIs, behavior, config, schemas, CLI flags, etc.
2. **Find related documentation** — search the codebase for any documentation that references or describes the changed code. This includes READMEs, docstrings, JSDoc, inline comments, API docs, config guides, setup instructions, or any other form of documentation.
3. **Evaluate each doc** — for every documentation artifact you find, determine if it is still accurate given the changes.
4. **Report discrepancies** — for each outdated doc, report:
   - The file path and line number(s)
   - What is stale and why
   - What the correct content should be (as a before/after suggestion)
5. **Summarize** — give a brief summary listing all discrepancies found, or state that all docs are up to date.

## Rules

- NEVER edit any files — this is a read-only exploration task
- NEVER commit or push changes
- If there are no changes in the diff, say so and stop
- If all docs are already up to date, say so and stop
- NEVER propose changes to auto-generated files (e.g. CHANGESETs, lock files, build artifacts, generated types). These are maintained by tooling, not humans.
