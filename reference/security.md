# Security Configuration

Every scaffolded project should include sensible security defaults. Two mechanisms:
**deny patterns** (block reads/writes to sensitive paths) and **safety hooks** (block dangerous commands).

## Deny Patterns

Block Claude from reading sensitive files. Add to `.claude/settings.json` at the project level:

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)",
      "Read(~/.gnupg/**)",
      "Read(~/.kube/**)",
      "Read(~/.npmrc)",
      "Read(~/.docker/config.json)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Edit(~/.bashrc)",
      "Edit(~/.zshrc)",
      "Edit(~/.profile)"
    ]
  }
}
```

These are sensible defaults — adjust per project (e.g., add `Read(**/*.pem)` for TLS-heavy projects).

## Safety Hooks

PreToolUse hooks that block dangerous operations. Create `.claude/hooks/block-dangerous.sh`:

```bash
#!/bin/bash
# Block dangerous commands in Bash tool usage
# Exit code 2 = blocking error (fed back to Claude)
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block destructive operations
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/|rm\s+-rf\s+\*'; then
  echo "BLOCKED: Destructive rm -rf. Be more specific about what to delete." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force\s+.*(main|master)'; then
  echo "BLOCKED: Force push to main/master." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: git reset --hard. Use git stash or create a backup branch first." >&2
  exit 2
fi

exit 0
```

Wire it up in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/block-dangerous.sh"
      }
    ]
  }
}
```

## Hook Exit Code Semantics

| Exit Code | Meaning | Behavior |
|---|---|---|
| 0 | Success | stdout shown in transcript |
| 2 | Blocking error | stderr fed back to Claude as error message |
| Other non-zero | Non-blocking error | stderr shown, execution continues |

## What to Include by Default

| Level | What | Example |
|---|---|---|
| **Always** | Deny patterns for secrets | `.ssh`, `.aws`, `.env` |
| **Usually** | Dangerous command blocking hook | `rm -rf /`, force push to main |
| **Ask user** | Protected path hooks | migrations, production configs |
| **Skip** | Over-restrictive patterns | Anything that hampers normal development |

## Combining with Formatting Hooks

Security hooks and formatting hooks coexist — they use different keys and matchers:

```json
{
  "permissions": {
    "deny": ["Read(~/.ssh/**)"]
  },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "command": ".claude/hooks/block-dangerous.sh" }
    ],
    "PostEditTool": [
      { "command": "npx prettier --write $CLAUDE_FILE_PATHS" }
    ]
  }
}
```

`permissions.deny` handles read/write blocking. `hooks.PreToolUse` handles command blocking. `hooks.PostEditTool` handles formatting. No conflicts — they operate independently.
