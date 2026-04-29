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

## Testing

- **Tests first** – When implementing something that requires tests, always write the tests before writing the implementation code (TDD). Run the tests to confirm they fail for the right reason, then write the implementation to make them pass.
- **Eval loop** – After every implementation step: run the relevant test file, type-check changed files, and run Biome on changed files. Fix all failures before moving on. Do not proceed to the next step with a failing test, type error, or lint error.

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
