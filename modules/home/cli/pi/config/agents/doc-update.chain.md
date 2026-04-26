---
name: doc-update
description: Map documentation gaps from recent changes, then update docs to match implementation
---

## context-builder

Analyze recent changes relevant to: {task}

If no scope is given, use git diff main...HEAD or git log --oneline -10 to identify
what changed. For each change, identify: what documentation exists (README, JSDoc,
inline comments, type signatures), what is now stale or missing, and what should be
updated. Output a structured gap list with file:line references.

## worker
progress: true

Update documentation based on the gaps identified: {previous}

Context: {task}

Rules:
- Update in-place — do not create new doc files unless the gap list explicitly calls for it
- Match existing tone and style of surrounding documentation
- JSDoc: complete params, return types, throws, examples where useful
- READMEs: update only stale sections, do not rewrite working sections
- Do NOT modify code — documentation only
