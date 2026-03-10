# CLAUDE.md Setup Checklist

Use when setting up or auditing CLAUDE.md for any repo.

## Root CLAUDE.md (Required)

- [ ] **Project summary** — 1-2 sentences. What is this, what tech stack.
- [ ] **Decision tree** — Table: "I want to X" → pattern → files to create.
- [ ] **File structure** — Brief tree with pointers to subdirectory CLAUDE.md files.
- [ ] **Run/test/deploy commands** — Exact, copy-pasteable.
- [ ] **Pitfalls** — 5-10 bullets ("Things That Will Bite You").
- [ ] **LESSONS.md reference** — "Consult before starting work."
- [ ] **Under 150 lines.**
- [ ] **No code style rules** — Those belong in linters/formatters.
- [ ] **No code snippets** — Use file:line references to real code.
- [ ] **No /init boilerplate** — Pruned to only non-inferable content.

## Subdirectory CLAUDE.md Files (As Needed)

Create one when a directory has APIs or conventions Claude can't infer from code. Skip when code is self-explanatory. Same ≤150 line budget.

- [ ] **What's in this directory** — File listing with one-line descriptions.
- [ ] **API signatures** — Constructor args + methods. No prose.
- [ ] **"How to add X" recipe** — Numbered steps with exact paths.
- [ ] **Local conventions** — Anything specific to this directory.
- [ ] **Under 150 lines.**
- [ ] **No duplication** — Don't repeat what's in the root CLAUDE.md.

## Enforcement

- [ ] **Path-scoped rules** — `.claude/rules/` for area-specific conventions.
- [ ] **Skills for domain workflows** — Complex processes as on-demand skills, not CLAUDE.md.
- [ ] **Security deny patterns** — `.ssh`, `.aws`, `.env` reads blocked globally via install script.
- [ ] **Verification instructions** — Claude knows how to verify its own work (test commands, expected output).

## Optional Scaffolding

Include when the project benefits from them — don't scaffold speculatively.

- [ ] **LSP configured** — Language servers enabled for the project's stack (Python, TS, Go, Rust).
- [ ] **Custom agents** — `.claude/agents/` for repeatable workflows (test-runner, security-reviewer).
- [ ] **Custom commands** — `.claude/commands/` for frequent workflows (/catchup, /pr).
- [ ] **Compaction instructions** — Claude knows what to preserve when context compresses.

## LESSONS.md (Required)

- [ ] **Exists at repo root.**
- [ ] **Hierarchical** — Repo-wide at top, specific at bottom.
- [ ] **Problem/Fix/Rule format** for each entry.
- [ ] **No stale entries** — Remove lessons for deleted code.

## Validation (The Five Questions)

1. Can Claude pick the right pattern from root CLAUDE.md alone? *(Decision tree)*
2. Can Claude write code from a subdirectory CLAUDE.md without reading source? *(Signatures)*
3. Is anything documented in two places? *(Duplication)*
4. Is anything documented that Claude could infer from code? *(Noise)*
5. Would a linter/formatter handle this better than an instruction? *(Enforcement)*

## The Litmus Test

For every line in CLAUDE.md: **"Would removing this cause Claude to make mistakes?"**

- If yes → keep it
- If no → cut it
- If "maybe" → try removing it, see if Claude's output degrades

## Template: Root CLAUDE.md Skeleton

```markdown
# [Project Name]

[1-2 sentence description. Tech stack.]

## Decision Tree

| You want to... | Pattern | You write | Framework provides |
|---|---|---|---|
| ... | ... | ... | ... |

## Commands

\`\`\`bash
[run command]     # Dev server
[test command]    # All tests
[deploy command]  # Deploy
\`\`\`

## File Structure

[3-5 line tree with pointers to subdirectory CLAUDE.md files]

## Things That Will Bite You

1. [Pitfall 1]
2. [Pitfall 2]
...

## LESSONS.md

Consult `LESSONS.md` before starting work. Document bugs and non-obvious
lessons there. Hierarchical: repo-wide at top, specific at bottom.
```
