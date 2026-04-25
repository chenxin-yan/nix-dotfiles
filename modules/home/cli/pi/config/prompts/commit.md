---
description: Stage and commit changes following Conventional Commits
argument-hint: "[scope-or-context-hint]"
---
Stage and commit all relevant changes with a well-structured commit message.

## Steps

1. Run `git status` and `git diff HEAD` to understand the full scope of changes
2. Run `git log --oneline -10` to match the repo's existing commit style
3. Stage all relevant changed and untracked files — skip files containing secrets (`.env`, credentials, etc.) and warn if found
4. Write the commit message following the format below
5. Commit with the full message and verify with `git status`

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Subject (required)

- Format: `type(scope): description` — scope is optional but preferred
- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`, `style`
- ≤ 72 characters total, ≤ 50 preferred
- Imperative mood: "add X" not "added X" or "adds X"
- No trailing period. Lowercase after the colon.

### Body (required unless the change is trivially obvious)

- Blank line between subject and body
- Wrap at 72 characters
- Explain **what** and **why** — not how (the diff shows how)
- Use bullet points for multiple distinct changes

### Footer (when applicable)

- `Fixes #<n>` or `Closes #<n>` — link to issues
- `BREAKING CHANGE: <description>` — for breaking API or behavior changes
- `Co-authored-by: Name <email>` — for co-authors

## Examples

```
feat(auth): add OAuth2 PKCE flow

Replace implicit grant with PKCE to eliminate token exposure in the
redirect URL. Required by the updated OAuth2 security BCP (RFC 9700).

Closes #42
```

```
fix(api): handle empty body in fetch wrapper

`res.json()` throws on 204 No Content. Guard with a content-type
check before parsing.
```

```
chore(deps): bump elysia to 1.3.0

Picks up the fixed cookie serialization behavior from 1.2.9 and
drops the now-redundant workaround in middleware/auth.ts.
```

## Rules

- If there are no changes, say so and stop
- Do NOT push to remote
- Do NOT use `--no-verify`, `--force`, or `--amend`
- If `$ARGUMENTS` is provided, treat it as a scope or context hint for the message
- If a pre-commit hook fails, fix the issue and commit again
