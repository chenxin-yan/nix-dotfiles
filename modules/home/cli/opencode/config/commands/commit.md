---
description: Stage and commit changes with an appropriate message
agent: build
model: anthropic/claude-haiku-4-5
subtask: true
---

Stage and commit all relevant changes made in this session.

## Current state

Git status:
!`git status`

Staged and unstaged diff:
!`git diff HEAD`

Recent commit messages (for style reference):
!`git log --oneline -10`

## Steps

1. Review the provided git status and diff above
2. Stage all relevant changed and untracked files — skip files that contain secrets (`.env`, credentials, etc.) and warn if found
3. Write a concise commit message that summarizes the changes and focuses on _why_ not _what_, matching the repo's existing style
4. Create the commit and verify with `git status`

## Rules

- If there are no changes, say so and stop
- Do NOT push to remote
- Do NOT use `--no-verify`, `--force`, or `--amend`
- If commit fails from a pre-commit hook, fix the issue and create a new commit
