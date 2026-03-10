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

This section explains the techniques used and why. Useful for customizing the scaffolder or applying these patterns to existing projects.

### CLAUDE.md — The System Prompt

Every project gets a `CLAUDE.md` file loaded into Claude's context on every conversation. It tells Claude how to work in your codebase so it doesn't waste time reverse-engineering patterns.

**What goes in it:**

| Include | Why |
|---|---|
| Decision tree ("I want to X" → pattern → files) | Maps intent to implementation — the #1 most valuable element |
| Run/test/deploy commands | Claude can't guess your test flags or dev server port |
| Pitfalls ("Things That Will Bite You") | Prevents repeating known mistakes |
| Verification instructions | Gives Claude a feedback loop ("run tests after every change") |
| Compaction instructions | Tells Claude what to preserve when context compresses |

**What stays out:** Code style rules (use linters instead), code snippets (they go stale), anything Claude can infer from reading the code.

**Budget:** ≤150 lines. [ETH Zurich research](https://arxiv.org/abs/2501.01858) (138 repos, 5,694 PRs) found that detailed context files reduce success rates and add 20%+ to costs. Shorter, high-signal instructions win.

**Subfolder CLAUDE.md files:** Large projects should have a CLAUDE.md in each major subdirectory. The root file is the entry point (decision tree, commands, pitfalls). Each subfolder file documents what's in that directory (APIs, recipes, local conventions). Same 150-line budget per file, no duplication across files.

### LESSONS.md — Institutional Memory

A living document where Claude records bugs, architectural traps, and framework gotchas as it encounters them. Without it, each Claude session starts from zero and the same bugs get re-introduced.

**Format:** Problem → Fix → Rule. Every entry must be actionable. Structured hierarchically: repo-wide lessons at top, module-specific fixes at bottom.

### REVIEW.md — Code Review Guidelines

Tells the `code-review` plugin what to check beyond default correctness. Every scaffolded CLAUDE.md includes a "Before You Ship" section that runs `/review` for code review and a security review for OWASP top 10 vulnerabilities.

### Security — Global Deny Patterns

The install script configures **global** deny patterns in `~/.claude/settings.json` that block Claude from reading sensitive files across all projects:

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)", "Read(~/.aws/**)", "Read(**/.env)"
    ]
  }
}
```

Global means every project gets these protections automatically — no per-project configuration needed.

### LSP — Structured Code Navigation

LSP (Language Server Protocol) gives Claude structured code intelligence: `goToDefinition`, `findReferences`, `hover` for types, `workspaceSymbol` for search. This replaces noisy `grep` commands with precise, instant results.

**Status:** Enabled via plugins (`pyright-lsp`, `typescript-lsp`) installed by the install script.

### Chrome Integration — Browser Automation

The install script sets up the [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) and launches Claude with `--chrome`. Claude can test web apps, read console logs, automate browser tasks, and record GIFs — all using your existing browser login state.

### Settings Merge — Non-Destructive Configuration

The install script deep-merges settings into `~/.claude/settings.json` with array deduplication. Existing settings, plugins, and deny patterns are preserved. Running the installer twice produces the same result (idempotent). Tested with 24 automated assertions.

### Context Management

Claude's context window (~200k tokens) degrades as it fills. The scaffolder manages this by:

- Keeping CLAUDE.md ≤150 lines (loaded every session)
- Using path-scoped rules in `.claude/rules/` (load only when matching files are touched)
- Including compaction instructions so Claude preserves key state when context compresses

### File Structure

```
claude-meta/
├── CLAUDE.md                    # Scaffolder system prompt
├── scaffold.md                  # Templates for generated files
├── install.sh / install.ps1     # One-command setup
├── doctor.sh / doctor.ps1       # System readiness checker
├── reference/                   # Deep-dive guides (inform scaffolding decisions)
│   ├── content.md               #   What to include/exclude in CLAUDE.md
│   ├── structure.md             #   File hierarchy, subfolder CLAUDE.md, @imports
│   ├── enforcement.md           #   Instructions vs path-scoped rules vs skills
│   ├── self-improving.md        #   Self-improving patterns, handoff files
│   ├── anti-patterns.md         #   Common mistakes (backed by research)
│   ├── checklist.md             #   Setup and audit checklist
│   ├── lessons.md               #   LESSONS.md format and maintenance
│   ├── lsp.md                   #   LSP integration (temporary)
│   ├── security.md              #   Deny patterns and safety
│   └── agents-and-commands.md   #   Subagents, commands, worktrees
└── tests/
    ├── test-repo.sh             #   Repo structure/content checks
    └── test-settings-merge.sh   #   Settings merge assertions
```

### Sources

- [Anthropic official best practices](https://code.claude.com/docs/en/best-practices)
- [ETH Zurich research](https://arxiv.org/abs/2501.01858) — 138 repos, 5,694 PRs analyzing CLAUDE.md effectiveness
- [HumanLayer — Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Shrivu Shankar — How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)
- [Trail of Bits — Claude Code Config](https://github.com/trailofbits/claude-code-config)
- [Karan Bansal — Claude Code LSP](https://karanbansal.in/blog/claude-code-lsp/)
- [Claude Code Chrome docs](https://code.claude.com/docs/en/chrome)
- [Claude Code Review docs](https://code.claude.com/docs/en/code-review)
