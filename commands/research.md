---
description: Ralph-powered autonomous experimental research — forms falsifiable conjectures, runs experiments, uses multi-model cross-verification (Codex + Gemini) for truth-seeking. Not web-search-and-theorize (that's /discover). This runs actual experiments.
argument-hint: "<research question> [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /research

Autonomous experimental research loop. Forms falsifiable conjectures with kill criteria, runs actual experiments, and uses multi-model cross-verification for truth-seeking.

**Not /discover.** /discover searches → hypothesizes → stress-tests via web search → distills. /research orients → conjectures → runs experiments → analyzes with multi-model verification → decides (DOUBLE DOWN | PIVOT | DIG DEEPER | ABANDON).

## Principles

1. **Conjectures are falsifiable or worthless.** Every conjecture has a kill criterion. If nothing can kill it, it's not science.
2. **Experiments over arguments.** Run the thing. Reading about it is phase 1, not the whole loop.
3. **Multi-model disagreement = signal.** When Codex, Gemini, and Claude disagree, that's where the interesting truth lives.
4. **Mistakes are data.** Track them explicitly. The pattern of mistakes reveals methodology gaps.
5. **Kill criteria are sacred.** If the kill criterion is met, the conjecture dies. No rationalizing.
6. **Decide, don't drift.** Every iteration ends with an explicit decision: DOUBLE DOWN | PIVOT | DIG DEEPER | ABANDON.

## Setup

```bash
# Parse research question from $ARGUMENTS
# Extract --max-iterations if present (default: 50)
mkdir -p docs/research/{topic-slug}/{EXPERIMENTS}
```

### Context Loading (before researching)

1. Read project's CLAUDE.md / README — understand the codebase, test commands, run commands
2. If in an Obsidian vault: scan VAULT-INDEX.md and relevant MOCs for prior knowledge
3. Read any existing docs/research/{topic-slug}/ files to resume prior work

### Output Files — 6 files, each serves a distinct purpose

**RESEARCH-PROGRESS.md** — THE readable output. Current state, active hypothesis, key results.

```markdown
# Research: {Question}
> Status: ORIENTING | SEARCHING | CONJECTURING | TESTING | ANALYZING | DECIDING | COMPLETE
> Active Conjecture: {name} | Confidence: {0-100}
> Iteration: {N}/{max} | Last updated: {timestamp}

## The Question
[What we're trying to answer. One paragraph. The REAL question behind the question.]

## Current Understanding
[What we know NOW. Updated every iteration. Not a history — the current best model.]

## Key Results
[Experiment outcomes that changed our understanding. Chronological, most recent first.]

### Result {N}: {title}
- **Experiment**: {what was run}
- **Expected**: {what conjecture predicted}
- **Observed**: {what actually happened}
- **Implication**: {what this means for the conjecture}

## Cross-Verification Log
| Check | Claude | Codex | Gemini | Agreement | Signal |
|-------|--------|-------|--------|-----------|--------|

## Decision Trail
| Iter | Decision | Rationale | Next Action |
|------|----------|-----------|-------------|

## Summary
- **Status**: CONFIRMED | KILLED | REVISED | IN_PROGRESS
- **Confidence**: {0-100}
- **Answer**: {one sentence}
- **Experiments run**: {N}
- **Conjectures tested**: {N} (confirmed: {C}, killed: {K}, revised: {R})
- **Models agreed**: {N}/{total checks}
- **Key mistake**: {biggest methodological error and what it taught}
```

**CONJECTURES.md** — All hypotheses with status tracking.

```markdown
# Conjectures

## Active
### C-{N}: {Name}
- **Statement**: {falsifiable claim}
- **Kill criterion**: {what would disprove this — specific, measurable}
- **Confidence**: {0-100}
- **Evidence for**: {bullet list with citations}
- **Evidence against**: {bullet list with citations}
- **Experiments pending**: {what remains to test}
- **Status**: ACTIVE | CONFIRMED | KILLED | REVISED → C-{M}

## Confirmed
### C-{N}: {Name} ✓
[same structure, frozen at confirmation]

## Killed
### C-{N}: {Name} ✗
- **Kill reason**: {what disproved it}
- **Killed by**: {experiment or evidence}
- **Lesson**: {what this taught us}

## Revised
### C-{N}: {Name} → C-{M}
- **What changed**: {delta}
- **Why**: {evidence that forced revision}
```

**EXPERIMENTS/experiment-log.md** — Chronological experiment record.

```markdown
# Experiment Log

## E-{N}: {Title}
- **Date**: {timestamp}
- **Conjecture**: C-{N}
- **Hypothesis**: {what we expected}
- **Method**: {exact steps, commands, code}
- **Result**: {what happened — data, not interpretation}
- **Analysis**: {what this means}
- **Decision**: DOUBLE DOWN | PIVOT | DIG DEEPER | ABANDON
```

**LITERATURE.md** — Structured notes from papers and sources.

```markdown
# Literature

## Key Papers
### {Author} {Year} — {Title}
- **Finding**: {one sentence}
- **Relevance**: {how it connects to our question}
- **Limitations**: {what it doesn't cover}
- **URL**: {link}

## Key Implementations
### {Repo/Tool} — {What it does}
- **Approach**: {how it works}
- **Results**: {their reported metrics}
- **Gap**: {what's missing that we're investigating}
```

**MISTAKES.md** — What went wrong and why. Pattern detection.

```markdown
# Mistakes

## M-{N}: {Title}
- **What happened**: {the error}
- **Why**: {root cause}
- **Pattern**: {is this a recurring type of mistake?}
- **Fix**: {what we changed in methodology}

## Recurring Patterns
| Pattern | Count | Mitigation |
|---------|-------|------------|
```

**TODO.md** — Next actions, prioritized.

```markdown
# TODO

## Immediate (this iteration)
- [ ] {action}

## Next (upcoming iterations)
- [ ] {action}

## Blocked
- [ ] {action} — blocked by: {what}

## Done
- [x] {action} — iter {N}
```

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-50}" \
  --completion-promise "RESEARCH_COMPLETE" \
  "You are an autonomous research agent. Your question is in the conversation context above.

## OUTPUT FILES

Write to docs/research/{topic-slug}/:
- RESEARCH-PROGRESS.md (the readable output — always current)
- CONJECTURES.md (hypothesis tracker)
- EXPERIMENTS/experiment-log.md (chronological experiment record)
- LITERATURE.md (structured source notes)
- MISTAKES.md (errors + patterns)
- TODO.md (prioritized next actions)

Do NOT create other files outside this structure.

## TOOLS AVAILABLE

- **Search**: WebSearch, Exa MCP (web_search_exa), ask_alphaxiv MCP (grounded paper answers with citations)
- **Read sources**: WebFetch, DeepWiki MCP (for repos/libraries)
- **Run experiments**: Bash (execute code, run tests, measure), Read/Write/Edit (modify code)
- **Cross-verify**: codex exec (peer review), gemini -p (adversarial critique)

**Codex session management (save $$$):**
- First codex call in a research topic → capture session ID from output (session id: {UUID})
- All follow-up codex calls for the SAME topic → use codex exec resume {SESSION_ID} --skip-git-repo-check instead of fresh codex exec
- This retains full conversation context — codex remembers prior conjectures, critiques, and evidence without re-sending
- Store session ID in TODO.md under Sessions section
- Gemini has no session resume — each gemini -p call is fresh. Keep gemini prompts self-contained with enough context.

**Tool priority for literature**:
1. ask_alphaxiv — synthesized answers grounded in papers (best signal/noise ratio)
2. Exa MCP — semantic search for specific topics
3. WebSearch — broad web search
4. WebFetch on arxiv.org/html/{id} — only for specific claims in specific papers

**⚠ ALPHAXIV HALLUCINATION WARNING**: alphaXiv commits prompt sycophancy. It returns REAL paper titles and arXiv IDs but FABRICATES specific mechanisms, formulas, and method names to match your prompt. The more specific/suggestive your question, the more it invents.
- Paper titles/IDs: RELIABLE
- General landscape/trends: MOSTLY RELIABLE
- Specific mathematical workarounds: UNRELIABLE — must cross-verify
- Method names not in the original paper: LIKELY FABRICATED

**Mandatory verification protocol**: After any ask_alphaxiv call that claims specific mechanisms:
1. Pick the 2-3 most critical claimed mechanisms
2. WebFetch arxiv.org/html/{paper_id} for each
3. Search the actual paper text for the claimed method/formula
4. If not found → mark as FABRICATED in MISTAKES.md, use only the paper's real contribution
5. If confirmed → mark as VERIFIED in LITERATURE.md with page/section reference

## ITERATION LOOP: ORIENT → SEARCH → CONJECTURE → TEST → ANALYZE → DECIDE

Every iteration follows this cycle. Not every phase runs every iteration — skip phases that aren't needed.

### ORIENT (iterations 1-2)

Understand the problem space before doing anything.

1. Read project context (CLAUDE.md, README, existing code)
2. Read any prior research files (resuming?)
3. Identify: What do we ACTUALLY need to learn? What would change our behavior?
4. Frame the question precisely — the real question, not the surface question
5. Write initial RESEARCH-PROGRESS.md with The Question section
6. Write initial TODO.md with research plan

### SEARCH (iterations 2-5)

Map what's known. Use parallel Task subagents:

**Literature Scout** (Task, general-purpose, run_in_background: true) — prompt:

    Search for existing work on: {research question}
    Tools: ask_alphaxiv (primary), Exa MCP (web_search_exa), WebSearch
    Do NOT dump full papers into context.

    ITERATIVE ALPHAXIV INTERROGATION (3-pass pattern):

    Pass 1 — Landscape scan (new conversation):
      ask_alphaxiv with broad question about SOTA, key papers, failure modes
      Extract conversation_id for follow-ups. Note claimed papers and mechanisms.

    Pass 2 — Drill into specifics (same conversation_id):
      ask_alphaxiv for exact mechanisms, pathologies, constraints
      Note specific claims about formulas, method names, architectural details

    Pass 3 — Adversarial pressure test (same conversation_id):
      ask_alphaxiv for strongest arguments AGAINST, failed attempts, broken assumptions

    After all passes: run mandatory verification protocol (see HALLUCINATION WARNING).
    Only VERIFIED claims go into LITERATURE.md. FABRICATED claims go into MISTAKES.md.

    Find: key papers, implementations, known results, failed approaches
    Write structured notes to: docs/research/{topic}/LITERATURE.md
    Focus on: {leads specific directive}

**Implementation Scout** (Task, Explore, run_in_background: true) — prompt:

    Search for existing implementations related to: {research question}
    Tools: WebSearch, Exa MCP (get_code_context_exa), DeepWiki MCP
    Find: repos, benchmarks, reference implementations, tooling
    Write to: docs/research/{topic}/LITERATURE.md (Key Implementations section)
    Focus on: {leads specific directive}

After scouts return: synthesize into Current Understanding in RESEARCH-PROGRESS.md.

### CONJECTURE (iterations 3-6)

Form falsifiable hypotheses from what SEARCH revealed.

**Multi-model abductive reasoning.** Different model biases → different conjectures → richer hypothesis space.

**Step 1: Independent conjecture generation** — run ALL THREE in parallel:

Your own: Generate 2-3 candidate conjectures from LITERATURE.md findings.

**Codex direction proposal** (via Bash):

    codex exec --skip-git-repo-check "ABDUCTIVE REASONING — CONJECTURE GENERATION
    Research question: {question}
    Literature summary: {key findings from LITERATURE.md}
    Known dead ends: {failed approaches}
    Propose 2-3 falsifiable conjectures:
    1. What pattern in the evidence suggests a non-obvious explanation? (abduction)
    2. What direction would you investigate that isnt in the literature?
    3. What assumption is everyone taking for granted but might be wrong?
    For each: formal statement, kill criterion (specific + measurable), what experiment would test it.
    Propose freely — diverge from the literature if you see something."

**Gemini direction proposal** (via Bash):

    gemini -p "CONJECTURE GENERATION
    Research question: {question}
    Whats known: {literature summary}
    Whats failed: {dead ends}
    Propose 2-3 conjectures I might be missing:
    1. What would a contrarian researcher bet on?
    2. What cross-domain analogy suggests an approach nobodys tried?
    3. Whats the simplest possible explanation that fits the data?
    For each: falsifiable statement + kill criterion + first experiment.
    Different perspective is the point — dont just echo the literature."

**Step 2: Merge and triangulate** all candidates (yours + codex + gemini):
- **Convergence**: multiple models propose similar direction → high prior, strong candidate
- **Unique angles**: only one model sees it → investigate, could be blind spot OR noise
- **Contradictions**: models propose opposite directions → the tension itself is informative, may be the real question

**Step 3: Cross-verify the selected conjecture(s)** — run in parallel:

    codex exec --skip-git-repo-check "PEER REVIEW: Conjecture '{statement}'. Kill criterion: '{criterion}'. Evidence: {summary}.
    Is it falsifiable? Obvious confounds? Simpler explanation? What experiment FIRST? Be direct."

    gemini -p "ADVERSARIAL REVIEW: Conjecture '{statement}'. Kill criterion: '{criterion}'.
    Strongest argument AGAINST? Kill criterion too easy/hard? Whats naive? Similar conjecture that failed? Be ruthless."

**Step 4:** Incorporate feedback. If both models flag the same issue → fix before proceeding.
**Step 5:** Write selected conjecture(s) to CONJECTURES.md with ACTIVE status.

### TEST (iterations 5-30)

Run actual experiments. This is where /research differs from /discover.

1. Design experiment to test the ACTIVE conjecture's predictions
2. Log experiment design in EXPERIMENTS/experiment-log.md BEFORE running
3. **Run the experiment** — actually execute code, measure results, collect data
4. Record raw results in experiment log — data first, interpretation after
5. If experiment fails to run: log in MISTAKES.md, fix, retry (max 2 retries per experiment)

Experiment types (adapt to context):
- Run code and measure output
- Modify a variable and compare before/after
- A/B test between approaches
- Benchmark with specific metrics
- Reproduce a result from literature

### ANALYZE (iterations 5-30, after each TEST)

Interpret results. **CROSS-VERIFY at confidence transitions** (LOW→MEDIUM, MEDIUM→HIGH):

When confidence crosses a threshold (0→40, 40→70, 70→90):

Run in parallel:

**Codex analysis review** (via Bash):

    codex exec --skip-git-repo-check "RESULTS ANALYSIS
    Conjecture: {statement}
    Kill criterion: {criterion}
    Experiment: {what was run}
    Result: {raw data}
    My interpretation: {what I think this means}
    Review:
    1. Does the data actually support this interpretation?
    2. Are there alternative explanations for the same data?
    3. Is the sample size / test adequate?
    4. Whats the confidence level (0-100) youd assign?
    Disagree freely."

**Gemini analysis review** (via Bash):

    gemini -p "RESULTS VERIFICATION
    Conjecture: {statement}
    Experiment: {method}
    Result: {raw data}
    Claimed interpretation: {interpretation}
    Verify:
    1. Does this result ACTUALLY discriminate between the conjecture and alternatives?
    2. Whats the biggest threat to validity?
    3. What would you need to see to be convinced?
    4. Confidence (0-100)?
    Different perspective welcome."

Log all cross-verification results in the Cross-Verification Log table in RESEARCH-PROGRESS.md.

**Disagreement protocol:**
- All 3 agree → proceed with combined confidence
- 2 agree, 1 disagrees → investigate the disagreement (it's signal, not noise)
- All 3 disagree → step back, the question may be ill-posed. DIG DEEPER.

### DECIDE (every iteration)

Explicit decision. No drifting. Choose ONE:

| Decision | When | Action |
|----------|------|--------|
| **DOUBLE DOWN** | Evidence supports conjecture, more data needed | Design next experiment for same conjecture |
| **PIVOT** | Kill criterion met or evidence clearly against | Kill conjecture, ask all 3 models for new directions (see below) |
| **DIG DEEPER** | Results ambiguous, need more understanding | Return to SEARCH with refined questions |
| **ABANDON** | Direction exhausted, no productive path forward | Mark conjecture KILLED, check if all directions explored |

**On PIVOT — multi-model direction finding** (run in parallel via Bash):

    codex exec --skip-git-repo-check "PIVOT REQUIRED. Conjecture '{killed conjecture}' died because: {kill reason}.
    Research question: {question}. What weve learned so far: {summary}.
    Given this failure, what direction would you try next? What does the failure itself reveal?
    Propose 1-2 new conjectures with kill criteria."

    gemini -p "PIVOT REQUIRED. '{killed conjecture}' was killed by: {kill reason}.
    Question: {question}. Dead ends so far: {list}.
    Whats the most promising unexplored direction? What assumption should we drop?
    Propose 1-2 conjectures. Be contrarian — the obvious directions already failed."
Merge proposals with your own. Convergence across models = strong candidate.

Log decision in Decision Trail table in RESEARCH-PROGRESS.md.
Update TODO.md with next actions based on decision.

### DOCUMENT (every 5 iterations + at completion)

Ensure RESEARCH-PROGRESS.md reflects current understanding:
1. Current Understanding section is up-to-date (not historical — what we believe NOW)
2. Key Results has all significant experiment outcomes
3. Cross-Verification Log is complete
4. Decision Trail is current
5. Summary block is honest about confidence

## AUTO-EXIT CONDITIONS

Exit the loop when ANY of these are true:

1. **Conjecture CONFIRMED with HIGH confidence** — all 3 models agree (>80 confidence each), kill criterion was tested and survived, at least 2 experiments support it
2. **All directions ABANDONED** — every conjecture is KILLED or ABANDONED, no productive new directions identified
3. **Max iterations reached** — default 50
4. **Diminishing returns** — 5 consecutive iterations with no new experimental results or confidence change

When auto-exiting due to diminishing returns or max iterations, document honestly:
- What was learned despite not reaching conclusion
- What would be needed to continue (more compute? different approach? domain expertise?)
- Best current answer with honest confidence

## SELF-CHECK (each iteration)

Before deciding:
- Did I run an actual experiment this iteration (not just read/think)?
- Did the experiment produce data that discriminates between hypotheses?
- Am I testing the conjecture or confirming my bias?
- Have I checked MISTAKES.md for recurring patterns?
- Is my confidence calibrated? (If I say 80%, would I bet on it?)

If last 3 iterations had no experiments → force an experiment or ABANDON.

## COMPLETION

When exit condition is met:

1. Final DOCUMENT pass — all 6 files complete and consistent
2. Final cross-verification of conclusion:

       codex exec --skip-git-repo-check "FINAL REVIEW of research conclusion:
       Question: {question}
       Answer: {conclusion}
       Confidence: {N}
       Key evidence: {summary}
       Is this conclusion justified? What caveats should be stated?"

       gemini -p "FINAL REVIEW of research conclusion:
       Question: {question}
       Answer: {conclusion}
       Confidence: {N}
       Experiments: {summary}
       Grade this conclusion A-F. What would make it stronger?"

3. Write final Summary block in RESEARCH-PROGRESS.md
4. If in a vault project, run KG Deposit:
   a. Write `Discovery - {Title}.md` to `Obsidian-Template-Vault/3. Resources (Dynamic)/Distillations/`
      Frontmatter: tags (content/distillation, content/research, topics/{slug}), type: research, status: completed
   b. Extract key insights as `Insight - {Claim}.md` (Glob existing first to avoid dupes)
   c. Update relevant MOC and `MOC - Research Index.md` with wikilinks
   d. Update VAULT-INDEX.md if new entries

5. <promise>RESEARCH_COMPLETE</promise>

If stuck: <promise>BLOCKED: [reason]</promise>"
```

## Output

```
Research complete: docs/research/{topic-slug}/RESEARCH-PROGRESS.md

- Answer: {one sentence}
- Confidence: {0-100}
- Experiments run: {N}
- Conjectures tested: {N} (confirmed: {C}, killed: {K}, revised: {R})
- Cross-verifications: {N} (agreement rate: {%})
- Key mistake: {biggest methodological learning}
- Key disagreement: {most informative model disagreement}
```
