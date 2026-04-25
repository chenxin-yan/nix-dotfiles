## Planning & Communication

- **Keep plans concise** – Plans should be brief and to the point. Bullet fragments and short phrases are preferred over full sentences.

## Documentations & Context Search

- **No hallucination** – Never invent or assume API behavior, field names, or error codes. If documentation is unavailable, explicitly state this and request clarification from the user.
- **Verify before implementation** – Always confirm API signatures and contract details from authoritative sources before writing code.
- **Document mismatches** – If expected behavior differs from documented behavior, flag it clearly.

## Testing

- **Tests first** – When implementing something that requires tests, always write the tests before writing the implementation code (TDD). Run the tests to confirm they fail for the right reason, then write the implementation to make them pass.

## When Stuck

- **Ask, don't guess** – If the right approach is unclear, ask a clarifying question with a suggested answer and the tradeoff. Never make speculative changes to unrelated files.
- **Cap retries** – If the same test or type error persists after 2 attempts, stop and explain what you tried before asking for input.
- **No silent assumptions** – If a dependency, API, or behavior is undocumented or ambiguous, say so explicitly rather than assuming.
