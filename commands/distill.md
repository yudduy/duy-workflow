---
description: Distill enduring questions into timeless, incompressible wisdom — decomposes, challenges assumptions, synthesizes with Naval/Deutsch density
argument-hint: "<question> [--deep] [--refine PATH] [--team] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /distill

Takes a question and produces the incompressible kernel. Not a knowledge dump — the answer that survives mutual scrutiny between the best thinkers on the subject.

The process: decompose the question, challenge its assumptions, research the sub-questions, synthesize upward with compression. The output is clean and readable. The messy work stays internal.

## Flags

- `--deep`: 3x iterations, broader source mining
- `--refine PATH`: Go deeper on an existing distillation
- `--max-iterations N`: Override default (15, deep: 45)
- `--team`: Parallel agents: researcher + philosopher + editor

## Principles

1. **Lindy over trendy.** Centuries-old ideas that still work beat this year's blog post.
2. **First principles over opinions.** "Why?" until you hit bedrock — physics, human nature, math, evolution.
3. **Compress ruthlessly.** If you can say it shorter without losing meaning, say it shorter.
4. **The question behind the question.** Before answering, find what's really being asked.
5. **Incompressibility test.** You literally cannot make the final answer shorter without losing something essential.
6. **Action over theory.** Every insight must cash out in behavior change.
7. **Challenge assumptions.** Every question rests on presuppositions. Surface them. Attack them. Fork if contested.

## Setup

```bash
mkdir -p docs/distill
```

Check for `docs/HANDBOOK.md`. If it exists, READ it for related distillations.

If `--refine` flag was provided, read the existing file and skip to the Ralph Loop.

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

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-15}" \
  --completion-promise "DISTILLED" \
  "You are a distillation agent. Produce a DISTILL.md containing the incompressible, timeless answer. Think like Naval and Deutsch had a conversation and you're writing down only what survived their mutual scrutiny.

## OUTPUT FILE

Write to docs/distill/{question-slug}.md:

\`\`\`markdown
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
{3-7 load-bearing truths — remove any one and the answer collapses.}

1. **Name** — One sentence. [Source]
2. ...

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
{The better question you should now be asking.}

## Sources (by Lindy-ness)
### Timeless (100+ years)
### Enduring (10-100 years)
### Recent (< 10 years)
\`\`\`

## ITERATION PHASES

### Phase 1 — DECOMPOSE (iteration 1)
Break the question into sub-questions. List every presupposition.
Write Question/Real Question/Root sections.
Identify which sub-questions map to which output sections.

### Phase 2 — RESEARCH (iterations 2-5)
Answer sub-questions one at a time. Web search is mandatory.

Source hierarchy:
1. Thinkers who spent decades on this
2. Best-regarded books
3. Long-form essays/interviews (not hot takes)
4. Meta-analyses and foundational papers
5. Contrarian voices who disagree with mainstream

Source quality: reject listicles, SEO, opinions without reasoning. Accept first-principles reasoning, skin-in-the-game practitioners, frameworks that explain WHY.

Each iteration:
1. READ current file
2. IDENTIFY weakest section
3. WebSearch + WebFetch for better sources on that section
4. WRITE sub-question answers into the appropriate output sections

### Phase 3 — CRITICIZE (iterations 6-8)
Challenge the assumptions you listed in Phase 1.

For EACH presupposition, delegate to a Task (general-purpose) agent:

CRITIC PROMPT:
A researcher claims this is true: {presupposition}
It underlies this question: {question}
WebSearch for evidence AGAINST this claim. Also search FOR it.
Output: EVIDENCE FOR | EVIDENCE AGAINST | VERDICT (CONFIRMED/REFUTED/CONTESTED) | CONFIDENCE 0-100
Every claim must have a URL citation.

If REFUTED: rewrite the sections that depended on it.
If CONTESTED: note both sides in the answer. This is where Contrarian Truth often lives.
If CONFIRMED: move on.

Also: search for the strongest counterargument to your current Answer section. Steel-man it. Address it directly or incorporate it.

### Phase 4 — SYNTHESIZE + COMPRESS (iterations 9-12)
Compose sub-question answers upward into First Principles and The Answer.

Compression protocol:
1. Remove derivatives — if B follows from A, keep only A
2. Remove context-dependent claims — if not true in another era/culture, cut
3. Remove hedging — state it directly or cut it
4. Merge redundancies — two insights saying the same thing → keep the sharper one
5. Incompressibility test — can you remove a single word? Do it. Repeat.

The Answer must be SHORTER than the sum of your sub-question answers. If it's longer, you're not synthesizing.

### Phase 5 — POLISH (iterations 13-15)
Final incompressibility test. Every word load-bearing.
Lindy test: would Seneca, Feynman, or Naval nod? If not, cut.

## QUALITY GATES

Before completing:
- [ ] 'The Real Question' makes the reader feel understood
- [ ] Every First Principle traces to bedrock
- [ ] 'The Answer' passes the incompressibility test
- [ ] Every Key Insight is independently actionable
- [ ] Contrarian Truth is genuinely contrarian AND evidenced
- [ ] 'What Changes Tomorrow' is doable in 24 hours
- [ ] 'The Next Question' is more interesting than the original
- [ ] Timeless sources exist (if not, the answer isn't Lindy enough)
- [ ] Strongest counterargument addressed
- [ ] At least 2 presuppositions were challenged via adversarial Task agents

## SELF-CHECK (Each Iteration)
- Did I find genuinely new information?
- Did the file get SHORTER (not longer)?
- Would I be embarrassed showing this to Naval? To Deutsch?
If last 2 iterations produced no meaningful improvement, complete.

## REFINEMENT MODE (--refine)
1. Read existing file
2. Research ONLY the weakest area
3. File should get SHORTER or EQUAL, never longer

## COMPLETION

When ALL quality gates pass AND compression has converged:
1. Final read-through: is every sentence load-bearing?
2. If docs/HANDBOOK.md exists, UPDATE it:
   {Question short form}
   ├── docs/distill/{slug}.md
   ├── Core: {one-sentence answer}
   ├── Thinkers: {key sources}
   └── Opens: {the next question}
3. <promise>DISTILLED</promise>

If stuck: <promise>BLOCKED: [reason]</promise>"
```

## Team Mode (--team flag)

When `--team` is specified, SKIP the Ralph loop above. Three roles: researcher mines sources, philosopher extracts principles and challenges assumptions, editor compresses.

### Setup

```
1. Create team: Teammate tool, operation: 'spawnTeam', team_name: '{question-slug}-distill'
2. Create output file docs/distill/{slug}.md with template above
3. Create docs/distill/notes/ directory
4. Spawn 3 teammates via Task tool with team_name:

RESEARCHER (model: 'sonnet', subagent_type: general-purpose):
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
For each source: key insight (< 20 words), citation, Lindy rating (timeless/enduring/recent).
When the philosopher or editor need evidence checked, claim their tasks."

PHILOSOPHER (model: 'opus', subagent_type: general-purpose):
"You are a first-principles philosopher for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md for what the researcher found.
Your job: extract first principles AND challenge assumptions.
Write reasoning to docs/distill/notes/principles.md.
For each principle: state it, trace to bedrock (physics/evolution/math/human nature), what breaks if removed.
For each assumption in the question: WebSearch for evidence against it. Note contested assumptions.
Find the contrarian truth — what's true but unpopular?"

EDITOR (model: 'opus', subagent_type: general-purpose):
"You are a ruthless compression editor for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md and docs/distill/notes/principles.md.
Your job: compress. Every word must be load-bearing.
Write compressed drafts to docs/distill/notes/compressed.md.
Rules: remove derivatives, remove hedging, merge redundancies, incompressibility test.
The distillation should get SHORTER each pass, never longer."
```

### Lead Coordination

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-15}" \
  --completion-promise "DISTILLED" \
  "You are the distillation lead. Do NOT research or write insights yourself.

Each iteration:
1. Check TaskList for status
2. Read ALL note files in docs/distill/notes/
3. Synthesize into docs/distill/{slug}.md — apply the template format
4. Assess quality gates (same as solo mode)
5. Create follow-up tasks:
   - Researcher: 'Find sources for {weakest section}' or 'Search for counterargument to {insight}'
   - Philosopher: 'Trace {principle} to bedrock' or 'Challenge assumption: {assumption}'
   - Editor: 'Compress {section} — currently {N} words, target {N/2}'

When all quality gates pass:
1. Update docs/HANDBOOK.md
2. Shutdown teammates (SendMessage type: 'shutdown_request')
3. Teammate cleanup
4. <promise>DISTILLED</promise>"
```

### Token Efficiency (team mode)
- Researcher: Sonnet (search-heavy)
- Philosopher + Editor: Opus (deep reasoning)
- Cross-talk via note files only
- Lead only synthesizes — never searches or reasons about content
- Max 3 teammates

## Output

```
Distilled: docs/distill/{slug}.md
- First Principles: {N}
- Key Insights: {M}
- Sources: {S} (Timeless: {T}, Enduring: {E}, Recent: {R})
- Presuppositions challenged: {P}
- Next question: {the question this opens}
```
