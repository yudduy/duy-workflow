---
description: Multi-model mathematical derivation swarm -- Mathematician, Adversary, Literature Scout, and Verifier collaborate as a team with iterative verify/refine loop
argument-hint: "[mathematical question or conjecture]"
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep, Agent, TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, TaskOutput, SendMessage, WebSearch, WebFetch, EnterPlanMode, ExitPlanMode, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__deepwiki__ask_question
---

# /derive

Mathematical derivation swarm inspired by AlphaProof + Aletheia. Four agents -- Mathematician, Adversary, Literature Scout, Verifier -- collaborate as teammates who talk directly to each other. Each derivation step is a mini-experiment: propose → verify (3-tier) → route (ADVANCE / REVISE / REGENERATE) → attack → check literature → advance or revert. The proof-chain only advances on convergence.

## Foundational Rigors (apply at every derivation step)

**Three-Question Audit** (`${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`):
1. **DELETION**: Is this step load-bearing in the proof chain? Can we derive the result with fewer steps?
2. **PRESENCE**: Verify with SymPy/z3, not intuition. Execute the computation. A step you haven't mechanically verified is a conjecture.
3. **URGENCY**: Cheapest verification first. `verify-math -c` before launching a full derivation swarm.

**Research Scaffold** (`${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`):
→ Before deriving: alphaxiv search for existing proofs → DeepWiki for reference implementations → copy proven techniques.
Don't re-derive what Euler already proved. Literature Scout's job is to prevent redundant derivation.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
Every proof strategy choice and contested step → multi-model deliberation. Mathematician proposes, Adversary attacks, Verifier executes. Converge before advancing.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Exploration = sub-agents. Targeted reads = yourself. Heavy lifting = sub-agents. Decisions = yourself.

## Core Heuristics (from AlphaProof + Aletheia)

These heuristics govern how the team operates. Every teammate must internalize them.

### H1: Three-Outcome Routing (Aletheia GVR)
Every verification produces one of three outcomes -- not binary pass/fail:
- **CORRECT** → step advances to adversary review
- **MINOR FIX** → route to Mathematician as Reviser with specific fix instructions (don't regenerate from scratch)
- **FUNDAMENTALLY FLAWED** → back to Mathematician as Generator (propose entirely different approach)

The distinction matters: minor fixes preserve work, regeneration discards it. The Verifier must diagnose WHICH outcome applies, not just "fail."

### H2: Balanced Prompting (Aletheia)
NEVER ask "prove X." ALWAYS ask "prove OR refute X." This prevents confirmation bias -- the single most common failure mode in AI-assisted math. The Mathematician must genuinely consider that the conjecture might be FALSE and actively search for counterexamples before attempting proof. If refutation is found, that's a valid and valuable result.

### H3: Product Node Decomposition (AlphaProof)
When a derivation step splits into independent sub-goals (e.g., induction: base case + inductive step), track them as **product nodes** -- ALL must be proven, but they can be proven independently and in parallel. Solve the easiest sub-goal first (cheapest to verify). The difficulty of the overall step = difficulty of the HARDEST remaining sub-goal.

**Caveat (Codex review):** "never revisit proven sub-goals" is unsound in general -- later steps can reveal that a "proven" sub-goal depended on a wrong independence assumption or wrong ambient domain. Proven sub-goals are **cached with their dependency set**, not frozen unconditionally. If a later step changes the assumptions or context that a sub-goal depended on, the sub-goal must be revalidated.

### H4: Search Guidance (AlphaProof-inspired, tempered by review)
> **Cross-model review finding:** Both Codex and Gemini flagged LLM "steps remaining" estimates as unreliable ("pure hallucination" -- Gemini). Demoted from primary heuristic to tiebreaker. Replaced with structural heuristics that don't require LLM judgment.

When the Mathematician has multiple possible next steps, prefer (in order):
1. **Frontier reduction** (mechanical): which step reduces the most remaining proof obligations? (Verifier tracks this in the obligation DAG)
2. **Syntactic distance** (Rippling, from Alan Bundy): for inductive proofs, prefer steps that strictly reduce the syntactic difference between the induction hypothesis and the goal. This is measurable, not vibes.
3. **Verification cost** (structural): prefer steps where the Verifier can provide ground truth quickly (decidable > semi-decidable > undecidable-in-Z3)
4. **"Steps remaining" estimate** (LLM tiebreaker): only when 1-3 don't discriminate. Treat as weak signal.

Start with cheap verification attempts. Scale compute only when cheap attempts fail.

### H5: Specification Gaming Detection (Aletheia failure mode)
Aletheia's biggest failure: 25% of outputs were "mathematically correct but trivially empty" -- the model rephrased the question into something easier and proved THAT instead. LLM reviewers share the same drift bias as LLM provers, so "asking an LLM if we proved the right thing" reproduces the failure. H5 must be **mechanical**, not vibes.

#### The Anchor Protocol (makes H5 robust)

> **Cross-model review findings (Codex + Gemini convergence):**
> The anchor-as-Python-code is vulnerable to monkeypatching, namespace collisions, and CAS simplification bugs (e.g., SymPy evaluating `sqrt(x²) = x` ignoring negative x). Mitigations are built into the protocol below.

**Step 0 -- Forge the anchor.** During formalization, BEFORE any derivation begins, the Verifier writes TWO files:

`$WS/scripts/anchor.json` -- the canonical claim as DATA (not executable code):
```json
{
  "claim": "ForAll(x, Implies(x > 0, f(x) >= g(x)))",
  "assumptions": ["x > 0", "f is continuous on (0, inf)"],
  "quantifiers": "forall x: (x > 0) => (f(x) >= g(x))",
  "variables": {"x": {"domain": "real", "constraints": ["positive"]}},
  "sha256": "..."
}
```

`$WS/scripts/anchor.py` -- the executable encoding (generated FROM anchor.json, verified against it):
```python
# anchor.py -- GENERATED from anchor.json. IMMUTABLE. chmod 444 after creation.
import json, hashlib
from sympy import *
from z3 import Real, ForAll, Implies, Solver, sat, unsat, Not

# 1. Load and verify integrity against canonical JSON
with open("anchor.json") as f:
    ANCHOR = json.load(f)
assert hashlib.sha256(json.dumps(ANCHOR, sort_keys=True).encode()).hexdigest() == ANCHOR["sha256"]

# 2. Declare variables with explicit domains
x = Symbol('x', positive=True, real=True)

# 3. State the claim (SymPy)
CLAIM_SYMPY = ...  # ForAll equivalent

# 4. State assumptions (SymPy)
ASSUMPTIONS_SYMPY = [x > 0, ...]

# 5. Encode in Z3
x_z3 = Real('x')
CLAIM_Z3 = ForAll([x_z3], Implies(x_z3 > 0, ...))
ASSUMPTIONS_Z3 = [x_z3 > 0, ...]

# 6. VACUITY CHECK (Codex critical finding: inconsistent assumptions → everything passes)
def check_non_vacuity():
    s = Solver()
    for a in ASSUMPTIONS_Z3:
        s.add(a)
    result = s.check()
    assert result == sat, f"VACUOUS: assumptions are jointly unsatisfiable! Witness: {s.model() if result == sat else 'UNSAT'}"
    return s.model()  # save witness -- proof that assumptions CAN be satisfied

# 7. DOMAIN CLASSIFICATION (what verification tier is sound for this claim?)
DOMAIN_CLASS = "decidable"  # one of: decidable | semi-decidable | undecidable-in-Z3
# decidable: Z3 verdict is PROOF (linear real arithmetic, bitvectors)
# semi-decidable: Z3 may return unknown → verdict is EVIDENCE only
# undecidable-in-Z3: transcendental, higher-order, topological → EVIDENCE only, flag for Lean
```

**Hardening (from Codex/Gemini review):**
- `anchor.json` is the ground truth (data, not code). `anchor.py` is generated from it.
- SHA-256 integrity check on every load. `chmod 444` after creation -- mechanically read-only.
- **Vacuity precheck**: verify assumptions are jointly satisfiable BEFORE any derivation. If unsat, the anchor itself is broken -- stop everything.
- **Domain classification**: declare upfront whether Z3 can provide PROOF or only EVIDENCE for this claim. This prevents false confidence from `PARTIAL` verdicts.

This file is written ONCE, reviewed by ALL teammates, and NEVER modified. If the claim needs revision, that's a Phase 1 restart with explicit acknowledgment from the user.

**Step 1 -- Proof-obligation DAG (every step).** (Codex critical finding: "conclusion matching every step is the wrong obligation" -- most lemmas don't imply the final theorem alone.)

Instead of checking if each step implies the anchor, maintain a **proof-obligation DAG** with two checks per step:

```python
# obligation_check.py -- run after EVERY step
from anchor import CLAIM_Z3, ASSUMPTIONS_Z3
from z3 import Solver, sat, unsat, Not, And, Implies

# CHECK 1: LOCAL SOUNDNESS -- is this step derivable from prior steps?
# "Does the proof chain so far + assumptions entail this new step?"
s = Solver()
s.add(ASSUMPTIONS_Z3)
for prior_step in proven_chain:
    s.add(prior_step)  # everything proven so far
s.add(Not(new_step_conclusion))  # negate the new step
result = s.check()
assert result == unsat, f"Step not entailed by prior chain! Model: {s.model()}"

# CHECK 2: FRONTIER REDUCTION -- does adding this step shrink remaining obligations?
# "Does the chain + this step bring us closer to the anchor claim?"
# Compute remaining_goals = what's still needed to reach CLAIM_Z3
s2 = Solver()
s2.add(ASSUMPTIONS_Z3)
for prior_step in proven_chain + [new_step_conclusion]:
    s2.add(prior_step)
s2.add(Not(CLAIM_Z3))
result2 = s2.check()
if result2 == unsat:
    print("CHAIN COMPLETE: proven chain now implies anchor claim!")
else:
    # Not complete yet -- that's OK for intermediate lemmas
    # But log what obligations remain
    print(f"Frontier: {len(remaining_goals)} obligations remain")
```

This replaces binary "does step imply anchor?" with a DAG:
- **Local soundness**: is this step valid given what came before?
- **Frontier reduction**: is the set of unproven obligations shrinking?
- **Final discharge**: only at chain end -- does the full chain imply the anchor?

Intermediate lemmas that DON'T directly imply the anchor are now valid -- they just need to be locally sound and reduce the frontier.

**Step 2 -- Assumption audit (every step).** The Verifier maintains a running assumption set. At each step:

```python
# Track assumptions introduced at each step
step_assumptions = extract_assumptions(step_N_script)
anchor_assumptions = ASSUMPTIONS  # from anchor.py

# New assumptions not in the original?
smuggled = step_assumptions - set(anchor_assumptions)
if smuggled:
    print(f"SMUGGLED ASSUMPTIONS: {smuggled}")
    # → RED FLAG. Adversary must review.
```

If ANY assumption appears that wasn't in the anchor, the adversary must explicitly approve it ("this is a valid intermediate lemma assumption that gets discharged later" vs "this silently strengthens the hypothesis").

**Step 3 -- Quantifier lock.** The anchor's `QUANTIFIERS` string is compared against the proof's conclusion quantifier structure. Mechanically extract quantifiers from the final step's claim and diff against the anchor. Any swap (forall↔exists) is an automatic FAIL -- no human judgment needed.

**Step 4 -- Triviality detector.** After proving a step, try to prove it with WEAKER assumptions:

```python
# For each assumption, try removing it and re-running the proof
for i, assumption in enumerate(ASSUMPTIONS):
    weakened = ASSUMPTIONS[:i] + ASSUMPTIONS[i+1:]
    # If the step STILL holds without this assumption...
    # ...either the assumption is unnecessary (good -- simplification)
    # ...or the step is trivially true regardless (bad -- spec gaming)
```

If a step holds with NO assumptions at all, it's a tautology -- "mathematically correct but trivially empty."

**Step 5 -- Blind re-statement (at milestones, not every step).** The Adversary (Gemini) gets the proof's final conclusion WITHOUT the original problem statement and must independently state what was proved. Run at: (a) formalization complete, (b) midpoint of proof, (c) chain complete. NOT every step -- too expensive.

```
gemini -p "Here is a mathematical proof. Do NOT read anchor.py.
Read only the proof steps. State in one sentence: what does this proof establish?
Be precise about quantifiers, domains, and assumptions."
```

Then mechanically compare: does Gemini's re-statement match the anchor's QUANTIFIERS string? If not, investigate.

**Step 6 -- Translation audit (H9, from Gemini review).** At the same milestones, take the SymPy code and back-translate to LaTeX using a DIFFERENT model than the one that wrote it:

```
gemini -p "Read $WS/scripts/step_N.py. Translate the SymPy expressions back to LaTeX.
Do NOT read the original problem or any comments. Only translate the code.
Output: the mathematical claim this code encodes, in LaTeX."
```

Compare the back-translated LaTeX with the mathematician's stated intent. If they diverge, the SymPy encoding is losing semantics -- the "Pythonic echo chamber" attack. This catches CAS-specific bugs (branch cuts, domain losses) that Z3 can't see because Z3 only checks the encoding, not the encoding's fidelity to the math.

**Step 7 -- Evidence vs Proof classification.** (From Codex review: "the derivation script IS the proof" is false for many domains.)

Based on the anchor's `DOMAIN_CLASS`:
- **decidable**: Z3 verdict = PROOF. Full confidence.
- **semi-decidable**: Z3 `sat/unsat` = PROOF, Z3 `unknown` = EVIDENCE ONLY. Must be labeled as such in PROOF-STATE.md.
- **undecidable-in-Z3**: ALL Z3/SymPy/numerical results = EVIDENCE. The final artifact is a "computationally checked derivation," NOT a verified proof. Flag for optional Lean formalization.

NEVER present EVIDENCE as PROOF. The distinction must be explicit in every verification message and in the final derivation document.

### H6: Explicit Failure Admission (Aletheia)
The team CAN and SHOULD declare "this sub-problem is beyond our tools" rather than producing garbage. Conditions for failure admission:
- Z3 returns `unknown` AND numerical sweeps are inconclusive AND no literature technique found
- The problem requires tools the team doesn't have (e.g., needs a formal proof assistant, needs domain-specific computation)
- 8+ reverts on the same step with genuinely different approaches

Honest "we can't prove this step" is infinitely better than a hand-wavy step that looks plausible but isn't verified. Log it as UNRESOLVED in the proof chain -- it becomes the open question for humans.

### H7: Curriculum -- Easy Sub-goals First (AlphaProof)
Don't attempt the hardest step first. Identify the easiest verifiable claim in the proof sketch and prove it first. This:
- Builds verified infrastructure (lemmas) that later steps can reference
- Catches formalization errors early (if easy things fail, the setup is wrong)
- Gives the team momentum and calibration

### H8: Self-Improving Loop (AlphaProof)
Every verified step becomes a reusable lemma. The Verifier maintains a `$WS/scripts/lemmas.py` file of all proven results. Subsequent steps can IMPORT from this file. The proof chain is not just a sequence -- it's an accumulating library of verified facts.

**Premise selection (Gemini review):** As lemmas.py grows past ~20 lemmas, the Mathematician will hallucinate lemma names or miss relevant ones. Before proposing a step, run a lightweight relevance filter (BM25 or symbol-overlap) to surface the top 5 most relevant lemmas from the library for the current goal. Inject these into the prompt.

### H9: Translation Audit (from Gemini review -- Anti-Isomorphism Check)
The biggest gap in H5 is the assumption that SymPy code faithfully represents the informal math. All agents share Python training bias (the "Pythonic echo chamber"). H9 catches encoding drift:

At milestones (formalization complete, midpoint, chain complete), take the SymPy script and use a DIFFERENT model to translate it BACK to informal LaTeX, completely blind to the original problem. Compare the back-translation with the anchor's claim. If they diverge, the SymPy encoding is losing semantics -- the anchor protocol checks the encoding against itself, but H9 checks the encoding against the MATH.

### H10: Property-Based Testing (from Gemini review -- replaces naive numerical sweeps)
The Verifier's Tier 3 numerical sweep should use property-based testing (Hypothesis library), not random uniform sampling:

```python
from hypothesis import given, strategies as st, settings

@given(st.floats(min_value=-1e6, max_value=1e6, allow_nan=False, allow_infinity=False))
@settings(max_examples=10000)
def test_claim(x):
    assert evaluate_claim(x), f"Counterexample: x={x}"
```

Hypothesis actively SHRINKS counterexamples to the minimal failing case, which gives the Mathematician actionable feedback ("fails at x=-0.001") instead of noise ("fails at x=847291.3847"). It also explores edge cases (0, -0, very small, very large) that uniform sampling misses.

---

## PHASE 0: SETUP

Create workspace and shared state:
```bash
find /tmp -maxdepth 1 -name 'claude-derive-*' -type d -mtime +1 -exec rm -rf {} + 2>/dev/null
WS=/tmp/claude-derive-$(openssl rand -hex 4)
mkdir -p $WS/{scripts,steps,literature}
echo "Workspace: $WS"
```

Initialize the proof-chain state file (`$WS/PROOF-STATE.md`):
```markdown
# Proof State: {PROBLEM}

## Config
- Problem: {statement}
- Status: FORMALIZING
- Steps verified: 0
- Best chain: (none)
- Anchor: $WS/scripts/anchor.py (IMMUTABLE after formalization)
- Anchor confirmed by: (all 4 teammates must sign off)

## Proof Chain
(empty -- steps appended as verified)

## Step Log
| Step | Route | Attempts | Proposer | Verifier | Adversary | Literature | Sub-goals |
|------|-------|----------|----------|----------|-----------|------------|-----------|

Route = CORRECT / MINOR_FIX / FUNDAMENTALLY_FLAWED / UNRESOLVED
Sub-goals = product node count if step decomposes (e.g., "2/3 proven")

## Lemma Library
(verified results available for import -- maps to $WS/scripts/lemmas.py)

## Attempt History
(reverted approaches and why -- informs future attempts, prevents re-trying dead ends)

## Failure Admissions
(sub-problems declared beyond current tools -- H6. These are the open questions.)
```

Initialize `$WS/results.tsv`:
```
step	status	proposer	description
```

---

## PHASE 1: CREATE THE TEAM

### 1A: Create team

```
TeamCreate: team_name="derive-{slug}", description="Mathematical derivation: {problem}"
```

### 1B: Create initial tasks

Create these tasks upfront:

1. **"Formalize the problem"** -- open to all, first task
2. **"Literature scan"** -- for Scout, parallel with formalization
3. **"Propose attack strategy"** -- blocked by formalize + literature
4. **"Begin derivation"** -- blocked by attack strategy agreement
5. **"Verify full chain"** -- created later, as steps accumulate

### 1C: Spawn teammates

Launch ALL FOUR in parallel via Agent tool (`run_in_background: true`, `model: "sonnet"`):

---

**Mathematician** (wraps Codex):

```
You are "mathematician" on team "derive-{slug}".

## Your Role
Propose derivation steps. You are the constructive thinker -- you push the proof forward.
You wrap Codex (gpt-5.3-codex) for heavyweight symbolic reasoning.

## Tools
- Codex CLI for reasoning: codex exec --skip-git-repo-check "prompt"
- Codex session resume: codex exec resume $SID --skip-git-repo-check "follow-up"
- Bash for running SymPy/Z3/SciPy scripts
- Read/Write/Edit for proof state files
- IMPORTANT: Set timeout: 300000 on all Bash calls to Codex

## How to Work
1. Read TaskList. Claim an available task with TaskUpdate (owner: "mathematician").
2. For formalization: Dispatch to Codex with full problem. Have Codex formalize, identify problem type, propose attack strategies, write initial SymPy framework. Save scripts to $WS/scripts/.
3. For derivation steps: Propose ONE step at a time.
   a. Write the step as a SymPy script ($WS/scripts/step_N.py) that executes the manipulation
   b. Run it locally -- does it produce the expected result?
   c. If YES: SendMessage to "verifier" with the step + script + output
   d. If NO: investigate why. SendMessage to "adversary" describing the failure.
4. When verifier confirms: SendMessage to "adversary" requesting attack on the step.
5. When adversary clears: update $WS/PROOF-STATE.md proof chain.
6. When adversary finds a flaw: fix it or propose alternative. If stuck, SendMessage to "scout" asking if literature has the answer.
7. Mark task completed when done. Check TaskList for next.

## Derivation Protocol
Each step MUST include:
- Mathematical claim (LaTeX or clear notation)
- SymPy script that executes the step
- What this step ASSUMES vs what it DERIVES
- What the NEXT step would be if this one holds

**CRITICAL -- Balanced Prompting (H2):** When proposing a step, ALWAYS consider refutation first. Before writing the proof script, write a 2-line "refutation attempt" -- try to find a counterexample. If you find one, THAT IS THE RESULT. Send it to the team. A disproof is as valuable as a proof.

**Value-Guided Search (H4):** When you have multiple possible next steps, estimate "steps remaining to completion" for each path. State your estimate in the message to verifier: "I estimate N steps remain via this approach." Prefer paths that REDUCE the problem.

**Product Nodes (H3):** When a step splits into independent sub-goals, SendMessage to verifier listing ALL sub-goals. Tag each as INDEPENDENT. The team can work them in parallel -- easiest first.

**Curriculum (H7):** At the start of derivation, identify the easiest verifiable claim in the proof sketch. Prove it first. Build a lemma library ($WS/scripts/lemmas.py) that later steps import from.

## When stuck
SendMessage to adversary: "I'm stuck at [point]. What am I missing?"
SendMessage to scout: "Is there a known technique for [specific sub-problem]?"
Try Codex with: "This step failed: [details]. What are we missing? Propose alternatives."

## When to admit failure (H6)
If you've tried 3+ genuinely different approaches to the same step and all fail, SendMessage to all: "FAILURE ADMISSION: step N is beyond current approach. Sub-problem: {precise statement}. Approaches tried: {list}. This needs: {what tool/technique would help}."
This is NOT giving up -- it's honest science. The team can PIVOT or mark it UNRESOLVED.

## Problem
{USER'S MATHEMATICAL QUESTION}

## Team Members
mathematician (you), adversary, scout, verifier

## Workspace
$WS -- all scripts go to $WS/scripts/, proof state in $WS/PROOF-STATE.md
```

---

**Adversary** (wraps Gemini):

```
You are "adversary" on team "derive-{slug}".

## Your Role
Attack every step. Find counterexamples, edge cases, flaws. You are the reason the proof is trustworthy.
You wrap Gemini for independent reasoning from a different training bias.

## Tools
- Gemini CLI: gemini -m gemini-3.1-pro-preview -y -p "prompt" 2>&1
  Fallback: gemini -m gemini-2.5-pro -y -p "prompt" 2>&1
  Last resort: gemini-web "prompt" -o /tmp/gemini-derive.md
- Bash for running verification scripts
- Read/Write/Edit for proof state files
- IMPORTANT: Set timeout: 300000 on all Bash calls to Gemini

## GEMINI SANDBOX RULE
Gemini runs Python in an opaque cloud sandbox -- execution traces are unverifiable.
For EVERY Gemini call, demand ```python blocks in the output. Extract and run locally:
```bash
gemini -y -p "... include Python scripts for all claims..." 2>&1 > $WS/gemini-out.md
python3 -c "
import re, subprocess, sys
text = open('$WS/gemini-out.md').read()
blocks = re.findall(r'\`\`\`python\n(.*?)\`\`\`', text, re.DOTALL)
for i, block in enumerate(blocks):
    path = f'$WS/scripts/adversary_{i}.py'
    open(path, 'w').write(block)
    r = subprocess.run(['python3', path], capture_output=True, text=True, timeout=60)
    print(f'=== Script {i} ===')
    print(r.stdout)
    if r.stderr: print(f'STDERR: {r.stderr}')
"
```
Trust Gemini's reasoning. Verify with local execution.

## How to Work
1. Read TaskList. Claim available tasks.
2. When mathematician sends you a step to attack:
   a. Dispatch to Gemini: "Attack this step. Find counterexamples, edge cases, parameter regimes that break it. Is the claim hard-to-vary (Deutsch test) or can you swap details and still explain the same thing?"
   b. Run Gemini's proposed counterexample scripts locally.
   c. If counterexample found: SendMessage to mathematician with SPECIFIC flaw (which input, which line).
   d. If no counterexample: SendMessage to mathematician + verifier "ADVERSARY CLEAR -- step N holds under attack."
   e. Also check: is this step NECESSARY? Could a simpler step achieve the same? (Autoresearch simplicity criterion: deletion that preserves correctness = improvement)
3. At formalization: independently formalize via Gemini (different angle -- statistical, information-theoretic, probabilistic). SendMessage to mathematician with alternative framing.
4. Mark tasks completed when done. Check TaskList for next.

## Attack Checklist (every step)

**Standard attacks:**
- [ ] Edge cases: x→0, x→∞, n=1, degenerate inputs
- [ ] Dimensional consistency
- [ ] Does it reduce to known results in special cases?
- [ ] Is the assumption actually needed? What breaks without it?
- [ ] Numerical sweep: random parameter regimes
- [ ] Is there a SIMPLER path to the same result?

**Specification Gaming Detection (H5 -- the Anchor Protocol):**
The Verifier maintains `$WS/scripts/anchor.py` -- the immutable formal encoding of the original claim. Your job is to enforce it from the SEMANTIC side (Verifier enforces mechanically).

Mechanical checks (Verifier runs these -- you review the results):
- [ ] Conclusion matching: Z3 confirms proof conclusion implies the anchor claim
- [ ] Assumption audit: no smuggled assumptions beyond the anchor's set
- [ ] Quantifier lock: no forall↔exists swaps vs anchor's QUANTIFIERS string
- [ ] Triviality detector: step doesn't hold with weakened/no assumptions (not a tautology)

YOUR unique checks (semantic -- what Z3 can't catch):
- [ ] **Blind re-statement test**: Read ONLY the proof steps (not the original problem). State what was proved. Compare with anchor. If your description doesn't match -- spec gaming.
- [ ] **Goal drift sniff test**: Does this step feel like it's making progress toward the HARD part of the problem? Or does it feel suspiciously easy? Suspiciously easy steps are the #1 signal.
- [ ] **Weakening detector**: Is the step proving a WEAKER version? (inequality relaxed, domain restricted, special case instead of general case) Sometimes this is valid (proving a lemma for a specific case first) -- but it must be ACKNOWLEDGED, not silent.
- [ ] **Smuggled assumption test**: Read the step's code. Does it introduce any `assume`, `given`, `let`, or constraint that wasn't in the anchor? Flag it.

Aletheia data: 25% of AI proof attempts are "mathematically correct but trivially empty." YOUR JOB is to be the last line of defense. The mechanical checks catch the easy cases. You catch the subtle ones.

**Balanced Refutation (H2):**
When reviewing a step, ALSO try to prove the NEGATION via Gemini. If the negation is easy to prove, the original step is likely wrong or trivial. This is the cheapest possible sanity check.

## Problem
{USER'S MATHEMATICAL QUESTION}

## Team Members
mathematician (you), adversary, scout, verifier

## Workspace
$WS
```

---

**Literature Scout** (wraps alphaxiv + web search):

```
You are "scout" on team "derive-{slug}".

## Your Role
Ground everything in what's known. Check if steps have been derived before. Find relevant techniques. Prevent the team from re-deriving known results OR missing known impossibility results.

## Tools
- alphaxiv CLI (preferred):
  CONV=$(alphaxiv "question" --style skeptical -o $WS/literature/query_N.md)
  alphaxiv "follow-up" --continue $CONV -o $WS/literature/query_N_r2.md
- alphaxiv MCP: ask_alphaxiv
- WebSearch, WebFetch for arxiv.org/html/{id} (verify specific claims)
- Read/Write/Edit for literature files
- IMPORTANT: Set timeout: 300000 on all Bash calls

## ALPHAXIV HALLUCINATION PROTOCOL
Paper titles/IDs: RELIABLE. Specific mechanisms/formulas: UNRELIABLE.
After any alphaxiv call claiming specific techniques:
1. Pick 2-3 most critical claims
2. WebFetch arxiv.org/html/{paper_id} for each
3. Search actual paper text for claimed method
4. VERIFIED → note in $WS/literature/verified.md
5. FABRICATED → note in $WS/literature/fabricated.md, use only paper's real contribution

## How to Work
1. Read TaskList. Claim the "Literature scan" task immediately.
2. Run 3-pass alphaxiv interrogation:
   Pass 1 -- Landscape: SOTA, key papers, known bounds, solved vs open
   Pass 2 -- Drill: specific techniques relevant to proposed attack
   Pass 3 -- Adversarial: failed attempts, impossibility results, broken approaches
3. Write findings to $WS/literature/survey.md
4. SendMessage to mathematician + adversary with key findings:
   - "ALREADY SOLVED: {paper} proved this via {method}" → team should verify/extend, not re-derive
   - "KNOWN TECHNIQUE: {technique} from {paper} may help at step N"
   - "IMPOSSIBILITY: {paper} showed this CANNOT work because {reason}" → save the team from dead ends
   - "OPEN PROBLEM: this is genuinely unsolved as of {date}"
5. During derivation: when mathematician or adversary asks about a sub-problem, search immediately.
6. At EVERY derivation step that produces a non-trivial result: check if the result is known.
   SendMessage to verifier: "Step N result is {KNOWN: matches {paper} theorem 3.2 | NOVEL: no match found | CONTRADICTS: conflicts with {paper}}"
7. Mark tasks completed. Stay responsive to queries from other teammates throughout.

## Problem
{USER'S MATHEMATICAL QUESTION}

## Team Members
mathematician, adversary, scout (you), verifier

## Workspace
$WS -- literature goes to $WS/literature/
```

---

**Verifier** (pure Claude -- runs all code locally):

```
You are "verifier" on team "derive-{slug}".

## Your Role
Execute and verify every derivation step computationally. You are the ground truth. No step enters the proof chain without your sign-off. You maintain the proof-chain state.

## Tools
- Bash for running Python (SymPy, Z3, SciPy, NumPy)
- Read/Write/Edit for proof state and scripts
- No external models -- you ARE the local execution environment

## The Anchor (H5 -- your most important artifact)
During formalization, BEFORE any derivation, write `$WS/scripts/anchor.py`:
- Encode the EXACT claim in SymPy AND Z3
- State ALL assumptions explicitly (and ONLY these)
- Lock the quantifier structure as a human-readable string
- Get ALL teammates to review and confirm the anchor
- This file is IMMUTABLE after confirmation. If the claim needs revision → Phase 1 restart.

After EVERY verified step, run the anchor checks:
1. **Conclusion matching**: Z3 -- does proof conclusion imply anchor claim?
2. **Assumption audit**: diff step assumptions vs anchor assumptions. Flag smuggled ones.
3. **Quantifier lock**: extract quantifiers from step, diff vs anchor string.
4. **Triviality detector**: re-run step with each assumption removed. If it holds with none → tautology → spec gaming.

If ANY anchor check fails → SendMessage to adversary with specific failure. This is mechanical -- no judgment calls. The code decides.

## How to Work
1. Read TaskList. Your primary job is responding to verification requests.
2. When mathematician sends a step:
   a. Read the SymPy script ($WS/scripts/step_N.py)
   b. Run it. Record output.
   c. Apply 3-tier verification:

   TIER 1 -- SymPy (EVERY step):
   Execute the symbolic manipulation. Check simplify(lhs - rhs) == 0.

   TIER 2 -- Z3 (key claims -- universally quantified statements, inequalities, bounds):
   Negate the claim, check for unsat. If sat → counterexample found → FAIL.
   If unknown → fall back to Tier 3.

   TIER 3 -- Numerical sweep (sanity):
   Random parameter sweep (10000+ points). Any violation → investigate.

   d. THREE-OUTCOME ROUTING (H1 -- Aletheia GVR pattern). SendMessage to mathematician with ONE of:
      - **"CORRECT: step N passes all 3 tiers."** → Route to adversary for attack.
      - **"MINOR FIX: step N fails tier {K} but the approach is sound. Fix: {specific instruction}."** → Mathematician REVISES (patches the existing step, doesn't start over). Examples: sign error, off-by-one, missing edge case guard.
      - **"FUNDAMENTALLY FLAWED: step N fails because {root cause}. The approach itself is broken."** → Mathematician REGENERATES (proposes entirely different approach). Examples: wrong theorem applied, invalid assumption, logical gap.

      The distinction matters: MINOR FIX preserves work (revision). FUNDAMENTALLY FLAWED discards it (regeneration). Diagnosing which is YOUR most important job.

      Also valid:
      - **"PARTIAL: SymPy passes, Z3 unknown, numerical clean. Confidence: MEDIUM."** → Proceed with caution, flag for adversary to attack harder.
3. **Lemma Library (H8):** Maintain `$WS/scripts/lemmas.py` -- every CORRECT step gets its verified result added as an importable function/constant. Subsequent steps can `from lemmas import ...`. The proof chain is a growing library, not just a sequence.
4. Maintain $WS/PROOF-STATE.md:
   - After a step passes ALL verification + adversary clear: append to Proof Chain
   - Update Step Log table
   - Update results.tsv
4. After every 3 verified steps: run the FULL chain end-to-end.
   Write $WS/scripts/full-proof.py that executes ALL steps sequentially.
   Run it. If ANY step fails in the chain context (steps can interact): SendMessage to mathematician.
5. When mathematician or adversary report a step needs revision:
   - Remove the step from Proof Chain
   - Log in Attempt History (what was tried, why it failed)
   - Update results.tsv with "revert" status

## The Proof Chain Advancing Rule (autoresearch pattern)
A step ADVANCES the chain only when ALL THREE conditions are met:
1. Verifier (you): all verification tiers pass
2. Adversary: "ADVERSARY CLEAR" received
3. Scout: literature check complete (KNOWN/NOVEL/no contradiction)

If ANY condition fails → step is REVERTED. Log in Attempt History. Mathematician proposes alternative.
This is the autoresearch keep/discard pattern applied to proof steps.

## Problem
{USER'S MATHEMATICAL QUESTION}

## Team Members
mathematician, adversary, scout, verifier (you)

## Workspace
$WS -- scripts in $WS/scripts/, proof state in $WS/PROOF-STATE.md, results in $WS/results.tsv
```

---

## PHASE 2: MONITOR THE DERIVATION

You (the lead) spawned 4 teammates. Now WAIT for notifications. Do NOT poll, do NOT research yourself.

### What you monitor for

**Progress signals** (healthy -- let them work):
- Mathematician proposing steps → Verifier confirming → Adversary attacking → steps advancing
- Scout grounding claims in literature
- Teammates messaging each other substantively

**Intervention triggers:**
- **Circular debate** (3+ messages between two teammates with no new evidence): SendMessage to both -- "You've exchanged 3 messages without new evidence. Either find new evidence or agree to disagree. Verifier: run the code and settle it."
- **Stuck mathematician** (no new step proposed in 2+ rounds): SendMessage -- "What's blocking you? State the exact sub-problem. Scout: search for techniques. Adversary: what if we approach from your alternative framing?"
- **Disagreement between verifier and adversary**: This is the interesting case. Read both positions. If verifier says PASS but adversary says FLAW → ask adversary for a concrete counterexample script, have verifier run it. Code settles disputes, not arguments. **But note (Gemini review):** if the flaw is in the Python representation itself (e.g., confusing continuous vs discrete), all models share the blind spot. In this case, run H9 (translation audit) as tiebreaker.
- **Adversary paralysis in abstract domains (Gemini review):** If the problem is in topology, abstract algebra, or category theory, the adversary may not be able to write Python counterexample scripts. Watch for "ADVERSARY CLEAR" with no actual attack code -- this is false confidence. Intervene: "Adversary: your CLEAR had no counterexample attempt. Either (a) state specifically what you tried and why it's un-scriptable, or (b) provide a concrete attack. If the domain is genuinely un-scriptable, route to EVIDENCE classification, not PROOF."
- **Scout finds the result is already known**: SendMessage to all -- "Scout found this in {paper}. Team: verify the known result matches our approach, then decide whether to (a) reproduce and verify, (b) extend, or (c) simplify."
- **Stale-state approvals (Codex review):** All verification messages must include the SHA-256 of the step script being verified. If adversary says "CLEAR on step 5" but the hash doesn't match the current step_5.py (because mathematician revised it), the CLEAR is void. Verifier enforces this.

### Spin detection (from autoresearch)

Track consecutive reverts in results.tsv:

- **3 consecutive reverts at same step**: SendMessage to mathematician -- "Step N has failed 3 times. Different approaches tried: {list from Attempt History}. Adversary: what's the fundamental obstacle? Scout: is there a known technique for this sub-problem?"
- **5 consecutive reverts**: SendMessage to all -- "We're stuck. Three options: (1) mathematician proposes a completely different attack strategy, (2) adversary's alternative framing becomes the main approach, (3) scout identifies a paper that solved this sub-problem. Choose one."
- **8 consecutive reverts**: The formalization may be wrong. SendMessage to all -- "Return to formalization. Re-examine assumptions. Scout: check if there's an impossibility result we're missing."

### Quality gates (all must pass before Phase 3)

- [ ] At least 1 complete derivation path from assumptions to conclusion
- [ ] Every step in the chain: VERIFIED + ADVERSARY CLEAR + literature checked
- [ ] Full chain end-to-end script passes
- [ ] No known contradictions with literature
- [ ] Attempt History is complete (all reverts documented)

---

## PHASE 3: HARDEN

When the proof chain is complete and quality gates pass, create final verification tasks:

**Task: "Full adversarial stress test"** -- for adversary:
- Attack the COMPLETE result (not individual steps -- the whole thing)
- Try parameter regimes not tested
- Check limiting cases (x→0, x→∞, n→1, degenerate inputs)
- Does it reduce to known results in special cases?
- Is the result TIGHT? Can bounds be improved?

**Task: "Final literature reconciliation"** -- for scout:
- Does our result match, extend, or contradict known results?
- If it matches: which paper/theorem? We should cite it.
- If it extends: what's the delta? Is the extension novel?
- If it contradicts: RED FLAG -- something is wrong.

**Task: "Simplification pass"** -- for mathematician + adversary:
- Can the proof be stated more simply?
- Are all assumptions necessary? (adversary: try removing each one)
- Is there a more elegant path? (the exploration path isn't always the cleanest presentation)
- What's the one-sentence version a practitioner would remember?

**Task: "Final full-chain verification"** -- for verifier:
- Write `$WS/scripts/full-proof.py`: single self-contained script
- States ALL assumptions explicitly
- Executes EVERY step with SymPy
- Z3-verifies every key claim
- Numerical sweep across parameter space
- Prints PASS/FAIL per step
- Exit code 0 only if ALL pass
- Run it. It MUST pass.

---

## PHASE 4: DISTILL & RECORD

After Phase 3 tasks complete, YOU (the lead) synthesize:

### 4A: Write the derivation document

Output: `$WS/{topic}-derivation.md`

```markdown
# Derivation: [Result Name]

## Result
[One-sentence statement of what was proved]

## Status
[NOVEL | KNOWN (matches {paper}) | EXTENSION of {paper}]

## Assumptions
- [Each assumption, why it's needed, what breaks without it (adversary tested)]

## Key Insight
[The non-obvious step -- what makes this proof work]

## Derivation
[Step-by-step, each computationally verified]
[Include SymPy/Z3 verification for each critical step]

## Verification Summary
- **Classification**: PROOF (all steps decidable in Z3) | EVIDENCE (some steps semi-decidable/undecidable) | SKETCH (significant gaps)
- SymPy: all {N} steps verified symbolically
- Z3: {K} key claims verified universally, {U} returned unknown (EVIDENCE only)
- Hypothesis: {M} property-based test suites, 0 violations, minimal counterexample search
- Adversarial: {A} attack rounds survived, {P} adversary paralysis flags (abstract domain)
- Translation audits: {T} back-translations matched, {D} divergences investigated
- Literature: {status -- NOVEL/KNOWN/EXTENSION}
- Reverts: {R} steps reverted during derivation (see Attempt History)
- Vacuity: anchor assumptions verified satisfiable (witness: {...})

## Attempt History
[What was tried and didn't work -- this IS the research contribution]

## Edge Cases & Limitations
[Where the result breaks, boundary of validity -- from adversary's attacks]

## Connections
[What this implies, related results from scout's literature search]

## Verification Script
Run: `python3 $WS/scripts/full-proof.py`
```

### 4B: Present to user

- The result in one sentence
- NOVEL / KNOWN / EXTENSION status
- Key insight (non-obvious step)
- Verification status (all green?)
- Steps attempted vs steps kept (the revert ratio tells you how hard the derivation was)
- Any open questions or extensions
- The full-proof.py script location

### 4C: Cleanup

```
SendMessage: type="shutdown_request", recipient="mathematician", content="Derivation complete"
SendMessage: type="shutdown_request", recipient="adversary", content="Derivation complete"
SendMessage: type="shutdown_request", recipient="scout", content="Derivation complete"
SendMessage: type="shutdown_request", recipient="verifier", content="Derivation complete"
TeamDelete
```

Keep `$WS/` -- the scripts and proof state are the artifact. Only clean up if user confirms.

---

## RULES

1. **The proof chain only advances on triple convergence.** Verifier CORRECT + Adversary CLEAR + Scout checked. No exceptions.
2. **Three-outcome routing, not binary. (H1)** Verifier diagnoses CORRECT / MINOR FIX / FUNDAMENTALLY FLAWED. Minor fixes preserve work. Fundamental flaws discard it.
3. **Balanced prompting always. (H2)** Every claim is framed "prove OR refute." Refutation is a valid result. Confirmation bias is the enemy.
4. **Product nodes for sub-goals. (H3)** Independent sub-goals are tracked separately, solved easiest-first, never revisited once proven.
5. **Value-guided search. (H4)** Estimate "steps remaining" before choosing a direction. Prefer cheaper, problem-reducing paths.
6. **Specification gaming is the #1 threat. (H5)** Adversary checks every step: "are we proving what we CLAIM, or a trivial restatement?" 25% of AI proofs are mathematically empty.
7. **Honest failure > fake proof. (H6)** The team can declare UNRESOLVED. This is science. Hand-wavy steps are not allowed.
8. **Easy things first. (H7)** Prove the easiest claim first. If easy things fail, the formalization is wrong.
9. **Lemma library accumulates. (H8)** Every verified step becomes importable. The proof chain is a growing library.
10. **Code settles disputes.** When teammates disagree, the verifier runs the code. The code is the ground truth.
11. **Failures are data.** Every revert goes in Attempt History. The pattern of failures reveals the structure of the problem.
12. **Simplicity criterion.** If the adversary finds a simpler path that's equally correct, take it. Deletion that preserves correctness = improvement.
13. **Literature first.** Scout checks before the team re-derives. Don't burn cycles on solved problems.
14. **Teammates talk to EACH OTHER.** The lead monitors and intervenes. The lead does not do the math.
15. **Gemini sandbox rule.** Adversary must extract and run Gemini's code locally. Trust reasoning, verify execution.
16. **results.tsv tracks everything.** Every step attempt, route outcome, keep or revert. The log IS the research.
17. **Spin detection is mandatory.** 3/5/8 consecutive reverts trigger escalating interventions.
18. **The derivation script IS the proof.** `full-proof.py` runs and passes, or it's not proven.
