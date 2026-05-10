---
description: Push current branch and open a PR with a structured description
argument-hint: "[title-or-context]"
---
Push the current branch and open a pull request.

## Step 0 — Detect VCS

If `.jj/` exists at the repo root or `jj root` exits 0, this is a jj workspace
(colocated repos with both `.jj/` and `.git/` count as jj). Follow the **jj
workflow** below. Otherwise follow the **git workflow**.

`gh pr create` works the same in both cases because the GitHub remote is shared.

---

## jj workflow

1. Run `jj st` to confirm no in-flight conflicts and a sane working copy. Warn
   if there are conflicts and stop.
2. Identify the change to push:
   - Run `jj log -r 'trunk()..@' --no-graph -T 'change_id ++ "\n"'` to see the
     change(s) ahead of trunk. If empty, stop and tell me there's nothing to
     push.
   - Pick a bookmark name. Prefer an existing bookmark on `@` from
     `jj bookmark list -r @`. If none, derive one from the change description
     (or `$ARGUMENTS`) and create it: `jj bookmark create <name> -r @`.
3. Detect PR target repo and base branch:
   - Run `gh repo view --json isFork,nameWithOwner,parent,defaultBranchRef`
   - If `isFork` is `true`: PR targets the parent. `BASE_REPO = parent.nameWithOwner`,
     `BASE_BRANCH = parent.defaultBranchRef.name`.
   - Otherwise: `BASE_REPO = nameWithOwner`, `BASE_BRANCH = defaultBranchRef.name`
     (fallback `main`).
4. Gather diff context:
   - `jj log -r 'trunk()..@' --no-graph` for the commit list.
   - `jj diff -r 'trunk()..@' --stat` for a high-level summary.
5. Push the bookmark: `jj git push --bookmark <name>` (add `--allow-new` only
   if the bookmark hasn't been pushed before).
6. `gh pr create --repo "$BASE_REPO" --base "$BASE_BRANCH"` with title + body
   per the **PR body** section below.
7. Print the PR URL.

## git workflow

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

---

## PR body (both workflows)

- Title: concise, imperative, matching the repo's PR style. Use `$ARGUMENTS` as
  a hint if provided.
- Body sections: short summary, `## Changes` bullet list, `## Test plan`.

## Rules

- Do NOT use `--draft` unless I ask.
- Do NOT auto-merge.
- If `gh` is not authenticated, stop and ask.
- If a PR already exists for this branch/bookmark, print its URL and stop.
- On a forked repo, the PR target is ALWAYS the parent repo (`--repo <parent>`),
  never the fork itself. Confirm with `gh repo view --json isFork,parent` before
  opening the PR.
