---
description: Ralph-powered scientific discovery — hypothesis generation, adversarial stress-testing, and evidence accumulation until something robust emerges
argument-hint: "<problem-statement> [--knowledge PATH] [--team] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /discover

Takes a problem and hunts for a robust hypothesis. Not a fixed pipeline — a continuous loop that hypothesizes, searches for evidence and counterevidence, stress-tests adversarially, and keeps going until the hypothesis survives real scrutiny or the landscape is exhausted.

The output is clean and readable. The adversarial work stays internal.

## Flags

- `--knowledge PATH`: Load existing research as starting context
- `--team`: Parallel agents: scout + theorist + critic
- `--max-iterations N`: Override default (30)

## Principles

1. **Evidence over reasoning.** Every claim grounded in something you actually found. WebSearch is not optional.
2. **Adversarial by default.** Every hypothesis gets attacked by a separate agent. Unattacked hypotheses are worthless.
3. **Grounded critiques only.** Verifier flaws must have citations or logical contradictions. Vibes don't trigger refinement.
4. **Dead ends are findings.** Knowing what doesn't work and why is as valuable as a positive result.
5. **The landscape first.** Before hypothesizing, understand what exists. Map before you move.

## Setup

```bash
mkdir -p docs/discoveries/{topic-slug}
```

Check for `docs/HANDBOOK.md`. If it exists, READ it for related discoveries and research.

If `--knowledge` flag was provided, read the knowledge file and incorporate into Landscape.

Create TWO files:

### DISCOVERY.md — The Readable Output

This is the "paper." When someone reads this, they immediately understand: what we set out to solve, what we found, and how confident we are.

```markdown
# Discovery: {Topic}
> Status: In Progress | Confidence: -- | Last updated: {timestamp}

## The Problem
[What are we trying to solve and why. One paragraph.]

## The Landscape
[What exists today — current SOTA, known limits, key researchers, failed approaches. Every claim CITED.]

## What We Found
[THE finding. The hypothesis that survived adversarial scrutiny.
3-7 sentences. Every word load-bearing. Every claim cited.
If no robust hypothesis yet: state the best candidate and its weaknesses.]

## Evidence
### Supporting
- [finding — CITE source]

### Contradicting
- [counterpoint — CITE source]

### Attacks Survived
- [specific adversarial critique it withstood — what was claimed, why it held]

## Cross-Domain Analogies
| Source Domain | Transferable Insight | Limitations |
|---------------|---------------------|-------------|

## Dead Ends
| Approach | Why It Failed | What We Learned |
|----------|---------------|-----------------|

## What's Still Open
- [questions this doesn't answer]
- [what would change our mind]

## What Changes
[Concrete implications if this finding holds. What you'd build or do differently.]

## The Next Discovery
[The frontier question this opens. The better problem to work on now.]

## Sources
### Foundational (field-defining)
### Supporting (confirms hypothesis)
### Contrarian (strongest counterevidence)
```

### STATE.md — Internal Working State

The "lab notebook." Playbook, tried registry, iteration log. Agents read this; humans don't need to.

```markdown
# State: {Topic}

## Playbook
> Max 5 families, 3 entries each. Updated via deltas.

### Verification Tactics | Score: {N}
- [V-01] (+2) Heuristic. Evidence: Iteration N.

### Search Strategies | Score: {N}
- [S-01] (+1) Heuristic. Evidence: Iteration M.

### Hypothesis Patterns | Score: {N}
- [H-01] (+3) Heuristic. Evidence: Iteration K.

## Tried (cooldown: 5 iterations or 2+ new heuristics since failure)
| Iter | Approach | Why Failed | Playbook State |
|------|----------|-----------|----------------|

## Iteration Log
### Iteration {N} | {timestamp}
- **Goal**: what this iteration set out to do
- **Findings**: what was found (with sources)
- **Decision**: HYPOTHESIZE | VERIFY | REFINE | PIVOT | RESEARCH MORE
- **Confidence delta**: +/- and why
- **Playbook delta**: what changed
```

### Document Rules

1. **DISCOVERY.md** is the product — overwrite freely, always reflects current best understanding
2. **STATE.md** is internal — playbook, tried, iteration log. Updated every iteration.
3. **Every claim in DISCOVERY.md must have a citation** — URL, paper, or STATE.md iteration reference
4. **Rejected hypotheses get ONE ROW** in Dead Ends. Details live in STATE.md.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are a discovery agent. Produce a DISCOVERY.md containing the finding that survived adversarial scrutiny. The problem statement is in the conversation context above.

## OUTPUT FILES

Write to docs/discoveries/{topic-slug}/DISCOVERY.md (readable output) and docs/discoveries/{topic-slug}/STATE.md (internal working state). Follow the templates and document rules above.

## ITERATION PHASES

### Phase 1 — MAP THE LANDSCAPE (iteration 1-2)

Before hypothesizing, understand what exists. Use parallel Task (Explore) agents:
- Agent 1: Current SOTA and recent papers (WebSearch + WebFetch)
- Agent 2: Known impossibility results and fundamental limits
- Agent 3: Failed approaches and why they failed

Fill in: Problem, Landscape, and Cross-Domain Analogies in DISCOVERY.md.
Initialize STATE.md with any useful search strategies.

### Phase 2 — HYPOTHESIZE (iterations 3-5)

Synthesize landscape + analogies into candidates:
1. Generate 3 candidates independently
2. For each: formal statement, assumptions (each with confidence 0-100), predictions that discriminate from alternatives, kill condition
3. Select the most promising — write to 'What We Found' section
4. Check STATE.md Tried section — if this matches a recent failure, pick something else or state what changed

### Phase 3 — ADVERSARIAL STRESS-TEST (iterations 6-15)

Delegate to a VERIFIER subagent via Task (general-purpose):

VERIFIER PROMPT:
A colleague submitted this hypothesis for peer review. You have FULL PERMISSION to reject it.
HYPOTHESIS: {formal statement} | ASSUMPTIONS: {list} | ARGUMENT: {reasoning}

You MUST:
1. WebSearch for evidence that CONTRADICTS this hypothesis
2. WebSearch for existing work that already does what this proposes
3. State the strongest argument AGAINST
4. Find the weakest link in the reasoning chain
5. Propose a simpler alternative explanation
6. For each flaw: rate confidence 0-100

GROUNDING REQUIREMENT: Every critique must have (a) a web citation, OR (b) a specific logical contradiction. Ungrounded critiques are flagged but do NOT trigger refinement.

Output: FATAL FLAWS | WEAKNESSES | EVIDENCE FOUND | VERDICT (REJECT/REVISE/ACCEPT)

After verifier returns:
- FATAL FLAWS (grounded): WebSearch the flaw first. If real → PIVOT. If misunderstanding → REFINE with evidence.
- WEAKNESSES (grounded): REFINE the hypothesis to address them.
- After refinement: RE-VERIFY (never skip)
- If verifier found nothing grounded: run a SECOND verifier with a different framing (domain skeptic), then your own counterargument search. Only if both pass → mark CANDIDATE.

### Phase 4 — VALIDATE CANDIDATE (iterations 16-20)

For CANDIDATE hypotheses:
1. WebSearch for most recent papers (last 6 months) in this space
2. Check: does it actually improve on the SOTA in the Landscape section?
3. Run one final adversarial round with a fresh framing
4. If it survives: mark ACCEPTED with confidence assessment
5. If not: document what you found, refine or pivot

### Phase 5 — POLISH OUTPUT (iterations 21+)

Make DISCOVERY.md clean and readable:
1. Every section filled and cited
2. 'What We Found' is crisp — 3-7 sentences, no hedging
3. Dead Ends table complete — each entry has 'What We Learned'
4. Sources organized: Foundational / Supporting / Contrarian
5. 'The Next Discovery' is a better question than the original

## REFLECTOR (after every iteration)

Delegate a Reflector (Task, general-purpose):
Input: iteration summary + current Playbook + Tried sections from STATE.md
Job: update playbook entries (increment/decrement/add/remove), expire tried entries, one-sentence learning summary.
Write to STATE.md Playbook and Tried sections.

## QUALITY GATES

Before completing:
- [ ] Landscape section maps the field with citations
- [ ] Hypothesis survived 2+ adversarial rounds with grounded critiques addressed
- [ ] Your own counterargument search found nothing fatal
- [ ] Every claim in DISCOVERY.md has a citation
- [ ] Dead Ends table captures what was ruled out and why
- [ ] 'What's Still Open' is honest about limitations
- [ ] Sources include at least one Contrarian entry
- [ ] Hypothesis improves on documented SOTA (or honest about not doing so)

## SELF-CHECK (Each Iteration)
- Did I find genuinely new information?
- Did DISCOVERY.md get clearer (not just longer)?
- Am I making progress or spinning?
If last 2 iterations produced no meaningful improvement, complete with best result.

## COMPLETION

When quality gates pass OR stop conditions trigger (exhausted landscape, diminishing returns, max iterations):
1. Update DISCOVERY.md with final state and honest confidence
2. UPDATE docs/HANDBOOK.md:
   {Topic}
   ├── docs/discoveries/{topic}/DISCOVERY.md
   ├── Status: {Accepted|Exhausted|Incomplete} | Confidence: {HIGH|MEDIUM|LOW}
   ├── Key: {one-sentence finding}
   └── Opens: {the next discovery}
3. <promise>DISCOVERY_COMPLETE</promise>

If stuck: <promise>BLOCKED: [reason]</promise>"
```

## Team Mode (--team flag)

When `--team` is specified, SKIP the Ralph loop above. Three roles: scout finds evidence, theorist proposes hypotheses, critic stress-tests.

### Setup

```
1. Create team: Teammate tool, operation: 'spawnTeam', team_name: '{topic-slug}-discovery'
2. Create output files (DISCOVERY.md and STATE.md) as described above
3. Create docs/discoveries/{topic}/notes/ directory
4. Spawn 3 teammates via Task tool with team_name:

SCOUT (model: 'sonnet', subagent_type: general-purpose):
"You are a research scout for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Your job: map the landscape. WebSearch aggressively for SOTA, key papers, known limits, failed approaches.
Write ALL findings to docs/discoveries/{topic}/notes/landscape.md.
When the theorist or critic need evidence checked, claim their tasks.
After initial landscape scan, keep searching for new evidence as the hypothesis evolves."

THEORIST (model: 'opus', subagent_type: general-purpose):
"You are a hypothesis theorist for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Read docs/discoveries/{topic}/notes/landscape.md for what the scout found.
Your job: generate, refine, and defend hypotheses.
Write reasoning to docs/discoveries/{topic}/notes/theorist.md.
After proposing a hypothesis, create a task for the critic to attack it.
When the critic finds flaws (read their notes), address each one — refine or pivot.
Do NOT accept your own hypothesis — only the lead can mark it as accepted."

CRITIC (model: 'opus', subagent_type: general-purpose):
"You are a persistent adversarial critic for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Your job: find flaws in every hypothesis the theorist proposes.
Write critiques to docs/discoveries/{topic}/notes/critic.md.
For EVERY hypothesis: WebSearch for contradicting evidence, existing work, counterexamples.
GROUNDING REQUIREMENT: Every critique must have a web citation or logical contradiction.
Rate each flaw 0-100 confidence. Verdict: REJECT / REVISE / ACCEPT.
Each round, get HARDER — don't repeat attacks already addressed.
Only issue ACCEPT after 2+ rounds where you genuinely could not find flaws."
```

### Lead Coordination

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are the discovery lead. Do NOT research or hypothesize yourself.

Each iteration:
1. Check TaskList for status
2. Read ALL note files in docs/discoveries/{topic}/notes/
3. Synthesize into DISCOVERY.md — clean, readable, current beliefs only
4. Update STATE.md with playbook/tried/iteration log
5. Assess progress:
   - Critic accepted after 2+ rounds? → Candidate
   - Theorist stuck? → Task scout for new angles
   - 3+ iterations with no new learning? → Trigger stop
6. Create follow-up tasks to keep the team productive

When stopping:
1. Update DISCOVERY.md with final state
2. UPDATE docs/HANDBOOK.md (same format as solo mode)
3. Shutdown teammates (SendMessage type: 'shutdown_request')
4. <promise>DISCOVERY_COMPLETE</promise>"
```

### Token Efficiency (team mode)
- Scout: Sonnet (search-heavy)
- Theorist + Critic: Opus (deep reasoning)
- Cross-talk via note files only
- Lead only synthesizes — never searches or hypothesizes
- Max 3 teammates

## Output

```
Discovery complete: docs/discoveries/{topic-slug}/DISCOVERY.md
- Hypotheses explored: {N}
- Best finding: {one sentence}
- Confidence: {HIGH|MEDIUM|LOW}
- Attacks survived: {N adversarial rounds}
- Dead ends documented: {N}
- Next discovery: {the frontier question}
```
