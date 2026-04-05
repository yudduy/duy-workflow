---
description: "Product-driven interview → Product Intent Document in Plan Mode. Researches exhaustively, understands the WHY, produces understanding deep enough for autonomous execution."
argument-hint: "[product/feature/problem description]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, EnterPlanMode, ExitPlanMode, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository
---

# /interview

Produce a Product Intent Document -- the execution contract for /execute. Deep enough that an autonomous agent can make implementation decisions without asking.

## Foundational Rigors (apply before and during ALL work)

Before each phase, run the **Three-Question Audit** from `${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`:
1. **DELETION**: What is the minimum true question here? Kill every assumption that can't survive interrogation.
2. **PRESENCE**: Go to primary sources. Read the paper, not the blog post. Reproduce the finding, not the claim.
3. **URGENCY**: What is the next action in the next 10 minutes? Fast rough answer now > perfect answer later.

Before proposing ANY approach, run the **Research Scaffold** from `${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`:
→ `gh search repos` + `gh search code` → DeepWiki on best candidates → alphaxiv (3 tools parallel) → clone → copy → scaffold.
**Adopt 80%+ solutions. Don't reinvent.** Phase 1 IS this pipeline.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
Every approach recommendation, research conclusion, and the final Product Intent Document → multi-model deliberation. Exhaust web search, alphaxiv, DeepWiki, and multi-model debate BEFORE presenting to user. The user is the LAST checkpoint, not the first reviewer.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Exploration = sub-agents. Targeted reads = yourself. Heavy lifting = sub-agents. Decisions = yourself.

## Enter Plan Mode

Call `EnterPlanMode` immediately.

---

## Anti-Reward-Hacking Gates

1. **Backpressure**: After drafting, ask: "Could an agent make a novel implementation decision from this document alone?" If no -- research more, ask more.
2. **Knowledge Map**: Every source gets one row: source | core contribution | verified? | implication. Never re-read a source. Read the row.
3. **Cross-agent verification**: Dispatch Codex with a specific ambiguous scenario from the document. If its answer diverges from user intent -- the document is missing something.
4. **Constraint re-injection**: Every 3 questions, re-read the user's original description. Still solving THEIR problem?
5. **Never invent requirements**: Capture what the user wants. If you see a gap, ASK -- don't fill silently.

---

## PHASE 1: RESEARCH (before asking a single question)

Run all 7 tasks in parallel as subagents:

1. **Find existing solutions** -- `gh search repos` + `gh search code` for 80%+ candidates
2. **Understand best candidates** -- DeepWiki each: architecture, mechanism, positioning, complaints, extractability
3. **Literature** -- All 3 alphaxiv search tools in parallel, then `get_paper_content` on most relevant
4. **Competitor/market** -- WebSearch: how do existing products solve this? Unmet needs? User complaints?
5. **Codebase scan** -- Grep for related functionality, existing patterns, conventions
6. **Build Knowledge Map** -- Compress ALL research: one row per source (source | ID | contribution | verified? | implication)
7. **Multi-model deliberation** -- Run the Deliberation Protocol (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`): Codex proposes approach + biggest risk, Gemini provides contrarian view + unmet needs, Claude subagent synthesizes. Iterate until convergence. This shapes the initial proposal to the user.

---

## PHASE 2: PRESENT RESEARCH + INTERVIEW

### Present What You Found

Before asking any questions, show the user:
1. What already exists that solves this (repos, products, assessment)
2. Best candidate to build from and why
3. Unmet need existing solutions miss
4. Codex recommendation + Gemini critique
5. Your hypothesis of what they want -- invite correction

### The Interview Loop

```
Propose what you THINK the user means (grounded in research)
  -> User corrects or confirms
    -> Corrects: SEARCH for what they corrected toward, update Knowledge Map, re-propose
    -> Confirms: deepen, move to next aspect
      -> Repeat until the document passes the backpressure gate
```

### What to Elicit

- **The Job (JTBD)**: Who is the user? What are they trying to accomplish? Before/after state. Switching forces -- what pulls them toward this, what holds them back.
- **The Announcement (Working Backwards)**: Write the launch tweet. One paragraph press release. If you can't write it compellingly, the vision isn't clear -- keep interviewing.
- **The Appetite (Shape Up)**: How much complexity is this worth? Rough solution shape. What's EXPLICITLY out of scope? Identified rabbit holes and decisions.
- **The Principles (Constitution)**: Non-negotiable product values. "Always X over Y." "Never Z." These become the agent's decision heuristics for ambiguous situations.
- **The Boundaries (Intent Engineering)**: Success criteria. Invariants (must not break). Guardrails (hard limits). Stop rules (escalate vs decide).

Also elicit:
- **The Why Behind Decisions**: For each major decision -- WHY. Not "we use Postgres" but "we chose Postgres because..." This lets the agent make analogous decisions.
- **Build Environment**: ASK the user: test command? Linter? Type checker? Build command? Start command? If unknown, determine from the codebase (package.json, pyproject.toml, Makefile). /execute needs exact commands -- pseudo-code is not enough.

### Reactive Research

When the user mentions something you can't ground -- search IMMEDIATELY. Don't ask them to explain what you could look up. Update Knowledge Map.

---

## PHASE 3: PRODUCE THE PRODUCT INTENT DOCUMENT

Write in Plan Mode. This is the **execution contract** -- everything /execute needs to build autonomously. Missing sections force /execute to improvise, which is exactly what we prevent.

Generate the plan ID deterministically:
```
PLAN_ID="$(date +%Y%m%d-%H%M%S)-$(echo '{short-name}' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
```

Read `${CLAUDE_PLUGIN_ROOT}/templates/plan-template.md` for the document structure. Fill every section. Every requirement gets a REQ-N ID with WHEN/SHALL acceptance criteria.

### Iterative Adversarial Review (NON-NEGOTIABLE)

**The user's time is the most expensive resource. NEVER present unreviewed work.**

Dispatch 3 reviewers in parallel using `${CLAUDE_PLUGIN_ROOT}/templates/review-taxonomy.md` for specific prompts:

1. **Codex** (via Bash, run_in_background): Ambiguity test -- what requirement would you get WRONG? What's missing for implementation decisions? Is Source Map complete? Are Build Environment commands real?
2. **Gemini** (via Bash, run_in_background): Product critique -- what will FAIL when built? What would the user REJECT? Over-engineered? Under-specified? Grade A-F.
3. **Claude subagent** (via Agent, run_in_background): Implementability -- can you build without questions? Riskiest assumption? Would you cut anything?

**Iteration bounds**: Min 2, max 3 rounds. Each round: fix valid issues, feed revised doc + ALL prior critiques to all reviewers (they see each other's findings -- dialectic, not just feedback collection). **Convergence: all 3 agree "ready to present" with no remaining critical issues.** If no convergence after 3 rounds, present with explicit "Unresolved disagreements" section.

---

## PHASE 4: APPROVE & PERSIST

User approves the plan in Plan Mode. You MUST write to disk -- Plan Mode context does not survive /clear.

**Step 1: Write the plan file.**
```bash
mkdir -p .claude/plans
```
Use the Write tool to create `.claude/plans/{PLAN_ID}.md` with the FULL Product Intent Document (all sections, including YAML frontmatter).

**Step 2: Exit Plan Mode.** Call `ExitPlanMode`.

**Step 3: Verify structure.**
```bash
PLAN=".claude/plans/{PLAN_ID}.md"
ls -la "$PLAN"
for section in "## Requirements" "## Build Environment" "## Source Map" "## Principles" "## Boundaries" "## Decision Precedence"; do
  grep -q "$section" "$PLAN" || echo "WARNING: Missing section: $section"
done
grep -q 'REQ-[0-9]' "$PLAN" || echo "ERROR: No enumerated requirements found"
```

**Step 4: Create mission artifacts.**
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
[ -d "$CLAUDE_PLUGIN_ROOT" ]
mkdir -p .claude/mission
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/sync-mission.py" --plan "$PLAN" --phase interview
ls -la .claude/mission/
jq -e . .claude/mission/intent.json >/dev/null
jq -e . .claude/mission/evidence.json >/dev/null
jq -e . .claude/mission/state.json >/dev/null
grep -q '^# Mission Plan:' .claude/mission/plan.md
```

Mission artifacts are required output of `/interview`, not optional extras.

**Step 5: Confirm.**
```
Product Intent Document written to .claude/plans/{PLAN_ID}.md
- Plan ID: {PLAN_ID}
- Job: {one sentence}
- Requirements: {N} (REQ-1 through REQ-N)
- Approach: {scaffold from X, build Y}
- Build Environment: {test/lint/type/build commands confirmed}
- Knowledge Map: {N sources, M verified}
- Principles: {top 3}
- Review convergence: {PASSED / Unresolved: ...}
- Mission artifacts: `.claude/mission/{intent.json,plan.md,evidence.json,state.json}`
```

**Step 6: Invoke /execute.** Invoke the `duy-workflow:execute` skill via the Skill tool. The plan and mission artifacts are on disk -- `/execute` reads and maintains them.
