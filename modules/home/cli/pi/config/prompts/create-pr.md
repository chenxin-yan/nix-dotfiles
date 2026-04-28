---
description: Push current branch and open a PR with a structured description
argument-hint: "[title-or-context]"
---
Push the current branch and open a pull request.

## Steps

1. Run `git status` to confirm a clean working tree (warn if dirty, ask before proceeding)
2. Run `git branch --show-current` to get the branch name. If on `main`/`master`, stop and tell me to switch to a feature branch
3. Detect the PR target repo and base branch:
   - Run `gh repo view --json isFork,nameWithOwner,parent,defaultBranchRef`
   - If `isFork` is `true`: this is a fork. Set `BASE_REPO` = `parent.nameWithOwner` and `BASE_BRANCH` = `parent.defaultBranchRef.name`. The PR MUST target the upstream (original) repo, not the fork.
   - Otherwise: `BASE_REPO` = `nameWithOwner`, `BASE_BRANCH` = `defaultBranchRef.name` (fall back to `main` if missing)
   - Pick a usable local ref for diffs in this order: `upstream/$BASE_BRANCH` → `origin/$BASE_BRANCH` → `$BASE_BRANCH`. Call this `BASE_REF`.
4. Run `git log $BASE_REF..HEAD --oneline` to gather the commits in this PR
5. Run `git diff $BASE_REF...HEAD --stat` for a high-level change summary
6. Push the branch with `git push -u origin HEAD` if it has no upstream, otherwise `git push` (always push the branch to `origin`, which is the fork on a fork)
7. Use `gh pr create --repo "$BASE_REPO" --base "$BASE_BRANCH"` with:
   - Title: concise, imperative, matching the repo's PR style. Use `$ARGUMENTS` as a hint if provided
   - Body: a short summary, a `## Changes` bullet list, and a `## Test plan` section
   - On a fork, `gh` will automatically set head to `<fork-owner>:<branch>` — do not pass `--head` unless cross-fork resolution fails
8. Print the PR URL

## Rules

- Do NOT use `--draft` unless I ask
- Do NOT auto-merge
- If `gh` is not authenticated, stop and ask
- If a PR already exists for this branch, print its URL and stop
- On a forked repo, the PR target is ALWAYS the parent repo (`--repo <parent>`), never the fork itself. Confirm with `gh repo view --json isFork,parent` before opening the PR.
