# claude-meta installer — idempotent setup for Windows
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Banner ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  claude-meta installer" -ForegroundColor Cyan
Write-Host "  ---------------------" -ForegroundColor DarkGray
Write-Host ""

# ── 1. Check Node.js >= 18 ──────────────────────────────────────────
try {
    $nodeRaw = & node --version 2>$null
    $major = [int]($nodeRaw -replace '^v','').Split('.')[0]
} catch {
    $major = 0
}
if ($major -lt 18) {
    Write-Host "  [ERROR] Node.js 18+ is required." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Run .\doctor.ps1 to see what's needed and how to install it." -ForegroundColor Yellow
    exit 1
}
Write-Host "  Found Node.js $nodeRaw" -ForegroundColor Green

# ── 2. Install Claude Code ──────────────────────────────────────────
try {
    npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
    Write-Host "  Installed Claude Code" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed to install Claude Code: $_" -ForegroundColor Red
    exit 1
}

# ── 3. Install LSP language servers ─────────────────────────────────
try {
    npm install -g pyright typescript-language-server typescript 2>&1 | Out-Null
    Write-Host "  Installed LSP language servers" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed to install LSP servers: $_" -ForegroundColor Red
    exit 1
}

# ── 4. Install Claude Code plugins ──────────────────────────────────
try {
    $plugins = @(
        "superpowers@claude-plugins-official",
        "code-review@claude-plugins-official",
        "pyright-lsp@claude-plugins-official",
        "typescript-lsp@claude-plugins-official"
    )
    foreach ($p in $plugins) {
        & claude plugins install $p 2>&1 | Out-Null
    }
    Write-Host "  Installed plugins" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed to install plugins: $_" -ForegroundColor Red
    exit 1
}

# ── 5. Install Chrome extension ────────────────────────────────────
$chromeUrl = "https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"
Write-Host ""
Write-Host "  One more thing:" -ForegroundColor Cyan -NoNewline
Write-Host " Claude can control your browser to test web apps,"
Write-Host "  fill forms, take screenshots, and more. Install the Chrome extension:"
Write-Host ""
Write-Host "  Opening Chrome Web Store now — just click " -NoNewline
Write-Host '"Add to Chrome"' -ForegroundColor Yellow
Write-Host ""

# Open the Chrome Web Store page
try { Start-Process $chromeUrl } catch { }

Write-Host "  (If it didn't open, go to: $chromeUrl)"
Write-Host ""
Read-Host "  Press Enter after installing the extension (or to skip)"
Write-Host "  [OK] Chrome extension step complete" -ForegroundColor Green

# ── 6. Merge settings into ~/.claude/settings.json ──────────────────
function Merge-JsonObjects($base, $overlay) {
    # Deep-merge $overlay into $base, returning merged object.
    # Arrays under permissions.deny are concatenated and deduplicated.
    foreach ($prop in $overlay.PSObject.Properties) {
        $name = $prop.Name
        $val  = $prop.Value
        if ($null -eq $base.$name) {
            $base | Add-Member -NotePropertyName $name -NotePropertyValue $val
        } elseif ($val -is [PSCustomObject] -and $base.$name -is [PSCustomObject]) {
            Merge-JsonObjects $base.$name $val
        } elseif ($val -is [System.Collections.IEnumerable] -and $val -isnot [string]) {
            # Array merge: concatenate and deduplicate
            $merged = @($base.$name) + @($val) | Select-Object -Unique
            $base.$name = $merged
        } else {
            $base.$name = $val
        }
    }
    return $base
}

$settingsDir  = Join-Path $env:USERPROFILE ".claude"
$settingsFile = Join-Path $settingsDir "settings.json"

$desired = @'
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  },
  "enabledPlugins": {
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "code-review@claude-plugins-official": true
  },
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
'@ | ConvertFrom-Json

try {
    if (-not (Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    }
    if (Test-Path $settingsFile) {
        $existing = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $merged   = Merge-JsonObjects $existing $desired
    } else {
        $merged = $desired
    }
    $merged | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
    Write-Host "  Settings configured" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Failed to configure settings: $_" -ForegroundColor Red
    exit 1
}

# ── 7. Success ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  [OK] Claude Code installed"      -ForegroundColor Green
Write-Host "  [OK] LSP servers installed"       -ForegroundColor Green
Write-Host "  [OK] Plugins installed (superpowers, code-review, LSP)" -ForegroundColor Green
Write-Host "  [OK] Chrome extension ready"      -ForegroundColor Green
Write-Host "  [OK] Settings configured"         -ForegroundColor Green
Write-Host ""
Write-Host "  Launching Claude Code..." -ForegroundColor Cyan
Write-Host ""

# Auto-launch claude with Chrome integration in this directory
Set-Location $PSScriptRoot
& claude --chrome
