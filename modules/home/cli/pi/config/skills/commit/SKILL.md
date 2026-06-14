---
name: commit
description: Stage and commit changes with a Conventional Commits message. Matches the repo's existing style, writes a structured subject and body, and commits without push/force/amend. Use whenever the user wants to commit, ship, save progress, or close out a task — including "commit this", "make a commit", "commit the changes", or "/skill:commit".
---

# Commit

Make one or more commits for the current session's changes. Your job is
to actually commit, not describe what a commit would look like.

If the user appends free-form text (e.g. `/skill:commit auth refactor`),
treat it as a hint about scope — but the diff is the source of truth.

The rule against rewriting published history lives in AGENTS.md.

## Workflow

1. **Survey changes.** `git status` + `git diff HEAD`. If nothing has
   changed, say so and stop.
2. **Match style.** `git log --oneline -10` — pick up the repo's scope
   vocabulary and subject phrasing.
3. **Handle secrets.** Skip anything that looks like credentials
   (`.env`, `*.pem`, `id_rsa`, files with API keys or tokens) and warn
   the user. Don't stage them.
4. **Write the message** (format below).
5. **Commit and verify.** Stage relevant paths, `git commit -m "..."`,
   then `git status` to confirm a clean tree (or surface what was left
   unstaged deliberately).

## Message format

`type(scope): subject` + blank line + body explaining **what** and
**why** (the diff already shows how).

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`,
`build`, `ci`, `style`. Match recent commits for scope vocabulary and
phrasing.

Skip the body only for trivially obvious changes (typo, pure
formatting). Behaviour changes, refactors, and anything someone might
`git blame` later deserve a body.

Footers when applicable: `Fixes #N` / `Closes #N`,
`BREAKING CHANGE: <description>`, `Co-authored-by: Name <email>`.

## Splitting commits

If the diff mixes clearly unrelated work (e.g. a feature + an unrelated
bugfix + formatting), prefer multiple commits over one sprawling
message. Stage and commit each logical group in turn, each with its own
subject and body. Ask the user first when in doubt.

## Skill-specific rules

- **Local commits only.** No `git push`.
- **No bypassing pre-commit hooks** with `--no-verify`. If a hook
  fails, read its output, fix the cause, re-commit.
- **No `--amend`.** If the user wants to amend or rewrite a commit,
  that's a different operation and they should ask for it explicitly.
