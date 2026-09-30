---
name: codebase-walkthrough
description: Map a codebase or run a resumable, dependency-first guided tour.
disable-model-invocation: true
---

# Codebase Walkthrough

Build the user a working mental model of a codebase: where its important parts
live, how execution flows through them, and why its boundaries exist.

## Choose the route

Follow the user's explicit request:

- **Map only:** map the codebase, present it, offer a full tour, then stop. Do
  not create a progress file.
- **Fresh tour:** map the codebase, agree on a reading plan, then teach one
  part per response.
- **Resume:** continue from the existing progress file after checking drift.

For a fresh tour or resume, look for `WALKTHROUGH.md` at the repository root,
then `docs/WALKTHROUGH.md`. Resume whichever exists. If both exist, ask which
is authoritative. If a fresh tour would replace an existing file, ask before
overwriting it. Create new progress files only at the repository root.

When the route or scope is unclear, confirm the user's goal, current
familiarity, desired depth, and areas to include or skip. Proceed when the
route and scope are explicit.

## 1. Map

Read the repository and produce a codebase map grounded in cited paths:

1. **Orientation:** what the project produces and how it is built, run, and
   tested.
2. **Structure:** each important top-level package or directory in one line;
   identify generated, vendored, and irrelevant areas to skip.
3. **Architecture:** the 3–7 core subsystems, their dependency direction, and
   the main data or control flow. Use a small ASCII diagram when it clarifies
   the flow.
4. **Entry points:** where execution starts for each supported mode, including
   tests when their setup reveals architecture.

The map is complete when every claim is supported by files you read and the
next repository read would not change its architecture-level picture.

For a map-only request, present the map, offer a full tour, and stop here.

## 2. Plan the tour

Propose a dependency-first reading order: foundations before their consumers.
Each part covers one subsystem or package and states:

- its purpose and scope paths;
- why it appears at this point in the order;
- a rough size: small, medium, or large.

Wait for approval. After approval, create `WALKTHROUGH.md` from the template
below. Do not start Part 1 while approval is still pending.

## 3. Teach one part

Cover exactly one part per response. For that part, give the user:

1. **Purpose:** what it contributes to the system in 2–3 sentences.
2. **Reading order:** key files and symbols, with current `path:line` pointers
   for the important code.
3. **Core abstractions:** the 1–3 ideas that make the remaining code easier to
   predict.
4. **Trace:** one representative input, request, or call through the part.
5. **Boundaries and gotchas:** callers, dependencies, contracts, invariants,
   and surprising behavior.
6. **Check:** 2–3 questions that reveal whether the mental model holds.

Depth follows importance: explain core logic in detail and summarize glue.
Update `WALKTHROUGH.md`, then stop. Answer follow-up questions and correct
misunderstandings before moving on. Log feedback that changed the explanation
or plan. When the user changes the plan, immediately update its order,
current marker, and handoff notes.

Before teaching any later part, check whether the repository state recorded in
`WALKTHROUGH.md` still matches the worktree. Run the drift check if it changed.

## Progress file

`WALKTHROUGH.md` is the tour's compact source of truth, not a transcript.
Update it after plan approval, after presenting each part, after consequential
user feedback, and after every drift briefing.

```markdown
# Codebase Walkthrough — <project>

Updated: <date>
Repository state: <full HEAD sha> <clean | dirty: paths>

## Tour contract

- Goal: <what the user wants to understand or do>
- Starting familiarity: <relevant context>
- Depth and scope: <included and skipped areas>

## Codebase map

<current map>

## Plan

- [x] Part 1: <name> — covered
- [ ] Part 2: <name> ← current
- [ ] Part 3: <name>

## Part logs

### Part 1: <name>

- Baseline: <full commit sha>
- Scope paths: <paths used to detect drift>
- Key files walked: <paths>
- Core abstractions: <one line each>
- User corrections and decisions: <what changed the shared understanding>
- Open questions: <unresolved items>

## Handoff notes

<current user preferences, pending checks, plan changes, and dirty files>
```

A part's baseline is the current commit when it is presented. Keep part logs
brief: preserve decisions and the mental model, not the lesson prose.

## Drift check

Run this on every resume and whenever the repository changes during the tour:

1. For each covered part, use its own baseline and scope paths. Compare that
   commit through the current worktree, including renames, staged changes,
   unstaged changes, and untracked files.
2. Map changed files to covered parts. Treat a part as affected when a change
   touches its scope or a boundary it depends on; when uncertain, re-read it.
3. Re-read each affected part and give a short delta briefing: what moved,
   changed behavior, or invalidated the prior mental model.
4. Update affected logs and advance their baselines to current `HEAD`. Record
   dirty paths in handoff notes and recheck them on later resumes until they
   are committed or reverted.
5. Name unaffected covered parts once; do not re-tour them. Re-read changed
   source for the current uncovered part before teaching it.

Without Git history, reliable drift detection is unavailable. Say so, ask the
user what changed, and re-read those areas before continuing.

## Completion

After the last part and its check, replace the handoff notes with a one-page
system summary and mark every resolved open question.
