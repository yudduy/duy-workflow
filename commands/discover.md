---
description: Ralph-powered scientific discovery - open-ended hypothesis-verify-research loop with evolving playbook
argument-hint: "<problem-statement> [--knowledge PATH] [--team] [--max-iterations N] [--rigor formal|semi-formal|informal]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /discover

Open-ended discovery loop. Hypothesizes, web-searches for evidence and counterevidence, stress-tests adversarially, refines, and keeps going until the hypothesis is robust against the known landscape. Not a fixed pipeline — a continuous OODA cycle with an evolving strategy playbook that accumulates verification heuristics across iterations.

## Usage

```bash
/discover How can we improve Byzantine fault tolerance beyond 3f+1?
/discover adaptive contracts for LLM workflows --knowledge docs/research/contracts/KNOWLEDGE.md
/discover novel consensus algorithm --max-iterations 50 --rigor formal
/discover new approach to X --team    # persistent adversarial debate with scout/theorist/critic
```

## Setup

```bash
mkdir -p docs/discoveries/{topic-slug}
```

### Read Handbook First

Check for `docs/HANDBOOK.md`. If it exists, READ it before creating any files:
- Check Knowledge Tree for related research (load relevant KNOWLEDGE.md files)
- Check Discovery Tree for related discoveries (avoid re-exploring solved problems)
- Check Cross-References for connections that inform this discovery
- Check Operational Notes for gotchas

If `docs/HANDBOOK.md` doesn't exist, create it (same template as /research skill).

Create TWO files:

### File 1: `docs/discoveries/{topic-slug}/DISCOVERY.md` (Current State)

This is the "paper" — synthesized, current, overwritten freely. When the LLM reads this at the start of each iteration, it should immediately understand: what do we believe, what evidence supports it, what's still open.

```markdown
# Discovery: {Topic}
> Status: In Progress | Iteration: 0 | Last updated: {timestamp}

## Problem
[One paragraph. What are we trying to solve and why.]

## Landscape (What Exists)
- **Current SOTA**: [best known approach — CITE source]
- **Key papers**: [who has worked on this — CITE URLs]
- **Known limits**: [impossibility results, fundamental constraints — CITE]
- **Open gaps**: [what hasn't been tried]

## Current Hypothesis
- **Statement**: [precise, falsifiable claim]
- **Confidence**: [0-100]
- **Status**: Forming | Testing | Candidate | Accepted | Rejected

### Evidence Supporting
- [finding — CITE source]
- [finding — CITE source]

### Evidence Against
- [counterpoint — CITE source]

### Survived Attacks
- [verifier critique it addressed]
- [counterargument it withstood]

### Open Questions
- [what we still don't know]
- [what would change our mind]

## Cross-Domain Analogies
| Source Domain | Insight | Transfers? | Limitations |
|---------------|---------|------------|-------------|

## Rejected Hypotheses (summary only)
| Hypothesis | Why Rejected | What We Learned |
|------------|--------------|-----------------|

## Evaluation Criteria
[What counts as success — must be falsifiable, must improve on SOTA]

## Playbook
> Max families: 5 | Max entries per family: 3

### Family: Verification Tactics | Total score: {N}
- [V-01] (+2) Heuristic. Evidence: Iteration N — what happened.

### Family: Search Strategies | Total score: {N}
- [S-01] (+1) Heuristic. Evidence: Iteration M — what happened.

### Family: Hypothesis Patterns | Total score: {N}
- [H-01] (+3) Heuristic. Evidence: Iteration K — what happened.

## Tried
> Cooldown: re-entry after 5 iterations OR when >= 2 new playbook heuristics added since failure

| Iter | Approach | Why Failed | Playbook State At Failure |
|------|----------|-----------|--------------------------|
```

### File 2: `docs/discoveries/{topic-slug}/LOG.md` (Append-Only History)

This is the "lab notebook" — chronological, immutable, never edited. Raw observations separated from interpretations.

```markdown
# Research Log: {Topic}
> Append-only. Never edit past entries.

---
## Iteration 1 | {timestamp}
**Goal**: [what this iteration set out to do]

### Observations (raw — what I found)
- [observation — CITE source]
- [observation — CITE source]

### Interpretation (what I think it means)
[analysis]

### Reflector Output
- Playbook delta: [what was added/updated/removed]
- Diversity check: [which strategy families used recently]

### Decision
- **Action**: HYPOTHESIZE | VERIFY | REFINE | PIVOT | RESEARCH MORE
- **Rationale**: [why this decision]
- **Confidence delta**: [did confidence go up or down? by how much?]

### What changed in DISCOVERY.md
[what was updated in the state document]

---
```

### Document Rules

1. **DISCOVERY.md is overwritten freely** — always reflects current beliefs. When you update a hypothesis, REPLACE the old one. Don't append.
2. **LOG.md is append-only** — never edit past iterations. Only add new entries at the bottom.
3. **Playbook section is updated via delta** — append, increment/decrement, remove. Never full rewrite except during 5-iteration prune.
4. **Tried section has cooldown gating** — entries expire after 5 iterations OR when playbook has grown by >= 2 new heuristics since the failure was logged. Expired entries can be re-explored IF the agent states what changed.
5. **Every claim in DISCOVERY.md must have a CITE** — URL, paper, or reference to a LOG.md iteration where the evidence was found.
6. **Rejected hypotheses get ONE ROW in a table** in DISCOVERY.md — not full entries. The details live in LOG.md.
7. **Observations != Interpretations** — always separate in LOG.md.
8. **Atomic writes** — Reflector writes to `PLAYBOOK_PENDING.md`. Main agent applies on next iteration.

If `--knowledge` flag was provided, read the knowledge file first and incorporate into the Landscape section.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are a discovery agent. The user's problem statement is in the conversation context above.

You operate in a continuous OODA loop — Observe, Orient, Decide, Act — like a frontier researcher. You do NOT follow a fixed pipeline. You do what a great scientist would do next given the current state of your knowledge.

You maintain an evolving strategy playbook that accumulates verification heuristics, search strategies, and hypothesis patterns across iterations. The loop gets smarter over time.

## TWO DOCUMENTS

Follow Document Rules above. Additionally:

**DISCOVERY.md** — Current state. OVERWRITE freely.
- **Playbook**: 5 families max, 3 entries each, 15 total. Each entry: {ID, +/-counter, content, evidence}. Update via deltas (append/increment/decrement/remove). Highest-counter families at top and bottom (primacy/recency).
- **Tried**: cooldown-gated registry. Entries expire after 5 iterations OR when 2+ new heuristics added since failure. On re-entry, state what changed.

**LOG.md** — Append-only. Each entry: goal, observations (with sources), interpretation (separate section), reflector output, decision, what changed in DISCOVERY.md.

Each iteration START: READ DISCOVERY.md + 2-3 Playbook entries (from DIFFERENT families — selective retrieval, not full section).
Each iteration END: UPDATE DISCOVERY.md (including Playbook/Tried), APPEND to LOG.md, delegate Reflector.

## CORE PRINCIPLE

Every claim must be GROUNDED in evidence you actually found. WebSearch and WebFetch are your primary tools. Use them aggressively — not just in a research phase but every time you make a claim, check for counterevidence, or assess novelty.

You are not just thinking. You are RESEARCHING. There is a difference.

## REASONING PROTOCOL

For ALL reasoning:
1. STATE the claim
2. CITE the evidence (URL, paper, or LOG.md iteration)
3. ASSESS: primary source or inference?
4. RATE confidence 0-100. Below 60 = go research it before proceeding.

## FIRST ITERATION: Map the Landscape

Before hypothesizing, understand what exists:

0. READ docs/HANDBOOK.md — pull in any related research or discoveries as starting context for the Landscape section. Don't re-research what's already in the handbook.
1. WebSearch the problem space extensively:
   - Current state of the art?
   - Key researchers and recent publications?
   - Known impossibility results or fundamental limits?
   - Approaches tried and failed? Why?
2. Fill in Landscape section of DISCOVERY.md with CITED findings
3. Fill in Evaluation Criteria — what constitutes improvement over SOTA?
4. Initialize Playbook section with any search strategies that worked well

Use parallel Task (Explore) agents:
- Agent 1: Current SOTA and recent papers (WebSearch + WebFetch)
- Agent 2: Known impossibility results and fundamental limits
- Agent 3: Failed approaches and why they failed

Only after the landscape is mapped, proceed to hypothesize.

## CROSS-DOMAIN ANALOGY SEARCH

Map the problem's abstract structure to other domains. Run parallel Explore agents across at least 3 unrelated fields:
- What is the analogous problem?
- How was it solved?
- What is the key transferable insight?
- What breaks when you try to transfer it?

WebSearch in each domain — do not rely on what you already know.

## CONTINUOUS OODA CYCLE

Each iteration, decide what the most productive next action is:

### STEP 0: DEFIXATE
Before deciding your next action, restate what success looks like WITHOUT reference to specific strategies or past approaches. Strip away surface details. This prevents design fixation from accumulated playbook heuristics.

### STEP 1: CHECK Tried section
Before hypothesizing or conjecturing, check the tried-and-failed registry. If your planned approach matches a recent failure whose cooldown hasn't expired, either pick something else or state explicitly what changed since the failure.

### IF you don't have a hypothesis yet:
- Synthesize landscape + analogies into a candidate
- Generate 3 candidates independently (Tree-of-Thought)
- For each: trace reasoning chain, rate promise 1-10, identify weakest assumption
- Select the most promising
- Write it up: formal statement, assumptions (each with confidence 0-100), predictions that discriminate it from alternatives, kill condition

### IF you have a hypothesis and haven't stress-tested it:
- Delegate to an adversarial VERIFIER subagent via Task tool:

VERIFIER PROMPT (delegate via Task, general-purpose):
A colleague submitted this hypothesis for peer review. You have FULL PERMISSION to reject it entirely.
HYPOTHESIS: {formal statement} | ASSUMPTIONS: {list} | ARGUMENT: {reasoning} | PREDICTIONS: {what this predicts that alternatives do not}

You MUST:
1. WebSearch for evidence that CONTRADICTS this hypothesis
2. WebSearch for existing work that already does what this proposes
3. State the strongest argument AGAINST
4. Find the weakest link in the reasoning chain
5. Propose a simpler alternative explanation
6. Construct a specific counterexample or explain why none exists
7. For each flaw: rate confidence 0-100

GROUNDING REQUIREMENT: Every critique must provide EITHER (a) a web-searched citation, OR (b) a specific logical contradiction with references. Ungrounded critiques are flagged but do NOT trigger refinement.

Output: FATAL FLAWS | WEAKNESSES | MISSING | EVIDENCE FOUND | UNGROUNDED | VERDICT (REJECT/REVISE/ACCEPT)
Do not praise. Do not hedge. CITE your sources.

- Record ALL verifier output in DISCOVERY.md under the hypothesis entry

### IF the verifier found GROUNDED flaws:
- For FATAL FLAWS: decide between REFINE and PIVOT
  - Before deciding: WebSearch the specific flaw. Is it a real constraint or a misunderstanding?
  - If the flaw is grounded in real evidence: PIVOT to a new direction informed by what you learned
  - If the flaw was based on incorrect assumptions by the verifier: REFINE with evidence
- For WEAKNESSES: REFINE the hypothesis to address them
- After refinement: go back to stress-testing (do NOT skip re-verification)

### IF the verifier found NO grounded flaws:
- Do NOT accept yet. Instead:
  1. WebSearch for the STRONGEST possible counterargument yourself
  2. Search for existing work that subsumes or contradicts your hypothesis
  3. Try to construct a counterexample yourself
  4. Run the verifier AGAIN with a different framing (domain skeptic):

SKEPTIC PROMPT (delegate via Task, general-purpose):
You are an expert in {relevant domain} known for skepticism toward {claim type}.
A junior researcher asks your honest opinion on: HYPOTHESIS: {hypothesis}
WebSearch for evidence AGAINST this. What would convince you? Most likely way this fails in practice?
GROUNDING REQUIREMENT: Every critique must be backed by citation or logical contradiction. Be direct.

  5. Only if BOTH verifiers and your own search found nothing grounded: mark as CANDIDATE

### DIFFICULTY-ADAPTIVE VERIFICATION
- Confidence > 80: single verifier pass is sufficient
- Confidence 40-80: standard two-verifier protocol (adversarial + skeptic)
- Confidence < 40: parallel heterogeneous verifiers (adversarial + skeptic + domain expert) with mandatory independent web searches

### IF you have a CANDIDATE hypothesis:
- One more round: WebSearch for the most recent papers (last 6 months) in this space
- Check: does it actually improve on the SOTA you documented in the Landscape section?
- If yes: mark ACCEPTED
- If no: document what you found and refine or pivot

## REFLECTOR SUBAGENT

After EVERY iteration, delegate a Reflector (Task, general-purpose):

Input: iteration summary (goal, key findings, evidence URLs, verification outcome, confidence delta) + current Playbook + Tried sections.

Job:
1. What verification tactic worked or failed? → Update Verification Tactics family
2. What search strategy yielded useful evidence? → Update Search Strategies family
3. What hypothesis structure was robust or fragile? → Update Hypothesis Patterns family
4. Increment/decrement/remove existing entries as warranted
5. Expire Tried entries whose cooldown has passed

Output format:
PLAYBOOK_DELTA: ADD {family}|{entry}|{evidence} / INCREMENT {ID} / DECREMENT {ID} / REMOVE {ID}|{reason}
TRIED_DELTA: ADD {approach}|{why failed}|{playbook state} / EXPIRE {entry}|{reason}
SUMMARY: [one sentence — what did we learn about HOW to discover in this domain?]

Write to PLAYBOOK_PENDING.md. Main loop applies on next iteration.

## INCUBATION PROTOCOL

After 3+ CONSECUTIVE iterations with no new substantive findings or progress:
1. Write a HIGH-LEVEL summary of current state (problem, hypothesis, key evidence, key gaps) — max 500 words
2. Clear all detailed failure traces and iteration minutiae from your working context
3. Resume with ONLY: the summary + DISCOVERY.md (with top 3 Playbook entries only)
4. This achieves 'beneficial forgetting' — misleading associations decay, structural knowledge preserved
5. After incubation, consider pivoting to a different sub-problem for 1-2 iterations before returning

## WHAT TO DO EVERY ITERATION

1. READ DISCOVERY.md + 2-3 Playbook entries (from different strategy families — selective retrieval)
2. CHECK the Tried section for cooldown-gated approaches
3. DEFIXATE — restate success criteria abstractly, without referencing past strategies
4. Execute the appropriate OODA branch above
5. UPDATE DISCOVERY.md with current beliefs
6. APPEND to LOG.md with what you did
7. DELEGATE Reflector subagent for playbook update
8. ASSESS: am I making progress or spinning? (honestly)

## PRUNE CYCLE (every 5 iterations)

Reflector does a full playbook review:
- Remove entries with score <= 0
- If families exceed 5, remove lowest-total-score family
- Re-rank by total score (highest at top and bottom for primacy/recency)
- Abstract high-counter heuristics into family-level descriptions, freeing slots

## WHEN TO STOP

This is an OPEN-ENDED loop. You keep going until one of:

A. ROBUST HYPOTHESIS: Your hypothesis has survived:
   - At least 2 adversarial verifier rounds (different framings) with grounded critiques addressed
   - Your own counterargument search
   - Confirmation it improves on documented SOTA
   Mark ACCEPTED. Confidence = HIGH.

B. EXHAUSTED LANDSCAPE: You have thoroughly searched and cannot find a viable hypothesis.
   - Document what you tried and why each failed
   - Document what the remaining open questions are
   - Confidence = LOW. This is a valid outcome — knowing what doesn't work is valuable.

C. MAX ITERATIONS: Safety valve at --max-iterations (default 30).
   - Pick the best hypothesis so far with honest confidence assessment.

D. DIMINISHING RETURNS: 3+ iterations where you learned nothing new (AND incubation didn't help).
   - Be honest about this. Log it.

When ANY stop condition triggers:
1. Update Best Result with: hypothesis, confidence, what attacks it survived, open questions
2. Update Termination with reason and robustness assessment
3. UPDATE docs/HANDBOOK.md — add/update entry in Discovery Tree:
   {Topic}
   ├── docs/discoveries/{topic}/DISCOVERY.md
   ├── Status: {Accepted|Exhausted|Incomplete} | Confidence: {HIGH|MEDIUM|LOW}
   ├── Key: {one-sentence summary of best hypothesis or finding}
   ├── Playbook entries: {N across families}
   └── Connects to: [[related topics or discoveries in handbook]]
   Also update Cross-References with any new connections found.
   Also add operational gotchas and playbook heuristics worth preserving to Operational Notes.
4. Output: <promise>DISCOVERY_COMPLETE</promise>

## ANTI-CIRCUMVENTION
- Do NOT output the promise prematurely — the hypothesis must have survived real scrutiny
- Do NOT skip web searching — EVERY claim must be grounded in evidence you found
- Do NOT simulate the verifier or reflector — delegate via Task tool to SEPARATE agents
- Do NOT accept after one verification round — minimum 2 adversarial rounds with different framings
- Do NOT ignore verifier flaws that are grounded — address each one explicitly
- Do NOT trigger refinement from UNGROUNDED critiques — log them but don't act on them
- Do NOT read the full Playbook section every iteration — select 2-3 entries from different families
- Do NOT re-try a failed approach without checking Tried section cooldown
- If stuck: try incubation protocol first, then WebSearch for a completely different approach, then ask the user for direction.
- Track what you actually learned each iteration — if the Iteration Log shows no new information for 3+ rounds, trigger incubation then stop condition D"
```

---

## Team Mode (--team flag)

When `--team` is specified, SKIP the Ralph loop above. Use agent teams with persistent adversarial debate.

Three persistent teammates: scout finds evidence, theorist proposes/refines hypotheses, critic stress-tests. The critic accumulates context across rounds — remembers what attacks worked, what the theorist already addressed, gets harder to satisfy over time.

### Setup

```
1. Create team: Teammate tool, operation: 'spawnTeam', team_name: '{topic-slug}-discovery'
2. Create the two output files (DISCOVERY.md and LOG.md) as described above
3. Spawn 3 teammates via Task tool with team_name:

SCOUT (model: 'sonnet', subagent_type: general-purpose):
"You are a research scout for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Your job: map the landscape. WebSearch aggressively for SOTA, key papers, known limits, failed approaches.
Write ALL findings to docs/discoveries/{topic}/notes/landscape.md.
When the theorist or critic need evidence checked, they'll create tasks for you — claim and fulfill them.
After initial landscape scan, keep searching for new evidence as the hypothesis evolves.
Read the theorist's and critic's notes to know what evidence is needed."

THEORIST (model: 'opus', subagent_type: general-purpose):
"You are a hypothesis theorist for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Read docs/discoveries/{topic}/notes/landscape.md for what the scout found.
Your job: generate, refine, and defend hypotheses.
Write your reasoning to docs/discoveries/{topic}/notes/theorist.md.
After proposing a hypothesis, create a task for the critic to attack it (include the formal statement, assumptions, and reasoning).
When the critic finds flaws (read their notes), address each one explicitly — refine or pivot.
Do NOT accept your own hypothesis — only the lead can mark it as accepted."

CRITIC (model: 'opus', subagent_type: general-purpose):
"You are a persistent adversarial critic for a discovery project.
Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Your job: find flaws in every hypothesis the theorist proposes. You are a skeptic.
Write your critiques to docs/discoveries/{topic}/notes/critic.md.
For EVERY hypothesis: WebSearch for contradicting evidence, existing work, counterexamples.
GROUNDING REQUIREMENT: Every critique must have a web citation or logical contradiction.
Rate each flaw 0-100 confidence. Verdict: REJECT / REVISE / ACCEPT.
You maintain a running list of attacks tried and their outcomes in your notes file.
Each verification round, get HARDER — don't repeat attacks that were already addressed.
Create tasks for the scout when you need specific evidence checked.
Only issue ACCEPT verdict after 2+ rounds where you genuinely could not find flaws."
```

### Lead Coordination (Ralph loop drives this)

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are the discovery lead coordinating a team. Do NOT research or hypothesize yourself.

Each iteration:
1. Check TaskList for status
2. Read ALL note files in docs/discoveries/{topic}/notes/
3. Synthesize current state into DISCOVERY.md (overwrite — always reflects NOW)
4. Append iteration summary to LOG.md
5. Assess progress:
   - Has the critic issued ACCEPT on 2+ rounds? → Candidate hypothesis
   - Is the theorist stuck? → Create task for scout to find new angles
   - Is the scout idle? → Create task for frontier/recent papers search
   - 3+ iterations with no new learning? → Trigger diminishing returns stop
6. Create follow-up tasks as needed to keep the team productive

Stopping conditions (same as subagent mode):
A. ROBUST: Critic accepted after 2+ adversarial rounds → mark ACCEPTED
B. EXHAUSTED: Thorough search, no viable hypothesis
C. MAX ITERATIONS
D. DIMINISHING RETURNS: 3+ iterations, nothing new

When stopping:
1. Update DISCOVERY.md with final state
2. UPDATE docs/HANDBOOK.md — add entry to Discovery Tree (same format as subagent mode)
3. Shutdown all teammates (SendMessage type: 'shutdown_request')
4. Teammate cleanup (Teammate tool, operation: 'cleanup')
5. <promise>DISCOVERY_COMPLETE</promise>"
```

### Token Efficiency Rules (team mode)
- Scout uses Sonnet (search-heavy, doesn't need deep reasoning)
- Theorist and critic use Opus (need deep reasoning for hypothesis generation and adversarial attacks)
- Cross-talk via note files (no direct messages — teammates read each other's notes)
- Lead only synthesizes and coordinates — never searches or hypothesizes
- Max 3 teammates (scout + theorist + critic). Don't spawn more.
- Scout can be shut down early if landscape is fully mapped

---

## Output

After completion:
```
Discovery complete: docs/discoveries/{topic-slug}/DISCOVERY.md
- Hypotheses explored: {N}
- Best hypothesis: {name}
- Confidence: {HIGH|MEDIUM|LOW}
- Survived: {list of attacks/verifications it passed}
- Playbook entries: {count across families}
- Termination: {reason}
- Handbook: docs/HANDBOOK.md (updated)
```

---

## Completion

```
<promise>DISCOVERY_COMPLETE</promise>
```

If blocked:
```
<promise>BLOCKED: [reason]</promise>
```
