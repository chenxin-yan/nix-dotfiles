---
description: Enter implementation mode — read the plan and build it out
argument-hint: "[plan file path, defaults to PLAN.md]"
---
Enter implementation mode. Read the plan and implement it step by step.
Do NOT skip ahead. Do NOT batch fixes. Do NOT proceed with failing tests or type errors.

## Step 1 — Load the plan

Read `$ARGUMENTS` (default: `PLAN.md`). If the file does not exist, say so and stop.

Confirm the goal and scope with the user in one line before starting.
Use pi-manage-todo-list to load the plan's checklist for progress tracking.

## Step 2 — Implement

Work through the plan top to bottom. For each task:

1. **Write tests first** — confirm they fail for the right reason before implementing
2. **Implement** — make the tests pass
3. **Eval loop** — run tests + `tsc --noEmit` + `biome check` on changed files
4. **Fix immediately** — if a test, type error, or lint error appears, fix it before the next task
5. **Check off** — mark the task done in the todo list

If you are stuck on the same error after 2 attempts, stop and ask.

## Step 3 — Suggest commit points

After completing a logical chunk (a full feature slice, a passing test suite, a clean module),
suggest a commit. Do not commit automatically — let the user decide the boundary.

## Rules

- Never skip the eval loop
- Never proceed with a failing test or type error
- Never make speculative changes to files outside the current task's scope
- If the plan is unclear or contradicts itself, ask before guessing
