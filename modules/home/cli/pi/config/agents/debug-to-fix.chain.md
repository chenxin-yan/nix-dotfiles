name: debug-to-fix
description: Localize a bug, research similar patterns, then propose and implement a fix

## scout
output: bug-report.md

Trace and localize this bug: {task}

Output: the exact files and lines involved, the call stack or data flow leading to the
issue, your root cause hypothesis, and relevant context such as recent changes or
related code.

## researcher
reads: bug-report.md
output: research-summary.md

Given the bug report in bug-report.md, research similar patterns and known solutions.

Context: {task}

Search git log and grep for similar issues in this codebase. Use web search for
relevant external docs or known library bugs. Output your findings as a research summary.

## worker
reads: bug-report.md research-summary.md
progress: true

Propose and implement a fix for the bug in bug-report.md, informed by research-summary.md.

Context: {task}

Rules:
- Explain the fix before making changes
- Make the minimal change necessary
- Add a regression test
- Run the eval loop after: tests, type-check, lint
