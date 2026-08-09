---
name: explain-this
description: Explain a file, function, or code snippet the user points at, grounded in real codebase context. Use when the user says "explain this", asks how some code works, or wants to understand a piece of code they name.
---

# Explain This

Build the user a strong mental model of the code they pointed at. Ground every claim in code you actually read — no guessing from names.

## Step 1 — Trace

Read the target fully, then trace outward until every symbol in it is accounted for:

- **Callers** — who invokes this, and why. Grep for usages; read the 2–3 most representative call sites.
- **Callees & types** — every function, type, or constant the target uses that isn't obvious: read its definition (or its docs, for a dependency).
- **Surroundings** — config, sibling code, or conventions that shape its behavior (a registry it plugs into, a lifecycle that calls it, a schema it mirrors).

Done when: every name in the target is either self-evident or you've read its source. Stop tracing when the next read wouldn't change the explanation.

## Step 2 — Explain

Write for someone smart who lacks the context you just gathered. Structure:

1. **One-sentence summary** — what it is and why it exists.
2. **The picture** — where it sits in the system: what feeds it, what it feeds. A small ASCII diagram if flow matters.
3. **How it works** — walk the logic in execution order, not file order. Plain language; introduce each unfamiliar term the first time it appears.
4. **The non-obvious** — gotchas, invariants, historical quirks, the "why is it written this way" that code alone doesn't confess.

Rules:

- Simple words, short sentences. An analogy is worth ten sentences when it fits.
- Concrete over abstract: show a real input flowing through, not a description of categories.
- Length matches the target: a helper gets a paragraph; a subsystem gets the full structure. Never pad.
- Flag uncertainty explicitly ("I didn't trace X; it appears to...") rather than smoothing over it.
