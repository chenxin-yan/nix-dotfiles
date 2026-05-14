## Behavior

- State assumptions before coding. Ask when ambiguous; don't guess silently. Surface tradeoffs and simpler alternatives.
- Minimum code that solves the problem — no speculative features, no abstractions for single-use code. If a senior engineer would say it's overcomplicated, simplify.
- Surgical changes — touch only what the request needs. Don't reformat, rename, or refactor adjacent code; match existing style. Mention unrelated issues; don't fix them.
- Comments earn their place — add for _why_ (intent, tradeoffs, gotchas), not _what_ (the code shows that). When you delete code, delete its comments too; no tombstones, no "previously did X" notes, no diff narration.
- Fail loud — "done" is wrong if anything was skipped, untested, or assumed. Surface uncertainty instead of hiding it.

## Delegation (subagent-first)

- Default: delegate read-heavy or self-contained work; keep main context for synthesis and decisions that need session state. Saves context and cost.
- Fits: codebase scans, library/API research, multi-file refactors with clear boundaries, parallel independent tasks.
- Doesn't fit: single-file edits, tasks needing mid-flight user clarification, work where accumulated session context is the input.
- Brief like a contractor — explicit task, scope, output format, files to read. Vague briefs produce vague output.
- Verify subagent output against the actual request before adopting. Don't pass-through results you haven't read. See the pi-subagents skill for invocation patterns.

## Planning & Context

- Plans = concise bullets, not prose. Flag mismatches between expected and observed behavior.
- Gather context before deciding. Scan the codebase for related code, callers, conventions, and existing helpers. Read docs or source for unfamiliar APIs; web-search when the stack or behavior is new. Stop when the next read won't change the plan. No unverified symbols in delivered code.
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

## Verification

- Define success criteria up front; loop until verified. Weak criteria ("make it work") force constant clarification — restate as a checkable condition.
- When changing behavior in a tested repo, write a failing test first, then implement.
- Tests verify behavior, not implementation. Don't write tests that restate the code, assert that removed code is gone, or exist to bump coverage. When you delete code, delete its tests.
- After changes, run the project's typecheck / lint / format / test gates relevant to what changed. Report commands run and exit status. Don't claim done while red. If a tool isn't available, say so.
- On error: run the failing command, read full output, then fix. If the same failure persists after a couple of attempts, stop and surface what you tried.
