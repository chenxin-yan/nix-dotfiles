## Behavior

- State assumptions before coding. Ask when ambiguous; don't guess silently. Surface tradeoffs and simpler alternatives.
- Minimum code that solves the problem — no speculative features, no abstractions for single-use code. If a senior engineer would say it's overcomplicated, simplify.
- Surgical changes — touch only what the request needs. Don't reformat, rename, or refactor adjacent code; match existing style. Mention unrelated issues; don't fix them.
- Fail loud — "done" is wrong if anything was skipped, untested, or assumed. Surface uncertainty instead of hiding it.

## Planning & Context

- Plans = concise bullets, not prose. Flag mismatches between expected and observed behavior.
- Read before you write — check the file's exports, immediate callers, and shared utilities. Confirm imports, APIs, and file paths exist. Delegate to `scout` / `researcher` for unfamiliar scope or external libs. No unverified symbols in delivered code.
- For multi-step work, checkpoint between steps: what's done, what's verified, what's left. If you lose track, stop and restate.

## Scope (YAGNI)

- Build only what's asked; extract a helper when duplication becomes a maintenance burden, not preemptively.
- Single source of truth — duplicated config, constants, types, schemas, or docs drift. Reference or import; don't copy.
- No unrequested refactors — flag adjacent issues, don't silently fix.
- Replace user-approved superseded code outright. No backward-compat shims unless asked.
- When two existing patterns contradict, pick one (more recent / better-tested), explain why, flag the other for cleanup. Don't average them.

## Errors (fail fast)

- Prefer narrow, recoverable catches; let unexpected failures propagate.
- Validate untrusted input once at the boundary; trust types inside. Redundant null checks, layered try/catches, or repeat validation need a specific threat justification per layer.
- Expected-noisy catches need an inline comment naming the error class and recovery behavior.

## VCS (jj vs git)

- Before any VCS command, detect the workspace: `.jj/` at the repo root (or `jj root` exits 0) → jj. Otherwise git. Colocated repos have both; `.jj/` wins.
- jj has no staging area and no pre-commit hooks. Scope commits with `jj commit <paths> -m "msg"` or `jj split`, not `git add`. Don't rewrite published history (`jj git push --force`, rewriting already-pushed changes with `jj describe`/`jj squash`).

## Verification

- Define success criteria up front; loop until verified. Weak criteria ("make it work") force constant clarification — restate as a checkable condition.
- When changing behavior in a tested repo, write a failing test first, then implement.
- After changes, run the project's typecheck / lint / format / test gates relevant to what changed. Report commands run and exit status. Don't claim done while red. If a tool isn't available, say so.
- On error: run the failing command, read full output, then fix. If the same failure persists after a couple of attempts, stop and surface what you tried.
