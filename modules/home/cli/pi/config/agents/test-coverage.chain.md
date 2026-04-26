name: test-coverage
description: Map untested code paths then write tests for each gap

## context-builder

Scan for untested code paths relevant to: {task}

If no specific scope is given, focus on recently changed files (git log --oneline -20).
For each gap output: file path, function/component name, what needs to be tested, and
why (edge case, error path, happy path).

## worker
progress: true

Write tests for the coverage gaps identified in the previous step: {previous}

Context: {task}

Rules:
- TDD: write the test first, confirm it fails for the right reason
- Follow existing test patterns in the codebase
- Cover exactly the gaps identified — no speculative tests
