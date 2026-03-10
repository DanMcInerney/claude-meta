# Enforcement: Hooks vs Instructions vs Skills

Three mechanisms for controlling Claude's behavior, each with different guarantees.

## The Spectrum

| Mechanism | Guarantee | Loads when | Use for |
|---|---|---|---|
| **Hook** | Deterministic — always runs | Lifecycle event fires | Hard rules that must never be violated |
| **CLAUDE.md instruction** | Best-effort — may be deprioritized in long contexts | Every conversation | Guidance, conventions, patterns |
| **Skill** | On-demand — loads only when triggered | Context matches or manually invoked | Domain knowledge, complex workflows |

## Hooks (Guaranteed Enforcement)

Shell commands that run at specific lifecycle points. Configure in `.claude/settings.json`.

**Use hooks for:**
- Running formatters/linters after file edits
- Blocking commits to protected branches
- Secret scanning before commits
- Auto-pushing after commits
- Type-checking after edits
- Any rule where "Claude forgot" is unacceptable

```json
{
  "hooks": {
    "PostEditTool": [
      { "command": "npx prettier --write $CLAUDE_FILE_PATHS" }
    ],
    "PreCommit": [
      { "command": "npm run lint && npm run typecheck" }
    ]
  }
}
```

**Key insight:** If you find yourself writing "IMPORTANT: Always run the linter after editing" in CLAUDE.md, that's a hook, not an instruction. Instructions are suggestions. Hooks are laws.

## Hook Taxonomy

Hooks serve different purposes beyond formatting. Use the right hook type for the right job:

| Hook Event | Fires when | Use for |
|---|---|---|
| `PostEditTool` | After any file edit | Formatters, linters |
| `PreToolUse` | Before a tool runs | Blocking dangerous commands, protected paths |
| `PreCommit` | Before git commit | Type-checking, test running, secret scanning |
| `SessionStart` | Session begins | Injecting context (recent tickets, team notes) |
| `Notification` | Claude needs attention | Desktop notifications for long-running sessions |
| `Stop` | Claude finishes responding | Anti-rationalization gates, completion checks |

### Exit Code Semantics

| Exit Code | Meaning | Behavior |
|---|---|---|
| 0 | Success | stdout shown in transcript |
| 2 | Blocking error | stderr fed back to Claude as error message |
| Other non-zero | Non-blocking error | stderr shown, execution continues |

### Hook Placement Strategy

- **Avoid blocking at Edit/Write** — confuses agents mid-plan. Check completed work at commit stage instead.
- **Use `$CLAUDE_PROJECT_DIR`** prefix for hook script paths to ensure reliable resolution.
- **Prefer commit-stage checks** — run tests/linters as PreCommit hooks rather than blocking individual edits.

## CLAUDE.md Instructions (Best-Effort Guidance)

Loaded into context on every conversation. Claude will *usually* follow them, but instruction-following degrades as context grows and instruction count increases.

**Use CLAUDE.md for:**
- Decision trees (which pattern to use)
- API signatures and conventions
- Pitfalls and gotchas
- "How to add X" recipes
- Run/test/deploy commands
- Architectural constraints

**Don't use CLAUDE.md for:**
- Code formatting (use linters + hooks)
- Things Claude already does correctly (delete the instruction)
- Task-specific instructions (put in the prompt, not CLAUDE.md)
- Things that must always happen (use hooks)

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

## Path-Scoped Rules (.claude/rules/)

A hybrid between CLAUDE.md and skills. Rules that load only when Claude touches files matching a glob pattern:

```yaml
---
paths: ["src/api/**/*.ts"]
---
# API Conventions
- All endpoints return {data, error} envelope
- Use Zod for request validation
```

**Use path-scoped rules for:**
- Directory-specific conventions
- Module-specific gotchas
- Area-specific API patterns

## Decision Framework

```
Will Claude's failure to follow this cause a broken build or data loss?
  → Yes: HOOK (guaranteed)
  → No: Does this apply to every conversation?
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
- **Right:** Hook running `prettier --write` after every edit

Claude is an in-context learner. If your code follows conventions consistently, Claude will follow them without being told.
