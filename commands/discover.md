---
description: Ralph-powered scientific discovery - open-ended hypothesis-verify-research loop until convergence
argument-hint: "<problem-statement> [--knowledge PATH] [--max-iterations N] [--rigor formal|semi-formal|informal]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /discover

Open-ended discovery loop. Hypothesizes, web-searches for evidence and counterevidence, stress-tests adversarially, refines, and keeps going until the hypothesis is robust against the known landscape. Not a fixed pipeline — a continuous OODA cycle.

## Usage

```bash
/discover How can we improve Byzantine fault tolerance beyond 3f+1?
/discover adaptive contracts for LLM workflows --knowledge docs/research/contracts/KNOWLEDGE.md
/discover novel consensus algorithm --max-iterations 50 --rigor formal
```

## Setup

```bash
mkdir -p docs/discoveries/{topic-slug}
```

Create TWO files. The first is the living state document — always reflects what we believe NOW. The second is the append-only research log — never edit past entries, only add new ones.

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
3. **Every claim in DISCOVERY.md must have a CITE** — URL, paper, or reference to a LOG.md iteration where the evidence was found.
4. **Rejected hypotheses get ONE ROW in a table** in DISCOVERY.md — not full entries. The details live in LOG.md.
5. **Observations ≠ Interpretations** — always separate in LOG.md. Raw findings first, then what you think they mean.
6. **Each LOG.md entry records what changed** in DISCOVERY.md — so anyone reading the log can reconstruct the state at any point.

If `--knowledge` flag was provided, read the knowledge file first and incorporate into the Landscape section.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are a discovery agent. The user's problem statement is in the conversation context above.

You operate in a continuous OODA loop — Observe, Orient, Decide, Act — like a frontier researcher. You do NOT follow a fixed pipeline. You do what a great scientist would do next given the current state of your knowledge.

## TWO DOCUMENTS

You maintain two files in docs/discoveries/{topic-slug}/:

**DISCOVERY.md** — Current state. OVERWRITE freely. Always reflects what you believe NOW.
- When you update a hypothesis, REPLACE the old content
- Rejected hypotheses get ONE ROW in the Rejected table, not full entries
- Every claim must have a CITE (URL, paper, or LOG.md iteration reference)

**LOG.md** — Append-only history. NEVER edit past entries. Only add new iterations at the bottom.
- Each entry: goal, raw observations (with sources), interpretation (separate section), decision, what changed in DISCOVERY.md
- Observations and interpretations are ALWAYS in separate sections

At the START of each iteration: READ DISCOVERY.md to understand current state.
At the END of each iteration: UPDATE DISCOVERY.md with current beliefs, APPEND to LOG.md with what you did.

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

1. WebSearch the problem space extensively:
   - Current state of the art?
   - Key researchers and recent publications?
   - Known impossibility results or fundamental limits?
   - Approaches tried and failed? Why?
2. Fill in Landscape section of DISCOVERY.md with CITED findings
3. Fill in Evaluation Criteria — what constitutes improvement over SOTA?

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

### IF you don't have a hypothesis yet:
- Synthesize landscape + analogies into a candidate
- Generate 3 candidates independently (Tree-of-Thought)
- For each: trace reasoning chain, rate promise 1-10, identify weakest assumption
- Select the most promising
- Write it up: formal statement, assumptions (each with confidence 0-100), predictions that discriminate it from alternatives, kill condition

### IF you have a hypothesis and haven't stress-tested it:
- Delegate to an adversarial VERIFIER subagent via Task tool:

VERIFIER PROMPT:
A colleague (not present) submitted this hypothesis for peer review.
You have FULL PERMISSION to reject it entirely. Disagreement is valued.

HYPOTHESIS: {formal statement}
ASSUMPTIONS: {list}
ARGUMENT: {reasoning}
PREDICTIONS: {what this predicts that alternatives do not}

You MUST:
1. WebSearch for evidence that CONTRADICTS this hypothesis
2. WebSearch for existing work that already does what this proposes (is it actually novel?)
3. State the strongest argument AGAINST
4. Find the weakest link in the reasoning chain
5. Propose a simpler alternative explanation
6. Construct a specific counterexample or explain why none exists
7. For each flaw: rate confidence 0-100 that this flaw is genuine

FATAL FLAWS: [invalidating issues with evidence]
WEAKNESSES: [non-fatal issues]
MISSING: [what evidence would you need to see?]
EVIDENCE FOUND: [what did your web searches turn up?]
VERDICT: REJECT / REVISE / ACCEPT

Do not praise. Do not hedge. CITE your sources.

- Record ALL verifier output in DISCOVERY.md under the hypothesis entry

### IF the verifier found flaws:
- For FATAL FLAWS: decide between REFINE and PIVOT
  - Before deciding: WebSearch the specific flaw. Is it a real constraint or a misunderstanding?
  - If the flaw is grounded in real evidence: PIVOT to a new direction informed by what you learned
  - If the flaw was based on incorrect assumptions by the verifier: REFINE with evidence
- For WEAKNESSES: REFINE the hypothesis to address them
- After refinement: go back to stress-testing (do NOT skip re-verification)

### IF the verifier found NO flaws:
- Do NOT accept yet. Instead:
  1. WebSearch for the STRONGEST possible counterargument yourself
  2. Search for existing work that subsumes or contradicts your hypothesis
  3. Try to construct a counterexample yourself
  4. Run the verifier AGAIN with a different framing (domain skeptic):

SKEPTIC PROMPT:
You are an expert in {relevant domain} known for skepticism toward {claim type}.
A junior researcher asks your honest opinion on:
HYPOTHESIS: {hypothesis}
WebSearch for evidence AGAINST this. What would convince you? What is the most likely way this fails in practice? Be direct.

  5. Only if BOTH verifiers and your own search found nothing: mark as CANDIDATE

### IF you have a CANDIDATE hypothesis:
- One more round: WebSearch for the most recent papers (last 6 months) in this space
- Check: has someone already published this? Is it actually novel?
- Check: does it actually improve on the SOTA you documented in the Landscape section?
- If yes to novelty and improvement: mark ACCEPTED
- If no: document what you found and refine or pivot

## WHAT TO DO EVERY ITERATION

Regardless of which branch above you're in:
1. READ DISCOVERY.md for current state
2. Do the action described above
3. UPDATE DISCOVERY.md — the Iteration Log must have an entry for every iteration
4. UPDATE the hypothesis entry with any new evidence, critiques, or refinements
5. ASSESS: am I making progress or spinning? (honestly)

## WHEN TO STOP

This is an OPEN-ENDED loop. You keep going until one of:

A. ROBUST HYPOTHESIS: Your hypothesis has survived:
   - At least 2 adversarial verifier rounds (different framings)
   - Your own counterargument search
   - Novelty check against recent literature
   - Confirmation it improves on documented SOTA
   Mark ACCEPTED. Confidence = HIGH.

B. EXHAUSTED LANDSCAPE: You have thoroughly searched and cannot find a viable hypothesis.
   - Document what you tried and why each failed
   - Document what the remaining open questions are
   - Confidence = LOW. This is a valid outcome — knowing what doesn't work is valuable.

C. MAX ITERATIONS: Safety valve at --max-iterations (default 30).
   - Pick the best hypothesis so far with honest confidence assessment.

D. DIMINISHING RETURNS: 3+ iterations where you learned nothing new.
   - Be honest about this. Log it.

When ANY stop condition triggers:
1. Update Best Result with: hypothesis, confidence, what attacks it survived, open questions
2. Update Termination with reason and robustness assessment
3. Output: <promise>DISCOVERY_COMPLETE</promise>

## ANTI-CIRCUMVENTION
- Do NOT output the promise prematurely — the hypothesis must have survived real scrutiny
- Do NOT skip web searching — EVERY claim must be grounded in evidence you found
- Do NOT simulate the verifier — delegate via Task tool to a SEPARATE agent
- Do NOT accept after one verification round — minimum 2 adversarial rounds with different framings
- Do NOT claim novelty without searching for existing work
- Do NOT ignore verifier flaws — address each one explicitly
- If stuck: WebSearch for a completely different approach. Try a new cross-domain analogy. Ask the user for direction.
- Track what you actually learned each iteration — if the Iteration Log shows no new information for 3+ rounds, trigger stop condition D"
```

## Agent Templates

### Landscape Agent
```
Task (Explore): "Research the current state of {problem domain}:
- WebSearch: '{topic} state of the art 2024 2025'
- WebSearch: '{topic} impossibility theorem limits'
- WebSearch: '{topic} failed approaches why'
- For top results: WebFetch and read abstracts/methodology
Return: SOTA summary, key papers with URLs, known limits, failed approaches"
```

### Analogy Agent
```
Task (Explore): "Find analogous solved problems in {domain}:
- WebSearch: '{abstract structure} {domain}'
- What is the analogous problem? How was it solved?
- What is the key transferable insight?
- What breaks when you try to transfer it?
Return: analogy, mapping, insight, limitations — with URLs"
```

### Adversarial Verifier Agent
```
Task (general-purpose): "A colleague (not present) submitted this for peer review:
HYPOTHESIS: {formal statement}
ASSUMPTIONS: {list}
ARGUMENT: {reasoning}

You have full permission to reject this entirely.
WebSearch for CONTRADICTING evidence. WebSearch for EXISTING work that already does this.
State the strongest argument AGAINST. Construct a counterexample.
For each flaw: rate confidence 0-100.
CITE your sources. Do not praise. Be direct.
VERDICT: REJECT / REVISE / ACCEPT"
```

### Domain Skeptic Agent
```
Task (general-purpose): "You are an expert in {domain} known for skepticism.
A junior researcher asks your opinion on: {hypothesis}
WebSearch for evidence AGAINST this.
What would convince you? Most likely way this fails?
Be direct. CITE sources."
```

## Output

After completion:
```
Discovery complete: docs/discoveries/{topic-slug}/DISCOVERY.md
- Hypotheses explored: {N}
- Best hypothesis: {name}
- Confidence: {HIGH|MEDIUM|LOW}
- Survived: {list of attacks/verifications it passed}
- Termination: {reason}
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
