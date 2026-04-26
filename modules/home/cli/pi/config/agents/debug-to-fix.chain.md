name: debug-to-fix
description: Localize a bug, research similar patterns, then propose and implement a fix

## scout

Trace and localize this bug: {task}

Output: the exact files and lines involved, the call stack or data flow leading to the
issue, your root cause hypothesis, and relevant context such as recent changes or
related code.

## researcher

Given this bug report from scout: {previous}

Research similar patterns and known solutions for: {task}

Search git log and grep for similar issues in this codebase. Use web search for
relevant external docs or known library bugs. Include the full bug context in your
output so the next step has everything it needs.

## worker
progress: true

Based on this bug analysis and research: {previous}

Propose and implement a fix for: {task}

Rules:
- Explain the fix before making changes
- Make the minimal change necessary
- Add a regression test
- Run the eval loop after: tests, type-check, lint
