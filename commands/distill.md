---
description: Distill enduring questions into timeless, incompressible wisdom — decomposes, challenges assumptions, vary-tests principles, synthesizes with Naval/Deutsch density
argument-hint: "<question> [--deep] [--refine PATH] [--drill PRINCIPLE] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /distill

Takes a question and produces the incompressible kernel. Not a knowledge dump — the answer that survives mutual scrutiny between the best thinkers on the subject.

3-agent team (researcher + philosopher + editor) coordinated by a lead.

## Flags

- `--deep`: 3x iterations, broader source mining
- `--refine PATH`: Go deeper on an existing distillation (targets weakest area or OPEN principles)
- `--drill PRINCIPLE`: Focused deep-dive on a specific principle from an existing distillation
- `--max-iterations N`: Override default (15, deep: 45)

## Principles

1. **Lindy over trendy.** Centuries-old ideas that still work beat this year's blog post.
2. **First principles over opinions.** "Why?" until you hit bedrock — physics, human nature, math, evolution.
3. **Compress ruthlessly.** If you can say it shorter without losing meaning, say it shorter.
4. **The question behind the question.** Before answering, find what's really being asked.
5. **Incompressibility test.** You literally cannot make the final answer shorter without losing something essential.
6. **Action over theory.** Every insight must cash out in behavior change.
7. **Challenge assumptions.** Every question rests on presuppositions. Surface them. Attack them. Fork if contested.
8. **Hard to vary over easy to vary.** A good explanation breaks when you change its details (Deutsch). Principles that survive variation are foundations. Principles that don't are your frontier.

## Setup

```bash
mkdir -p docs/distill/notes
```

### KG Survey (before researching)

Check what the vault already knows:

1. Read `Obsidian-Template-Vault/VAULT-INDEX.md` — scan Distillations table and Knowledge Graph (MOCs)
2. Identify MOCs relevant to the topic (by title/domain match)
3. For each relevant MOC: read its `## Key Insights` section (the wikilink list)
4. For each relevant MOC: read its `## Questions to Explore` section
5. Compile:
   - KNOWN: claims already captured as insights (don't re-research these)
   - OPEN: questions explicitly listed as unresolved
   - GAPS: what's not covered by any existing MOC
6. Research ONLY what's in OPEN + GAPS

If the topic matches an existing distillation exactly, this is refinement — read deeper, focus on gaps.

If `--refine` flag was provided, read the existing file and skip to execution.

## Phase 0: Decompose the Question

Before researching, break the question open:

```
1. RESTATE the question exactly as asked
2. What is the REAL question? (the question behind the question)
3. What is the ROOT? (the philosophical tension this is an instance of)
4. What ASSUMPTIONS does this question contain? List each one explicitly.
5. Break into 2-4 SUB-QUESTIONS that are more tractable than the root.
   Each sub-question must be answerable with research.
   Don't go past depth 2 — this is distillation, not a PhD thesis.
6. Who has spent DECADES on this? (identify the giants)
7. Is this question Lindy? (will people still ask this in 100 years?)
```

Write the decomposition to the output file. This IS the first three sections (Question You Asked, Real Question, Root).

## Output Template

```markdown
# {Question — short form}

## The Question You Asked
{original question, verbatim}

## The Real Question
{the deeper question — what you're actually wrestling with}
{1-3 sentences. Should make the reader go 'oh, THAT's what I meant.'}

## The Root
{the philosophical tension this touches}
{1-2 sentences.}

## First Principles
{3-7 load-bearing truths — each vary-tested. Remove any FOUNDATION and the answer collapses.}

1. **Name** — One sentence. [Source] ⬛ FOUNDATION — hard to vary; negating breaks {what}
2. **Name** — One sentence. [Source] ⬜ OPEN — {what varies}; competing framings: {A vs B}
...

## The Answer
{THE incompressible kernel. 3-7 sentences MAX. Every word load-bearing.}

## Key Insights
{5-10 independently valuable and actionable insights.}

1. **Insight** — 1-2 sentences. [Source]
2. ...

## Contrarian Truth
{1-2 things most people get wrong. True but unpopular.}

## What Changes Tomorrow
{1-3 concrete behavioral changes. DO differently, not think differently.}

## The Next Question
{Driven by the highest-value OPEN principle above. Must state:
 - Which OPEN principle this emerges from
 - The competing framings that make it genuinely open
 - What would resolve it — experiment, evidence, or artifact
 - Why answering THIS opens more territory than any alternative}

## Sources (by Lindy-ness)
### Timeless (100+ years)
### Enduring (10-100 years)
### Recent (< 10 years)
```

## Quality Gates

Before completing:
- [ ] 'The Real Question' makes the reader feel understood
- [ ] Every First Principle traces to bedrock
- [ ] Every First Principle has a variability annotation (⬛ FOUNDATION or ⬜ OPEN)
- [ ] At least 2 principles were vary-tested (philosopher agent or self-test)
- [ ] Every ⬜ OPEN principle states what specifically varies and competing framings
- [ ] 'The Answer' passes the incompressibility test
- [ ] Every Key Insight is independently actionable
- [ ] Contrarian Truth is genuinely contrarian AND evidenced
- [ ] 'What Changes Tomorrow' is doable in 24 hours
- [ ] 'The Next Question' traces to a specific ⬜ OPEN principle (not generic)
- [ ] 'The Next Question' was verified as genuinely open via WebSearch
- [ ] Timeless sources exist (if not, the answer isn't Lindy enough)
- [ ] Strongest counterargument addressed
- [ ] At least 2 presuppositions were challenged

## KG Deposit (runs at completion in all modes)

After the distillation passes quality gates, deposit findings into the vault knowledge graph.

### Step 1: Write finished output to vault
Write to `Obsidian-Template-Vault/3. Resources (Dynamic)/Distillations/Distillation - {Title}.md`

Frontmatter:
```yaml
tags:
  - content/distillation
  - topics/{topic-slug}
type: research
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: completed
```

### Step 2: Extract atomic insights (3-7 new, not duplicates)
a. Glob `Obsidian-Template-Vault/3. Resources (Dynamic)/Insights/Insight - *.md` — scan filenames
b. For each candidate claim: if a similar insight already exists, skip (or update if new evidence strengthens it)
c. Create new: `Insight - {Claim as Statement}.md` with frontmatter (tags, type: research, belief_confidence 0.5-0.95), claim paragraph, Evidence section, Relationships section with wikilinks

### Step 3: Update or create MOC
a. Check if `MOC - {Topic}.md` exists in `3. Resources (Dynamic)/`
b. If exists: add new insight wikilinks to `## Key Insights`, add distillation link to `## Distillation`, update `modified`
c. If new: create from template (Overview, Distillation, Key Insights, Research Notes, Questions to Explore, Agent Navigation Notes)

### Step 4: Update indexes
a. Add/update entry in `MOC - Research Index.md` (in `3. Resources (Dynamic)/`)
b. Update VAULT-INDEX.md if new MOC or new distillation

---

## Agent Team

Three persistent agents coordinated by a lead ralph loop. Each agent accumulates context across iterations — no one-shot throwaway agents.

### Agent Team

```
Spawn 3 Task agents (run_in_background: true):

RESEARCHER (model: sonnet, subagent_type: general-purpose):
"You are a research miner for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Your job: find the BEST sources. Not the most — the best.
Source hierarchy: decade-long practitioners > books > papers > essays.
WebSearch aggressively for:
- Thinkers who spent decades on this question
- Best-regarded books on this topic
- Contrarian voices who disagree with mainstream
- Meta-analyses and foundational research
Write ALL findings to docs/distill/notes/sources.md.
For each source: key insight (< 20 words), citation, Lindy rating (timeless/enduring/recent)."

PHILOSOPHER (model: opus, subagent_type: general-purpose):
"You are a first-principles philosopher for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md for what the researcher found.
Your job: extract first principles, challenge ALL assumptions, AND run the Deutsch vary test on ALL principles.

For each assumption in the question: WebSearch for evidence against it.
Verdict per assumption: CONFIRMED / REFUTED / CONTESTED + confidence 0-100.

For each principle you identify:
1. State it. Trace to bedrock. What breaks if removed.
2. NEGATE it — does the answer survive? If yes → decorative.
3. SWAP it — find a plausible alternative. WebSearch for evidence.
4. SCOPE it — universal or domain-specific? WebSearch for counterexamples.
5. Rate: FOUNDATION (0-30) / CONTESTED (30-70) / OPEN (70-100)

Write to docs/distill/notes/principles.md.
Format per principle: PRINCIPLE | VARIABILITY SCORE | BEST ALTERNATIVE | WHAT BREAKS IF NEGATED | VERDICT

Find the contrarian truth — what's true but unpopular?
The OPEN principles are as valuable as the FOUNDATIONS — they're where discoveries hide."

EDITOR (model: opus, subagent_type: general-purpose):
"You are a ruthless compression editor for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md and docs/distill/notes/principles.md.
Your job: compress while preserving structural information. Every word must be load-bearing.
Write compressed drafts to docs/distill/notes/compressed.md.
Rules: remove derivatives, remove hedging, merge redundancies, incompressibility test.

CRITICAL: preserve variability annotations from principles.md through compression.
- Every First Principle keeps its ⬛/⬜ marker
- ⬜ OPEN must state what varies (the frontier)
- ⬛ FOUNDATION must state what breaks if negated
- The Next Question must trace to highest-value ⬜ OPEN principle

The distillation should get SHORTER each pass, never longer."
```

### Lead Coordination

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-15}" \
  --completion-promise "DISTILLED" \
  "You are the distillation lead. Do NOT research or write insights yourself.

Each iteration:
1. Check on background agents (read their output files)
2. Read ALL note files in docs/distill/notes/
3. Synthesize into docs/distill/{slug}.md — apply the template format
4. Assess quality gates (including variability annotations)
5. If agents are still running, wait. If done, resume them with follow-up work:
   - Researcher: 'Find sources for {weakest section}' or 'Verify {OPEN principle} is genuinely unresolved'
   - Philosopher: 'Vary-test {principle}' or 'Challenge assumption: {assumption}'
   - Editor: 'Compress {section} — currently {N} words, target {N/2}'

Aporia-driven synthesis (your unique responsibility):
- Review all principles with variability annotations from philosopher
- Rank OPEN principles by productive tension
- Drive The Next Question from the confirmed highest-value OPEN principle

When all quality gates pass:
1. Run KG Deposit (see KG Deposit section below)
2. <promise>DISTILLED</promise>"
```

### Token Efficiency
- Researcher: Sonnet (search-heavy, cheaper)
- Philosopher + Editor: Opus (deep reasoning)
- Cross-talk via note files only (docs/distill/notes/)
- Lead only synthesizes — never searches or reasons about content
- 3 agents total, persistent across iterations

---

## Refinement Mode (--refine)

1. Read existing file
2. Identify target: weakest area OR if `--drill PRINCIPLE` specified, focus on that principle
3. Drilling behavior depends on target type:
   - ⬜ OPEN principle: search for who's actively working on this. Map competing framings with citations.
   - ⬛ FOUNDATION principle: run a second vary test with a different framing. If it breaks, reclassify as OPEN.
   - The Next Question: treat as a new distillation input with parent distillation as context.
4. File should get SHORTER or EQUAL, never longer

## Output

```
Distilled: Obsidian-Template-Vault/3. Resources (Dynamic)/Distillations/Distillation - {Title}.md
- First Principles: {N} (⬛ Foundations: {F}, ⬜ Open: {O})
- Key Insights: {M}
- Sources: {S} (Timeless: {T}, Enduring: {E}, Recent: {R})
- Presuppositions challenged: {P}
- Principles vary-tested: {V}
- Next question: {driven by OPEN principle — the question this opens}
- Drill targets: {list of OPEN principles available for --drill}
```
