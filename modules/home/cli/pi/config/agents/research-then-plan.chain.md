name: research-then-plan
description: Scout codebase for context, then delegate to planner to write PLAN.md

## scout

Scan the codebase for context relevant to: {task}

Output a concise summary covering: relevant files and their purpose, existing patterns
and conventions, related types and interfaces, and prior work in this area. Be specific
— include actual file paths and function names.

## planner
progress: true

Create a detailed implementation plan for: {task}

Codebase context from scout: {previous}

Write the final implementation plan to PLAN.md in the project root.
