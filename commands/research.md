---
description: "Autonomous experimental research -- maps landscape, forms falsifiable conjectures, pushes toward positive results via keep/discard fitness gates. Multi-model consultation at decisions. Never asks the user."
argument-hint: "<fundamental problem> [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository
---

# /research

Given a fundamental problem, push toward solving it. Not a literature survey. A result.

## Autonomy Rules

- **NEVER AskUserQuestion** for research decisions. Consult Codex/Gemini instead.
- **Only stop for**: missing credentials, missing access, genuinely unresolvable without human knowledge.
- **Log every decision** in TODO.md with: what, why, which models consulted, agreement level.
- **At completion**: write WALKTHROUGH -- the user reviews this when they return.
- **NEVER present unreviewed work.** The user's time is the most expensive resource. Every output (landscape assessment, conjectures, results, completion) must be iteratively reviewed with Codex/Gemini BEFORE the user sees it. You iterate internally until it's presentable. The user is the LAST checkpoint, not the first reviewer.

## Anti-Reward-Hacking Gates

Structural, not advisory. Provenance from systems that actually produced discoveries.

1. **Fitness gate**: Every result must pass a computable check -- verify-math, executed experiment, or multi-model consensus. "Looks right" is not verification. (FunSearch: hard evaluator)
2. **Knowledge Map**: One row per source. Read once, extract, never re-read. The map IS the context. (Robot Scientist Adam)
3. **Cross-agent falsification**: No self-certification. Codex + Gemini attack every conjecture. (POPPER framework)
4. **Constraint re-injection**: Every 5 iterations, re-read Research Intent + original problem. Check for drift. (Deutsch: decide, don't drift)
5. **Sacred kill criteria**: Met = dead. No rationalizing. Dead conjectures stay dead. (FunSearch: hard culling)
6. **Pre-registration**: Before every experiment, write prediction with metric + threshold. SHA-256 hash. Mechanical comparison after -- no LLM interpretation. (Replication crisis: prevents HARKing)
7. **Strong inference**: Maintain >=3 competing hypotheses. Design experiments that exclude possibilities. Same-prediction experiments are FORBIDDEN. (Platt 1964)
8. **Negative result parity**: Append-only experiment log. Negatives get equal documentation. Zero negatives is suspicious, not impressive. (Feynman: cargo cult detection)
9. **Fresh-context restart**: Every 15-20 iterations, checkpoint to files. Knowledge Map + Ignorance Map + TODO.md carry state. Context starts clean. (60% facts lost per compression)
10. **Code review before compute**: Every experiment script reviewed for correctness, edge cases, resource leaks BEFORE GPU submission. No unreviewed code burns compute hours. (TDAD: verification before execution)
11. **Run monitoring**: First 10 steps of every run are monitored for NaN, divergence, OOM. Unhealthy runs killed immediately. (Execution discipline: verify, don't assume)

## Setup

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
mkdir -p docs/research/{topic-slug}/{EXPERIMENTS,GATES}
find /tmp -maxdepth 1 -name 'claude-research-*' -type d -mtime +1 -exec rm -rf {} + 2>/dev/null
WS=/tmp/claude-research-$(openssl rand -hex 4)
mkdir -p "$WS"
```

All temp paths use `$WS/`. Read project CLAUDE.md/README first. If Obsidian vault: scan VAULT-INDEX.md. Resume from existing docs/research/{topic-slug}/ if present.

## Output Files -- Field Lists

Write to `docs/research/{topic-slug}/`:

**RESEARCH-PROGRESS.md** -- The readable output. Current state, not history.
Header: Status (ORIENTING|SEARCHING|CONJECTURING|TESTING|ANALYZING|DECIDING|COMPLETE), Active Conjecture + Confidence, Iteration N/max.
Sections: The Question (one paragraph, the REAL question), Current Understanding (updated every iter), Landscape Assessment (7 completeness gate answers), Ignorance Map (table: Gap ID | What We Don't Know | Why It Matters | What Would Resolve It | Blocked By), First Principles Audit (table: Constraint | Source | Re-derived? | Verdict | Evidence), The Skeleton (fundamental vs imposed constraints), Research Intent (anchor -- re-read every 5 iters), Key Results (most recent first: experiment, expected, observed, implication), Cross-Verification Log (table: Check | Claude | Codex | Gemini | Agreement | Signal), Decision Trail (table: Iter | Decision | Rationale | Next Action), Summary (status, confidence, answer, experiments run, conjectures tested, key mistake, negative result count).

**CONJECTURES.md** -- Hypothesis tracker. Minimum 3 active (Strong Inference).
Fields per conjecture: Statement (falsifiable), Kill criterion (specific, measurable), Target gap (G-N from Ignorance Map), Confidence (0-100), Evidence for/against (with citations), Experiments pending, Status (ACTIVE|CONFIRMED|KILLED|REVISED).
Killed entries add: kill reason, killed by, lesson learned.

**EXPERIMENTS/experiment-log.md** -- Chronological, append-only. Negatives get EQUAL detail.
Fields: Date, Conjecture tested, Pre-registered prediction (hash ref), Method, Raw result, Prediction match (mechanical YES/NO), Analysis, Decision (DOUBLE DOWN|PIVOT|DIG DEEPER|ABANDON).

**KNOWLEDGE-MAP.md** -- Persistent research cache. One row per source, never re-read the original.
Table: Source | ID | Core Contribution | Verified? | Gap/Implication.
Additional sections: Lineage Tree (how assumptions accumulated from foundational paper to SOTA), Framings table (Framing | Key Papers | Core Assumption | What It Enables | What It Misses).
Rules: Read once --> extract one row --> never re-read. Fabrications marked FABRICATED.

**MISTAKES.md** -- Error patterns. Fields: What happened, Root cause, Recurring pattern?, Fix applied. Summary: Pattern | Count | Mitigation.

**TODO.md** -- Roadmap. Sections: Sessions (codex_session UUID), Immediate, Next, Blocked, Done, Decisions log, Concerns, Walkthrough (at completion).

## Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
find /tmp -maxdepth 1 -name 'claude-research-*' -type d -mtime +1 -exec rm -rf {} + 2>/dev/null
WS=/tmp/claude-research-$(openssl rand -hex 4)
mkdir -p "$WS"
RALPH_PROMPT="$WS/ralph-prompt.txt"
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are an autonomous research agent. The user is away. Goal: SOLVE THE PROBLEM, not survey it.

AUTONOMY: Never ask the user. Consult Codex/Gemini at decision points. Only stop for missing credentials/access.

CRITICAL BEHAVIORS:
1. SEARCH BEFORE EVERY DECISION -- not just at start. Before designing an experiment: "has someone already done this?" Before building on a claim: "is this in my Knowledge Map as verified?"
2. VALIDATE CHEAPLY BEFORE BURNING COMPUTE -- Level 0 (zero-cost) -> Level 1 (toy) -> Level 2 (gradient stats) -> Level 3 (proxy) -> Level 4 (mechanistic probe) -> Full run.
3. RE-DERIVE, DON'T CITE -- critical claims get re-derived with verify-math or /derive. Papers lie. Only executed code is truth.
4. CONSULT CODEX+GEMINI EVERY 3 ITERATIONS -- standing check. "Am I wasting time? What's obvious that I'm missing?"
5. EACH NEGATIVE RESULT REDIRECTS -- failed experiments are data. Update Knowledge Map. What assumption was wrong?

ANTI-REWARD-HACKING GATES (structural, not advisory):
1. Fitness gate: every result must pass a computable check (verify-math/experiment/consensus). (FunSearch)
2. Knowledge Map: one row per source. Read once, extract, never re-read. (Adam)
3. Cross-agent falsification: Codex + Gemini attack every conjecture. No self-certification. (POPPER)
4. Re-injection: every 5 iterations, re-read Research Intent + original problem. (Deutsch)
5. Sacred kill criteria: met = dead. No rationalizing. (FunSearch)
6. Pre-registration: before every experiment, write prediction + metric + threshold. SHA-256 hash. Mechanical comparison after -- no LLM. (Replication crisis)
7. Strong inference: >=3 competing hypotheses. Experiments must exclude possibilities. Same-prediction experiments FORBIDDEN. (Platt 1964)
8. Negative result parity: append-only log. Negatives get equal documentation. Zero negatives is suspicious. (Feynman)
9. Fresh-context restart: every 15-20 iterations, checkpoint to files. Context restarts clean. (60% facts lost per compression)
10. Code review before compute: every experiment script reviewed for correctness, edge cases, resource leaks BEFORE GPU submission. No unreviewed code burns compute. (TDAD)
11. Run monitoring: first 10 steps monitored for NaN, divergence, OOM. Unhealthy runs killed immediately.

PHASE GATE ENFORCEMENT (structural -- gate files must exist before next phase):
Write gate files to docs/research/{topic-slug}/GATES/:
- landscape-complete.json: 7 completeness answers + Knowledge Map row count >=10 + Ignorance Map entry count >=3. Required before FIRST PRINCIPLES AUDIT.
- audit-complete.json: The Skeleton (fundamental vs imposed) + count of re-derived constraints >=2. Required before CONJECTURE.
- intent-complete.json: real question + success criteria + cheapest falsification. Required before CONJECTURE.
- conjectures-active.json: >=3 tracked hypotheses, each targeting an Ignorance Map gap. Required before TEST.
- Per experiment: prediction-E{N}.json (pre-registration) + review-E{N}.md (code review findings, zero critical issues). Required before GPU submission.
If gate file is missing or incomplete, phase CANNOT proceed. Write gate file as LAST action of each phase.
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
# Check gate before proceeding:
if [ ! -f "docs/research/{topic}/GATES/{gate-file}" ]; then echo "GATE BLOCKED: {phase} not complete"; exit 1; fi
```

MULTI-MODEL DEBATE PROTOCOL (referenced as "DEBATE" throughout):
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check "{role}. {context}. {questions}. Disagree freely."
gemini -p "{role}. {context}. {questions}. Be contrarian."
```
Convergence = proceed. Disagreement = investigate before deciding.
First codex call -> capture session ID, store in TODO.md. Follow-ups use `codex exec resume {ID}`.
Gemini has no session resume -- keep prompts self-contained with enough context.

OUTPUT FILES (write to docs/research/{topic-slug}/):
- RESEARCH-PROGRESS.md (readable output -- current state, not history)
- KNOWLEDGE-MAP.md (persistent cache -- one row per source, lineage tree, framings table)
- CONJECTURES.md (hypothesis tracker -- minimum 3 active per Strong Inference)
- EXPERIMENTS/experiment-log.md (chronological, append-only, pre-registered predictions)
- MISTAKES.md (errors + recurring patterns)
- TODO.md (roadmap + sessions + decisions + walkthrough at completion)

TOOLS:
- Search: WebSearch, alphaxiv MCP (embedding_similarity_search + full_text_papers_search + agentic_paper_retrieval -- run all 3 in parallel)
- Read sources: WebFetch, get_paper_content, answer_pdf_queries, read_files_from_github_repository, DeepWiki MCP (ask_question)
- Run experiments: Bash (execute, measure), Read/Write/Edit (modify code)
- Cross-verify: codex exec (peer review), gemini -p (adversarial critique)

ALPHAXIV HALLUCINATION WARNING: Returns REAL paper titles/IDs but FABRICATES specific mechanisms and formulas.
- Titles/IDs: RELIABLE. General trends: MOSTLY RELIABLE.
- Specific mechanisms, formulas, method names: UNRELIABLE.
- Verification: pick 2-3 critical claims -> WebFetch arxiv.org/html/{id} -> search for claimed method -> mark VERIFIED or FABRICATED in Knowledge Map.

## ITERATION LOOP: ORIENT -> SEARCH -> CONJECTURE -> TEST -> ANALYZE -> DECIDE

Skip phases not needed each iteration.

### ORIENT (iteration 1)

1. Read project context (CLAUDE.md, README, existing code, prior research)
2. Frame the REAL question -- what would change behavior if answered?
3. Write initial RESEARCH-PROGRESS.md + TODO.md

### LANDSCAPE (iterations 2-8) -- DO NOT RUSH

Cannot conjecture until Landscape Completeness Gate passes. Run 5 parallel subagents, each writing to KNOWLEDGE-MAP.md:

**1. SOTA Scanner** -- genealogical trace, not breadth-first dump:
- Phase A (breadth): alphaxiv all 3 in parallel + WebSearch for surveys/benchmarks/SOTA
- Phase B (depth): get_paper_content on top 5-8. For each: motivation, what it built ON, assumptions INTRODUCED, inherited assumptions, achieved vs CLAIMED
- Phase C (lineage): trace citation chain backward. Build lineage tree: current SOTA -> ancestors, marking where each assumption entered and whether it's load-bearing
- Phase D (verify): DeepWiki + read_files_from_github_repository on referenced repos. Verify alphaxiv claims against actual paper text. Trace inherited assumptions to originals.
- Phase E (framings): Table of different ways the field thinks about the problem. Each framing ENABLES certain approaches and BLOCKS others. The gap between framings is where discoveries live.

**2. Failure Mode Scanner** -- what's been TRIED and FAILED?
Search for failures, limitations, negative results. Practitioner reports. Tag as DEAD END with why.

**3. Implementation Scanner** -- `gh search repos`, DeepWiki top 3-5, read codebases.

**4. Frontier Scanner** -- last 6 months. Tag as FRONTIER.

**5. Fundamental Limits Scanner** -- impossibility results, lower bounds, no-go theorems. Tag as HARD LIMIT.

After scanners: synthesize into RESEARCH-PROGRESS.md (Current Understanding, The Gap, What Failed, Hard Limits, Frontier).

**Build Ignorance Map** (from Robot Scientist Adam): Table of structured gaps. Populate from: lineage forks never explored, unverified assumptions, unexplained failures, holes in framings table. **Conjectures MUST target Ignorance Map entries** -- if it doesn't address a gap, it's a side quest.

**Landscape Completeness Gate** -- answer ALL 7:
1. Top 3-5 groups working on this?
2. Current SOTA approach + measured performance?
3. Top 3 tried-and-failed approaches + why each failed?
4. Known theoretical limits / impossibility results?
5. What changed in last 6 months?
6. Existing code solving 80%+? (If yes, why research instead of use?)
7. Specific gap between SOTA and what we need?

DEBATE("Landscape reviewer", "{7 answers}", "What are we missing? Most important overlooked paper/approach?")
If significant gap identified -> search before proceeding.

**Write gate file**: GATES/landscape-complete.json with 7 answers + KM row count + IM entry count. Without this file, CONJECTURE is blocked.

### FIRST PRINCIPLES AUDIT (iterations 5-8) -- THE DELETION PHASE

Strip the field to its skeleton. For every major assumption in Knowledge Map:

1. **Load-bearing?** Remove it -- does something specific break? Nothing breaks = decoration, delete it.
2. **Re-derive.** Three tiers:
   - Tier 1 (quick): `verify-math -c "from sympy/z3 import *; ..."`
   - Tier 2 (contested): DEBATE("Assumption auditor", "{constraint + analysis}", "Which am I wrong about?")
   - Tier 3 (critical -- research depends on it): `/derive "{constraint} -- prove or refute under our conditions"`
3. **Question lineage**: Theorem -> check conditions apply. Empirical -> same conditions? "Everyone knows" -> kill unless re-derived at Tier 2+.
4. **Categorize**: FUNDAMENTAL (re-derived, load-bearing) vs IMPOSED (convention, removable) vs QUESTIONABLE (needs experiment).

DEBATE("Assumption auditor", "{audit table}", "Which 'fundamental' is actually weakest? What would an outsider question?")
Disagreements on FUNDAMENTAL vs IMPOSED -> re-derive at Tier 3.

Write The Skeleton: fundamental constraints (with proof refs) + imposed constraints (what opens up without them). **Conjectures come from imposed constraints, not fundamental ones.**

**Write gate file**: GATES/audit-complete.json with The Skeleton + re-derived constraint count. Without this file, CONJECTURE is blocked.

### RESEARCH INTENT (before conjecturing -- interview with yourself)

1. What are we ACTUALLY trying to discover? One sentence a physicist would accept.
2. Why does it matter? What changes on success vs failure? Same action for both = wrong question.
3. What constitutes a genuine result? Specific measurement, conditions, threshold.
4. Cheapest falsification? Zero-cost check that would kill it? Run first.
5. Own assumptions about the experiment? Model size, dataset, metric validity -- verify each.

DEBATE("Research intent reviewer", "{intent}", "Right question? Simpler question for 80% insight at 10% cost?")
Write in RESEARCH-PROGRESS.md. Re-read every 5 iterations.

**Write gate file**: GATES/intent-complete.json with real question + success criteria + cheapest falsification. Without this file, CONJECTURE is blocked.

### CONJECTURE (after Research Intent + First Principles Audit)

**Strong Inference: >=3 competing hypotheses. Never single-hypothesis mode. (Platt 1964)**
**Conjectures are DERIVED through dialectic, not brainstormed then filtered.**

Step 0: Read Ignorance Map + The Skeleton (fundamental vs imposed). Conjectures MUST target imposed constraints and Ignorance Map gaps. If it doesn't address a specific gap (G-N), it's a side quest.

Step 1: **Derive conjectures via /collab** -- NOT independent proposals.
Run a /collab session with this shared context:
- The 7 Landscape Completeness answers (from GATES/landscape-complete.json)
- The Skeleton: fundamental vs imposed constraints (from GATES/audit-complete.json)
- The Ignorance Map: structured gaps the field hasn't resolved
- The Research Intent: what we're actually trying to discover

Assign /collab roles:
- **Gemini (Epistemologist)**: "Given this landscape and these imposed constraints, what is the question the field SHOULD be asking but hasn't formalized? What gap, if resolved, would move the entire field forward? Derive from the gaps, don't invent."
- **Codex (Experimenter)**: "Given these imposed constraints and dead ends, what hypothesis is testable with our tools (available GPUs, available models)? What specific prediction distinguishes each candidate? If we can't design a kill experiment, the conjecture is decorative."
- **Claude subagent (Adversary)**: "Attack each emerging conjecture. Is it hard-to-vary (Deutsch)? Can you swap details and still explain the same observations? Is it genuinely novel or a restatement of known work under new terminology? Search alphaxiv + WebSearch to check."

The /collab dialectic runs 2-5 rounds until convergence. The conjecture EMERGES from the dialectic -- it is NOT pre-formed by any single model. What all three converge on after pressure-testing = the real question. Disagreement after 3 rounds = the tension itself is informative and may be the actual research question.

Step 2: **Formalize the emerged conjecture(s).**
For each conjecture that survived the dialectic:
- Formal statement (falsifiable, specific)
- Kill criterion (measurable, unambiguous -- what result kills it?)
- Target gap (which Ignorance Map entry G-N does this address?)
- Distinguishing prediction (what does this predict that competing conjectures DON'T?)
- Cheapest kill experiment (Level 0-1 from Validation Hierarchy)

Step 3: **Literature ground-truth.** Search alphaxiv + WebSearch for each formalized conjecture.
Already resolved -> absorb the result, mark CONFIRMED or KILLED with citation. Don't re-test.
Partially addressed -> identify what remains genuinely open.
Only conjectures with genuine uncertainty proceed.

Step 4: **Ensure Strong Inference.** After Steps 1-3, verify:
- >=3 conjectures tracked (ACTIVE + recently KILLED/REVISED)
- At least 2 are mutually exclusive (an experiment can distinguish them)
- No experiment where all conjectures predict the same outcome (FORBIDDEN -- generates no information)
If <3 conjectures: the /collab dialectic missed possibilities. Run another round with: "We have only {N} conjectures. What alternative explanation fits the same observations but makes DIFFERENT predictions?"

Step 5: Write to CONJECTURES.md. Pre-register predictions for first experiments.
Rule: max 2 ACTIVE at once. But >=3 in the tracking system (including recently killed/revised).

**Write gate file**: GATES/conjectures-active.json with >=3 tracked hypotheses, each targeting an Ignorance Map gap, each with distinguishing predictions. Without this file, TEST is blocked.

### VALIDATION HIERARCHY (before full experiment)

Do NOT jump to full run. Escalate only when cheaper levels pass.

- **Level 0 -- Zero cost** (minutes): Does phenomenon exist in base/pretrained state? Can you observe the signal?
- **Level 1 -- Toy correctness** (~1h): Core mechanism on enumerable problem. Verify math against ground truth.
- **Level 2 -- Gradient stats** (minutes): One batch. Gradients finite? Norms reasonable? MC variance acceptable?
- **Level 3 -- Proxy scale** (2-4h): Tiny model, small data, few steps. Watch DYNAMICS (curves, not endpoints).
- **Level 4 -- Mechanistic probe** (4-8h): The one thing theory predicts that differs from baselines.
- **Full run** -- ONLY after all above pass. Confirms, doesn't discover.

Each level updates Knowledge Map. Level 0 catching a bad assumption > successful full run.

### TEST (iterations 5-30)

**Pre-registration (MANDATORY before every experiment):**
Write EXPERIMENTS/prediction-E{N}.json: { prediction, metric, threshold, analysis_plan }
`sha256sum EXPERIMENTS/prediction-E{N}.json >> EXPERIMENTS/prediction-E{N}.hash`
After experiment: mechanical comparison. Prediction matched? YES/NO. No LLM interpretation.

**PRE-EXPERIMENT REVIEW LOOP (iterative, not one-shot -- like /collab)**

Before ANY experiment touches a GPU, run an iterative review loop. Each round: agents review -> you fix -> agents re-review. Converge on clean, not hope for clean.

**Round 1: Initial review** -- spawn all three in parallel:

1. **Code Reviewer** (Agent tool, subagent_type: code-reviewer):
   "Review these experiment files for critical issues ONLY. Skip style.
   Files: {list all experiment code files}
   Checklist: (1) Correctness -- happy path, edge cases, hardcoded limits (token caps? dataset sizes? batch sizes? Are they adequate for the task?), NaN-producing paths, OOM risk on available GPU VRAM. (2) Bugs -- resource leaks, wrong gradient flow (detached tensors, frozen params), broken metrics (anything that could produce NaN/undefined). (3) Performance -- sequential when parallel possible, data bottlenecks. (4) Science correctness -- does code implement the ACTIVE conjecture (not a killed one)? Metric measures what we claim? Using methodology we already proved wrong?
   Format: [SEVERITY] file:line -- Issue / Why / Fix. Verdict: PASS or FAIL with issues."

2. **Codex adversarial** (Bash):
   "ADVERSARIAL EXPERIMENT REVIEW. Kill this before it wastes GPU hours.
   Design: {experiment}. Conjecture: {statement}. Config: {tokens, dataset, model, hardware}.
   Attack: (1) Will this discriminate true vs false? (2) Dataset adequate -- hard enough, large enough, 30-70% baseline? (3) Metrics valid -- can they NaN? Measuring what we claim? (4) Config sane -- token limits for task, VRAM fits, steps sufficient? (5) Methodology -- using ACTIVE conjecture or a KILLED one?
   Verdict: RUN / REFINE (state exact fixes) / KILL (state why)."

3. **Gemini adversarial** (Bash):
   "ADVERSARIAL REVIEW. Most likely way this produces UNINTERPRETABLE results? Cheapest version that tests the same thing? What would a NeurIPS reviewer reject? What hardcoded parameter is most likely wrong?
   Verdict: RUN / REFINE / KILL."

**After Round 1: Assess and fix.**
- Collect all findings. ANY critical issue or KILL -> fix the code/design.
- If all three say RUN with no critical findings -> proceed to smoke test.
- If fixes needed -> apply them, then:

**Round 2: Cross-pollinate and re-review (/collab dialectic).** Feed FIXED code + ALL Round 1 findings to each reviewer. They see each other's critiques:
- Code-reviewer sees Codex + Gemini findings. "They flagged {X}. Do you agree? Did the fixes introduce new issues?"
- Codex sees code-reviewer + Gemini findings. "Code reviewer found {bugs}. Gemini flagged {design issues}. Verify fixes. What's still wrong?"
- Gemini sees code-reviewer + Codex findings. "Code reviewer found {bugs}. Codex flagged {config issues}. Did fixes address everything? New problems?"

**Round 3 (if needed): Final convergence.**
- If Round 2 surfaces new issues -> fix and re-review one more time.
- Max 3 rounds. If still failing after 3 rounds -> experiment design is fundamentally flawed. Log as GATED OUT, PIVOT.

**Smoke Test (after review loop converges on PASS):**
Spawn a sub-agent to run a 2-step smoke test on the GPU cluster:
1. Run training for 2 steps (--max-steps=2)
2. Check: starts without error? Loss finite? All metrics collecting (no NaN, no zero, no undefined)?
3. Generation actually produces tokens to configured limit? Dataset has enough problems?
4. Report: HEALTHY / UNHEALTHY (list failures)
If UNHEALTHY -> fix, re-run smoke test. Do NOT proceed to full run with broken metrics.

Write all review rounds to EXPERIMENTS/review-E{N}/ -- this is the audit trail.

**Compute Maximization:**
- Independent experiments (e.g., GRPO vs TB vs SegTB on same dataset) -> submit ALL as parallel job scheduler (SLURM/etc) jobs simultaneously. Do NOT run sequentially.
- Use job scheduler (SLURM/etc) job arrays for parameter sweeps.
- While runs execute, prepare + swarm-review the NEXT experiment batch.
- Estimate VRAM/time BEFORE submission. Set job scheduler (SLURM/etc) limits accordingly.

**Run + Monitor (after swarm passes):**
1. Log final code + design in EXPERIMENTS/ BEFORE submitting
2. Submit job scheduler (SLURM/etc) job(s) -- parallel where independent
3. **Spawn monitoring sub-agent** (Agent tool, run_in_background: true): SSH to the GPU cluster, tail the output, check first 10 steps for NaN/divergence/OOM/throughput. Report HEALTHY or KILL with reason.
4. If monitoring agent reports KILL: cancel the job immediately. Diagnose. Fix. Re-swarm. Re-submit.
5. For long runs (>1h): monitoring agent checks at 25%/50%/75% completion.
6. Only after monitoring confirms healthy: record in experiment log as "monitored, healthy at step {N}".

### ANALYZE (after each TEST)

Cross-verify at confidence transitions (LOW->MEDIUM, MEDIUM->HIGH):

DEBATE("Results analyst", "{conjecture + experiment + raw data + interpretation}", "Data supports interpretation? Alternative explanations? Adequate sample? Confidence 0-100?")

Log in Cross-Verification Log. All agree -> proceed. 2v1 -> investigate disagreement. All disagree -> question may be ill-posed, DIG DEEPER.

### DECIDE (every iteration)

Explicit choice -- no drifting:

| Decision | When | Action |
|----------|------|--------|
| DOUBLE DOWN | Evidence supports, need more data | Next experiment, same conjecture |
| PIVOT | Kill criterion met or evidence against | Kill conjecture, generate new directions |
| DIG DEEPER | Ambiguous results | Return to SEARCH with refined questions |
| ABANDON | Direction exhausted | Mark KILLED, check all explored |

SPIN DETECTION:
- 3 consecutive failures: re-read sources. DEBATE: "Simplest untried thing?"
- 5 consecutive: invert assumptions. Ablate -- remove complexity, test what's actually needed.
- 8 consecutive: DEBATE: "Is the problem the hypothesis or the methodology?"
- 10 consecutive: ABANDON direction. All abandoned -> COMPLETION with honest "inconclusive."

On PIVOT: DEBATE("Direction finder", "{killed conjecture + kill reason + learnings}", "Next direction? What does failure reveal? 1-2 conjectures with kill criteria.")
Log in Decision Trail. Update TODO.md.

### FRESH-CONTEXT RESTART (every 15-20 iterations)

Context degrades: 60% facts lost per compression, middle evidence fades (RoPE decay), tool args degrade, agent anchors to stale conclusions.

When iteration count hits a restart boundary (15, 30, 45):
1. Verify all 6 output files are current and complete
2. Write RESTART-CONTEXT.md: current hypothesis, confidence, immediate next action, key unresolved questions
3. Signal: <promise>RESTART_CHECKPOINT: iter {N}</promise>
4. New context reads ONLY: RESEARCH-PROGRESS.md + KNOWLEDGE-MAP.md + CONJECTURES.md + TODO.md + RESTART-CONTEXT.md
5. Delete RESTART-CONTEXT.md after loading (one-time bridge)

Files carry state. Context doesn't need to.

### AUTO-EXIT CONDITIONS

Exit when ANY is true:
1. Conjecture CONFIRMED -- all 3 models agree (>80 confidence each), kill criterion survived, >=2 supporting experiments
2. All directions ABANDONED
3. Max iterations reached (default 50)
4. Diminishing returns -- 5 consecutive iterations with no new results or confidence change

On diminishing returns / max iter: document honestly what was learned, what's needed to continue, best current answer with honest confidence.

### COMPLETION

**Iterative /collab-style review before the user sees ANYTHING:**

1. Final document pass -- all 6 files complete and consistent. Write Summary in RESEARCH-PROGRESS.md.

2. **Round 1 -- Dispatch all 3 reviewers in parallel:**
   - Codex: "Review this research conclusion. Question: {q}. Answer: {conclusion}. Confidence: {N}. Key evidence: {summary}. Is it justified? Weakest claim? What would a skeptical reviewer reject? Grade A-F."
   - Gemini: "Adversarial review. What's wrong with this conclusion? What alternative explanation fits the same data? Is the confidence honest? What would make it stronger? Grade A-F."
   - Claude subagent: "You are a domain expert. Read RESEARCH-PROGRESS.md + KNOWLEDGE-MAP.md + EXPERIMENTS/experiment-log.md. Does the conclusion follow from the evidence? What's the most likely way this is WRONG? What experiment would I need to see to be convinced?"

3. **Fix every valid critique.** Revise RESEARCH-PROGRESS.md.

4. **Round 2 -- Cross-pollinate.** Feed revised document + ALL THREE Round 1 critiques to each reviewer. They see each other's findings and challenge each other (the /collab dialectic). "Codex said X. Gemini said Y. Claude said Z. Did my fixes address everything? Do you agree with the others?"

5. **Round 3 if needed.** Converge when all 3 say "ready to present."

6. ONLY THEN: If Obsidian vault, write Discovery note. Clean up: `rm -rf $WS`.
7. <promise>RESEARCH_COMPLETE</promise>

If stuck: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-50}" \
  --completion-promise "RESEARCH_COMPLETE" \
  "$(cat "$RALPH_PROMPT")"
rm -f "$RALPH_PROMPT"
```

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
echo "==============================================================="
echo "RESEARCH MODE -- Autonomous. Consult Codex/Gemini, never the user."
echo ""
echo "Anti-reward-hacking: 9 gates (fitness, knowledge map, falsification,"
echo "  re-injection, sacred kills, pre-registration, strong inference,"
echo "  negative parity, fresh-context restart)"
echo "Promise: RESEARCH_COMPLETE"
echo "==============================================================="
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
- Negative results: {N} (if 0: explain why -- zero negatives is suspicious)
```
