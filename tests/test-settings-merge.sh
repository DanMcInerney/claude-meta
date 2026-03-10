#!/usr/bin/env bash
set -euo pipefail
# test-settings-merge.sh — test settings.json merge logic

# --- Prerequisites ---
if ! command -v jq &>/dev/null; then
  echo "SKIP: jq not installed (required for merge tests)"
  exit 0
fi

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED+1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED+1)); echo "  FAIL: $1"; }

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

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

# Helper: run the merge logic from install.sh
do_merge() {
  local settings="$1"
  local new_file="$TMPDIR/_new_settings.json"
  echo "$NEW_SETTINGS" | jq . > "$new_file"
  if [ ! -f "$settings" ]; then
    cp "$new_file" "$settings"
  else
    local merged
    merged=$(jq -s '
      .[0] as $old | .[1] as $new |
      ($old * $new) |
      .permissions.deny = ([$old.permissions.deny // [], $new.permissions.deny // []] | add | unique)
    ' "$settings" "$new_file")
    echo "$merged" > "$settings"
  fi
}

# --- Test 1: Fresh install (no existing settings.json) ---
echo "--- Test 1: Fresh install ---"
test1="$TMPDIR/test1.json"
do_merge "$test1"

if jq -e '.env.ENABLE_LSP_TOOL' "$test1" &>/dev/null; then
  pass "env.ENABLE_LSP_TOOL exists"
else
  fail "env.ENABLE_LSP_TOOL missing"
fi
if jq -e '.enabledPlugins' "$test1" &>/dev/null; then
  pass "enabledPlugins exists"
else
  fail "enabledPlugins missing"
fi
if jq -e '.permissions.deny' "$test1" &>/dev/null; then
  pass "permissions.deny exists"
else
  fail "permissions.deny missing"
fi
count=$(jq '.permissions.deny | length' "$test1")
if [ "$count" -eq 7 ]; then
  pass "permissions.deny has 7 entries"
else
  fail "permissions.deny has $count entries (expected 7)"
fi

# --- Test 2: Merge with existing settings (no overlap) ---
echo "--- Test 2: Merge with no overlap ---"
test2="$TMPDIR/test2.json"
echo '{"customSetting": "keep-me", "hooks": {"PostEditTool": [{"command": "prettier"}]}}' > "$test2"
do_merge "$test2"

val=$(jq -r '.customSetting' "$test2")
if [ "$val" = "keep-me" ]; then
  pass "customSetting preserved"
else
  fail "customSetting lost (got: $val)"
fi
if jq -e '.hooks.PostEditTool[0].command' "$test2" &>/dev/null; then
  pass "hooks.PostEditTool preserved"
else
  fail "hooks.PostEditTool lost"
fi
for key in env enabledPlugins permissions; do
  if jq -e ".$key" "$test2" &>/dev/null; then
    pass "$key added"
  else
    fail "$key missing after merge"
  fi
done

# --- Test 3: Merge with overlapping deny patterns ---
echo "--- Test 3: Overlapping deny patterns ---"
test3="$TMPDIR/test3.json"
echo '{"permissions": {"deny": ["Read(~/.ssh/**)", "Read(~/.kube/**)"]}}' > "$test3"
do_merge "$test3"

if jq -e '.permissions.deny | index("Read(~/.kube/**)")' "$test3" &>/dev/null; then
  pass "Read(~/.kube/**) preserved"
else
  fail "Read(~/.kube/**) lost"
fi
ssh_count=$(jq '[.permissions.deny[] | select(. == "Read(~/.ssh/**)")] | length' "$test3")
if [ "$ssh_count" -eq 1 ]; then
  pass "Read(~/.ssh/**) appears exactly once"
else
  fail "Read(~/.ssh/**) appears $ssh_count times (expected 1)"
fi
for pat in "Read(~/.aws/**)" "Read(~/.gnupg/**)" "Read(**/.env)" "Read(**/.env.*)" "Edit(~/.bashrc)" "Edit(~/.zshrc)"; do
  if jq -e --arg p "$pat" '.permissions.deny | index($p)' "$test3" &>/dev/null; then
    pass "$pat present"
  else
    fail "$pat missing"
  fi
done
total=$(jq '.permissions.deny | length' "$test3")
if [ "$total" -eq 8 ]; then
  pass "total deny count is 8 (7 new + 1 existing-only)"
else
  fail "total deny count is $total (expected 8)"
fi

# --- Test 4: Merge preserves existing plugins ---
echo "--- Test 4: Existing plugins preserved ---"
test4="$TMPDIR/test4.json"
echo '{"enabledPlugins": {"my-custom-plugin": true}}' > "$test4"
do_merge "$test4"

if jq -e '.enabledPlugins["my-custom-plugin"]' "$test4" | grep -q true; then
  pass "my-custom-plugin still true"
else
  fail "my-custom-plugin lost or changed"
fi
for plugin in "pyright-lsp@claude-plugins-official" "typescript-lsp@claude-plugins-official" \
              "superpowers@claude-plugins-official" "code-review@claude-plugins-official"; do
  if jq -e --arg p "$plugin" '.enabledPlugins[$p]' "$test4" &>/dev/null; then
    pass "$plugin added"
  else
    fail "$plugin missing"
  fi
done

# --- Test 5: Idempotent — merging twice produces same result ---
echo "--- Test 5: Idempotent ---"
test5="$TMPDIR/test5.json"
echo '{}' > "$test5"
do_merge "$test5"
cp "$test5" "$TMPDIR/test5_after_first.json"
do_merge "$test5"

if diff -q "$TMPDIR/test5_after_first.json" "$test5" &>/dev/null; then
  pass "merge is idempotent"
else
  fail "second merge changed output"
fi

# --- Summary ---
echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed"
exit $(( FAILED > 0 ? 1 : 0 ))
