#!/usr/bin/env bash
set -euo pipefail

# claude-meta installer — idempotent setup for the project scaffolder
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Colors (with fallback) ---
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  GREEN=$(tput setaf 2); RED=$(tput setaf 1); BOLD=$(tput bold); RESET=$(tput sgr0)
else
  GREEN=""; RED=""; BOLD=""; RESET=""
fi
ok()   { echo "${GREEN}✓${RESET} $*"; }
fail() { echo "${RED}✗ $*${RESET}" >&2; }

# --- Banner ---
echo ""
echo "${BOLD}claude-meta installer${RESET}"
echo "---------------------"
echo ""

# --- 1. Check Node.js >= 18 ---
if ! command -v node &>/dev/null; then
  fail "Node.js not found."
  echo ""
  echo "  Run ${BOLD}./doctor.sh${RESET} to see what's needed and how to install it."
  exit 1
fi
NODE_MAJOR=$(node --version | sed 's/v\([0-9]*\).*/\1/')
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js 18+ is required (found v${NODE_MAJOR})."
  echo ""
  echo "  Run ${BOLD}./doctor.sh${RESET} to see what's needed and how to install it."
  exit 1
fi

# --- 2. Check / install jq ---
HAS_JQ=true
if ! command -v jq &>/dev/null; then
  echo "Installing jq..."
  if [ "$(uname)" = "Darwin" ]; then
    if command -v brew &>/dev/null; then
      brew install jq
    else
      fail "jq not found. Install Homebrew (https://brew.sh) or install jq manually."
      HAS_JQ=false
    fi
  else
    sudo apt-get install -y jq 2>/dev/null \
      || sudo yum install -y jq 2>/dev/null \
      || sudo pacman -S --noconfirm jq 2>/dev/null \
      || { fail "Could not install jq automatically. Settings merge will be skipped."; HAS_JQ=false; }
  fi
fi

# --- 3. Install Claude Code ---
npm install -g @anthropic-ai/claude-code
ok "Installed Claude Code"

# --- 4. Install LSP language servers ---
npm install -g pyright typescript-language-server typescript
ok "Installed LSP language servers (pyright, typescript-language-server)"

# --- 5. Install Claude Code plugins ---
claude plugins install superpowers@claude-plugins-official
claude plugins install code-review@claude-plugins-official
claude plugins install pyright-lsp@claude-plugins-official
claude plugins install typescript-lsp@claude-plugins-official
ok "Installed plugins: superpowers, code-review, pyright-lsp, typescript-lsp"

# --- 6. Install Chrome extension ---
CHROME_URL="https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"
echo ""
echo "${BOLD}One more thing:${RESET} Claude can control your browser to test web apps,"
echo "fill forms, take screenshots, and more. Install the Chrome extension:"
echo ""
echo "  Opening Chrome Web Store now — just click ${BOLD}\"Add to Chrome\"${RESET}"
echo ""

# Open the Chrome Web Store page
if [ "$(uname)" = "Darwin" ]; then
  open "$CHROME_URL" 2>/dev/null || true
else
  xdg-open "$CHROME_URL" 2>/dev/null || true
fi

# Brief pause so the user sees the message before terminal scrolls
echo "  (If it didn't open, go to: $CHROME_URL)"
echo ""
read -r -p "  Press Enter after installing the extension (or to skip)..."
ok "Chrome extension step complete"

# --- 7. Merge settings into ~/.claude/settings.json ---
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
mkdir -p "$CLAUDE_DIR"

NEW_SETTINGS='{
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
}'

if [ "$HAS_JQ" = true ]; then
  if [ ! -f "$SETTINGS" ]; then
    echo "$NEW_SETTINGS" | jq . > "$SETTINGS"
  else
    # Deep merge with array dedup for permissions.deny
    NEW_TMP=$(mktemp)
    echo "$NEW_SETTINGS" | jq . > "$NEW_TMP"
    MERGED=$(jq -s '
      .[0] as $old | .[1] as $new |
      ($old * $new) |
      .permissions.deny = ([$old.permissions.deny // [], $new.permissions.deny // []] | add | unique)
    ' "$SETTINGS" "$NEW_TMP")
    rm -f "$NEW_TMP"
    echo "$MERGED" > "$SETTINGS"
  fi
  ok "Settings configured (~/.claude/settings.json)"
else
  if [ ! -f "$SETTINGS" ]; then
    echo "$NEW_SETTINGS" > "$SETTINGS"
    ok "Settings created (~/.claude/settings.json)"
  else
    fail "jq unavailable — skipped settings merge. Manually add settings to $SETTINGS"
  fi
fi

# --- 8. Success ---
echo ""
echo "${GREEN}✓${RESET} Claude Code installed"
echo "${GREEN}✓${RESET} LSP servers installed"
echo "${GREEN}✓${RESET} Plugins installed (superpowers, code-review, LSP)"
echo "${GREEN}✓${RESET} Chrome extension ready"
echo "${GREEN}✓${RESET} Settings configured (~/.claude/settings.json)"
echo ""
echo "Launching Claude Code..."
echo ""

# Auto-launch claude with Chrome integration in this directory
cd "$SCRIPT_DIR"
exec claude --chrome
