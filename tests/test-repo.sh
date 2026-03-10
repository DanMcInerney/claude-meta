#!/usr/bin/env bash
set -euo pipefail
# test-repo.sh — validate repo structure and content integrity

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED+1)); echo "  PASS: $1"; }
fail() { FAILED=$((FAILED+1)); echo "  FAIL: $1"; }

check_file() {
  if [[ -f "$1" ]]; then
    pass "$1 exists"
  else
    fail "$1 missing"
  fi
}

# 1. Required files exist
echo "--- Required files ---"
for f in CLAUDE.md README.md scaffold.md install.sh install.ps1 doctor.sh doctor.ps1; do
  check_file "$f"
done

# 2. Reference files exist
echo "--- Reference files ---"
for f in content structure enforcement self-improving anti-patterns checklist lessons lsp security agents-and-commands; do
  check_file "reference/${f}.md"
done

# 3. CLAUDE.md is under 150 lines
echo "--- Line budgets ---"
lines=$(wc -l < CLAUDE.md)
if (( lines <= 150 )); then
  pass "CLAUDE.md is ${lines} lines (≤150)"
else
  fail "CLAUDE.md is ${lines} lines (>150)"
fi

# 4. All reference files are under 150 lines each
for f in reference/*.md; do
  [[ -f "$f" ]] || continue
  n=$(wc -l < "$f")
  if (( n <= 150 )); then
    pass "${f} is ${n} lines (≤150)"
  else
    fail "${f} is ${n} lines (>150)"
  fi
done

# 5. scaffold.md contains required template sections
echo "--- scaffold.md sections ---"
for section in "CLAUDE.md Template" "LESSONS.md Template" "REVIEW.md Template" "Common Pitfalls by Domain"; do
  if grep -q "$section" scaffold.md 2>/dev/null; then
    pass "scaffold.md contains '${section}'"
  else
    fail "scaffold.md missing '${section}'"
  fi
done

# 6. install.sh is executable
echo "--- install.sh permissions ---"
if [[ -x install.sh ]] || head -1 install.sh 2>/dev/null | grep -q '^#!'; then
  pass "install.sh is executable or has shebang"
else
  fail "install.sh not executable and no shebang"
fi

# 7. install.sh contains all required steps
echo "--- install.sh content ---"
for marker in \
  "npm install -g @anthropic-ai/claude-code" \
  "npm install -g pyright" \
  "plugins install superpowers" \
  "plugins install code-review" \
  "chromewebstore.google.com" \
  "claude --chrome"; do
  if grep -qF "$marker" install.sh 2>/dev/null; then
    pass "install.sh contains '${marker}'"
  else
    fail "install.sh missing '${marker}'"
  fi
done

# 8. No broken internal references in CLAUDE.md
echo "--- CLAUDE.md internal references ---"
broken=0
while IFS= read -r ref; do
  if [[ ! -e "$ref" ]]; then
    fail "CLAUDE.md references '${ref}' which does not exist"
    broken=1
  fi
done < <(grep -oE '(reference/[a-z0-9_-]+\.md|scaffold\.md|install\.(sh|ps1)|doctor\.(sh|ps1))' CLAUDE.md 2>/dev/null | sort -u)
if (( broken == 0 )); then
  pass "All file references in CLAUDE.md resolve"
fi

# 9. LSP temporary marker exists
echo "--- LSP marker ---"
if grep -qi "TEMPORARY" reference/lsp.md 2>/dev/null; then
  pass "reference/lsp.md contains TEMPORARY marker"
else
  fail "reference/lsp.md missing TEMPORARY marker"
fi

# Summary
echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed"
exit $(( FAILED > 0 ? 1 : 0 ))
