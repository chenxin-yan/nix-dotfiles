---
name: test-coverage
description: Map untested code paths then write tests for each gap
---

## scout

Map untested code paths relevant to: {task}

If no scope is given, focus on recently changed files (`git log --oneline -20`).

## worker

Write tests for the gaps. These are tests for **existing** code — they should pass
on first run, which overrides the standard red-then-green TDD rule.

Context: {task}

## reviewer

Validate the new tests against the gap list and the code under test, for: {task}
