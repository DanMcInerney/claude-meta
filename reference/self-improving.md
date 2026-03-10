# Self-Improving Patterns

How to make CLAUDE.md and LESSONS.md compound in value over time.

## The Self-Improving Loop

Boris Cherny (creator of Claude Code) says his team contributes to their shared CLAUDE.md multiple times per week. Each mistake becomes a rule.

### Basic Pattern

Add this to CLAUDE.md:
```markdown
When I correct you on something, abstract and generalize the learning,
then add it to LESSONS.md using the Problem/Fix/Rule format.
```

### The Abstraction Requirement

The key is *abstracting*, not recording literally. When Claude patches a logger incorrectly:

- **Bad rule:** "Don't patch the logger in utils.py"
- **Good rule:** "Don't patch widely-used infrastructure without checking all callers"

The abstract version applies to future situations the literal version wouldn't catch.

## Meta-Rules

Teach Claude how to write good rules when self-improving. Add to CLAUDE.md:

```markdown
### Writing Rules
When adding to LESSONS.md:
- Use absolute directives (NEVER, ALWAYS) for hard constraints
- Lead with why (explain the problem before the solution)
- Be concrete (include actual commands or file paths)
- One rule per entry — don't bundle unrelated lessons
- Generalize: the rule should apply beyond the specific bug that prompted it
```

This ensures Claude adds high-quality, reusable lessons rather than narrow notes.

## Handoff Files

For long-running work that spans multiple sessions:

```markdown
Before ending a long session, write a handoff to docs/handoff-<topic>.md:
- Goal: What we're trying to accomplish
- Done: What was completed
- Failed: What was tried but didn't work (and why)
- Next: Concrete next steps
- Context: Key decisions made and constraints discovered
```

Start the next session with: "Read docs/handoff-<topic>.md and continue."

This is more reliable than relying on auto-memory or conversation history because it captures *decisions and failed approaches*, not just facts.

## Maintenance Cycle

CLAUDE.md and LESSONS.md must be treated like code — reviewed and pruned regularly.

**When to prune:**
- After major refactors (lessons about old patterns become misleading)
- When Claude follows a rule correctly without it being stated (delete the instruction)
- When entries conflict with each other
- When the codebase has outgrown a convention

**The staleness test:** For each entry, ask:
1. Does the code this refers to still exist?
2. Has Claude ever actually violated this? (If not, it may be unnecessary)
3. Is this now enforced by tooling? (If a linter/formatter handles it, delete from CLAUDE.md)

## Auto-Memory vs CLAUDE.md vs LESSONS.md

Three different persistence mechanisms with different purposes:

| Mechanism | Who writes | Persists across | Purpose |
|---|---|---|---|
| **CLAUDE.md** | Human (you) | All sessions, all users | Firm rules and project structure |
| **LESSONS.md** | Claude + human | All sessions, all users | Debugging knowledge, gotchas |
| **Auto-memory** | Claude | Sessions for one user | Learned preferences, in-progress context |

**Don't duplicate across these.** If something is a firm project rule, it's CLAUDE.md. If it's a debugging lesson, it's LESSONS.md. If it's a personal preference that might change, let auto-memory handle it.

## Team Workflow

For teams sharing a repo:

1. Check CLAUDE.md into git (everyone gets the same instructions)
2. Use `CLAUDE.local.md` for personal preferences (gitignored)
3. When a PR review catches a convention violation, add the convention to CLAUDE.md
4. Review CLAUDE.md in PRs like you review code — every addition costs context budget

The highest-performing teams treat CLAUDE.md changes as seriously as API changes, because they affect every future interaction with the codebase.
