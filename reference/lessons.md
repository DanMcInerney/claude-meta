# LESSONS.md — Accumulated Debugging Knowledge

## Purpose

LESSONS.md is the repo's institutional memory for non-obvious problems. Every Claude instance reads it before starting work, preventing the same bug from being debugged twice.

## Structure

Hierarchical by impact. Most important lessons at top, smallest at bottom.

```markdown
# Lessons Learned

Document bugs, surprises, and non-obvious solutions here. Consult before starting work.
Structure: most important repo-wide lessons at top, smaller bug fixes at bottom.

---

## Architecture & Design Patterns
<!-- Repo-wide lessons that affect how you design new features -->

### [Short Title]
**Problem:** What happened and why it was surprising.
**Fix:** What was done to resolve it.
**Rule:** The generalizable principle for future work.

---

## Integration & Configuration
<!-- Cross-cutting concerns: build, deploy, environment -->

---

## Module-Specific Bugs
<!-- Narrow fixes in specific files or features -->
```

## What Goes In LESSONS.md

### Yes — Document These:

1. **Bugs where the root cause was non-obvious.** If debugging took more than 5 minutes, the lesson belongs here.

2. **Architectural traps.** Patterns that look correct but fail in specific contexts (e.g., "method A calls method B which changes state, causing the caller's assumption to break").

3. **Framework/library gotchas.** Behavior that contradicts documentation or reasonable expectations.

4. **Convention violations that caused bugs.** If someone broke an implicit rule and it caused a failure, make the rule explicit here.

5. **Token/resource limits.** Concrete numbers for what works and what doesn't (e.g., "keep generated files under 800 lines or agents will truncate").

### No — Skip These:

1. **Obvious bugs** (typos, missing imports, wrong variable names). These don't recur.
2. **One-time setup issues** (installing a dependency, configuring an environment).
3. **Things the compiler/linter catches.** If the tooling prevents it, no lesson needed.
4. **User-specific preferences.** Those belong in CLAUDE.md rules, not lessons.

## Entry Format

Every entry follows the same three-part structure:

```markdown
### [Descriptive Title — What Went Wrong]

**Problem:** [What happened. Be specific — include the error message, the symptom,
and what made it confusing. 2-3 sentences.]

**Fix:** [What was done. Include code if the fix is non-obvious. 1-3 sentences.]

**Rule:** [The generalizable principle. One sentence that future Claude instances
can apply without understanding the full context.]
```

The **Rule** line is the most important. It's what Claude actually uses when deciding how to approach a new task. Make it actionable and specific:

- **Bad rule:** "Be careful with state transitions."
- **Good rule:** "When wrapping game methods that may change state, snapshot game.state before the call and check after — never assume the phase is unchanged."

## Maintenance

- **Add entries immediately** when a non-obvious bug is found. Don't wait.
- **Promote entries** that turn out to apply broadly — move them higher in the hierarchy.
- **Remove entries** when the underlying code changes and the lesson no longer applies.
- **Merge entries** that describe the same root cause from different angles.

## Integration with CLAUDE.md

The root CLAUDE.md should reference LESSONS.md:

```markdown
### LESSONS.md
Consult `LESSONS.md` before starting work to avoid repeating past mistakes.
For every bug, surprise, or non-obvious lesson learned during development,
document it there. Structure is hierarchical: most important repo-wide
lessons at top, smaller bug fixes at bottom.
```

This ensures every Claude instance checks lessons before writing code.
