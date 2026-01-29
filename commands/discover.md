---
description: Ralph-powered scientific discovery - hypothesis generation, layered verification, cross-domain analogy search
argument-hint: "<problem-statement> [--knowledge PATH] [--max-iterations N] [--rigor formal|semi-formal|informal]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /discover

Ralph-powered discovery loop with layered verification. Proposes hypotheses, stress-tests through multiple verification layers, searches across domains for inspiration.

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

Initialize `docs/discoveries/{topic-slug}/DISCOVERY.md`:
```markdown
# Discovery: {Topic}

> Started: {timestamp}
> Rigor: {rigor}
> Provenance: {knowledge-file-if-any}

## Problem Statement
[Extracted from conversation context]

## Problem Decomposition
- Sub-questions: [independent components]
- Necessary conditions: [what must hold for any solution]
- Boundary conditions: [constraints, edge cases]
- Verification approach: [how we'll know if we found something]

## Evaluation Criteria
[What counts as a solution/insight — must be falsifiable]

## Cross-Domain Analogies

| Source Domain | Analogous Concept | Mapping | Insight |
|---------------|-------------------|---------|---------|

## Hypothesis Log

## Verification Results

### Proxy Check Summary
| Hypothesis | Consistent | Novel | Falsifiable | Literature | Score |
|------------|-----------|-------|-------------|------------|-------|

### Adversarial Results
| Hypothesis | Fatal Flaws | Weaknesses | Verdict | Confidence Bet |
|------------|-------------|------------|---------|----------------|

### Falsification Results
| Hypothesis | Prediction Tested | Method | Result | Survives? |
|------------|-------------------|--------|--------|-----------|

## Best Result
- Hypothesis: [none yet]
- Confidence: LOW
- Verification layers passed: 0/4
- Open Questions: [pending]

## Iteration Summary

| # | Phase | Action | Hypothesis | Verification Layer | Result | Decision |
|---|-------|--------|------------|--------------------|--------|----------|

## Termination
- Reason: [pending]
```

If `--knowledge` flag was provided, read the knowledge file first and incorporate into Problem Statement and Evaluation Criteria.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "You are a discovery orchestrator. The user's problem statement is in the conversation context above. Read it carefully.

## REASONING PROTOCOL

For ALL reasoning in this pipeline:
1. STATE the claim explicitly
2. LIST assumptions required
3. ASSESS evidence for and against
4. IDENTIFY the weakest link
5. RATE your confidence 0-100. Below 60, flag as uncertain.

When combining insights from multiple sources:
- Reference earlier conclusions by number
- Explicitly note contradictions with earlier conclusions
- Revise earlier conclusions when warranted

## DISCOVERY PIPELINE

Update docs/discoveries/{topic-slug}/DISCOVERY.md after each phase.

### Phase 1: Problem Formulation
- READ DISCOVERY.md for current state
- If first iteration: parse problem, define scope, write Evaluation Criteria
- If resuming: read hypothesis log, identify what to try next
- If knowledge file provided: READ it, extract concepts, methods, gaps

Decompose before proceeding:
- What are the independent sub-questions?
- What must be true for ANY solution to work?
- What are the boundary conditions and constraints?
- What type of verification is possible for this problem? Choose the strongest available:
  (a) Formal proof / code execution — use if the claim is mathematical or algorithmic
  (b) Statistical falsification — use if the claim makes measurable predictions
  (c) Multi-agent panel — use for open-ended claims where (a) and (b) are not possible
  Write the chosen verification approach into DISCOVERY.md Problem Decomposition section.

### Phase 2: Cross-Domain Analogy Search
Map the problem abstract structure to other domains. Use parallel Task (Explore) subagents.

Run at least 3 agents in parallel across DIFFERENT domains:

ANALOGY AGENT PROMPT:
You are researching {domain} for analogous problems to: {abstract structure}.
1. What is the analogous problem in {domain}?
2. How was it solved? What is the canonical solution?
3. What is the KEY INSIGHT that makes the solution work?
4. How does that insight MAP BACK to the original problem?
5. What breaks when you try to transfer it? What assumptions differ?
Return: domain, analogous concept, solution insight, mapping, transfer limitations.

Add findings to the Cross-Domain Analogies table.
If no analogies found: log it, proceed from first principles.

### Phase 3: Hypothesis Generation (Tree-of-Thought)
Generate 3 candidate hypotheses INDEPENDENTLY:
- For each, trace the FULL reasoning chain (Chain-of-Thought)
- Rate each on promise (1-10)
- For each, identify: where would this fail? what is the weakest assumption?
- Select the most promising and develop it fully

For the selected hypothesis, write:
(a) Formal Statement: precise, falsifiable claim
(b) Assumptions: numbered list, each with justification and confidence (0-100)
(c) Predicted Consequences: what this predicts that ALTERNATIVES DO NOT
(d) Kill Condition: what specific evidence would DISPROVE this
(e) Testable Implications: concrete predictions that can be checked

Rigor levels (adaptive by default):
- formal: structured logic, symbolic notation, explicit axioms
- semi-formal: clear reasoning chains, explicit assumptions
- informal: intuitive arguments, analogies, thought experiments
- adaptive: informal in Phase 2, configured rigor in Phase 3, formal in Phase 4

Add hypothesis to the Hypothesis Log.

### Phase 4: LAYERED VERIFICATION

Each hypothesis passes through verification layers in order. A hypothesis that fails an earlier layer does not proceed to later layers. Record ALL results in the Verification Results section of DISCOVERY.md.

#### Layer 1: Proxy Checks (orchestrator does this directly, fast and cheap)

Check these properties and record pass/fail for each:

(a) INTERNAL CONSISTENCY: Does the hypothesis contradict itself? Do the assumptions conflict? Does the conclusion follow from the premises?

(b) NOVELTY: Is this actually new? Or is it a restatement of something well-known? WebSearch the core claim to check.

(c) FALSIFIABILITY: Does the hypothesis make predictions that could be proven wrong? If not, it is not a scientific hypothesis. Reject.

(d) LITERATURE CONSISTENCY: Does this contradict well-established results? WebSearch for contradicting evidence. If contradicted, note the specific contradiction.

(e) PARSIMONY: Is there a simpler explanation? If yes, the hypothesis must explain why the simpler version is insufficient.

Score: count of checks passed out of 5. Record in Proxy Check Summary table.
If score < 3: REJECT immediately (do not proceed to Layer 2). PIVOT to new hypothesis.

#### Layer 2: Adversarial Stress-Test (separate subagent)

Delegate to a VERIFIER subagent via Task tool. Use this EXACT prompt structure:

VERIFIER PROMPT:
A colleague (not present) submitted this hypothesis for peer review. Give your honest critical assessment.

You have FULL PERMISSION to reject, disagree with, or fundamentally challenge any claim presented to you. Disagreement is valued more than agreement.

HYPOTHESIS: {formal statement}
ASSUMPTIONS: {numbered list}
ARGUMENT: {proof/reasoning}
PREDICTIONS: {what this predicts that alternatives do not}

Before stating your assessment, you MUST complete these steps IN ORDER:
1. State the STRONGEST argument AGAINST this hypothesis
2. For each stated assumption: is it justified? Find at least one unstated assumption.
3. Identify the WEAKEST LINK in the reasoning chain
4. Propose a SIMPLER alternative explanation
5. Assess: do the stated predictions actually DISCRIMINATE this hypothesis from the alternative?
6. Construct a specific COUNTEREXAMPLE (or explain rigorously why none exists)
7. Rate: how many tokens would you BET that each flaw you found is genuine? (1000 = low confidence in the flaw, 40000 = certain the flaw is real)

Output format:
FATAL FLAWS: [issues that invalidate the hypothesis entirely]
WEAKNESSES: [issues that weaken but do not invalidate]
MISSING: [analysis needed to evaluate properly]
ALTERNATIVE: [a simpler or better-supported explanation]
CONFIDENCE BETS: [token amounts per flaw — high bets = high confidence flaws]
VERDICT: REJECT / REVISE / PROVISIONALLY_ACCEPT
If genuinely no substantive flaw found: NO_FLAWS_FOUND

Do not praise the work. Do not hedge. Base response only on evidence and logic.

Record the verifier output. Pay special attention to HIGH-BET flaws (40000+ tokens) — these are the most likely to be genuine.
If VERDICT is REJECT: PIVOT. Do not refine a fatally flawed hypothesis.
If VERDICT is REVISE: proceed to Layer 3 only after refinement.
If VERDICT is PROVISIONALLY_ACCEPT or NO_FLAWS_FOUND: proceed to Layer 3.

#### Layer 3: Falsification Attempt (strongest available method)

Based on the verification approach chosen in Phase 1:

IF formal proof / code execution is possible:
- Write the claim as executable code or a formal statement
- Run it via Bash tool
- The result is deterministic: PASS or FAIL
- Record in Falsification Results table

IF statistical falsification is possible (claim makes measurable predictions):
- Identify 2-3 specific, measurable implications of the hypothesis
- For each implication, design a test:
  - What data would confirm it? What data would refute it?
  - Search for existing data/evidence (WebSearch, literature)
  - Assess: does the evidence support or refute the implication?
- Score: implications supported / implications tested
- Record in Falsification Results table

IF neither is possible (open-ended claim):
- Run a SECOND verifier subagent with a DIFFERENT framing:

SECOND VERIFIER PROMPT:
You are an expert in {relevant domain} known for your skepticism toward {the type of claim being made}. Your methodology emphasizes {empirical evidence / formal rigor / practical feasibility}.

A junior researcher asks for your honest opinion on this hypothesis:
{hypothesis}

You have published extensively on why claims like this often fail. What do you think? Be direct. Do not soften your assessment.

Focus on: what would you need to see to be convinced? What is the most likely way this fails in practice?

- Record the second verifier result
- If BOTH verifiers return NO_FLAWS_FOUND: hypothesis passes Layer 3
- If either finds flaws: record and decide refine vs pivot

Record all Layer 3 results in Falsification Results table.

#### Layer 4: Confidence Calibration (orchestrator synthesis)

After all verification layers, the orchestrator synthesizes:
- How many layers did this hypothesis pass? (out of 3 active layers)
- What was the highest-confidence flaw found? (from token bets)
- What is the overall confidence?

Confidence mapping:
- Passed all 3 layers + deterministic verification: VERY HIGH
- Passed all 3 layers with LLM-only verification: HIGH
- Passed layers 1-2 but mixed results on layer 3: MEDIUM
- Failed any layer: LOW (but may still be the best available)

Update Best Result section with layers passed and confidence.

### Phase 5: Refinement or Pivot

Based on layered verification results:
- If FATAL FLAWS from any layer: PIVOT (try new direction informed by the specific failure)
- If WEAKNESSES only (no fatal flaws): REFINE (address the specific weaknesses found)
- If passed all layers: mark CANDIDATE. Run full verification stack AGAIN next iteration (need 2 consecutive passes for ACCEPTED status)

Before deciding refine vs pivot:
- Strongest argument FOR pivoting: [generate this]
- Strongest argument FOR refining: [generate this]
- Choose based on which argument is stronger, not on sunk cost.

Log decision in Iteration Summary table with verification layer that triggered the decision.

## STOP CONDITIONS

A. VERIFIED: Hypothesis passed ALL verification layers on TWO consecutive iterations.
   Mark ACCEPTED. Confidence from Layer 4. Log reason and layers passed.

B. MAX ITERATIONS reached.
   Pick hypothesis with highest layer-pass count. Confidence from Layer 4. Log reason.

C. DIMINISHING RETURNS: 3+ substantially similar hypotheses generated (self-assessed).
   Log honestly. Pick best. Confidence = MEDIUM at most. Log reason.

When ANY stop condition triggers:
1. Update Best Result with final hypothesis, confidence, layers passed
2. Update Termination with reason
3. List all open questions and unresolved flaws
4. Output: <promise>DISCOVERY_COMPLETE</promise>

## ANTI-CIRCUMVENTION
- Do NOT output the promise until a stop condition is genuinely met
- Do NOT skip verification layers — every hypothesis goes through Layer 1 and Layer 2 minimum
- Do NOT accept on first full pass — require TWO consecutive
- Do NOT self-critique as a substitute for the verifier subagent
- The verifier is a SEPARATE agent — delegate via Task tool, do not simulate its response
- If stuck: try a radically different approach, different domain analogy, or decompose further
- Track duplicate hypotheses honestly — similar hypotheses count toward diminishing returns
- HIGH-BET flaws (40000+ tokens) from verifiers should be treated as likely genuine"
```

## Parallel Agent Templates

### Analogy Agent
```
Task (Explore): "Find analogous solved problems to: {abstract problem structure}.
Search in {domain} (e.g., physics, biology, economics, control theory).
- What is the analogous problem in this field?
- How was it solved?
- What is the key insight that transfers?
- What breaks when you try to transfer it?
Return: domain, concept, mapping, transferable insight, transfer limitations"
```

### Adversarial Verifier Agent
```
Task (general-purpose): "A colleague (not present) submitted this for peer review:
HYPOTHESIS: {formal statement}
ASSUMPTIONS: {list}
ARGUMENT: {proof/reasoning}
PREDICTIONS: {discriminating predictions}

You have full permission to reject this entirely.
Before assessing: state the strongest argument AGAINST.
For each flaw found: how many tokens (1000-40000) would you bet it is genuine?
Find: fatal flaws, weaknesses, missing analysis, simpler alternatives.
If genuinely no flaws: output NO_FLAWS_FOUND
Do not praise. Be direct."
```

### Domain Skeptic Verifier Agent
```
Task (general-purpose): "You are an expert in {domain} known for skepticism toward {claim type}.
A junior researcher asks your honest opinion on:
HYPOTHESIS: {hypothesis}
What would convince you? What is the most likely way this fails?
Be direct. Do not soften your assessment."
```

## Output

After completion:
```
Discovery complete: docs/discoveries/{topic-slug}/DISCOVERY.md
- Hypotheses explored: {N}
- Best hypothesis: {name}
- Confidence: {VERY HIGH|HIGH|MEDIUM|LOW}
- Verification layers passed: {N}/3
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
