---
description: Distill enduring questions into timeless, incompressible wisdom — Naval/Deutsch-density answers grounded in research
argument-hint: "<question> [--deep] [--refine PATH] [--team] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /distill

Takes an enduring question — about how to live, learn, act, optimize — and compresses it into Lindy, first-principles wisdom. Not a knowledge dump. The incompressible kernel.

The question matters more than the answer. This skill refines both.

## Flags

- `--deep`: 3x iterations, broader source mining, cross-domain analogies
- `--refine PATH`: Iterate on an existing distillation — go deeper on a specific insight or question
- `--max-iterations N`: Override default iteration limit (default: 15, deep: 45)
- `--team`: Use agent team: researcher + philosopher + editor working in parallel

## Principles

These govern every decision in the pipeline:

1. **Lindy over trendy.** Prefer ideas that survived centuries over ideas from this year. A principle from Seneca that still works beats a 2024 blog post.
2. **First principles over opinions.** Trace every claim to its root. "Why?" until you hit bedrock — physics, human nature, mathematics, evolution.
3. **Compress ruthlessly.** If you can say it shorter without losing meaning, say it shorter. The goal is Naval's almanack density — years of reading compressed into sentences.
4. **The question behind the question.** Before answering, find what's really being asked. "How do I approach girls?" might really be "How do I become someone who doesn't need to think about approaching girls?"
5. **Incompressibility test.** The final answer should fail the compression test — you literally cannot make it shorter without losing something essential.
6. **Action over theory.** Every insight must cash out in behavior change. If knowing it changes nothing about tomorrow, it's not worth distilling.
7. **Cite the giants.** Prefer thinkers who spent decades on the question: Naval on wealth, Taleb on risk, Deutsch on knowledge, Epictetus on control, Feynman on learning.

## Setup

```bash
mkdir -p docs/distill
```

### Initialize Handbook (if it doesn't exist)

Check for `docs/HANDBOOK.md`. If it exists, READ it — check for related distillations, research, or discoveries that inform this question.

If `--refine` flag was provided, read the existing distillation file and skip to the Ralph Loop with refinement context.

## Phase 0: Question Triage

Before researching, decompose the question:

```
1. RESTATE the question exactly as asked
2. Ask: what is the REAL question here? (the question behind the question)
3. Ask: what is the question behind THAT? (the existential/philosophical root)
4. Ask: what ASSUMPTIONS does this question contain? (hidden premises)
5. Ask: who has spent DECADES thinking about this? (identify the giants)
6. Ask: is this question Lindy? (will people still ask this in 100 years?)
7. Rewrite the question at 3 levels:
   - Surface level (what was asked)
   - Structural level (what pattern is this an instance of)
   - Root level (what fundamental tension does this touch)
```

Write the decomposition to the output file before researching. This IS the output's first section.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-15}" \
  --completion-promise "DISTILLED" \
  "You are a distillation agent. Your job: take the user's question and produce a DISTILL.md that contains the incompressible, timeless answer. You think like Naval Ravikant and David Deutsch had a conversation about this question and you're writing down only what survived their mutual scrutiny.

## OUTPUT FILE

Write to docs/distill/{question-slug}.md using this format:

\`\`\`markdown
# {Question — short form}

## The Question You Asked
{original question, verbatim}

## The Real Question
{the deeper question — what you're actually wrestling with}
{1-3 sentences. This reframe should make the reader go 'oh, THAT's what I meant.'}

## The Root
{the philosophical/existential tension this touches}
{1-2 sentences. The thing humans have always struggled with that this is an instance of.}

## First Principles
{3-7 principles. Each one is a load-bearing truth — remove any one and the answer collapses.}

1. **Principle name** — One sentence. [Source or reasoning chain]
2. ...

## The Answer
{THE incompressible kernel. What you'd say if you had 60 seconds and the person would forget everything else. 3-7 sentences MAX. Naval density. Every word load-bearing.}

## Key Insights
{5-10 insights. Each one is independently valuable and actionable.}

1. **Insight** — 1-2 sentence explanation. [Source: thinker/book/paper]
2. ...

## Contrarian Truth
{1-2 insights that most people get wrong about this topic. The thing that's true but unpopular.}

## What Changes Tomorrow
{1-3 concrete behavioral changes. Not 'think differently' — DO differently.}
- Action — why this specific action (one sentence)

## The Next Question
{The question this answer opens up. The better question you should now be asking.}

## Sources (by Lindy-ness)
### Timeless (100+ years)
- {ancient texts, philosophy, proven frameworks}
### Enduring (10-100 years)
- {seminal books, established research}
### Recent (< 10 years)
- {current research, modern synthesis}
\`\`\`

## RESEARCH PROTOCOL

You are not just reasoning from training data. You are RESEARCHING. Web search is mandatory.

### Source Hierarchy (search in this order)
1. **Thinkers who spent decades on this**: Search for their specific writing on this topic
2. **Books**: Search for the best-regarded books on this question
3. **Long-form essays/interviews**: Search for deep treatments, not hot takes
4. **Academic research**: Search for meta-analyses and foundational papers
5. **Contrarian voices**: Search specifically for people who disagree with the mainstream answer

### Source Quality Gates
- Reject: listicles, SEO content, anything that reads like it was written for clicks
- Reject: opinions without reasoning chains
- Reject: advice that depends on a specific era/culture/context (not Lindy)
- Accept: first-principles reasoning with clear logic
- Accept: advice backed by decades of practice
- Accept: frameworks that explain WHY, not just WHAT
- Prefer: sources where the author has skin in the game (Taleb's filter)

### Research Process (Each Iteration)
1. READ current distillation file
2. IDENTIFY: what's the weakest section? (thinnest reasoning, fewest sources, most compressible)
3. WEB SEARCH for better sources on that section:
   - Search for specific thinkers: '{thinker name} on {topic}'
   - Search for contrarian views: '{topic} counterintuitive' or '{topic} wrong'
   - Search for meta-analyses: '{topic} meta-analysis research'
   - Search for book recommendations: 'best books on {topic}'
4. WEB FETCH the most promising results — actually read them, don't just skim titles
5. EXTRACT first principles from what you read
6. COMPRESS: rewrite the section with better sources and tighter language

## COMPRESSION PROTOCOL

After each research pass, run the compression filter:

1. **Remove derivatives.** If insight B follows logically from principle A, keep only A.
2. **Remove context-dependent claims.** If it won't be true in a different culture/era, it's not a first principle.
3. **Remove hedging.** 'It might be helpful to consider possibly...' → state the thing directly or cut it.
4. **Merge redundancies.** Two insights that say the same thing in different words → keep the sharper one.
5. **Test incompressibility.** For each remaining sentence: can you remove a single word? Do it. Repeat until you can't.
6. **Lindy test.** For each insight: would Seneca, Feynman, or Naval nod? If none of them would care, cut it.

## QUALITY GATES

Before completing, verify:
- [ ] 'The Real Question' makes the reader feel understood
- [ ] Every First Principle traces to bedrock (physics, human nature, math, evolution)
- [ ] 'The Answer' passes the incompressibility test — you literally tried to make it shorter and couldn't
- [ ] Every Key Insight is independently actionable
- [ ] Contrarian Truth is genuinely contrarian AND supported by evidence
- [ ] 'What Changes Tomorrow' is concrete enough to do in the next 24 hours
- [ ] 'The Next Question' is more interesting than the original question
- [ ] Sources exist in the 'Timeless' category (if not, the answer isn't Lindy enough)
- [ ] You searched for and addressed the strongest counterargument

## ITERATION STRATEGY

- Iterations 1-3: Research heavy. Map the landscape of thinkers and ideas.
- Iterations 4-8: Compression heavy. Ruthlessly cut and tighten.
- Iterations 9-12: Adversarial. Search for counterarguments. Steel-man the opposition.
- Iterations 13-15: Polish. Every word load-bearing. Final incompressibility test.

If --deep: expand each phase proportionally (3x iterations).

## SELF-CHECK (Each Iteration)
Before continuing, answer honestly:
- Did I find genuinely new information this iteration?
- Did the distillation get SHORTER (not longer)?
- Would I be embarrassed showing this to Naval? To Deutsch?
- Is the weakest section now stronger than the strongest section was 3 iterations ago?

If last 2 iterations produced no meaningful improvement, complete.

## REFINEMENT MODE (--refine)
When refining an existing distillation:
1. Read the existing file
2. User may specify which section to go deeper on
3. Research ONLY the specified area (or the weakest area if not specified)
4. Apply same compression protocol
5. The file should get SHORTER or EQUAL, never longer (unless adding a genuinely new insight)

## COMPLETION

When ALL quality gates pass AND compression has converged (2 iterations with no meaningful changes):
1. Final read-through: is every sentence load-bearing?
2. If docs/HANDBOOK.md exists, UPDATE it:
   \`\`\`
   {Question short form}
   ├── docs/distill/{slug}.md
   ├── Core: {the one-sentence incompressible answer}
   ├── Thinkers: {key sources}
   └── Opens: {the next question}
   \`\`\`
3. <promise>DISTILLED</promise>

If genuinely stuck: <promise>BLOCKED: [reason]</promise>"
```

## Team Mode (--team flag)

When `--team` is specified, SKIP the Ralph loop above. Three roles: researcher mines sources, philosopher extracts principles, editor compresses.

### Setup

```
1. Create team: Teammate tool, operation: 'spawnTeam', team_name: '{question-slug}-distill'
2. Create output file docs/distill/{slug}.md with template above
3. Spawn 3 teammates via Task tool with team_name:

RESEARCHER (model: 'sonnet', subagent_type: general-purpose):
"You are a research miner for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Your job: find the BEST sources. Not the most sources — the best.
Source hierarchy: decade-long practitioners > books > papers > essays > articles.
WebSearch aggressively for:
- Specific thinkers who spent decades on this question
- The best-regarded books on this topic
- Contrarian voices who disagree with mainstream
- Meta-analyses and foundational research
Write ALL findings to docs/distill/notes/sources.md.
For each source: quote the key insight (< 20 words), cite it, rate Lindy-ness (timeless/enduring/recent).
When the philosopher or editor need evidence checked, claim their tasks."

PHILOSOPHER (model: 'opus', subagent_type: general-purpose):
"You are a first-principles philosopher for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md for what the researcher found.
Your job: extract first principles. Trace every claim to bedrock.
Think like Naval + Deutsch: what is the irreducible truth here?
Write reasoning to docs/distill/notes/principles.md.
For each principle: state it, prove it traces to bedrock (physics/evolution/math/human nature), identify what breaks if you remove it.
Also: decompose the question (question behind the question behind the question).
Also: find the contrarian truth — what's true but unpopular?"

EDITOR (model: 'opus', subagent_type: general-purpose):
"You are a ruthless compression editor for a distillation project.
Question: {question}
Read docs/distill/{slug}.md for current state.
Read docs/distill/notes/sources.md and docs/distill/notes/principles.md.
Your job: compress. Every word must be load-bearing.
Write compressed drafts to docs/distill/notes/compressed.md.
Compression rules:
- Remove derivatives (if B follows from A, keep only A)
- Remove hedging ('might', 'perhaps', 'consider' → state it or cut it)
- Merge redundancies (two insights saying same thing → keep sharper one)
- Test: can you remove any word without losing meaning? Do it.
- Lindy test: would Seneca, Feynman, or Naval nod? If not, cut.
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
   - Philosopher: 'Trace {principle} to bedrock' or 'Decompose {question} further'
   - Editor: 'Compress {section} — currently {N} words, target {N/2}'

Progress check:
- Is the file getting shorter? (good)
- Is every section sourced? (required)
- Do quality gates pass? (completion condition)

When all quality gates pass:
1. Update docs/HANDBOOK.md
2. Shutdown teammates
3. <promise>DISTILLED</promise>"
```

### Token Efficiency Rules (team mode)
- Researcher uses Sonnet (search-heavy)
- Philosopher and editor use Opus (deep reasoning)
- Cross-talk via note files only
- Lead only synthesizes — never searches or reasons about content
- Max 3 teammates. Don't spawn more.

---

## Output

After completion:
```
Distilled: docs/distill/{slug}.md
- First Principles: {N}
- Key Insights: {M}
- Sources: {S} (Timeless: {T}, Enduring: {E}, Recent: {R})
- Compression ratio: {original research words} → {final words}
- Next question: {the question this opens}
```
