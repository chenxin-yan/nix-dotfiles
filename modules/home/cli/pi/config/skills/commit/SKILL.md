---
name: commit
description: Stage and commit changes with a Conventional Commits message. Detects jj vs git, matches the repo's existing style, writes a structured subject and body, and commits without push/force/amend. Use whenever the user wants to commit, ship, save progress, or close out a task — including "commit this", "make a commit", "commit the changes", or "/skill:commit".
---

# Commit

Make one or more commits for the current session's changes. Your job is
to actually commit, not describe what a commit would look like.

If the user appends free-form text (e.g. `/skill:commit auth refactor`),
treat it as a hint about scope — but the diff is the source of truth.

VCS detection (jj vs git) and the rule against rewriting published
history live in AGENTS.md; this skill assumes you've already picked the
right one.

## Workflow

1. **Survey changes.** `git status` + `git diff HEAD`, or `jj st` +
   `jj diff`. If nothing has changed, say so and stop.
2. **Match style.** `git log --oneline -10` or
   `jj log -n 10 --no-graph` — pick up the repo's scope vocabulary and
   subject phrasing.
3. **Handle secrets.** Skip anything that looks like credentials
   (`.env`, `*.pem`, `id_rsa`, files with API keys or tokens) and warn
   the user. On git, don't stage them. On jj, commit the safe paths
   with `jj commit <paths> -m "..."` so the secrets roll forward into
   the new working-copy commit instead of being recorded.
4. **Write the message** (format below).
5. **Commit and verify.**
   - git: stage relevant paths, `git commit -m "..."`, then
     `git status` to confirm a clean tree (or surface what was left
     unstaged deliberately).
   - jj: `jj commit -m "..."` — this finalizes `@` and opens a fresh
     empty working-copy commit. Then `jj st` to confirm `@` is empty.

> `jj describe` only edits the description on `@` without opening a new
> change. Prefer `jj commit` here — it's the direct analog of
> `git commit -a`.

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
message. Ask the user first when in doubt.

- git: stage and commit each logical group in turn, each with its own
  subject and body.
- jj: `jj commit <paths> -m "..."` per group — unselected files roll
  forward into the next working-copy commit, so you keep narrowing. For
  hunk-level splits, `jj split -i` is the right tool; hand it to the
  user to drive interactively.

## Skill-specific rules

- **Local commits only.** No `git push`, no `jj git push`.
- **No bypassing git pre-commit hooks** with `--no-verify`. If a hook
  fails, read its output, fix the cause, re-commit. (jj has no
  pre-commit hooks even in colocated repos — run formatters via
  `jj fix` or by hand.)
- **No `--amend`, no `jj squash`/`jj describe` to rewrite a commit
  here.** If the user wants to amend or rewrite, that's a different
  operation and they should ask for it explicitly.
