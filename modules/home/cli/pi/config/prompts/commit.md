---
description: Stage and commit changes with an appropriate message
argument-hint: "[scope-or-message-hint]"
---
Stage and commit all relevant changes made in this session.

## Steps

1. Run `git status` and `git diff HEAD` to review current state
2. Run `git log --oneline -10` to match the repo's commit message style
3. Stage all relevant changed and untracked files — skip files that contain secrets (`.env`, credentials, etc.) and warn if found
4. Write a concise commit message that summarizes the changes and focuses on _why_ not _what_, matching the repo's existing style. If `$ARGUMENTS` is provided, treat it as a scope/style hint
5. Create the commit and verify with `git status`

## Rules

- If there are no changes, say so and stop
- Do NOT push to remote
- Do NOT use `--no-verify`, `--force`, or `--amend`
- If commit fails from a pre-commit hook, fix the issue and create a new commit
