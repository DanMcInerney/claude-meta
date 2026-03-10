<!-- TEMPORARY: Remove this file when Claude Code ships LSP support natively. Until then, LSP must be manually enabled. -->

# LSP Integration

LSP gives Claude structured code intelligence instead of text-based grep. goToDefinition, findReferences, hover types, workspaceSymbol — all faster and more accurate than scanning files. For large codebases, LSP is the difference between Claude guessing and Claude knowing.

## Enabling LSP

Add to the user's `~/.claude/settings.json`:

```json
{
  "env": { "ENABLE_LSP_TOOL": "1" },
  "enabledPlugins": {
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true
  }
}
```

Enable only the language servers relevant to the project's stack.

## Language Server Installation

| Language | Server | Install Command |
|---|---|---|
| Python | pyright | `npm i -g pyright` |
| TypeScript/JS | typescript-language-server | `npm i -g typescript-language-server typescript` |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` |
| Rust | rust-analyzer | `rustup component add rust-analyzer` |

## CLAUDE.md Instructions to Scaffold

When LSP is enabled for a project, add this block to the scaffolded CLAUDE.md:

```markdown
## Code Navigation (LSP)

Prefer LSP over Grep/Glob/Read for code navigation:

| Task | LSP Method |
|---|---|
| Find where something is defined | goToDefinition |
| Find all usages of a symbol | findReferences |
| Get type info without reading file | hover |
| Find a class/function by name | workspaceSymbol |
| Understand call chains | incomingCalls / outgoingCalls |
| Jump to interface implementation | goToImplementation |

Before renaming or changing signatures, use findReferences first.
Check LSP diagnostics after edits — fix type errors immediately.
```

## When to Include LSP in a Scaffold

- Always ask the user if they want LSP enabled
- Include if the project uses Python, TypeScript, Go, or Rust
- Skip for languages without official Claude Code LSP plugins
- LSP config goes in the project's `.claude/settings.json` alongside hooks
