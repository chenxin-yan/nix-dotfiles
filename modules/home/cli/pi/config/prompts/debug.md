---
description: Structured debugging workflow — localize root cause, confirm, then fix
argument-hint: "<error or stack trace>"
---
You are running a structured debugging session. Do NOT jump to fixes. Follow the steps in order.

If `$ARGUMENTS` is empty, ask what the error is before proceeding.

## Step 1 — Orient

Read the error/stack trace from `$ARGUMENTS`. Identify:
- The failing file and function/line
- The error type and message
- Any relevant surrounding call chain

Pull and read the relevant source files in full. Do this inline — no subagent needed.

## Step 2 — Reproduce

Infer the failing command or test from the stack trace and run it. Collect the actual output.

If the reproduction command cannot be confidently inferred, ask before running anything.

## Step 3 — Localize

Spawn `context-builder` with this task:

> Trace this error to its root cause — not just the symptom.
>
> Error: [ERROR]
> Reproduction output: [OUTPUT]
>
> Read all relevant source files in full before forming a conclusion. Return:
> - **Root cause** — the specific line/condition that triggers the error
> - **Why it fails** — the underlying logic or state that leads here
> - **Affected paths** — other code paths that may be impacted

If the error clearly traces to an external library, API, or framework behavior (not your own
code), also spawn `researcher` in parallel with this task:

> Find relevant documentation, known issues, or changelog entries for: [LIBRARY/API + ERROR]
> Focus on the specific error message and version in use.

## Step 4 — Present and confirm ⏸️

Present the root cause analysis (and research findings if applicable). Be specific — cite
file:line for the root cause.

Ask:
- Is this the right root cause?
- Any adjustments to scope or approach before fixing?

**Do not proceed to Step 5 until the user confirms.**

## Step 5 — Fix

Spawn `worker` with this task:

> Fix this bug.
>
> Root cause: [CONFIRMED ROOT CAUSE]
> Reproduction command: [COMMAND]
> Relevant files: [FILES]
>
> Follow TDD where applicable. Write a regression test if none exists for this code path.
> Do not modify files outside the confirmed scope.

## Step 6 — Verify

Re-run the reproduction command. Typecheck and lint changed files. Report pass/fail clearly.

If verification fails, explain what still fails and ask how to proceed — do not silently retry.

## Step 7 — Wrap

If verification passes:
- Summarize what was fixed and why in 2–3 lines
- Suggest a commit (`/commit`) or ask if a full review is wanted (`/review`)
