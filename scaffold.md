# Scaffold Template

Use this as the skeleton when generating CLAUDE.md for a new project. Fill in the brackets. Delete sections that don't apply. Result must be ≤150 lines.

---

## CLAUDE.md Template

```markdown
# [Project Name]

[1-2 sentence description. Tech stack. Primary language.]

## Quick Start

| You want to... | Do this | Key files |
|---|---|---|
| [Most common task] | [Pattern/approach] | [Paths] |
| [Second most common] | [Pattern/approach] | [Paths] |
| [Third most common] | [Pattern/approach] | [Paths] |

## Commands

\`\`\`bash
[dev command]       # Run dev server / start app
[test command]      # Run tests
[lint command]      # Lint (if no hook)
[build command]     # Build for production
[deploy command]    # Deploy (if applicable)
\`\`\`

## Verification

\`\`\`bash
[test command]                 # Run after every change — fix failures before moving on
[type-check command]           # Expected: no errors
\`\`\`

## File Structure

\`\`\`
[3-8 lines showing top-level structure]
[Point to subdirectory CLAUDE.md files where they exist]
\`\`\`

## Things That Will Bite You

1. [Most common gotcha for this tech stack]
2. [Second most common]
3. [Project-specific trap]
...

## LESSONS.md

Consult `LESSONS.md` before starting work. Document all non-obvious bugs
and lessons there. Hierarchical: repo-wide at top, specific at bottom.

## Before You Ship

After implementation is complete, run these before committing final code:

1. Run `/review` to catch logic errors, edge cases, and regressions
2. Review for security: "Review this codebase for OWASP top 10 vulnerabilities, hardcoded secrets, injection risks, and broken access control. Fix any issues found."

See `REVIEW.md` for project-specific review guidelines.

## Context Management

When compacting, preserve: modified file list, failing tests, current task.
```

---

## LESSONS.md Template

```markdown
# Lessons Learned

Document bugs, surprises, and non-obvious solutions here. Consult before starting work.
Structure: most important repo-wide lessons at top, smaller bug fixes at bottom.

---

## Architecture & Design Patterns
<!-- Repo-wide lessons that affect how you design new features -->

---

## Integration & Tooling
<!-- Build, deploy, environment, CI/CD lessons -->

---

## Module-Specific Bugs
<!-- Narrow fixes in specific files or features -->
```

---

## REVIEW.md Template

```markdown
# Code Review Guidelines

## Always check
- [Domain-specific correctness rule, e.g. "New API endpoints have integration tests"]
- [Data integrity rule, e.g. "Database migrations are backward-compatible"]
- [Security rule, e.g. "Error messages don't leak internal details"]
- No hardcoded secrets, API keys, or credentials
- No SQL injection, XSS, or command injection vulnerabilities

## Style
- [Project-specific style preference, e.g. "Prefer early returns over nested conditionals"]
- [Framework convention, e.g. "Use structured logging, not f-string interpolation"]

## Skip
- Generated files under [generated code path]
- Formatting-only changes
```

---

## Common Pitfalls by Domain

Seed the "Things That Will Bite You" section with domain-relevant gotchas:

### Web API
- CORS must be configured for cross-origin requests
- Auth middleware ordering matters — put it before route handlers
- Environment variables for secrets, never hardcode

### CLI Tool
- Exit codes: 0 = success, 1 = error, 2 = usage error
- stderr for errors/progress, stdout for output (pipeable)
- Handle SIGINT/SIGTERM gracefully

### Data Pipeline
- Idempotency: re-running should not duplicate data
- Always validate input schema before processing
- Log row counts at each stage for debugging

### Machine Learning
- Pin all dependency versions (reproducibility)
- Set random seeds everywhere (torch, numpy, random)
- Never commit model weights or large datasets to git

### Game / Real-Time App
- Server is source of truth, client is just a view
- Timer drift: client timers are visual only
- Handle disconnection and reconnection gracefully

### Library / SDK
- Semantic versioning: breaking changes = major bump
- No side effects on import
- Minimal dependencies (each one is a liability)
