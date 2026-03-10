# Security Configuration

Every scaffolded project benefits from sensible security defaults. The install script configures **global deny patterns** in `~/.claude/settings.json` that protect all projects automatically.

## Deny Patterns

Block Claude from reading sensitive files. These are set globally by the install script:

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)",
      "Read(~/.gnupg/**)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Edit(~/.bashrc)",
      "Edit(~/.zshrc)"
    ]
  }
}
```

These are sensible defaults — adjust per project if needed (e.g., add `Read(**/*.pem)` for TLS-heavy projects).

## What the Install Script Configures

| Category | What | Example |
|---|---|---|
| **Secret files** | Block reads to credential stores | `.ssh`, `.aws`, `.gnupg` |
| **Environment files** | Block reads to env files | `.env`, `.env.*` |
| **Shell configs** | Block edits to shell profiles | `.bashrc`, `.zshrc` |

## Per-Project Deny Patterns

If a project needs additional protections beyond the global defaults, add them to the project's `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Read(**/*.pem)",
      "Read(**/credentials.json)",
      "Edit(migrations/**)"
    ]
  }
}
```

## Why Global Instead of Per-Project

Global deny patterns apply to every project automatically. This means:
- New projects are protected from the first session
- No per-project security configuration needed
- Users can't accidentally forget to add protections
- The install script handles everything once
