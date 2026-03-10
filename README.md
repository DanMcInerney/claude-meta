# claude-meta

Turn a one-sentence idea into a fully scaffolded project with best-practice Claude Code configuration.

## Prerequisites

- [Node.js 18+](https://nodejs.org) — pick the big green "LTS" button
- [Google Chrome](https://www.google.com/chrome/) or [Microsoft Edge](https://www.microsoft.com/edge)
- A Claude Code subscription ([claude.ai](https://claude.ai))

Not sure if you're ready? Run the system check first:

```bash
./doctor.sh          # macOS / Linux
.\doctor.ps1         # Windows (PowerShell)
```

It will tell you exactly what's missing and how to fix it.

## Get Started

**macOS / Linux:**

```bash
git clone https://github.com/DanMcInerney/claude-meta.git
cd claude-meta
chmod +x install.sh doctor.sh
./install.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/DanMcInerney/claude-meta.git
cd claude-meta
.\install.ps1
```

That's it. The script installs everything (Claude Code, LSP servers, plugins, Chrome extension) and launches Claude automatically.

## What Happens

Claude will greet you and ask what you want to build. Just tell it:

> "Make me a solitaire game I can play in my browser"

> "Create a personal website with a blog"

> "Build an app that tracks my daily habits"

Claude picks the best tech stack, creates a new project folder next to this one, and sets up:

```
../your-project/
├── CLAUDE.md              # AI instructions tuned for your stack
├── LESSONS.md             # Grows as you build — bugs, gotchas, solutions
├── REVIEW.md              # Code review guidelines
├── .claude/
│   ├── settings.json      # Formatter hooks, security, LSP
│   └── hooks/             # Safety scripts
└── src/                   # Your project code
```

Then it tells you exactly what to do next:

```
cd ../your-project
claude
```

Tell Claude "Let's build this" and it starts implementing. Claude can also control your browser to test web apps, fill forms, and take screenshots.

## Troubleshooting

Run `./doctor.sh` (or `.\doctor.ps1` on Windows) anytime to check your setup. It explains everything in plain English.

---

## How It Works (Technical Details)

This section explains every technique used and why. Useful if you want to customize the scaffolder, understand the design decisions, or apply these patterns to existing projects.

### CLAUDE.md — The System Prompt

Every scaffolded project gets a `CLAUDE.md` file. This is the single highest-leverage file in any Claude Code project — it's loaded into context on every conversation and tells Claude how to work in your codebase.

**Why it matters:** Without it, Claude reads 10+ files to reverse-engineer patterns. With a good CLAUDE.md, Claude picks the right approach immediately.

**What goes in it:**

| Include | Why |
|---|---|
| Decision tree ("I want to X" → pattern → files) | The #1 most valuable element. Maps intent to implementation. |
| Run/test/deploy commands | Claude can't guess your `pytest` flags or dev server port. |
| Pitfalls ("Things That Will Bite You") | Prevents Claude from repeating mistakes other devs already made. |
| Verification instructions | "Run tests after every change" gives Claude a feedback loop. |
| Compaction instructions | Tells Claude what to preserve when context compresses. |
| Post-implementation review | Ensures code review + security review happen before shipping. |

**What stays out:**

| Exclude | Why |
|---|---|
| Code style rules | Use formatters + hooks instead. LLMs are expensive, unreliable formatters. Linters are cheap and deterministic. |
| Code snippets | They go stale. Point to real files with `file:line` references. |
| Anything Claude can infer from code | Claude can read imports, class hierarchies, and follow conventions from existing code. Don't waste context budget restating what's already in the source. |

**Budget:** ≤150 lines per CLAUDE.md file. [ETH Zurich research](https://arxiv.org/abs/2501.01858) (138 repos, 5,694 PRs) found that detailed context files reduce success rates while adding 20%+ to costs. Shorter, high-signal instructions outperform longer ones.

**Format hierarchy:** Tables > prose. Signatures > descriptions. Bullets > paragraphs. Code blocks > English.

### LESSONS.md — Institutional Memory

A living document where Claude records non-obvious bugs, architectural traps, and framework gotchas as it encounters them. Structured hierarchically:

```
Architecture & Design Patterns    ← repo-wide lessons
Integration & Tooling             ← build, deploy, CI/CD
Module-Specific Bugs              ← narrow fixes
```

**Why it matters:** Without LESSONS.md, each Claude session starts from zero. The same bugs get re-introduced, the same debugging rabbit holes get explored. LESSONS.md is how Claude learns across sessions.

**Entry format:** Problem → Fix → Rule. Every lesson must be actionable, not just a description.

**Maintenance:** Add immediately when a bug takes >5 minutes to debug. Remove when the underlying code changes. Promote broadly-applicable entries to the top.

### Hooks — Deterministic Enforcement

Hooks are shell commands that run at specific lifecycle points. They go in `.claude/settings.json` and provide **guaranteed** enforcement — unlike CLAUDE.md instructions which are best-effort and can be deprioritized in long contexts.

| Hook Event | Fires When | Use For |
|---|---|---|
| `PostEditTool` | After any file edit | Formatters (prettier, ruff, gofmt) |
| `PreToolUse` | Before a tool runs | Blocking dangerous commands |
| `PreCommit` | Before git commit | Type-checking, test running, secret scanning |
| `SessionStart` | Session begins | Injecting context (recent tickets, team notes) |
| `Stop` | Claude finishes responding | Anti-rationalization gates, completion checks |

**Exit codes matter:**
- `0` = success (stdout shown in transcript)
- `2` = blocking error (stderr fed back to Claude as a message — Claude will try to fix the issue)
- Other non-zero = non-blocking warning

**The core rule:** "Never send an LLM to do a linter's job." If you find yourself writing `IMPORTANT: Always use 2-space indentation` in CLAUDE.md, that's a hook running `prettier --write`, not an instruction.

**Placement strategy:** Avoid blocking at `Edit/Write` — it confuses agents mid-plan. Prefer checking completed work at commit stage (`PreCommit`).

### Security — Deny Patterns & Safety Hooks

Every scaffolded project includes two security layers:

**1. Deny patterns** block Claude from reading sensitive files:
```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)", "Read(~/.aws/**)", "Read(**/.env)"
    ]
  }
}
```

**2. Safety hooks** block dangerous commands before they execute:
```bash
# .claude/hooks/block-dangerous.sh
# Blocks: rm -rf /, force push to main, git reset --hard
```

**Why both?** Deny patterns handle file access. Safety hooks handle command execution. They're independent layers — a command can be allowed to run but blocked from reading certain files, or vice versa.

### LSP — Structured Code Navigation

LSP (Language Server Protocol) gives Claude structured code intelligence instead of text-based grep. This is the difference between Claude *guessing* where a function is defined and Claude *knowing*.

| Task | Without LSP | With LSP |
|---|---|---|
| Find a definition | `grep -r "def functionName"` (may hit comments, strings, wrong files) | `goToDefinition` (exact, instant) |
| Find all usages | `grep -r "functionName"` (noisy) | `findReferences` (precise, includes imports) |
| Get type info | Read the file, parse mentally | `hover` (instant type signature) |
| Find a class by name | `find . -name "*.py" \| xargs grep "class Foo"` | `workspaceSymbol("Foo")` |

**Status:** LSP support is not yet built into Claude Code natively. The install script enables it via plugins (`pyright-lsp`, `typescript-lsp`). The `reference/lsp.md` file is marked `<!-- TEMPORARY -->` and should be removed when Claude Code ships LSP natively.

### REVIEW.md — Code Review Guidelines

A `REVIEW.md` file at the project root tells the `code-review` plugin what to check beyond default correctness. The plugin runs multi-agent analysis: specialized agents examine different aspects of the code in parallel, then findings are verified against actual behavior to filter false positives.

**What to put in REVIEW.md:**
- Domain-specific correctness rules ("New API endpoints must have integration tests")
- Framework conventions not covered by linters ("Prefer early returns over nested conditionals")
- Things to skip ("Don't flag formatting in generated code under `/gen/`")

**Post-implementation review:** Every scaffolded CLAUDE.md includes a "Before You Ship" section that instructs Claude to:
1. Run `/review` for code review (logic errors, edge cases, regressions)
2. Run a security review (OWASP top 10, hardcoded secrets, injection, broken auth)

### Custom Agents — Specialized Subprocesses

Custom agents live in `.claude/agents/<name>.md` and define specialized subprocesses with restricted tool access and specific models. They're useful for well-defined, repeatable workflows.

```markdown
---
name: test-runner
tools: Read, Grep, Glob, Bash
model: sonnet
---
Run the test suite. Report: total, passed, failed, skipped.
```

**Model selection:** Use `sonnet` for focused tasks (test running, doc generation). Use `opus` for complex reasoning (security review, architectural analysis). This optimizes cost without sacrificing quality.

**The key insight:** "Most sub-agent failures are invocation failures, not execution failures." Always provide: specific scope, file references, expected outputs, and success criteria. Agents can't ask for clarification.

**Master-clone pattern:** For dynamic delegation, prefer the built-in `Task(...)` feature over rigid custom agents. Custom agents are best for workflows you'll run repeatedly with the same structure.

### Custom Commands — Slash Command Shortcuts

Custom commands in `.claude/commands/<name>.md` create `/name` shortcuts for common workflows:

| Command | What it does |
|---|---|
| `/catchup` | Review all changes on current branch vs main |
| `/pr` | Stage changes, prepare and create a pull request |
| `/deploy` | Run deployment checklist |

**When to create one:** Only for workflows that are truly repetitive and always follow the same steps. Value comes from natural language flexibility — don't over-formalize.

### Context Management — The Hidden Constraint

Claude Code's context window (~200k tokens) is the most important resource to manage. Performance degrades as it fills. The scaffolder addresses this in two ways:

**1. Compaction instructions** in every CLAUDE.md:
```
When compacting, preserve: modified file list, failing tests, current task.
```
Without this, Claude forgets what files it changed when context compresses and wastes tokens re-reading them.

**2. Structural decisions** that minimize context usage:
- CLAUDE.md ≤150 lines (loaded every session — keep it lean)
- Path-scoped rules in `.claude/rules/` (load only when matching files are touched)
- Skills for on-demand knowledge (don't bloat every conversation)

### Chrome Integration — Browser Automation

The install script sets up the [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) and launches Claude with `--chrome`. This lets Claude:

- **Test web apps** — navigate to localhost, fill forms, check for visual regressions
- **Debug with console logs** — read browser console output and fix the code that caused errors
- **Automate browser tasks** — data entry, multi-site workflows, authenticated app interactions
- **Record GIFs** — capture interaction sequences for documentation or sharing

Claude shares your browser's login state, so it can interact with any site you're signed into (Google Docs, Notion, internal tools) without API setup.

### Settings Merge — Non-Destructive Configuration

The install scripts merge settings into `~/.claude/settings.json` using deep merge with array deduplication. This means:

- **Existing settings are preserved** — your custom hooks, plugins, and deny patterns aren't overwritten
- **Deny arrays are deduplicated** — running the installer twice doesn't create duplicate entries
- **It's idempotent** — safe to run as many times as you want

This is tested with 24 automated assertions covering fresh install, no-overlap merge, overlapping arrays, plugin preservation, and idempotency.

### The Three Enforcement Layers

Claude Code has three mechanisms for controlling behavior, each with different guarantees:

| Layer | Guarantee | When it loads | Use for |
|---|---|---|---|
| **Hooks** | Deterministic — always runs | Lifecycle event fires | Hard rules (formatting, security, blocking) |
| **CLAUDE.md** | Best-effort — may be deprioritized | Every conversation | Guidance, conventions, patterns, recipes |
| **Skills / Path rules** | On-demand — loads when relevant | Context match or manual trigger | Domain knowledge, complex workflows |

**The decision framework:**
```
Will Claude's failure to follow this cause a broken build or data loss?
  → Yes: HOOK
  → No: Does this apply to every conversation?
    → Yes: CLAUDE.md instruction
    → No: Skill or path-scoped rule
```

### File Structure

```
claude-meta/
├── CLAUDE.md                    # Scaffolder system prompt (what Claude reads)
├── scaffold.md                  # Templates for generated files
├── install.sh / install.ps1     # One-command setup
├── doctor.sh / doctor.ps1       # System readiness checker
├── reference/                   # Deep-dive guides (inform scaffolding decisions)
│   ├── content.md               #   What to include/exclude in CLAUDE.md
│   ├── structure.md             #   File hierarchy and @imports
│   ├── enforcement.md           #   Hooks vs instructions vs skills
│   ├── self-improving.md        #   Self-improving patterns, handoff files
│   ├── anti-patterns.md         #   Common mistakes (backed by research)
│   ├── checklist.md             #   Setup and audit checklist
│   ├── lessons.md               #   LESSONS.md format and maintenance
│   ├── lsp.md                   #   LSP integration (temporary)
│   ├── security.md              #   Deny patterns and safety hooks
│   └── agents-and-commands.md   #   Subagents, commands, worktrees
└── tests/
    ├── test-repo.sh             #   42 repo structure/content checks
    └── test-settings-merge.sh   #   24 settings merge assertions
```

### Sources

These best practices are drawn from:

- [Anthropic official best practices](https://code.claude.com/docs/en/best-practices)
- [ETH Zurich research](https://arxiv.org/abs/2501.01858) — 138 repos, 5,694 PRs analyzing CLAUDE.md effectiveness
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Shrivu Shankar — How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)
- [Trail of Bits — Claude Code Config](https://github.com/trailofbits/claude-code-config)
- [Karan Bansal — Claude Code LSP](https://karanbansal.in/blog/claude-code-lsp/)
- [Claude Code Chrome docs](https://code.claude.com/docs/en/chrome)
- [Claude Code Review docs](https://code.claude.com/docs/en/code-review)
