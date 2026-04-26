---
description: Stress-test a plan by interviewing me until we reach shared understanding
argument-hint: "[plan-context or path, defaults to PLAN.md]"
---
Load the plan:
- If `$ARGUMENTS` is provided, treat it as the plan text or a file path to read.
- Otherwise, read `PLAN.md`. If it does not exist, ask what to refine before proceeding.

Interview me relentlessly about every aspect of the plan until we reach a shared understanding.

Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer with a short tradeoff.

If a question can be answered by exploring the codebase, explore the codebase instead of asking me.

Ask one question at a time. Wait for my answer before moving on.
