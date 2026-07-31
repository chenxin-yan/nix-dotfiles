---
name: fix-pr-review-comments
description: Critically evaluate GitHub PR review comments instead of blindly applying them. verify each against the code, fix what's valid, and report per-comment verdicts. Use when the user wants to handle, triage, or address PR review feedback.
---

# PR Review Triage

Review comments are opinions, not orders. Reviewers (human or bot) misread
code, miss context, and suggest changes that break things. Your job:
verify each comment against the actual code, fix the valid ones, and
explain the rest. Never apply a suggestion you haven't independently
confirmed is correct.

## Step 1: Identify the PR

```bash
gh pr view --json number,title,headRefName,reviewDecision,url
```

The user should say which PR(s) to check. If they didn't name any and
the current branch's PR isn't an obvious match, ask — don't guess.
Multiple PRs: run the full workflow per PR, one report each.

Make sure the local checkout matches the PR head
(`git fetch && git status`) — you'll be evaluating comments against
this code.

## Step 2: Wait for reviews (if none yet)

Fetch what exists first:

```bash
gh pr view <num> --json reviews,comments
gh api repos/{owner}/{repo}/pulls/<num>/comments   # inline review comments
```

If there are no review comments yet, or the existing ones are stale, poll
for changes — use the background `process` tool if available so the
session isn't blocked.

## Step 3: Collect and de-duplicate

Gather every actionable item into one list:

- Inline review comments (`/pulls/<num>/comments`) — have `path`, `line`,
  `diff_hunk`.
- Review bodies (`--json reviews`) — top-level feedback.
- Skip: resolved threads, outdated comments on lines that no longer
  exist, pure approvals ("LGTM"), and comments you (the agent) authored.

Number the items. This numbering is the skeleton of the final report.

## Step 4: Evaluate each comment — the core discipline

For EACH item, before touching any code:

1. **Read the actual code** the comment points at — the file, the
   surrounding function, and callers if the claim is about behavior.
   Never evaluate from the diff hunk alone.
2. **Verify the claim.** Is the bug real? Does the suggested change
   actually improve things? Would it break a caller, a test, or an
   invariant the reviewer didn't see?
3. **Assign a verdict:**

| Verdict                 | Meaning                                      | Action                                                                 |
| ----------------------- | -------------------------------------------- | ---------------------------------------------------------------------- |
| ✅ Valid                | Claim confirmed against code                 | Fix it                                                                 |
| 🔧 Valid, different fix | Problem real, suggestion wrong/suboptimal    | Fix the root cause your way, note why                                  |
| ❓ Unclear              | Can't verify; needs author/reviewer context  | No change; list the open question                                      |
| ❌ Invalid              | Claim contradicted by the code               | No change; cite the evidence (file:line)                               |
| 💅 Style/nit            | Subjective preference, no correctness impact | Apply only if trivial and consistent with repo style; otherwise report |

Hard rules:

- A verdict of ❌ requires evidence — point to the specific code that
  disproves the claim, not just "I disagree".
- Suggested code in a comment is a hypothesis. If you adopt it, you own
  it: check types, callers, and edge cases as if you wrote it.
- When a comment conflicts with explicit user instructions or repo
  conventions, the user/repo wins — mark ❓ and flag it.

## Step 5: Fix

Apply fixes for ✅ and 🔧 items:

- Group related fixes; keep diffs surgical — fix what the comment
  covers, don't refactor the neighborhood.
- After all fixes, run the repo's relevant gates (typecheck / lint /
  tests). A "fix" that breaks the build is worse than no fix.
- Commit only if the user asked; otherwise leave changes staged/unstaged
  and say so. Never push without explicit instruction.

## Step 6: Report

One table, then details only where needed:

```markdown
## PR Review Triage — PR #123

| #   | Comment (file:line) | Reviewer says              | Verdict    | Action taken                                                                        |
| --- | ------------------- | -------------------------- | ---------- | ----------------------------------------------------------------------------------- |
| 1   | api.ts:42           | Possible null deref        | ✅ Valid   | Added guard in `fetchUser` (covers all 3 callers)                                   |
| 2   | db.py:17            | Use ORM instead of raw SQL | ❌ Invalid | No change — this is a migration script; ORM unavailable at this stage (see db.py:3) |
| 3   | ui.tsx:88           | Rename `x` to `count`      | 💅 Nit     | Applied, matches repo naming                                                        |

Gates: `npm test` ✅, `tsc` ✅
Open questions: #2 — confirm with reviewer whether migrations should stay raw SQL.
```

Every comment gets a row — including the ones you didn't act on. The
user decides what to relay back to reviewers; you don't reply on GitHub.
