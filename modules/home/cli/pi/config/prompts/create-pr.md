---
description: Push current branch and open a PR with a structured description
argument-hint: "[title-or-context]"
---
Push the current branch and open a pull request.

## Steps

1. Run `git status` to confirm a clean working tree (warn if dirty, ask before proceeding)
2. Run `git branch --show-current` to get the branch name. If on `main`/`master`, stop and tell me to switch to a feature branch
3. Run `git log <base>..HEAD --oneline` to gather the commits in this PR (infer base via `git rev-parse --abbrev-ref origin/HEAD` or default to `main`)
4. Run `git diff <base>...HEAD --stat` for a high-level change summary
5. Push the branch with `git push -u origin HEAD` if it has no upstream, otherwise `git push`
6. Use `gh pr create` with:
   - Title: concise, imperative, matching the repo's PR style. Use `$ARGUMENTS` as a hint if provided
   - Body: a short summary, a `## Changes` bullet list, and a `## Test plan` section
7. Print the PR URL

## Rules

- Do NOT use `--draft` unless I ask
- Do NOT auto-merge
- If `gh` is not authenticated, stop and ask
- If a PR already exists for this branch, print its URL and stop
