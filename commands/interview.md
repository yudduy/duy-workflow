---
description: "Product-driven interview → Product Intent Document in Plan Mode. Researches exhaustively, understands the WHY, produces understanding deep enough for autonomous execution."
argument-hint: "[product/feature/problem description]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, EnterPlanMode, ExitPlanMode, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository
---

# /interview

Produce a Product Intent Document -- deep enough that an autonomous agent can make implementation decisions without asking. Not a spec. An understanding.

## Enter Plan Mode

Call `EnterPlanMode` immediately.

---

## Anti-Reward-Hacking Gates

These prevent the interview from producing a document that "looks complete" but misses product intent.

1. **Backpressure**: After drafting the plan, ask yourself: "given a novel implementation decision the user didn't anticipate, could an agent make the right call from this document alone?" If no → the document is insufficient. Research more, ask more.
2. **Knowledge Map**: Every external source (paper, repo, competitor) gets one row: source → core contribution → verified? → implication. Never re-read a source. Read the row.
3. **Cross-agent verification**: Before presenting the plan, dispatch Codex: "Given this Product Intent Document, what implementation decision would YOU make about [specific ambiguous scenario]?" If Codex's answer diverges from what the user would want → the document is missing something.
4. **Constraint re-injection**: Every 3 questions, re-read the user's original description. Am I still solving THEIR problem or drifting to what's easier to build?
5. **Never invent requirements**: The document captures what the user wants, not what you think they should want. If you see a gap, ASK -- don't fill it silently.

---

## PHASE 1: RESEARCH (before asking a single question)

Run all in parallel as subagents:

### 1A: Find What Already Exists
```bash
gh search repos "<keywords>" --limit 10 --json fullName,description,stargazersCount --sort stars
gh search code "<specific patterns>" --limit 10 --json repository,path
```
Identify top candidates that solve 80%+ of the problem.

### 1B: Understand the Best Candidates
DeepWiki MCP (`ask_question`) on each:
- Architecture, key mechanism, interfaces
- How they solve the core problem
- What's their product positioning? Who uses it? What are the complaints?
- Can we extract or adopt?

### 1C: Literature (if academic grounding exists)
All three alphaxiv search tools in parallel. Then `get_paper_content` on most relevant. Verify claims.

### 1D: Competitor/Market Research
WebSearch for: how do existing products solve this? What do users complain about? What's the unmet need?

### 1E: Codebase Scan
Grep for related functionality. What already exists? What patterns does the codebase use?

### 1F: Build Knowledge Map
Compress ALL research into the Knowledge Map -- one row per source. This is what persists. The papers/repos don't.

```markdown
## Knowledge Map
| Source | ID | Core Contribution | Verified? | Implication |
|--------|-----|-------------------|-----------|-------------|
| {repo} | github.com/... | {what it does, how} | ✓ DeepWiki | {extract X / adopt Y / irrelevant} |
| {paper} | arxiv:... | {key finding} | ✓ WebFetched | {apply to our problem because...} |
| {competitor} | {product} | {how they solve it} | ✓ WebSearch | {we differentiate by...} |
```

### 1G: Multi-Model Consultation on Approach
Before proposing anything to the user:

```bash
codex exec --skip-git-repo-check "Given these findings: {research summary}
The user wants: {description}. Existing solutions: {top repos}.
What approach would you take? What's the biggest product risk?"

gemini -p "Given: {same context}. What would a contrarian product person say?
What's the unmet need that existing solutions miss?"
```

---

## PHASE 2: PRESENT RESEARCH, THEN INTERVIEW

### Present What You Found
Before asking any questions, show the user:
1. "Here's what already exists that solves this: [repos, products, with assessment]"
2. "The best candidate to build from: [X] because [reason]"
3. "The unmet need that existing solutions miss: [gap]"
4. "Codex recommends [approach]. Gemini flags [risk]."
5. "Here's what I think you want -- correct me"

### The Interview Loop
```
Propose what you THINK the user means (grounded in research)
  → User corrects or confirms
    → If corrects: SEARCH for what they corrected toward, update Knowledge Map, re-propose
    → If confirms: deepen understanding, move to next aspect
      → Repeat until the Product Intent Document can pass the backpressure gate
```

### What to Elicit (from 5 frameworks)

**The Job (JTBD):** Who is the user? What are they trying to accomplish? What does their life look like before and after? What are the switching forces -- what pulls them toward this, what holds them back?

**The Announcement (Working Backwards):** Can you write the launch tweet? One paragraph press release? If you can't write it compellingly, the vision isn't clear enough yet. Keep interviewing.

**The Appetite (Shape Up):** How much complexity is this worth? What's the rough solution shape? What's EXPLICITLY out of scope? What rabbit holes have been identified and decided?

**The Principles (Constitution):** Non-negotiable product values. "Always X over Y." "Never Z." These become the agent's decision-making heuristics for ambiguous situations.

**The Boundaries (Intent Engineering):**
- Success criteria: how do we know it worked?
- Invariants: what must NOT break while we build this?
- Guardrails: hard limits that cannot be violated
- Stop rules: when should the agent escalate vs decide autonomously?

**The Why Behind Decisions:** For each major decision already made -- WHY. Not "we use Postgres" but "we chose Postgres because..." This lets the agent make analogous decisions for things the document doesn't cover.

### Reactive Research
When the user mentions something you can't ground -- search IMMEDIATELY. Don't ask them to explain what you could look up. Update Knowledge Map with the finding.

---

## PHASE 3: PRODUCE THE PRODUCT INTENT DOCUMENT

Write this in Plan Mode. This is NOT a spec. It's compressed product understanding.

```markdown
# Product Intent: {Name}

## The Job
[Who is the user? What job are they hiring this to do? Before/after state.]

## The Announcement
[One paragraph. The launch tweet. If this isn't compelling, the vision isn't clear.]

## The Appetite
[How much complexity is this worth? Rough solution shape. Time box.]

## Out of Scope
[Explicit. With WHY for each exclusion.]

## Principles
[Non-negotiable product values. Decision heuristics for ambiguous situations.]
- Always {X} over {Y}
- Never {Z}
- When in doubt, choose {A}

## Boundaries
- **Success**: {how we know it worked}
- **Invariants**: {what must not break}
- **Guardrails**: {hard limits}
- **Stop rules**: {when to escalate vs decide}

## Key Decisions (with WHY)
| Decision | Choice | Why | Alternatives Considered |
|----------|--------|-----|------------------------|

## Approach
[Which existing implementation to scaffold from. What to extract/adopt/build.]

## Source Map (CRITICAL -- /execute uses this to copy before rewrite)
| Requirement | Reference Source | Repo/File | What to Copy | What to Adapt |
|-------------|----------------|-----------|-------------|---------------|
| REQ-1 | {existing repo or internal code} | {github.com/x or local path} | {specific classes/functions} | {what needs changing} |
[For each requirement: where does the code come from? /execute will COPY these files first, then adapt. If "Build from scratch" appears here, the agent must justify why no reference exists.]

## Knowledge Map
[Persisted research -- one row per source, verified, with implications]

## The Why Behind Everything
[The reasoning chain. If an agent reads only this section, it should understand
the product deeply enough to make aligned decisions the document doesn't cover.]
```

### ITERATIVE ADVERSARIAL REVIEW (before presenting to user -- NON-NEGOTIABLE)

**The user's time is the most expensive resource. NEVER present unreviewed work. You iterate internally until it's presentable. The user is the LAST checkpoint, not the first reviewer.**

Use the /collab pattern: three models debate back and forth across rounds. Not just "collect feedback" -- they see each other's critiques, challenge each other, and converge through dialectic.

**Round 1: Dispatch all 3 reviewers in parallel.**

Codex (via Bash, run_in_background: true):
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
codex exec --skip-git-repo-check "You are an autonomous agent about to implement this product.
Read this Product Intent Document: {full document text}
1. What requirement would you get WRONG from this document? (ambiguity test)
2. What's MISSING that you'd need to make implementation decisions?
3. What's the weakest section? Why?
4. Pick a specific ambiguous scenario not covered -- what would you decide? (alignment test)
5. Is the Source Map complete -- does every requirement have a reference implementation?
Write findings to /tmp/review-r1-codex.md"
```

Gemini (via Bash, run_in_background: true):
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
gemini -p "You are a product critic reviewing this plan before it goes to the founder.
Product Intent Document: {full document text}
1. What will FAIL when this gets built? What hasn't been thought through?
2. What would the user REJECT? What doesn't match how a busy technical founder thinks?
3. What's over-engineered? What's under-specified?
4. Is the scope realistic for the appetite described?
5. Grade A-F. What would make it an A?" > /tmp/review-r1-gemini.md
```

Claude subagent (via Agent tool, run_in_background: true):
```
You are a senior engineer reviewing this Product Intent Document for implementability.
Document: {full document text}
1. Can you build this WITHOUT asking any questions? If not, what's ambiguous?
2. What's the riskiest technical assumption?
3. Does the Source Map actually contain real repos with real code, or is it aspirational?
4. What would you cut to ship faster?
5. What critical edge case will blow up in production?
Write findings to /tmp/review-r1-claude.md
```

**After Round 1: Collect all findings. Fix EVERY valid issue.**

**Round 2: Cross-pollinate and debate.** Feed the REVISED document + ALL THREE Round 1 critiques to each reviewer. They see each other's findings:

- Codex: "Here's the revised doc. Gemini said {X}. Claude said {Y}. Your Round 1 said {Z}. Did my fixes address everything? Do you agree with the others' critiques? What's still wrong?"
- Gemini: same pattern, sees Codex + Claude findings
- Claude subagent: same pattern, sees Codex + Gemini findings

This is the /collab dialectic -- they challenge each other, not just you. Codex might disagree with Gemini's critique. That disagreement is signal.

**Round 3 (if needed): Final convergence.** Fix remaining issues. One more pass if Round 2 surfaced new problems. Max 3 rounds.

**Convergence: ONLY present to the user when all 3 agree "ready to present" with no remaining critical issues.** If they can't converge after 3 rounds, present with an explicit "Unresolved disagreements" section so the user knows what needs their judgment.

---

## PHASE 4: APPROVE & PERSIST

User approves the plan in Plan Mode. **You MUST write the file to disk** -- Plan Mode context does not survive /clear.

**Step 1: Write the plan file (MANDATORY -- this is the handoff to /execute):**
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
mkdir -p .claude/plans
```
Use the Write tool to create `.claude/plans/{auto-name}.md` with the FULL Product Intent Document (all sections from Phase 3). This file is what /execute reads. If it doesn't exist on disk, /execute is blind.

**Step 2: Exit Plan Mode.**
Call `ExitPlanMode`.

**Step 3: Verify the file exists:**
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
ls -la .claude/plans/*.md
```

**Step 4: Confirm to user:**
```
Product Intent Document written to .claude/plans/{auto-name}.md
- Job: {one sentence}
- Approach: {scaffold from X, build Y}
- Knowledge Map: {N sources, M verified}
- Principles: {top 3}
- Codex alignment check: PASSED

To build: /clear then /execute
The plan survives /clear because it's on disk, not in context.
```
