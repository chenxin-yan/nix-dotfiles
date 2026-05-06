---
name: commit
description: Stage and commit changes with a Conventional Commits message — runs git status/diff, matches the repo's existing style, picks a type and scope, writes a structured subject and body, and commits without push/force/amend. Use whenever the user wants to commit work, finalize changes, ship or save progress, or close out a task with git, even if they don't explicitly say "Conventional Commits". Also use when the user says things like "commit this", "make a commit", "commit the changes", or "/skill:commit".
---

# Commit

Stage and commit all relevant changes with a well-structured Conventional
Commits message. The user has invoked this skill because they want one or
more commits to be made now — your job is to actually make the commit, not
just describe what one would look like.

## When the user passes context

If the user appended free-form text to the invocation (e.g. `/skill:commit
auth refactor`, or "commit this, scope it to the parser"), treat it as a
**hint** about scope or framing. Honour it where it fits, but the diff
itself is the source of truth — don't force a misleading scope just
because the user suggested one.

## Workflow

1. `git status` and `git diff HEAD` to understand the full scope of changes.
2. `git log --oneline -10` to match the repo's existing commit style
   (scope conventions, subject phrasing, body length).
3. Stage relevant changed and untracked files. **Skip anything that looks
   like secrets** (`.env`, `*.pem`, `id_rsa`, files containing API keys
   or tokens) and surface a warning rather than committing them.
4. Write the commit message in the format below.
5. Commit with the full message, then run `git status` to confirm a clean
   tree (or to surface what was deliberately left unstaged).

If `git status` reports no changes at all, say so and stop — there is
nothing to commit.

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

- **Never push.** This skill commits locally only.
- **Never use `--no-verify`, `--force`, or `--amend`.** If the user wants
  to amend or force-push, that's a different operation and they should
  ask for it explicitly.
- **If a pre-commit hook fails**, read its output, fix the underlying
  issue, then commit again — don't bypass the hook.

## Splitting commits

If the diff contains clearly unrelated changes (e.g. a feature plus an
unrelated bugfix plus formatting), prefer multiple commits over one
sprawling message. Stage and commit each logical group separately, each
with its own subject/body. When in doubt, ask the user before splitting.
