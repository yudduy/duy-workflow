---
description: "Iteratively verify, fix, and improve PoC code before experiments. Finds bugs, fixes them, re-verifies, researches frontier improvements, implements them. Doesn't just report -- delivers working code."
argument-hint: "[path/to/poc]"
impact: CRITICAL
when-to-use: Before running experiments - verifies correctness AND applies improvements
allowed-tools: Task, Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch, mcp__deepwiki__ask_question, mcp__deepwiki__read_wiki_structure, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository
---

# /verify-poc

Verify, fix, and improve PoC code iteratively. Not a report generator -- an engineer that delivers working, frontier-informed code ready for experiments.

**The user's time is the most expensive resource. Don't hand them a list of bugs. Fix the bugs. Re-verify. Research improvements. Implement them. Hand back working code.**

---

## Phase 1: Discover + Environment Check

**Run in parallel:**

1. **Technique discovery** (Agent, Explore): Find all algorithm implementations in {path}. Look for paper references (arXiv, DOI), algorithm names, mathematical formulas in comments. Return: technique name, file:line, cited source.

2. **Environment check** (Agent, Explore): Dependencies pinned? Lockfile exists? Checkpoints/recovery? Input validation? Config sanity (token limits, batch sizes, dataset paths)?

3. **Codebase read** (you): Read ALL source files in {path}. Understand the full architecture before verifying anything.

---

## Phase 2: Parallel Verification + Research (one agent per technique)

For each discovered technique, spawn a sub-agent:

```
"Verify [TECHNIQUE] at [file:line] against its source.

1. RESEARCH: WebSearch for original paper. alphaxiv for the paper content. DeepWiki on reference implementations. Find canonical formula, parameters, known pitfalls.

2. VERIFY line-by-line: Does formula match source? Parameters correct? Edge cases handled? Numerical stability? Report: MATCH / MISMATCH / DEVIATION with specifics.

3. RESEARCH FRONTIER: alphaxiv + WebSearch for improvements since the original paper (2024-2026). What's the SOTA version of this technique? What do practitioners report as common failures?

4. FIND REFERENCE IMPLEMENTATIONS: gh search + WebSearch + DeepWiki for battle-tested implementations of this technique. We will COPY from these, not rewrite.

Output: verification status, list of bugs with exact file:line, frontier improvements with source, reference implementation links."
```

**Also in parallel:** Run a code-reviewer sub-agent on the ENTIRE codebase:
```
"Review all code in {path} for critical issues ONLY. Skip style.
1. Correctness: happy path, edge cases, hardcoded limits (token caps, dataset sizes), NaN-producing paths, OOM risks.
2. Bugs: resource leaks, wrong gradient flow, broken metrics, incorrect loss computation.
3. Performance: sequential when parallel possible, data bottlenecks, wasted memory.
4. Config: are hardcoded values appropriate for the task? Token limits? Batch sizes? Learning rates?
Format: [SEVERITY] file:line -- Issue / Why / Fix"
```

---

## Phase 3: FIX (iterative -- don't just report)

**For each bug found (CRITICAL and HIGH first):**

1. Read the reference implementation (from Phase 2 research)
2. COPY the correct implementation from the reference
3. Adapt to fit the codebase
4. Edit the file

**For each frontier improvement (if clearly better and low-risk):**

1. Read the reference implementation from the improved variant
2. Implement it (copy-before-rewrite from reference)
3. Mark as IMPROVEMENT in the changelog

**Track all changes:**
```markdown
## Changes Applied
| File:Line | Type | What | Reference Source | Before | After |
|-----------|------|------|-----------------|--------|-------|
| trainer.py:45 | BUG FIX | Wrong loss scaling | FlowRL repo | scale="default" | scale="none" |
| config.yaml:12 | BUG FIX | Token limit too low | SPO paper | 512 | 2048 |
| sampler.py:80 | IMPROVEMENT | Adaptive beta | SAC paper | fixed beta=1.0 | dual gradient descent |
```

---

## Phase 4: Re-verify (/collab dialectic)

After ALL fixes applied, run iterative cross-verification:

**Round 1: Three reviewers in parallel on the FIXED code:**

- Code-reviewer sub-agent: "Re-verify all techniques against sources. Are the fixes correct? Did fixes introduce new bugs? Run through the checklist again on the MODIFIED files."

- Codex: "ADVERSARIAL REVIEW of these changes: {changelog}. Original code: {before}. Fixed code: {after}. Did the fixes actually address the issues? Any new bugs? Any regression? What's still wrong?"

- Gemini: "ADVERSARIAL REVIEW. Changes applied: {changelog}. Is the math still correct after fixes? Any numerical stability issues introduced? What's the most likely way this STILL fails when we run experiments?"

**Round 2: Cross-pollinate.** Each reviewer sees the other two's findings. Fix any new issues. Re-review.

**Round 3 if needed.** Converge when all 3 say PASS.

---

## Phase 5: Smoke Test (if compute available)

If the PoC includes runnable experiments:

1. Run a 2-step smoke test (--max-steps=2 or equivalent)
2. Check: starts without error? Loss finite? Metrics collecting (no NaN)? Memory stable?
3. If smoke test fails: diagnose, fix, re-verify (back to Phase 4), re-smoke-test
4. **Parallelize independent conditions** -- if there are multiple experimental conditions (e.g., GRPO vs TB vs SegTB), smoke test ALL in parallel, not sequentially

---

## Phase 6: Present (only after all verification passes)

```markdown
## PoC Verification: {Name}

**Status:** VERIFIED AND FIXED | VERIFIED (no issues) | BLOCKED (unfixable issues)

### Changes Applied
{changelog table from Phase 3}

### Verification Results (post-fix)
| Technique | Status | Reference | Notes |
|-----------|--------|-----------|-------|
| {technique} | MATCH | {paper/repo} | {any caveats} |

### Frontier Improvements Applied
| Improvement | Source | Impact |
|-------------|--------|--------|
| {what changed} | {paper/repo} | {expected effect} |

### Remaining Concerns
- {anything that couldn't be fixed or needs user judgment}

### Smoke Test
- Status: PASS / FAIL / NOT RUN
- {results if run}

### Ready for Experiments?
YES -- code is verified, fixed, and frontier-informed. / NO -- {blocking issues}
```

**This report has been iteratively reviewed by Codex + Gemini + Claude sub-agent. The user is the last checkpoint, not the first reviewer.**
