---
name: create-prd
description: Create and manage prd.json task lists for Ralph AI coding agent. Use when asked to "create tasks", "add task", "create PRD", "break down features", "plan implementation", or when managing Ralph project tasks.
license: MIT
metadata:
  author: chenxin-yan
  version: "0.1.0"
---

# PRD/Task Creation Helper

Create and manage `prd.json` task lists for use with Ralph - an AI coding agent orchestration system.

## When to Apply

Reference this skill when:

- User asks to create, add, update, or manage tasks for Ralph
- Starting a new Ralph project and need to create initial tasks
- Adding a single task or a few tasks incrementally
- Breaking down features into implementable tasks
- Converting a SPEC.md into actionable task items
- Reviewing or refining existing prd.json files
- User asks to "create PRD", "create tasks", "add task", or "plan implementation"

## Context

Ralph runs an AI coding agent in a loop, where each iteration:

1. Agent reads `prd.json` and selects ONE task to work on
2. Agent completes the task and verifies it works
3. Agent marks the task as `passed: true`
4. Loop continues until all tasks are complete

The quality of your task breakdown directly impacts how well the agent performs. Tasks that are too large, too vague, or poorly ordered will cause the agent to struggle or produce inconsistent results.

## Task Guidelines Summary

| Aspect       | Good                       | Bad                          |
| ------------ | -------------------------- | ---------------------------- |
| Size         | Completable in 1-2 hours   | Takes a full day             |
| Subtasks     | Specific, actionable steps | Vague instructions           |
| Verification | Includes test/check steps  | No way to verify             |
| Scope        | Clear boundaries           | Overlapping with other tasks |

## What Makes Good Tasks

### Task Granularity

**The #1 rule: Each task must be completable in a single agent session.**

Guidelines:

- If a human developer could complete it in 1-2 hours, it's probably the right size
- If it would take a full day, break it down further
- If it takes 15 minutes, consider combining with related work

Examples of good granularity:

- "Set up project with TypeScript and configure ESLint"
- "Create User model with authentication fields"
- "Implement POST /api/auth/register endpoint"
- "Add form validation to login page"

Examples of tasks that are TOO LARGE:

- "Build the authentication system" (should be 4-6 tasks)
- "Create the entire API" (should be broken down by resource/feature)
- "Set up the frontend" (too vague, too broad)

### Subtasks

Subtasks are the step-by-step implementation guide. They must be:

**Specific and Actionable**

```json
// GOOD - Agent knows exactly what to do
"subtasks": [
  "Create src/models/user.ts with User interface",
  "Define fields: id (UUID), email (string), passwordHash (string), createdAt (Date)",
  "Add Zod schema for validation",
  "Export UserCreate and UserResponse types",
  "Write unit tests for validation schema"
]

// BAD - Too vague, agent will guess
"subtasks": [
  "Create user model",
  "Add fields",
  "Add validation",
  "Write tests"
]
```

**Include Verification Steps**

Every task should end with verification:

```json
"subtasks": [
  "... implementation steps ...",
  "Run npm test to verify all tests pass",
  "Run npm run typecheck to ensure no type errors",
  "Manually test the endpoint with curl or API client"
]
```

### Notes Field

The `notes` field provides context that helps the agent make good decisions:

```json
"notes": "Use bcrypt for password hashing (already installed). Follow the error response format defined in src/lib/errors.ts. The User model should match the schema in SPEC.md."
```

Good things to include in notes:

- References to decisions in SPEC.md
- Constraints or requirements
- Related files to look at
- Gotchas or edge cases to handle
- Dependencies on previous tasks (as context, not blockers)

### Task Ordering

Ralph has NO explicit priority or dependency fields. The agent infers what to work on based on:

- Task descriptions and context
- Current state of the codebase
- Logical ordering in the task list

**Best practices for ordering:**

1. **Setup tasks first**: Project initialization, configuration, base structure
2. **Core models/types next**: Data structures that other features depend on
3. **Core features**: Main functionality of the application
4. **Integrations**: External services, third-party APIs
5. **Polish**: Error handling improvements, edge cases, optimizations
6. **Testing**: Integration tests, E2E tests (if not done per-feature)

## Anti-patterns to Avoid

### 1. Tasks Too Large

```json
// BAD
{
  "description": "Implement user authentication with registration, login, logout, and password reset",
  "subtasks": ["Build auth system"],
  "notes": "",
  "passed": false
}

// GOOD - Break into multiple tasks
// Task 1: Set up auth infrastructure
// Task 2: Implement registration
// Task 3: Implement login/logout
// Task 4: Implement password reset
```

### 2. Vague Subtasks

```json
// BAD
"subtasks": ["Set up database", "Create models", "Add routes"]

// GOOD
"subtasks": [
  "Install Prisma and initialize with PostgreSQL provider",
  "Create prisma/schema.prisma with User model",
  "Run prisma migrate dev to create tables",
  "Generate Prisma client",
  "Create src/lib/db.ts with singleton client instance"
]
```

### 3. Missing Verification

```json
// BAD - No way to know if it works
"subtasks": [
  "Create login endpoint",
  "Add password checking"
]

// GOOD - Includes verification
"subtasks": [
  "Create POST /api/auth/login endpoint",
  "Validate request body with Zod schema",
  "Query user by email and verify password with bcrypt",
  "Return JWT token on success, 401 on failure",
  "Write tests for success and failure cases",
  "Run npm test to verify tests pass"
]
```

### 4. Overlapping Scope

```json
// BAD - These tasks overlap
{
  "description": "Create User model",
  "subtasks": ["Define User schema", "Add validation", "Create API routes"]
},
{
  "description": "Build user API",
  "subtasks": ["Create routes for users", "Add validation"]  // Overlap!
}

// GOOD - Clear boundaries
{
  "description": "Create User model and validation schemas",
  "subtasks": ["Define User schema", "Add Zod validation", "Export types"]
},
{
  "description": "Implement User CRUD API endpoints",
  "subtasks": ["Create GET /api/users", "Create POST /api/users", "..."]
}
```

## How to Use This Skill

This skill supports two main workflows:

1. **Full PRD Creation**: Creating a complete task list from a spec or project description
2. **Incremental Task Management**: Adding tasks one by one as the user requests them

### Workflow Selection

**Follow what the user asks you to do.** Determine the workflow based on the user's request:

- If user asks to "create PRD", "create all tasks", "plan the project", or "break down [feature/spec]" → Use **Full PRD Creation**
- If user asks to "add a task", "create a task for X", or describes a single feature to add → Use **Incremental Task Management**
- If unclear, ask the user which approach they prefer

---

## Workflow A: Full PRD Creation

Use this workflow when creating a complete task list from scratch.

### Step A1: Get the Project Spec

First, you need to understand what you're building. Follow this decision tree:

1. **Check for `SPEC.md`**: If it exists in the project root, read it and proceed to Step A2.

2. **If no SPEC.md exists**, check if the user provided a description or requirements in their message:
   - If yes, use that as your project understanding and proceed to Step A2.

3. **If no SPEC.md AND no user description**, explore the codebase first:
   - Skim the directory structure to understand project organization
   - Look at `package.json`, `pyproject.toml`, `Cargo.toml`, or similar manifests for dependencies and project type
   - Read key entry files (e.g., `src/index.ts`, `main.py`, `app.ts`, `README.md`)
   - Check for existing routes, models, components, or other structural patterns
   - Look at any existing tests to understand intended behavior

   **If the codebase has sufficient code** (meaningful implementation, not just boilerplate):
   - Summarize what you've learned about the project: its purpose, tech stack, current features, and apparent architecture
   - Present this understanding to the user and ask them to confirm or clarify
   - Ask what additional features or tasks they want to accomplish

   **If the codebase is empty or only has minimal boilerplate**:
   - Ask the user to describe their project so you can help create tasks
   - Offer to help them create a SPEC.md first if they'd like structured planning

### Step A2: Analyze the Spec

From the spec, identify:

1. **Setup requirements**: Project initialization, tooling, configuration
2. **Core data models**: Entities that need to be created
3. **Features**: Functionality to implement (break large features into tasks)
4. **API endpoints**: If building an API, each resource may be 1-3 tasks
5. **Frontend components**: If applicable, group by page or feature
6. **Integrations**: External services to connect
7. **Testing requirements**: Unit tests, integration tests, E2E tests

### Step A3: Propose Task Breakdown

Create a task list following this process:

1. Start with project setup/initialization
2. Add data model/schema tasks
3. Break each feature into appropriately-sized tasks
4. Add integration tasks
5. Include verification/testing tasks
6. Review for proper ordering

### Step A4: Get User Feedback

Present the proposed task list and ask:

- Does this ordering make sense?
- Are any tasks too large or too small?
- Did I miss any features from the spec?
- Any tasks that should be combined or split?

### Step A5: Refine and Output

Incorporate feedback and generate the final `prd.json`.

---

## Workflow B: Incremental Task Management

Use this workflow when adding tasks one at a time based on user requests.

### Step B1: Understand the Request

Listen to what the user wants to accomplish. They might say:

- "Add a task to implement user authentication"
- "Create a task for setting up the database"
- "I need a task that adds dark mode support"

### Step B2: Check Existing Context

1. **Read existing `prd.json`** if it exists to understand:
   - What tasks already exist (avoid duplicates or overlaps)
   - The current state of the project (which tasks are passed)
   - The style and granularity used in existing tasks

2. **Briefly explore the codebase** if needed to understand:
   - Tech stack and patterns in use
   - Where the new feature should integrate
   - Any relevant existing code to reference in notes

### Step B3: Create the Task

Based on the user's request, create a single well-formed task:

1. Write a clear `description` that captures the end goal
2. Break down into specific, actionable `subtasks`
3. Include verification steps
4. Add helpful `notes` with context, constraints, or references
5. Set `passed` to `false`

### Step B4: Present and Confirm

Show the proposed task to the user:

```json
{
  "description": "...",
  "subtasks": [...],
  "notes": "...",
  "passed": false
}
```

Ask if they want to:

- Modify anything about the task
- Add it to `prd.json`
- Create additional related tasks

### Step B5: Add to prd.json

Once confirmed:

- If `prd.json` exists, append the new task to the `tasks` array
- If `prd.json` doesn't exist, create it with the new task
- Consider placement: ask the user where it should go, or place it logically based on dependencies

### Incremental Mode Tips

- **Keep context between requests**: If the user is adding multiple tasks in a session, remember what was already added
- **Suggest related tasks**: If you notice the user's task implies other work, offer to create those tasks too
- **Respect user's pace**: Don't push for a complete PRD if the user wants to work incrementally
- **Handle modifications**: If the user wants to edit an existing task, help them update it

## Output Format

Generate valid JSON following this schema:

```json
{
  "tasks": [
    {
      "description": "End goal - what should be achieved when this task is complete",
      "subtasks": ["Specific step 1", "Specific step 2", "Verification step"],
      "notes": "Context, constraints, and helpful tips for the agent",
      "passed": false
    }
  ]
}
```

**Field descriptions:**

- `description` (string): The end goal of the task. Should be clear and specific.
- `subtasks` (string[]): Ordered list of specific, actionable implementation steps.
- `notes` (string): Context, constraints, references, or tips. Can be empty string.
- `passed` (boolean): Always `false` for new tasks. Agent sets to `true` when complete.

## Example Tasks

### Example 1: Project Setup

```json
{
  "description": "Initialize project with TypeScript, ESLint, and Prettier",
  "subtasks": [
    "Run npm init -y to create package.json",
    "Install TypeScript and initialize with npx tsc --init",
    "Configure tsconfig.json with strict mode, ES2022 target, and path aliases",
    "Install and configure ESLint with TypeScript plugin",
    "Install and configure Prettier with ESLint integration",
    "Add scripts to package.json: build, typecheck, lint, format",
    "Create src/index.ts with a simple console.log to verify setup",
    "Run npm run build and npm run typecheck to verify configuration"
  ],
  "notes": "Use ESM modules (type: module in package.json). Target Node.js 18+.",
  "passed": false
}
```

### Example 2: Data Model

```json
{
  "description": "Create User model with Prisma schema and TypeScript types",
  "subtasks": [
    "Add User model to prisma/schema.prisma with fields: id, email, passwordHash, name, createdAt, updatedAt",
    "Set id as UUID with @default(uuid())",
    "Add unique constraint on email",
    "Run npx prisma migrate dev --name add-user-model",
    "Create src/types/user.ts with User, UserCreate, and UserResponse types",
    "Create src/lib/validation/user.ts with Zod schemas",
    "Run npx prisma generate to update client",
    "Run npm run typecheck to verify types"
  ],
  "notes": "Ensure passwordHash is never included in UserResponse type. Email should be lowercase and trimmed.",
  "passed": false
}
```

### Example 3: API Endpoint

```json
{
  "description": "Implement POST /api/auth/register endpoint",
  "subtasks": [
    "Create src/routes/auth/register.ts",
    "Add POST handler that accepts { email, password, name }",
    "Validate request body using Zod schema from src/lib/validation/user.ts",
    "Check if user with email already exists, return 409 if so",
    "Hash password with bcrypt (12 rounds)",
    "Create user in database with Prisma",
    "Return 201 with user data (excluding passwordHash)",
    "Write tests in tests/routes/auth/register.test.ts",
    "Test: successful registration returns 201",
    "Test: duplicate email returns 409",
    "Test: invalid email format returns 400",
    "Run npm test to verify all tests pass"
  ],
  "notes": "Follow error response format in src/lib/errors.ts. Use the db client from src/lib/db.ts.",
  "passed": false
}
```

## Validation Checklist

Before finalizing any task (whether single or full PRD), verify:

- [ ] Every task can be completed in a single agent session
- [ ] Subtasks are specific and actionable (not vague)
- [ ] Each task includes verification/testing steps
- [ ] Tasks are ordered logically (setup -> models -> features -> polish)
- [ ] No overlapping scope between tasks
- [ ] Notes provide helpful context where needed
- [ ] The JSON is valid and follows the schema

## Summary: Following User Intent

**Always follow what the user prompts you to do:**

| User Says                                                    | Action                               |
| ------------------------------------------------------------ | ------------------------------------ |
| "Create PRD", "Plan the project", "Break down the spec"      | Full PRD Creation (Workflow A)       |
| "Add a task", "Create a task for X", "I need a task that..." | Incremental Task (Workflow B)        |
| "Add these tasks: X, Y, Z"                                   | Multiple incremental tasks           |
| "Update task X", "Modify the task for..."                    | Edit existing task in prd.json       |
| "What tasks do I have?"                                      | Read and summarize prd.json          |
| Unclear request                                              | Ask the user to clarify their intent |

The key principle: **This skill helps you manage tasks for Ralph. Adapt to what the user needs rather than forcing a specific workflow.**
