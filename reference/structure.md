# CLAUDE.md Structure

## The Hierarchy

CLAUDE.md files form a tree. Each level answers different questions at different scopes.

```
CLAUDE.md                    # "What is this? How do I add/change things?"
engines/CLAUDE.md            # "What APIs does the engine expose?"
engines/auth/CLAUDE.md       # "How does auth work specifically?"
static/CLAUDE.md             # "What client-side modules exist?"
.claude/rules/database.md    # Path-scoped rules (only load when touching db files)
```

### Root CLAUDE.md — The Entry Point

Loads on every conversation. Must answer:

1. **What is this project?** (1-2 sentences)
2. **What pattern do I use?** (decision tree — see content.md)
3. **Where do things live?** (brief file map with pointers to subdirectory CLAUDE.md files)
4. **How do I run/test/deploy?** (exact commands)
5. **What will bite me?** (pitfalls — Anthropic calls this "Things That Will Bite You")

### Subdirectory CLAUDE.md — API Reference

Each directory's CLAUDE.md documents what's *in* that directory:

1. **What's here?** (file listing with one-line descriptions)
2. **APIs** (signatures, not prose)
3. **"How to add a new X"** (recipe with exact file paths)
4. **Local conventions** (naming, patterns specific to this area)

### Leaf CLAUDE.md — Feature-Specific

For individual modules, features, or packages:

1. **What is this?** (1 sentence + which pattern it uses)
2. **State/data shapes** (public/private state, API responses)
3. **Events/API** (socket events, REST endpoints)
4. **Files** (exact listing)
5. **Test command** (exact command)

## Progressive Disclosure

**Tell Claude how to find information rather than giving it all information.**

Root CLAUDE.md is a lightweight entry point. Detailed guidance lives in separate files that Claude loads only when needed. Two mechanisms:

### @import Syntax

Reference other files from CLAUDE.md. Claude loads them on demand (up to 5 hops):
```markdown
For database conventions, see @docs/database-guide.md
For API design patterns, see @docs/api-patterns.md
```

### Path-Scoped Rules (.claude/rules/)

Create `.claude/rules/<name>.md` files with YAML frontmatter. These load only when Claude touches matching files:

```markdown
---
paths: ["src/api/**/*.ts", "src/middleware/**"]
---
# API Conventions
- All endpoints return {data, error, metadata} envelope
- Use Zod schemas for request validation
- Never throw — return Result types
```

This keeps engine-specific or feature-specific rules out of the root file entirely.

## Size Rules

- **150 lines max per file.** Compress when over: remove prose, convert to bullets, move detail to subdirectory files.
- **Root gets the decision tree and pitfalls.** Everything else belongs in subdirectories or @imported files.
- **No duplication across files.** Root says "see engines/CLAUDE.md for engine APIs." Never repeats them.
- **CLAUDE.md survives compaction.** It's re-read from disk after `/compact`, so it's always present even in long sessions. This is why keeping it lean matters — it loads every time.

## Pointer Pattern

```markdown
## File Structure
engines/            — Game engines (see engines/CLAUDE.md)
static/engine/      — Client components (see static/engine/CLAUDE.md)
tests/              — Test suite (see tests/CLAUDE.md)
```

Claude drills into exactly the area it needs without loading everything upfront.
