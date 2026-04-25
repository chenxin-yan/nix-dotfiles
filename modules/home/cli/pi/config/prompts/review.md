---
description: Review code changes for bugs, security, style, and test coverage
argument-hint: "[PR-URL | commit-range | --staged]"
---
Conduct a thorough code review.

## Scope

Determine the review scope from `$ARGUMENTS`:
- A GitHub PR URL → use `gh pr diff <url>` and `gh pr view <url>`
- A commit range like `main..HEAD` or `abc..def` → use `git diff <range>`
- `--staged` → review `git diff --cached`
- Empty → infer base via `git rev-parse --abbrev-ref origin/HEAD` (default `main`) and review `<base>...HEAD`

Read all changed files in full (not just the diff) before forming an opinion.

## Review dimensions

For each finding, cite the file:line and severity (`critical` / `high` / `medium` / `low` / `nit`).

1. **Correctness** — bugs, off-by-one errors, race conditions, null/undefined handling, type mismatches
2. **Security** — injection, auth/authz gaps, secret exposure, unsafe deserialization, SSRF, path traversal
3. **Error handling** — silent failures, swallowed exceptions, missing fallbacks, unbounded retries
4. **Performance** — N+1 queries, unnecessary work, allocations in hot paths, blocking I/O
5. **API & contracts** — breaking changes, missing types, inconsistent naming, leaky abstractions
6. **Tests** — missing coverage for new logic, unit vs integration balance, brittle assertions
7. **Style & readability** — dead code, naming, complexity, repo-conventions match (check existing code)

## Output

```
## Summary
<2-3 sentence verdict>

## Critical / High
<must-fix items, file:line + reason + suggested fix>

## Medium / Low
<should-fix items>

## Nits
<optional polish>

## Test coverage
<gaps + concrete tests to add>

## Verdict
APPROVE | REQUEST_CHANGES | NEEDS_DISCUSSION
```

## Rules

- Be specific, never generic. Reference exact file:line and quote the offending code
- Do NOT modify files
- Do NOT post review comments to GitHub unless asked explicitly
- If the diff is empty or the range is invalid, say so and stop
