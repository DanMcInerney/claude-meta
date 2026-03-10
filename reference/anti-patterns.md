# Anti-Patterns — What Wastes Claude's Tokens

## Research Backing

A 2026 ETH Zurich study across 138 repos and 5,694 PRs found that **detailed context files reduce success rates while adding 20%+ to costs**. LLM-generated context files performed worst. Human-written ones were only marginally useful when limited to non-inferable details.

The community consensus has shifted: **less is more**.

---

## 1. The Linter's Job

**Pattern:** Code style rules in CLAUDE.md — indentation, formatting, naming, import ordering.

**Why it fails:** LLMs are expensive and unreliable formatters. Style instructions add noise to every conversation. Claude is an in-context learner — if your code follows conventions, Claude follows them without being told.

**Fix:** Use linters/formatters enforced via hooks. Never send an LLM to do a linter's job.

---

## 2. The Documentation Novel

**Pattern:** Paragraphs of prose explaining how things work.

**Fix:** Replace with API signatures, tables, and code blocks. One signature > one paragraph.

---

## 3. The Stale Snippet

**Pattern:** Code examples inline in CLAUDE.md.

**Why it fails:** Code changes but CLAUDE.md doesn't get updated. Claude follows the stale example and produces outdated patterns.

**Fix:** Use `file:line` references to point to authoritative source: "See `games/hp_jeopardy/__init__.py` for a complete example." The code is always current.

---

## 4. The Monolithic Root File

**Pattern:** 400+ lines in a single root CLAUDE.md.

**Why it fails:** Loads on every conversation. Buries critical decisions under reference material. As instruction count increases, instruction-following quality decreases uniformly across all instructions.

**Fix:** Root ≤150 lines. Use subdirectory CLAUDE.md files, @imports, and path-scoped rules.

---

## 5. The Missing Decision Tree

**Pattern:** Documenting everything *about* the system except how to choose between approaches.

**Why it fails:** Claude's #1 question is "which pattern?" Without a decision tree, it reads 10+ files to reverse-engineer patterns. This is the single biggest source of wasted tokens.

**Fix:** Table mapping intent → pattern → files. Always in root CLAUDE.md.

---

## 6. The Echo Chamber

**Pattern:** Same information in root, subdirectory, and leaf CLAUDE.md files.

**Fix:** Each fact lives in one place. Others point to it.

---

## 7. The Over-Specified File

**Pattern:** Documenting things Claude can figure out from code — file structure, obvious method behavior, standard language conventions.

**Why it fails:** ETH Zurich study: detailed files hurt more than they help. Claude can `ls`, read code, and follow imports. Documenting what it can discover wastes instruction budget and trains it to not look at code.

**Fix:** Only document what Claude can't infer: decisions, conventions, gotchas, commands.

---

## 8. The Secret Convention

**Pattern:** Implicit conventions that aren't written anywhere.

**Fix:** If a convention exists, write it. One bullet prevents an entire class of bugs.

---

## 9. The Aspirational Doc

**Pattern:** Documenting planned features, future work, or things that don't exist yet.

**Why it fails:** Claude treats docs as describing current state. It will try to use APIs that don't exist.

**Fix:** CLAUDE.md describes what IS. Future plans go in docs/plans/.

---

## 10. The /init Dump

**Pattern:** Running `/init` and committing the output without curation.

**Why it fails:** `/init` generates a reasonable starting point but includes things Claude can infer. Uncurated, it's bloated and generic. Multiple guides cite this as the #1 beginner mistake.

**Fix:** Run `/init`, then ruthlessly prune. Keep only what passes the litmus test: "Would removing this cause mistakes?"

---

## 11. No CLAUDE.md At All

**Pattern:** Relying on Claude to figure everything out from exploration.

**Why it fails:** 5-15 tool calls per conversation to understand patterns. Multiplied across every session.

**Fix:** Even 30 lines (decision tree + commands + pitfalls) eliminates most exploration.

---

## 12. Everything Is IMPORTANT

**Pattern:** Using emphasis markers on every rule.

**Why it fails:** Emphasis works by contrast. If everything is critical, nothing stands out and Claude deprioritizes uniformly.

**Fix:** Reserve IMPORTANT/MUST for 2-3 rules where violation causes hard-to-debug failures.
