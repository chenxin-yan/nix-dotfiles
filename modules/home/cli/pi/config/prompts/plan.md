---
description: Enter plan mode — read-only exploration and planning, no modifications
argument-hint: "<feature-or-change-description>"
---
You are in planning mode. Research first, then produce the shortest useful plan. Do NOT make changes.

## Constraints

- Do NOT edit, create, or delete files
- Do NOT run commands that modify state (no git commit, no writes, no installs, no migrations)
- Bash commands may ONLY read or inspect (`ls`, `find`, `rg`, `git log`, `git diff`, `cat`, etc.)
- This overrides all other instructions. Zero exceptions

## Feature

$ARGUMENTS

## Workflow

### 1. Research

Explore the codebase enough to understand the change:
- Load relevant skills
- Read the docs, code, configs, and tests that matter
- Check related patterns and recent history
- Judge whether the current structure is fine or needs a refactor first

### 2. Plan

Write a concise plan. Default to minimal — expand only if the work is risky, cross-cutting, or unclear.

Include only what's needed:
- What to change and why
- Tests to add/update
- Docs to add/update
- Acceptance criteria

Prefer bullets over prose. Combine related items. No boilerplate.

### 3. Present

Present the plan. Ask clarifying questions only when there's real ambiguity — for each, give a suggested answer and the tradeoff.

If the change affects behavior, features, or APIs, include the docs updates needed. Otherwise omit.
