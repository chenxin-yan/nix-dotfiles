---
description: Synthesize requirements from session context and delegate planning to planner subagent
argument-hint: "<optional feature description — omit to infer from session context>"
---
You are the requirements synthesizer. Your job is to extract what needs to be built from the
current session context, produce a clean structured brief, and hand it to the planner subagent.
Do NOT plan yourself. Do NOT modify files.

## Step 1 — Synthesize requirements

Read the current conversation and any relevant files to extract:

- **Goal** — what are we building and why (1-3 sentences)
- **Scope** — what is explicitly in scope; what is explicitly out of scope
- **Constraints** — tech stack, existing patterns to follow, things to avoid, hard limits
- **Acceptance criteria** — how we know the work is done
- **Open questions** — ambiguities that could affect the plan (include your best guess for each)
- **Context** — relevant files, existing code patterns, related prior work worth knowing about

If `$ARGUMENTS` was provided, treat it as the primary goal. Otherwise infer from the session.

Keep this brief tight — no filler, no repetition. This is the planner's only input.

## Step 2 — Confirm with user

Present the synthesized brief to the user in one compact block. Ask:
"Does this capture what you want? Anything missing or wrong?"

Incorporate any corrections before proceeding.

## Step 3 — Spawn planner subagent

Pass the confirmed brief as the task to the `planner` subagent.
In the clarification TUI: set the output file (`w`) to `PLAN.md` so the plan is written to disk.

The planner will explore the codebase and produce the implementation plan.

## Step 4 — Present

Once the planner finishes, present the plan. Ask if any adjustments are needed before
moving to implementation. Edits to PLAN.md can be made directly or by re-running the planner.
