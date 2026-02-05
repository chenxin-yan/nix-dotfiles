---
name: create-spec
description: Create or refine SPEC.md technical specifications for Ralph AI coding agent. Use when asked to "create spec", "write specification", "define requirements", "plan architecture", or when setting up a new project.
license: MIT
metadata:
  author: chenxin-yan
  version: "0.1.0"
---

# SPEC Creation Helper

Create or refine `SPEC.md` files for use with Ralph - an AI coding agent orchestration system.

## When to Apply

Reference this skill when:

- Starting a new project and need to define requirements
- Converting user ideas into structured specifications
- Reviewing or improving existing SPEC.md files
- User asks to "create spec", "write specification", or "define requirements"
- Planning architecture before implementation

## Context

Ralph is a methodology for running AI coding agents in a continuous loop. The agent reads `SPEC.md` at the start of every iteration to understand what it's building. A well-written spec is critical because:

- It provides the "why" behind the project
- It guides technical decisions when the agent faces ambiguity
- It prevents scope creep by defining boundaries
- It ensures consistency across multiple agent sessions

## SPEC.md Quality Checklist

| Section         | Required    | Purpose                         |
| --------------- | ----------- | ------------------------------- |
| Overview        | Yes         | What, why, and who              |
| Features        | Yes         | Concrete, testable requirements |
| Technical Stack | Yes         | Eliminate technology guesswork  |
| Architecture    | Recommended | System structure guidance       |
| Constraints     | Recommended | Non-functional requirements     |

## What Makes a Good SPEC.md

### 1. Overview

- **What**: Clear, concise description of what you're building
- **Why**: The problem it solves or value it provides
- **Who**: Target users or audience

A vague overview leads to vague implementations. Be specific.

### 2. Features

- List concrete features, not aspirations
- Each feature should be implementable and testable
- Avoid feature creep - if it's not essential for now, put it in "Out of Scope"

### 3. Technical Stack

Explicit technology decisions eliminate guesswork:

- **Language**: Be specific (e.g., "TypeScript 5.x with strict mode")
- **Framework**: Include version preferences if relevant
- **Database**: Specify the database AND how it will be accessed (ORM, raw SQL, etc.)
- **Infrastructure**: Docker, cloud provider, deployment target
- **Key Libraries**: Authentication, validation, testing frameworks

### 4. Architecture

Help the agent understand the system structure:

- High-level architecture diagram or description
- Directory structure (what goes where)
- Key architectural patterns (MVC, Clean Architecture, etc.)
- How components communicate

### 5. Requirements

Non-functional requirements that guide implementation:

- **Performance**: Response time targets, throughput requirements
- **Security**: Authentication method, authorization rules, data protection
- **Compatibility**: Node version, browser support, OS requirements
- **Code Quality**: Testing requirements, linting rules, type safety

### 6. References

Link to relevant resources:

- Design mockups or wireframes
- API documentation for external services
- Similar projects for inspiration
- Technical documentation

## Common Mistakes to Avoid

### Vague Features

```markdown
// BAD - Not actionable

- Good user experience
- Fast performance
- Modern design

// GOOD - Specific and testable

- User can reset password via email link
- API responses under 200ms for 95th percentile
- Responsive layout supporting mobile (375px) to desktop (1440px)
```

### Missing Technical Decisions

```markdown
// BAD - Agent will guess

## Technical Stack

- Some backend framework
- A database

// GOOD - No ambiguity

## Technical Stack

- **Language**: TypeScript 5.x with strict mode
- **Framework**: Next.js 14 with App Router
- **Database**: PostgreSQL 15 with Prisma ORM
```

### No Boundaries

A spec without "Out of Scope" invites scope creep. The agent may:

- Add features you didn't ask for
- Over-engineer simple solutions
- Spend time on edge cases that don't matter yet

Always define what the project will NOT do.

## How to Use This Skill

### If the user has an existing SPEC.md

1. Read the file and analyze its completeness
2. Identify missing or weak sections
3. Ask clarifying questions to fill gaps
4. Suggest specific improvements
5. Help refine until the spec is comprehensive

### If starting from scratch

Guide the user through these questions:

1. **Project Vision**
   - What are you building in one sentence?
   - What problem does it solve?
   - Who will use it?

2. **Scope**
   - What are the must-have features for v1?
   - What can wait for later versions?

3. **Technical Decisions**
   - What language/framework do you want to use? Why?
   - What database fits your needs?
   - Any specific libraries or tools you want to use?

4. **Architecture**
   - Is this a monolith, microservices, or serverless?
   - What's the expected directory structure?

5. **Constraints**
   - Any performance requirements?
   - Security considerations?
   - Compatibility requirements?

## Output Format

Generate a complete `SPEC.md` following this template structure:

```markdown
# Project Name

> One-line description of the project.

## Overview

[2-3 paragraphs explaining what you're building, the problem it solves, and who it's for]

## Features

- Feature 1
- Feature 2
- Feature 3

## Technical Stack

- **Language**: [e.g., TypeScript 5.x]
- **Framework**: [e.g., Next.js 14 with App Router]
- **Database**: [e.g., PostgreSQL with Prisma ORM]
- **Authentication**: [e.g., NextAuth.js with JWT]
- **Testing**: [e.g., Vitest for unit tests, Playwright for E2E]
- **Other**: [Any other key technologies]

## Architecture

[Describe the architecture of the project]

## Requirements

- [e.g., API response time < 200ms for 95th percentile]
- [e.g., All endpoints require authentication except /api/auth/*]
- [e.g., Passwords hashed with bcrypt, minimum 12 rounds]
- [e.g., Node.js 18+, modern browsers only]
- [e.g., 80% test coverage minimum]
- [e.g., All code must pass TypeScript strict mode]

## References

- [Link to design mockups]
- [Link to external API docs]
- [Link to similar projects]
```

## Validation Checklist

Before finalizing, ensure the spec:

- [ ] Has a clear, specific project overview
- [ ] Lists concrete, implementable features
- [ ] Specifies all major technology choices
- [ ] Defines data models with field types
- [ ] States requirements
