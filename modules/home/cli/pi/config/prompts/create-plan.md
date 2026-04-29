---
description: Distil the current conversation into a PLAN.md — goal, decisions, ordered task list, open questions
argument-hint: "[output path, defaults to PLAN.md]"
---
Scan the conversation above and write a plan to `$ARGUMENTS` (default: `PLAN.md`).

## Rules

- Do NOT re-open settled decisions — capture them, move on.
- Tasks must be actionable checklist items (`- [ ]`), ordered by dependency.
- Omit anything already done or irrelevant to execution.
- Keep prose minimal — this is a working doc, not a summary.

## Output format

```markdown
# <goal in one sentence>

## Context
<why this is being built and any hard constraints — 3 lines max>

## Decisions
- <decision made>: <rationale in one clause>

## Tasks
- [ ] <first action>
- [ ] <next action>
...

## Open questions
- <anything unresolved that will block execution>
```

Omit any section that has nothing to put in it.

After writing the file, confirm in one line: what file was written and how many tasks it contains.
