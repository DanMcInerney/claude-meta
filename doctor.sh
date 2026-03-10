#!/usr/bin/env bash
# claude-meta doctor — check if your system is ready

# Colors (with fallback for dumb terminals)
if [[ -t 1 ]] && tput colors &>/dev/null; then
  GREEN=$(tput setaf 2) RED=$(tput setaf 1) YELLOW=$(tput setaf 3)
  BOLD=$(tput bold) RESET=$(tput sgr0)
else
  GREEN="" RED="" YELLOW="" BOLD="" RESET=""
fi

ok()   { echo "  ${GREEN}✓${RESET} $1"; }
fail() { echo "  ${RED}✗${RESET} $1"; }
info() { echo "  ${YELLOW}○${RESET} $1"; }
hint() { echo "    $1"; }

echo ""
echo "${BOLD}Claude Code — System Readiness Check${RESET}"
echo "======================================"; echo ""
errors=0

# 1. Node.js >= 18
if command -v node &>/dev/null; then
  node_ver=$(node --version | sed 's/^v//')
  node_major=${node_ver%%.*}
  if [[ "$node_major" -ge 18 ]]; then
    ok "Node.js v${node_ver}"
  else
    fail "Node.js v${node_ver} (need 18 or newer)"
    hint "Download a newer version from: https://nodejs.org (pick the big green 'LTS' button)"
    hint "After installing, close this terminal, open a new one, and run this check again."
    errors=$((errors + 1))
  fi
else
  fail "Node.js not found"
  hint "Node.js is what runs Claude Code under the hood. You need version 18 or newer."
  hint "Download it from: https://nodejs.org (pick the big green button that says 'LTS')"
  hint "After installing, close this terminal, open a new one, and run this check again."
  errors=$((errors + 1))
fi

# 2. npm
if command -v npm &>/dev/null; then
  npm_ver=$(npm --version)
  ok "npm v${npm_ver}"
else
  fail "npm not found (should come with Node.js — try reinstalling Node.js)"
  errors=$((errors + 1))
fi

# 3. Claude Code
if command -v claude &>/dev/null; then
  ok "Claude Code installed"
else
  info "Claude Code not installed yet (the install script will handle this)"
fi

# 4. jq
if command -v jq &>/dev/null; then
  ok "jq installed"
else
  info "jq not found (the install script will try to install it automatically)"
fi

# 5. Chrome or Edge browser
browser_found=false
for cmd in google-chrome google-chrome-stable chromium-browser microsoft-edge; do
  command -v "$cmd" &>/dev/null && browser_found=true && break
done
if [[ "$browser_found" == false && "$(uname)" == "Darwin" ]]; then
  for app in "/Applications/Google Chrome.app" "/Applications/Microsoft Edge.app"; do
    [[ -d "$app" ]] && browser_found=true && break
  done
fi
if [[ "$browser_found" == true ]]; then
  ok "Chrome/Edge browser found"
else
  info "Chrome/Edge not detected (optional — needed for browser automation)"
  hint "Get Chrome from: https://www.google.com/chrome"
fi

# 6. Settings file
if [[ -f "$HOME/.claude/settings.json" ]]; then
  ok "Settings file exists (~/.claude/settings.json)"
else
  info "No settings file yet (the install script will create one)"
fi

# Summary
echo ""; echo "--------------------------------------"; echo ""
if [[ "$errors" -eq 0 ]]; then
  echo "${GREEN}${BOLD}All good!${RESET} You're ready to install. Run:"
  echo ""; echo "  ./install.sh"
else
  echo "${YELLOW}${BOLD}Almost there!${RESET} Fix the items marked with ${RED}✗${RESET} above, then run this check again:"
  echo ""; echo "  ./doctor.sh"
fi; echo ""
