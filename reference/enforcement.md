# Enforcement: Instructions vs Path-Scoped Rules vs Skills

Three mechanisms for controlling Claude's behavior, each with different tradeoffs.

## The Spectrum

| Mechanism | Guarantee | Loads when | Use for |
|---|---|---|---|
| **CLAUDE.md instruction** | Best-effort — may be deprioritized in long contexts | Every conversation | Guidance, conventions, patterns |
| **Path-scoped rule** | Best-effort — scoped to matching files | Claude touches a matching file | Directory-specific conventions |
| **Skill** | On-demand — loads only when triggered | Context matches or manually invoked | Domain knowledge, complex workflows |

## CLAUDE.md Instructions (Every Conversation)

Loaded into context on every conversation. Claude will *usually* follow them, but instruction-following degrades as context grows and instruction count increases.

**Use CLAUDE.md for:**
- Decision trees (which pattern to use)
- API signatures and conventions
- Pitfalls and gotchas
- "How to add X" recipes
- Run/test/deploy commands
- Architectural constraints

**Don't use CLAUDE.md for:**
- Code formatting (use linters instead)
- Things Claude already does correctly (delete the instruction)
- Task-specific instructions (put in the prompt, not CLAUDE.md)

## Path-Scoped Rules (.claude/rules/)

A scoped version of CLAUDE.md. Rules that load only when Claude touches files matching a glob pattern:

```yaml
---
paths: ["src/api/**/*.ts", "src/middleware/**"]
---
# API Conventions
- All endpoints return {data, error, metadata} envelope
- Use Zod schemas for request validation
- Never throw — return Result types
```

**Use path-scoped rules for:**
- Directory-specific conventions
- Module-specific gotchas
- Area-specific API patterns

This keeps specialized rules out of root CLAUDE.md, saving context budget.

## Skills (On-Demand Domain Knowledge)

Packaged domain knowledge that loads only when relevant. More token-efficient than CLAUDE.md for specialized knowledge.

**Use skills for:**
- Complex multi-step workflows (TDD, code review, deployment)
- Domain-specific procedures (database migrations, API design)
- Infrequent but important processes
- Knowledge that only applies to certain task types

Skills live in `.claude/skills/` with `SKILL.md` files containing YAML frontmatter for auto-triggering:

```yaml
---
name: database-migration
description: Use when creating or modifying database schemas
---
# Database Migration Workflow
1. Create Alembic revision...
```

## Decision Framework

```
Does this apply to every conversation?
  → Yes: CLAUDE.md instruction
  → No: Does this apply to a specific directory?
    → Yes: Path-scoped rule (.claude/rules/)
    → No: Does this apply to a specific task type?
      → Yes: SKILL
      → No: Put it in the prompt when needed
```

## The "Never a Linter's Job" Rule

Code style (indentation, formatting, naming conventions, import ordering) is the #1 thing people put in CLAUDE.md that shouldn't be there. LLMs are expensive and unreliable formatters. Linters are cheap and deterministic.

- **Wrong:** `CLAUDE.md: "Use 2-space indentation, single quotes, trailing commas"`
- **Right:** Configure a linter/formatter in the project

Claude is an in-context learner. If your code follows conventions consistently, Claude will follow them without being told.
