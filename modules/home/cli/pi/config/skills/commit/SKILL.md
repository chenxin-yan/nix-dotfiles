---
name: commit
description: Stage and commit changes with a Conventional Commits message — detects whether the repo is jj or git, runs the appropriate status/diff/log, matches the repo's existing style, picks a type and scope, writes a structured subject and body, and commits without push/force/amend. Use whenever the user wants to commit work, finalize changes, ship or save progress, or close out a task with git or jj, even if they don't explicitly say "Conventional Commits". Also use when the user says things like "commit this", "make a commit", "commit the changes", or "/skill:commit".
---

# Commit

Commit all relevant changes for **current session** with a well-structured Conventional Commits
message. The user has invoked this skill because they want one or more
commits to be made now — your job is to actually make the commit, not
just describe what one would look like.

Works for both git and jj (Jujutsu) workspaces. Step 1 detects which one
and the rest of the workflow branches accordingly.

## When the user passes context

If the user appended free-form text to the invocation (e.g. `/skill:commit
auth refactor`, or "commit this, scope it to the parser"), treat it as a
**hint** about scope or framing. Honour it where it fits, but the diff
itself is the source of truth — don't force a misleading scope just
because the user suggested one.

## Workflow

1. **Detect the VCS.** If `.jj/` exists at the repo root (or `jj root`
   exits 0), follow the **jj path**. Otherwise follow the **git path**.
   Colocated repos have BOTH `.jj/` and `.git/` — `.jj/` wins, because
   the user is driving with jj.

### git path

1. `git status` and `git diff HEAD` to understand the full scope of
   changes.
2. `git log --oneline -10` to match the repo's existing commit style
   (scope conventions, subject phrasing, body length).
3. Stage relevant changed and untracked files. **Skip anything that looks
   like secrets** (`.env`, `*.pem`, `id_rsa`, files containing API keys
   or tokens) and surface a warning rather than committing them.
4. Write the commit message in the format below.
5. `git commit` with the full message, then `git status` to confirm a
   clean tree (or surface what was deliberately left unstaged).

If `git status` reports no changes at all, say so and stop — there is
nothing to commit.

### jj path

1. `jj st` and `jj diff` to understand the scope of changes in the
   current working-copy change (`@`).
2. `jj log -n 10 --no-graph` (or any revset that covers recent history)
   to match the repo's existing commit style.
3. **No staging step.** jj already tracks every working-copy edit as part
   of `@`. To scope a commit to a subset:
   - `jj commit <paths> -m "msg"` keeps only the matched paths in this
     change and bumps the rest into a new working-copy commit on top.
     Use this to **skip anything that looks like secrets** (`.env`,
     `*.pem`, `id_rsa`, files containing API keys or tokens) — commit
     the safe paths, surface a warning about the leftover ones.
   - `jj split` splits the current change into two commits when the
     diff contains clearly unrelated work (see "Splitting commits"
     below).
4. Write the commit message in the format below.
5. `jj commit -m "<full message>"` (this finalizes `@` with the message
   and opens a fresh empty working-copy commit on top), then `jj st` to
   confirm the new `@` is empty (or surface what was deliberately left
   in the new working-copy commit by step 3).

If `jj st` reports "The working copy has no changes" and there are no
undescribed ancestor changes the user wanted committed, say so and
stop — there is nothing to commit.

> Note: `jj describe -m "msg"` only sets the description on `@` without
> opening a new change. Prefer `jj commit -m "msg"` here — the user
> asked for a commit, not just a description, and `jj commit` is the
> direct analog of `git commit -a`.

## Message format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Subject (required)

- `type(scope): description` — scope is optional but preferred when it
  meaningfully narrows the change.
- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`,
  `build`, `ci`, `style`.
- ≤ 72 characters total, ≤ 50 preferred.
- Imperative mood: "add X", not "added X" or "adds X".
- No trailing period. Lowercase after the colon.

### Body (required unless the change is trivially obvious)

- Blank line between subject and body.
- Wrap at 72 characters.
- Explain **what** and **why**, not how — the diff already shows how.
- Bullet points for multiple distinct changes.

A one-line typo fix or a pure formatting change can skip the body. A
behaviour change, refactor, or anything someone might `git blame` later
should have one.

### Footer (when applicable)

- `Fixes #<n>` / `Closes #<n>` to link issues.
- `BREAKING CHANGE: <description>` for breaking API or behaviour changes.
- `Co-authored-by: Name <email>` for co-authors.

## Hard rules

These are non-negotiable because they affect history other people rely on:

- **Never push.** This skill commits locally only — no `git push`,
  no `jj git push`.
- **Never rewrite published history.** git: no `--no-verify`,
  `--force`, or `--amend`. jj: don't `jj describe` / `jj squash` /
  `jj abandon` a change that's already been pushed, and don't
  `jj git push --force-with-lease` (or any other force variant) to
  overwrite a remote bookmark. If the user wants to amend or rewrite,
  that's a different operation and they should ask for it explicitly.
- **git pre-commit hooks** — if a pre-commit hook fails, read its
  output, fix the underlying issue, then commit again. Don't bypass
  the hook with `--no-verify`. (Skip this rule on the jj path: jj has
  no support for pre-commit hooks, even in colocated repos. Run
  formatters/linters via `jj fix` or by hand instead.)

## Splitting commits

If the diff contains clearly unrelated changes (e.g. a feature plus an
unrelated bugfix plus formatting), prefer multiple commits over one
sprawling message. When in doubt, ask the user before splitting.

- **git path:** stage and commit each logical group separately
  (`git add <paths> && git commit -m "..."`), each with its own
  subject/body.
- **jj path:** commit each group with `jj commit <paths> -m "..."` in
  sequence — the unselected files automatically roll forward into the
  next working-copy commit, so you just keep narrowing. For
  finer-grained splits (e.g. by hunk within a single file), use
  `jj split` non-interactively with a fileset, or tell the user
  `jj split -i` is the right tool and let them drive it interactively.
