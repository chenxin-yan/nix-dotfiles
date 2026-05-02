## Context & Research

- **Scout first** – Before any non-trivial codebase task, run the `scout` subagent to map relevant files and flows. Read its output before touching code.
- **Research external unknowns** – Before using any external API or library you cannot verify locally, run the `researcher` subagent. Never assume signatures, field names, or behavior.
- **Parallel when both apply** – If the task involves both unfamiliar code and an external dependency, run `scout` and `researcher` in parallel.
- **context-builder for large scope** – For multi-file refactors or major features, use `context-builder` instead of `scout` for a thorough structured handoff.
- **No hallucination** – Never invent API behavior, field names, or error codes. If you cannot cite a concrete file path, line, or doc URL, delegate to `scout` or `researcher` before proceeding.
- **No unverified imports** – Never write code referencing an import, type, or API you haven't confirmed exists in the codebase or documentation.
- **Cite your source** – Before writing any code, state which subagent you ran and what it told you. If no subagent was needed, briefly say why.

## Planning & Communication

- **Keep plans concise** – Plans should be brief and to the point. Bullet fragments and short phrases are preferred over full sentences.
- **Flag mismatches** – If expected behavior differs from documented or observed behavior, call it out explicitly.

## Verification (hard gate)

No auto-lint or post-edit LSP feedback runs in this setup — you are the verification loop.

- **TDD** – Write tests first, confirm they fail for the right reason, then implement.
- **Eval loop** – After every change, for each touched file: typecheck → lint → format → run the relevant test. Fix all failures before moving on. Do not declare success while anything is red.
- **Use the repo's commands** – Read `package.json` / `pyproject.toml` / `Cargo.toml` / `flake.nix` / `Makefile` / `justfile` to find the project's actual scripts (e.g. `pnpm typecheck`, `just test`). Fall back to ecosystem defaults (`tsc`, `mypy`, `cargo check`, `nix flake check`, …) only when no script exists.
- **Show your work** – Never claim a change is done without naming the commands you ran and their exit status. If a tool is unavailable, say so before skipping it.
- **Read failures, don't guess** – On error, run the failing command and read the full output before proposing a fix.

## When Stuck

- **Ask, don't guess** – If the right approach is unclear, ask a clarifying question with a suggested answer and the tradeoff. Never make speculative changes to unrelated files.
- **Cap retries** – If the same test or type error persists after 2 attempts, stop and explain what you tried before asking for input.
- **No silent assumptions** – If a dependency, API, or behavior is undocumented or ambiguous, say so explicitly rather than assuming.

## Subagent Output Files

- **Mental model** – inline = immediate reasoning; files = durable state; session artifacts = forensics.
- **Foreground chain steps** – leave defaults. Relative handoff files land in the internal chain dir, not cwd.
- **Single, parallel, or async chain calls** – handoff files land in **cwd**. You must choose:
  - **Default (omit `output`)** when the user asked for a written artifact, the file will be reused across turns, the output is large enough to warrant separate inspection, or the file _is_ the deliverable.
  - **`output: false`** when the orchestrator will summarize inline, the work is exploratory or advisory, or nobody needs to read the file afterward.
- **Tiebreaker** – if there is no clear file consumer, use `output: false`. The session artifact remains for forensics, not as a handoff channel.
