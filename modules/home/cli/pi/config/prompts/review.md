---
description: Review code changes via reviewer subagent (GPT-5.5) + oracle adversarial critique in parallel
argument-hint: "[PR-URL | commit-range | --staged]"
---
Delegate this review to the `reviewer` subagent. Do NOT review the code yourself inline.

## Step 1 — Determine scope

From `$ARGUMENTS`:
- GitHub PR URL → `gh pr diff <url>` and `gh pr view <url>` to get the URL and title
- Commit range like `main..HEAD` or `abc..def` → pass as-is
- `--staged` → pass as-is
- Empty → infer base via `git rev-parse --abbrev-ref origin/HEAD` (default `main`), use `<base>...HEAD`

If the diff is empty or range is invalid, say so and stop.

## Step 2 — Spawn reviewer subagent

Pass the scope to the `reviewer` subagent with this task:

> Review the diff at [SCOPE]. Fetch the diff yourself — do not rely on any context passed to you.
> Read all changed files in full (not just the diff) before forming an opinion.
>
> For each finding cite file:line and severity (critical / high / medium / low / nit). Cover:
> 1. Correctness — bugs, race conditions, null handling, type mismatches
> 2. Security — injection, auth gaps, secret exposure, SSRF, path traversal
> 3. Error handling — silent failures, swallowed exceptions, missing fallbacks
> 4. Performance — N+1 queries, unnecessary allocations, blocking I/O in hot paths
> 5. API & contracts — breaking changes, missing types, leaky abstractions
> 6. Tests — missing coverage for new logic, brittle assertions
> 7. Style — dead code, naming, complexity, consistency with existing patterns
>
> Output:
> ## Summary (<2-3 sentence verdict>)
> ## Critical / High (must-fix: file:line + reason + suggested fix)
> ## Medium / Low (should-fix)
> ## Nits (optional polish)
> ## Test coverage (gaps + concrete tests to add)
> ## Verdict: APPROVE | REQUEST_CHANGES | NEEDS_DISCUSSION

## Step 3 — Spawn oracle in parallel

Spawn `oracle` at the same time as the reviewer (use parallel execution if possible, otherwise
immediately after). Task:

> Argue against the changes at [SCOPE]. Fetch the diff yourself.
> Be adversarial — find edge cases, question assumptions, identify what a standard reviewer
> might normalize over. What could go wrong in production? What is the weakest part of this change?

## Step 4 — Present

Present reviewer and oracle findings together. Call out any conflicts between them or anything
the oracle raised that the reviewer missed. Do NOT modify any files. Do NOT post to GitHub unless asked.
