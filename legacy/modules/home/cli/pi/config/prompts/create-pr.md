---
description: Push current branch and open a PR with a structured description
argument-hint: "[title-or-context]"
---
Push the current branch and open a pull request.

## Workflow

1. Run `git status` to confirm a clean working tree (warn if dirty, ask before
   proceeding).
2. Run `git branch --show-current`. If on `main`/`master`, stop and tell me to
   switch to a feature branch.
3. Detect PR target repo and base branch:
   - Run `gh repo view --json isFork,nameWithOwner,parent,defaultBranchRef`
   - If `isFork` is `true`: `BASE_REPO = parent.nameWithOwner`,
     `BASE_BRANCH = parent.defaultBranchRef.name`.
   - Otherwise: `BASE_REPO = nameWithOwner`, `BASE_BRANCH = defaultBranchRef.name`
     (fallback `main`).
   - Pick a usable local ref for diffs in this order:
     `upstream/$BASE_BRANCH` → `origin/$BASE_BRANCH` → `$BASE_BRANCH`. Call this `BASE_REF`.
4. `git log $BASE_REF..HEAD --oneline` to gather commits.
5. `git diff $BASE_REF...HEAD --stat` for the summary.
6. `git push -u origin HEAD` if no upstream, otherwise `git push`.
7. `gh pr create --repo "$BASE_REPO" --base "$BASE_BRANCH"` with title + body
   per the **PR body** section below. On a fork, do NOT pass `--head` unless
   cross-fork resolution fails — `gh` sets it automatically.
8. Print the PR URL.

## PR body

- Title: concise, imperative, matching the repo's PR style. Use `$ARGUMENTS` as
  a hint if provided.
- Body sections: short summary, `## Changes` bullet list, `## Test plan`.

## Rules

- Do NOT use `--draft` unless I ask.
- Do NOT auto-merge.
- If `gh` is not authenticated, stop and ask.
- If a PR already exists for this branch, print its URL and stop.
- On a forked repo, the PR target is ALWAYS the parent repo (`--repo <parent>`),
  never the fork itself. Confirm with `gh repo view --json isFork,parent` before
  opening the PR.
