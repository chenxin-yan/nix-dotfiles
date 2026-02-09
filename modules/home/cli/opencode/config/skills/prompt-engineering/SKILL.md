---
name: prompt-engineering
description: Guide for writing effective prompts, system prompts, and agent instructions. Use this skill when the user asks for help crafting, improving, or debugging prompts for LLMs, AI agents, or system prompt design.
---

Help the user write better prompts by applying these techniques in priority order. Match technique to need — don't over-engineer simple prompts.

## Technique Selection

```
Vague/unclear prompt?         → Apply CLARITY
Complex multi-part task?      → Apply STRUCTURE (XML tags)
Model needs format/style?     → Apply EXAMPLES (few-shot)
Reasoning or logic problem?   → Apply CHAIN OF THOUGHT
Agent/system behavior?        → Apply ROLE DEFINITION
Specific output needed?       → Apply OUTPUT FORMAT
Prompt too long/expensive?    → Apply TOKEN OPTIMIZATION
```

## 1. Clarity & Directness [CRITICAL — 15-25% improvement]

Replace vague instructions with specific, unambiguous requirements. Define success criteria.

```
BAD:  "Explain React"
GOOD: "Explain how React's useEffect hook works. Cover:
       1) What problem it solves
       2) When it runs (mounting, dependency changes)
       3) Common pitfall: infinite loops
       4) Code example showing correct cleanup"
```

- Use specific nouns, not "thing" or "stuff"
- State what you want, not what you don't want
- Include measurable success criteria when possible

## 2. Structure with XML Tags [CRITICAL — 20-40% improvement]

Organize complex prompts with tags. Claude parses these more accurately than prose.

```xml
<task>
  <objective>Generate a commit message</objective>
  <instructions>
    <instruction>Follow conventional commits: type(scope): description</instruction>
    <instruction>Keep subject under 50 characters</instruction>
  </instructions>
  <examples>
    <example>feat(auth): add JWT token validation</example>
  </examples>
  <constraints>
    <constraint>Use imperative mood</constraint>
  </constraints>
</task>
```

- Be consistent with tag names across your prompt
- Nest tags for hierarchical content
- Combine with other techniques inside tags

## 3. Examples / Few-Shot [HIGH — 10-30% improvement]

Show 2-3 input/output pairs. Examples teach format and style better than descriptions.

```
Format commit messages like these:

Input: "Added authentication with JWT"
Output: "feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware"

Input: "Fixed date display bug"
Output: "fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation"

Now format this: $INPUT
```

- Include both correct and incorrect examples when clarifying boundaries
- Match examples to the exact format/style you want
- 2-3 examples usually sufficient; more rarely helps

## 4. Chain of Thought [HIGH — 20-50% improvement on reasoning]

For complex reasoning, math, or multi-step logic, ask for step-by-step thinking.

```
Analyze this code for potential race conditions.
Think through this step by step:
1. Identify all shared mutable state
2. Trace concurrent access patterns
3. Check for missing synchronization
4. Propose fixes with rationale
```

- Works best for: reasoning, math, debugging, architecture decisions
- Trade-off: longer responses, more tokens
- Can combine with XML: `<thinking>...</thinking>` then `<answer>...</answer>`

## 5. Role Definition [HIGH — 15-25% improvement]

Define specific expertise in system prompts. More effective than generic "helpful assistant."

```
You are a senior backend architect with 15 years of experience
in cloud-native systems. Your expertise:
- Microservices architecture and Kubernetes
- Performance optimization and observability
- API design (REST, GraphQL, gRPC)

When answering:
1. Provide architectural context first
2. Consider scalability implications
3. Reference industry patterns by name
4. Flag potential operational concerns
```

- Place role in system prompt, not user prompt
- Include specific expertise areas, not just a title
- Define communication style and behavioral guidelines

## Common Mistakes

| Mistake                    | Fix                                           |
| -------------------------- | --------------------------------------------- |
| "Be helpful"               | Specific task + success criteria              |
| No examples given          | Add 2-3 input/output pairs                    |
| Generic role ("assistant") | Specific expertise + background               |
| Everything in one prompt   | Break into plan -> validate -> execute        |
| No output format           | Define schema or structure explicitly         |
| No boundaries              | State knowledge limits, prevent hallucination |

## Quick Checklist

Before finalizing any prompt, verify:

- [ ] Is it specific? (not vague)
- [ ] Are requirements explicit?
- [ ] Is it structured? (sections, tags if complex)
- [ ] Are examples included? (if format matters)
- [ ] Is success defined?
- [ ] Are boundaries clear?
