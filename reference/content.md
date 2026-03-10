# What to Write in CLAUDE.md Files

## The Golden Rule

Write what Claude can't infer from the code. Skip what it can.

Claude can read code, follow imports, understand class hierarchies. It *can't* efficiently:
- Know which of 5 approaches is the right one for this repo
- Know what's inherited vs what you must implement
- Know implicit conventions not enforced by code
- Know what mistakes other Claude instances already made here

## High-Value Content (Always Include)

### 1. Decision Trees

The single most valuable element. Maps user intent to implementation pattern.

```markdown
| You want to... | Pattern | You write | Framework provides |
|---|---|---|---|
| Add a trivia game | Data-only | Questions + config | Everything else |
| Add a party game | Phase-driven | Game class + prompts | Phases, timers, voting |
| Add a card game | Full custom | Game + namespace + UI | Base classes, components |
```

Without this, Claude reads 10+ files to reverse-engineer the pattern. With it, Claude picks a row and starts coding.

### 2. API Signatures (Not Prose)

```markdown
Deck(cards).shuffle() / .draw(n) -> list / .remaining -> int
Hand().add(cards) / .remove(card) / .has(card) -> bool / .cards -> list
```

Never: "The Deck class manages a collection of cards. You can shuffle..."

### 3. State/Data Shapes

Critical for frontend work — Claude writes the entire UI from shapes without reading backend:

```markdown
**Public:** {state, round, scores: {sid: int}, current_player, board: [...]}
**Private:** {hand: [card], playable: [bool], has_acted: bool}
```

### 4. "How to Add X" Recipes

The most common task. Numbered steps with exact file paths.

### 5. What's Inherited / Automatic

Prevents Claude from reimplementing framework features:

```markdown
**BaseNamespace provides (don't reimplement):**
join, disconnect, lobby, play_again, sync_state, timer management
```

### 6. Pitfalls ("Things That Will Bite You")

Short, scannable bullets. Anthropic's own CLAUDE.md uses this exact heading.

### 7. Exact Commands

```markdown
uv run pytest -v                    # All tests
uv run python server.py --debug     # Dev server
```

### 8. Few-Shot Examples

Anthropic benchmarks show few-shot examples improve stylistic consistency by 65%. One clear example per pattern:

```markdown
## Example: Adding a trivia game
See `games/hp_jeopardy/__init__.py` for a complete, minimal example.
```

Point to real files rather than inlining code snippets (snippets go stale — see below).

### 9. Domain Terminology

Define project-specific terms so Claude uses them correctly without redefining each time:

```markdown
**Glossary:** "room" = active game session, "namespace" = Socket.IO channel per game type,
"display" = TV/projector view, "player" = phone view, "sync_state" = push state to all clients
```

### 10. Verification Instructions

The #1 power user tip: give Claude a way to verify its own work. Without verification, you become the only feedback loop.

```markdown
## Verification

Run tests after every change. Fix failures before moving on.
[exact test command]           # Expected: all green
[type-check command]           # Expected: no errors
```

Include: test commands with expected output, type-checker commands, linter commands. For frontend projects, add screenshot comparison instructions.

### 11. Compaction Instructions

Claude's context window compresses old messages as it fills. Tell Claude what to preserve:

```markdown
When compacting, preserve: modified file list, failing tests, current task, architectural decisions made.
```

Without this, Claude forgets what files it changed and re-reads them, wasting tokens and time.

## Low-Value Content (Skip)

| Content | Why it fails |
|---|---|
| Code style rules | Never send an LLM to do a linter's job. Use formatters instead. |
| Code snippets | They go stale. Use `file:line` references to point to authoritative source. |
| Prose explanations | Claude needs signatures, not paragraphs. |
| History/rationale | "We chose Flask because..." — Claude cares *what*, not *why*. |
| External links | Claude can't always fetch URLs. Inline the essential facts. |
| Framework internals | Document what subclasses override, not how the base works. |
| File-by-file descriptions | Claude can `ls`. Don't describe what it can discover. |
| Aspirational features | Describe what IS, not what WILL BE. Future plans go in docs/plans/. |
| Frequently-changing info | If it changes weekly, Claude will read stale data. |

## Emphasis Markers

Use `IMPORTANT:` or `YOU MUST` for critical rules, but **sparingly**. If everything is emphasized, nothing is. Reserve for rules that, if violated, cause hard-to-debug failures.

## Format Preferences

- **Tables > prose** for decision trees and comparisons
- **Signatures > descriptions** for APIs
- **Bullets > paragraphs** for lists of facts
- **Code blocks > English** for data shapes and commands
- **`file:path` or section references > inline code** for examples (line numbers shift — prefer `"Section Name" in file.md`)

## The Compression Test

When hitting 150 lines, ask: "If Claude reads only this file and writes code, will it work?"

Cut first: prose restating code, duplicated info, rarely-needed details, historical context.
