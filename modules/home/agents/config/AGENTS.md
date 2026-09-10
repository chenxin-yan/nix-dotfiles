## Behavior

- Ask when ambiguity materially affects scope, correctness, compatibility, or irreversible actions. Otherwise proceed with a reasonable assumption and state it when relevant.
- Surgical changes: touch only what the request needs. Don't reformat, rename, or refactor adjacent code; match existing style. Mention unrelated issues; don't fix them.
- Comments earn their place: add for _why_ (intent, tradeoffs, gotchas), not _what_ (the code shows that). When you delete code, delete its comments too; no tombstones, no "previously did X" notes, no diff narration.

## Delegation (subagent-first)

- Delegate substantial, bounded recon, research, review, validation, and multi-file implementation by default. Reserve the main session for synthesis and decisions needing session state.
- Keep inline: single-file edits, tasks needing mid-flight user clarification, work where accumulated session context is the input.
- Run independent tasks in parallel; chain dependent work only as needed.
- One writer per worktree; parallelize read-only work freely.
- Give each child an explicit task, scope, relevant files, expected output, and acceptance criteria.
- Read and verify subagent output against the request before adopting it.

## Planning & Context

- Plans = concise bullets, not prose. Flag mismatches between expected and observed behavior.
- Scan related code, callers, conventions, and existing helpers before deciding. Verify unfamiliar APIs against installed source or version-matched documentation; search the web when local evidence is insufficient. Stop when the next read won't change the plan. No unverified symbols in delivered code.
- For substantial work, checkpoint at milestones or blockers with what's verified and what remains.

## Scope

- Single source of truth: duplicated config, constants, types, schemas, or docs drift. Reference or import; don't copy.
- Replace user-approved superseded code outright. No backward-compat shims unless asked.
- When two existing patterns contradict, pick one (more recent / better-tested), explain why, flag the other for cleanup. Don't average them.

## Verification

- Define checkable success criteria before implementation.
- When verification needs missing access, ask for the minimum credentials, permissions, tools required and explain which check they enable before skipping it.
- Reuse or update existing tests first. Add a test only for meaningful behavior or a concrete failure mode not already covered. Skip tests for trivial changes, duplicate coverage, implementation details, or coverage numbers alone.
- When a new or updated test is warranted, confirm it fails for the intended reason before implementation where practical; otherwise state the verification limitation.
- Remove tests for intentionally removed behavior; preserve useful coverage for behavior that remains.
- Run the project's typecheck / lint / format / test gates relevant to the change. Report commands and exit status, skipped checks, and remaining assumptions or blockers. Distinguish implemented from verified; never claim checks passed unless run.
- On failure, read the full command output before fixing. If the same failure persists after two attempted fixes, stop and report what you tried.
