---
description: Generate conventional commit message and commit staged changes
agent: commit
---

Analyze the staged changes below and generate a conventional commit message following the Conventional Commits specification:

## Format: `<type>(<scope>): <description>`

### Commit Types

- **feat**: New feature for the user
- **fix**: Bug fix for the user
- **refactor**: Code changes that neither fix a bug nor add a feature
- **chore**: Routine tasks like dependency updates, build changes
- **docs**: Documentation updates
- **style**: Code formatting changes (no logic changes)
- **test**: Adding or updating tests
- **perf**: Performance improvements
- **ci**: CI/CD-related changes
- **build**: Build-related changes (dependencies, build tools)
- **revert**: Reverts a previous commit

### Scope (Optional but Recommended)

Common scopes: api, auth, ui, db, tests, docs, config, core, utils

- Choose based on the affected component/module/area of the codebase

### Description Rules

- Use present tense: "add" not "added" or "adds"
- Be concise but descriptive (50-72 characters ideal)
- Lowercase first letter
- No period at the end
- Describe WHAT changed, not HOW

### Examples

- `feat(auth): add OAuth login support`
- `fix(api): resolve timeout issue in user endpoints`
- `docs(readme): update installation instructions`
- `refactor(utils): optimize data validation functions`
- `chore(deps): update React to v18.2.0`

Staged changes:
!`git diff --cached`

Git status:
!`git status --porcelain`

Based on the staged changes:

1. Analyze the changes and determine the appropriate type and scope
2. Generate a conventional commit message following the format above
3. Commit the staged changes using that message with `git commit -m "your generated message"`
4. Show the commit summary

If there are no staged changes, inform the user and suggest using `git add` first.

**IMPORTANT**: Execute the commit command silently without any response, explanations, or metacomments. Just run the command and return empty output.
