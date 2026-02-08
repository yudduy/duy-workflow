---
description: Structured inquiry — decomposes questions, challenges presuppositions, synthesizes answers. Produces insight a single prompt cannot.
argument-hint: "<question> [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash
---

# /inquire

Decompose → Criticize → Synthesize loop on a persistent investigation artifact. Takes a question, breaks it into falsifiable sub-questions, challenges presuppositions, answers tractable leaves, compresses upward. The artifact is the product.

## Setup

```bash
mkdir -p docs/inquiries/{question-slug}
```

Create `docs/inquiries/{question-slug}/INQUIRY.md`:

```markdown
# Inquiry: {Question}
> Status: Active | Iteration: 0

## Root Question
{Original question, verbatim}

## Question Graph
> Decomposition tree. Each node: question + status + presuppositions.

### Q0: {Root question}
- Status: OPEN
- Presuppositions: [what this question assumes to be true]
- Tractability: LOW | MEDIUM | HIGH

## Presupposition Registry
> Challenged assumptions. Fork when irresolvable.

| ID | Presupposition | Challenger | Status | Resolution |
|----|---------------|------------|--------|------------|

## Tried
> Approaches attempted. Prevents repetition.

| Iter | What | Outcome | Learning |
|------|------|---------|----------|

## Leaf Answers
> Answers to tractable sub-questions.

## Current Synthesis
> Best compressed answer to root question given current leaf answers.
> Fewer assumptions = better. This section should get SHORTER over iterations, not longer.

## Log
> Append-only. What happened each iteration.
```

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-20}" \
  --completion-promise "INQUIRY_COMPLETE" \
  "You are an inquiry agent. Your job: take the question above and produce an INQUIRY.md whose Current Synthesis section contains an answer that a direct prompt to an LLM could NOT produce. The value comes from the decomposition structure — surfacing hidden assumptions, connecting sub-domains, producing falsifiable claims instead of vague generalities.

## THE THREE FORCES

Every iteration, you execute exactly ONE of these:

### DECOMPOSE
Break an OPEN question into 2-4 sub-questions. Each sub-question must be:
- More tractable than its parent (closer to answerable)
- Falsifiable (you'd know an answer when you see one)
- Non-redundant (covers different ground from siblings)

Add sub-questions as children in the Question Graph. Mark parent as DECOMPOSED.
For each sub-question, list its presuppositions explicitly.

WebSearch to inform the decomposition — don't decompose from imagination. Ground sub-questions in what actually exists in the literature/evidence.

Stop decomposing when a question is tractable (an agent can answer it with web research). Depth > 3 is a smell — you're probably over-decomposing.

### CRITICIZE
Pick a presupposition from any question in the graph. Challenge it:

1. WebSearch for evidence AGAINST the presupposition
2. WebSearch for evidence FOR the presupposition
3. If the evidence is mixed or the presupposition is genuinely debatable:
   - Add to Presupposition Registry with status FORKED
   - Create two branches in the Question Graph: one assuming it, one not
   - Both branches continue independently
4. If the evidence clearly supports or refutes:
   - Mark CONFIRMED or REFUTED in the registry
   - If REFUTED: prune the branch that depended on it

Delegate criticism to a Task (general-purpose) agent — do NOT criticize your own decomposition. The critic must WebSearch independently.

CRITIC PROMPT (delegate via Task, general-purpose):
A researcher claims this presupposition is true: {presupposition}
Context: it underlies this question: {question}
WebSearch for evidence AGAINST this claim. Also search FOR it.
Output: EVIDENCE FOR | EVIDENCE AGAINST | VERDICT (CONFIRMED/REFUTED/CONTESTED) | CONFIDENCE 0-100
Every claim must have a URL citation. No ungrounded opinions.

### SYNTHESIZE
When 2+ leaf questions have answers, compress upward:

1. Read the leaf answers
2. Compose them into an answer for their parent question
3. Apply Occam's Razor: what is the SIMPLEST explanation that accounts for all leaf answers?
4. If two syntheses are possible, prefer the one with fewer assumptions
5. Update Current Synthesis with the best compressed answer to the root question

The synthesis must be SHORTER or EQUAL to the combined leaf answers. If it's longer, you're not synthesizing — you're padding.

## EACH ITERATION

1. READ INQUIRY.md
2. ASSESS: What's the weakest point?
   - Unexplored sub-questions → DECOMPOSE
   - Unchallenged presuppositions → CRITICIZE
   - Unanswered tractable questions → ANSWER (WebSearch, then write to Leaf Answers)
   - Multiple answered leaves without synthesis → SYNTHESIZE
3. EXECUTE one force
4. UPDATE INQUIRY.md
5. APPEND to Log section (2-3 lines: what you did, what you learned)

## ANSWERING LEAF QUESTIONS

When a question is tractable (HIGH tractability), answer it directly:
1. WebSearch for evidence
2. WebFetch the best sources
3. Write a concise answer with citations in Leaf Answers
4. Mark the question ANSWERED in the graph
5. Add the approach to Tried

## WHAT MAKES THIS DIFFERENT FROM A DIRECT PROMPT

A direct prompt gets you a flat, hedged, comprehensive-sounding response. This system:
- Surfaces HIDDEN ASSUMPTIONS (presupposition challenges)
- Forces FALSIFIABLE sub-claims (decomposition into tractable questions)
- Connects SUB-DOMAINS (leaf answers from different fields composed upward)
- Produces a COMPRESSED synthesis (Occam's Razor, not kitchen-sink)

If your Current Synthesis looks like something Claude would say to a direct prompt, you haven't gone deep enough. Push on presuppositions. Decompose further. Find the non-obvious connection.

## WHEN TO STOP

A. SYNTHESIS CONVERGED: Current Synthesis hasn't changed substantively in 2 iterations, all major branches have leaf answers, and presuppositions have been challenged. The synthesis is genuinely better than a direct prompt would produce.

B. DIMINISHING RETURNS: 3+ iterations with no new information or structural insight.

C. MAX ITERATIONS: Safety valve.

When stopping:
1. Final pass: is Current Synthesis shorter than it could be? Compress once more.
2. Verify: does the Question Graph show work a direct prompt wouldn't do?
3. <promise>INQUIRY_COMPLETE</promise>

## ANTI-CIRCUMVENTION
- Do NOT skip web research — every decomposition and answer must be grounded
- Do NOT criticize your own presuppositions — delegate to a Task agent
- Do NOT synthesize by concatenating — synthesis must COMPRESS
- Do NOT decompose past depth 3 without strong justification
- Do NOT output the promise until Current Synthesis is genuinely better than a direct prompt
- If stuck: answer more leaf questions, challenge more presuppositions, or ask the user for direction"
```

## Output

```
Inquiry complete: docs/inquiries/{question-slug}/INQUIRY.md
- Questions decomposed: {N}
- Presuppositions challenged: {M}
- Leaf answers: {L}
- Forks: {F}
- Synthesis length: {words}
```
