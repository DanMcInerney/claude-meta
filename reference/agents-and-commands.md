# Agents, Commands & Worktrees

Claude Code supports custom subagents (`.claude/agents/`), slash commands (`.claude/commands/`), and git worktrees for parallel development. Scaffold these when the project's workflow benefits from them — not speculatively.

## Custom Agents (`.claude/agents/<name>.md`)

Structure with YAML frontmatter:

```markdown
---
name: test-runner
description: Run tests and report results
tools: Read, Grep, Glob, Bash
model: sonnet
---
You are a test runner. Run the project's test suite and report:
- Total tests, passed, failed, skipped
- Full output of any failures
- Suggested fixes for failures
```

### Common Archetypes

| Agent | Purpose | Model | When to scaffold |
|---|---|---|---|
| test-runner | Run tests, report failures | sonnet | Projects with test suites |
| security-reviewer | Scan for vulnerabilities | opus | Security-sensitive projects |
| code-reviewer | Review PRs for quality | sonnet | Team projects |
| doc-generator | Generate/update docs | sonnet | Library/SDK projects |

### Key Principles

- **Most sub-agent failures are invocation failures, not execution failures.** Always provide: specific scope, file references, expected outputs, success criteria.
- **Model selection:** Use sonnet for focused tasks, opus for complex reasoning. Set via `model` frontmatter.
- **Master-clone pattern:** For dynamic delegation, prefer the built-in `Task(...)` feature over rigid custom agents. Custom agents are best for well-defined, repeatable workflows.

## Custom Commands (`.claude/commands/<name>.md`)

```markdown
---
description: Review all changes on current branch
---
Read all files changed in the current git branch compared to main:
1. Run `git diff --name-only main...HEAD` to get changed files
2. Read each changed file
3. Summarize what changed and why
```

### Common Commands

| Command | Purpose | When to scaffold |
|---|---|---|
| /catchup | Review changes on current branch | Git-based projects |
| /pr | Prepare and create a pull request | Team projects |
| /deploy | Run deployment checklist | Projects with deploy workflows |

Keep the list minimal. Value comes from natural language flexibility, not memorizing commands. Only scaffold commands for workflows that are truly repetitive.

## Git Worktrees for Parallel Development

- **Pattern:** `git worktree add trees/<feature> -b <feature-branch>`
- Each worktree gets an isolated copy of the repo for parallel subagent work.
- **Cleanup:** `git worktree remove trees/<feature>` after merging.

**When to use:** 3+ independent tasks with no shared files, clear domain boundaries.

**When NOT to use:** Tasks with dependencies, shared state, or unclear scope.

## Parallelization Decision Framework

```
Are there 3+ independent tasks?
  → No: Work sequentially
  → Yes: Do tasks share files or state?
    → Yes: Work sequentially
    → No: Are domain boundaries clear?
      → No: Work sequentially
      → Yes: Use parallel agents (worktrees if needed)
```

## When to Scaffold These

| Type | Scaffold when | Don't scaffold when |
|---|---|---|
| **Agents** | Project has a clear, repeatable workflow that benefits from a specialized agent | Speculative; no proven repeated workflow |
| **Commands** | User will run the workflow frequently — ask them | One-off tasks easily described in natural language |
| **Worktrees** | Document the pattern in CLAUDE.md pitfalls if parallel dev is expected | Don't create infrastructure for it — just document |
