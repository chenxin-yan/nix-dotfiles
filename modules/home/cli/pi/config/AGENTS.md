## Planning & Context

- Plans = concise bullets, not prose. Flag mismatches between expected and observed behavior.
- Verify before implementing — read the actual code; confirm imports, APIs, and file paths exist. Delegate to `scout` / `researcher` subagents for unfamiliar scope or external libs. No unverified symbols in delivered code.

## Scope (YAGNI)

- Build only what's asked; extract a helper when duplication becomes a maintenance burden, not preemptively.
- Single source of truth — duplicated config, constants, types, schemas, or docs drift over time. Reference or import; don't copy.
- No unrequested refactors — flag adjacent issues, don't silently fix.
- Replace user-approved superseded code outright. No backward-compat shims unless asked.

## Errors (fail fast)

- Prefer narrow, recoverable catches; let unexpected failures propagate.
- Validate untrusted input once at the boundary; trust types inside. No arbitrary defense-in-depth — redundant null checks, layered try/catches, or repeat validation need a specific threat justification per layer.
- Expected-noisy catches need an inline comment naming the error class and recovery behavior.

## Verification (you are the loop — no auto-LSP)

- When changing behavior in a tested repo, prefer writing a failing test first, then implement.
- After changes, run the project's typecheck / lint / format / test gates relevant to what changed. Don't claim done while red.
- Report commands run and exit status. If a tool isn't available, say so.
- On error: run the failing command, read full output, then fix.
- If the same failure persists after a couple of attempts, stop and surface what you tried.
