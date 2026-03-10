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
git clone https://github.com/YOUR_USERNAME/claude-meta.git
cd claude-meta
chmod +x install.sh doctor.sh
./install.sh
```

**Windows (PowerShell):**

```powershell
git clone https://github.com/YOUR_USERNAME/claude-meta.git
cd claude-meta
.\install.ps1
```

That's it. The script installs everything (Claude Code, LSP servers, plugins, Chrome extension) and launches Claude automatically.

## What Happens

Claude will greet you and ask what you want to build. Just tell it:

> "A REST API for managing bookmarks"

> "A CLI tool that monitors Kalshi prediction markets"

> "A multiplayer card game with React and WebSockets"

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
