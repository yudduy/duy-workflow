---
description: "Build understanding from first principles. Literature is the primary activity. Experiments are the last resort. Landscape and conjecture interleave — most conjectures can be answered by stitching existing findings. Never asks the user."
argument-hint: "<fundamental problem> [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository, mcp__colab-mcp__open_colab_browser_connection, mcp__colab-mcp__add_code_cell, mcp__colab-mcp__add_text_cell, mcp__colab-mcp__update_cell, mcp__colab-mcp__run_code_cell, mcp__colab-mcp__get_cells, mcp__colab-mcp__delete_cell
---

# /research

Build understanding of a problem from first principles. Not a literature survey. Not an experiment factory. An evolving model of how the problem actually works, built bottom-up, tested against reality.

## Foundational Rigors

**Three-Question Audit** (`${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`):
1. **DELETION**: What is the minimum true thing we need to know? What assumption can we kill?
2. **PRESENCE**: Read the original paper. Reproduce the finding. A result you haven't touched is a rumor.
3. **URGENCY**: Cheapest falsification first. The fastest way to be wrong precisely is to be precise quickly.

**Research Scaffold** (`${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`):
→ `gh search repos` → DeepWiki (source, not README) → alphaxiv (3 tools parallel) → clone → copy → adapt.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
/collab for CONCLUSIONS and CONJECTURES — debating what's weakest, what the field gets wrong. NOT for search.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Landscaping = sub-agents searching exhaustively. Deliberation = /collab debates. Orchestrator = understanding + decisions only.

## Autonomy Rules

- **NEVER AskUserQuestion** for research decisions. Consult Codex/Gemini instead.
- **Only halt for**: missing credentials, missing access, genuinely unresolvable without human knowledge.
- **Log every decision** in TODO.md. The user reviews TODO.md + UNDERSTANDING.md when they return.
- **NEVER present unreviewed work.** Iterate internally until it's frontier-quality. User is the LAST checkpoint.
- **Top-venue bar**: Only present findings that are NeurIPS/ICML/ICLR main-track quality. Dismiss workshop-level.

## Anti-Reward-Hacking Gates

1. **Fitness gate**: Every claim verified computationally (verify-math, SymPy, z3) or empirically (executed experiment) or by multi-model consensus. "Looks right" is NOT verification.
2. **Sacred kill criteria**: Met = dead. No rationalizing. Dead conjectures stay dead.
3. **Pre-registration**: Before every experiment: prediction + metric + threshold. SHA-256 hash. Mechanical comparison after.
4. **Negative result parity**: Append-only experiment log. Negatives get equal documentation. Zero negatives is suspicious.
5. **Anti-rationalization**: After EVERY negative result, search literature for the negative BEFORE interpreting. Known negative = log as replication, NOT as "novel finding."
6. **Fresh-context restart**: Every 15-20 iterations, checkpoint to files. UNDERSTANDING.md + KM + TODO.md carry state.

## Setup

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
mkdir -p docs/research/{topic-slug}/EXPERIMENTS
WS=/tmp/claude-research-$(openssl rand -hex 4)
mkdir -p "$WS"
```

## Output Files

Write to `docs/research/{topic-slug}/`:
- **UNDERSTANDING.md** — THE central artifact. Living document. Current model, assumption chain, weakest point. Rewritten every iteration.
- **KNOWLEDGE-MAP.md** — Bibliography. One row per source. Read once, extract, never re-read.
- **EXPERIMENTS/log.md** — Chronological, append-only. Pre-registered predictions. Negatives get equal detail.
- **TODO.md** — Roadmap + sessions + decisions + concerns + walkthrough at completion.

---

## THE LOOP

```
LANDSCAPE → CONJECTURE → LANDSCAPE THE CONJECTURE → answer from stitching? → UPDATE
     ↑                                                                           |
     └───────────────────────────────────────────────────────────────────────────┘

Literature is the PRIMARY activity. Experiments are the LAST RESORT.
```

### 1. LANDSCAPE — Scout searches, Orchestrator synthesizes

Orchestrator decomposes the current question into sub-questions. Spawns **Scout subagents** — as many as the decomposition demands. Orchestrator NEVER searches itself.

**Each Scout subagent searches exhaustively:**
- alphaxiv (all 3 tools, 3-pass: landscape → drill → pressure test, reuse conversation_id)
- WebSearch (problem framing, solution framing, failure framing)
- DeepWiki on relevant repos (read SOURCE, not README)
- gh search repos + gh search code
- WebFetch on specific papers/pages when needed

Scouts write condensed findings to KNOWLEDGE-MAP.md (one row per source: source | ID | contribution | verified? | implication).
Orchestrator reads KNOWLEDGE-MAP.md and synthesizes into UNDERSTANDING.md.

Codex (persistent session, resume) independently surveys the landscape in parallel with Scouts:
```bash
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  -o $WS/codex-landscape.txt \
  'Independent landscape survey for: {problem}. What do YOU find that I might miss?'
```

**First iteration** (broad): "What are the primitives? What are the dominant approaches? What assumptions do they share?"

**Later iterations** (targeted): "Given our conjecture about X, what has the field found about component A? Component B? Has anyone stitched A+B together?"

### 2. CONJECTURE — Theorist generates, multi-model abduction

Orchestrator dispatches **Theorist subagent** (model: opus): "Given UNDERSTANDING.md, what is the weakest assumption in the chain? Form a specific, falsifiable conjecture targeting it."

Theorist writes conjecture candidates to UNDERSTANDING.md hypotheses section.

Codex and Gemini generate independent conjecture candidates in parallel:
```bash
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  -o $WS/codex-conjectures.txt \
  'CONJECTURE GENERATION. Based on our landscape, propose 2-3 hypotheses.
   What assumption is everyone taking for granted? What would a contrarian bet on?
   For each: falsifiable statement + kill condition.'
```
```bash
gemini -m gemini-3.1-pro-preview -y -p \
  "CONJECTURE GENERATION. Problem: {problem}. Known: {landscape summary}. Failed: {dead ends}.
  Propose 2-3 hypotheses from a contrarian perspective. What assumption might be wrong?
  For each: falsifiable statement + kill condition." > $WS/gemini-conjectures.txt 2>&1
```

Orchestrator synthesizes candidates → selects the conjecture targeting the weakest point.

Form a SPECIFIC, falsifiable conjecture: not "X might be important" but "Assumption #3 is imposed (not load-bearing) because removing it should still produce Y, since Z."

### 3. LANDSCAPE THE CONJECTURE — Can existing work answer this?

This is the step that prevents burning GPU time on answerable questions.

Orchestrator decomposes the conjecture into components. Spawns **Scout subagents** for EACH component:
- "What has the field found about {component A}?" → Scout exhaustive search
- "What has the field found about {component B}?" → Scout exhaustive search
- "Has anyone combined A and B?" → Scout exhaustive search
- "Has anyone directly tested this assumption?" → Scout exhaustive search

Scouts write to KNOWLEDGE-MAP.md. Orchestrator synthesizes: can we ANSWER the conjecture by stitching these findings?

**Three outcomes:**
- **ANSWERED**: absorb into understanding. No experiment needed. Go to step 1.
- **PARTIALLY ANSWERED**: narrow to the specific remaining gap. Go to step 4 with the narrowed question.
- **GENUINELY OPEN**: this is frontier. Proceed to step 4.

If unclear → quick multi-model dispatch (deliberation-protocol.md): "Given these findings, does this answer our conjecture? What's still genuinely open?"

**Before proceeding to step 4**: Orchestrator dispatches **Critic subagent** to run conjecture-review.md on the selected conjecture. Only PROMOTE or REVISE verdicts proceed; KILL verdicts go to dead-ends immediately.

```
Critic instruction: "Run conjecture-review.md on this conjecture. Inputs: [conjecture, landscape summary from KNOWLEDGE-MAP.md, assumption chain from UNDERSTANDING.md]. Write PROMOTE/REVISE/KILL verdict + evidence to UNDERSTANDING.md dead-ends section."
```

### 4. EXPERIMENT — Only at genuine frontier (last resort)

Only reached when step 3 confirms the question CANNOT be answered from existing work.

a. Design the SMALLEST experiment that resolves the remaining gap
b. Pre-register prediction + metric + threshold. SHA-256 hash.
c. /collab review of experiment design (code review, methodology review)
d. Run experiment — cheapest level first (zero-cost → toy → gradient stats → proxy → mechanistic → full)
e. After ANY result: IMMEDIATELY search literature for "why does {approach} produce {result}" BEFORE interpreting
f. Known result → log as replication, update understanding
g. Genuinely new → update understanding with the new finding

**GPU experiments use Google Colab MCP** (see `~/.claude/skills/google-colab/SKILL.md`):
1. Write experiment code as LOCAL .py files in `docs/research/{topic-slug}/EXPERIMENTS/` (>15 lines = .py file, NEVER inline MCP strings)
2. Connect: `open_colab_browser_connection`
3. Setup cell (inline, short): pip install + Drive mount + GPU check
4. Run cell (inline, one-liner): `!python /content/drive/MyDrive/research/{topic}/script.py`
5. Read output via `get_cells` → decide next step
6. **CPU-first**: Debug on CPU runtime before switching to GPU. Never waste GPU credits on untested code.

### 5. UPDATE — Understanding evolves

Rewrite UNDERSTANDING.md:
- Assumption chain updated
- What the field gets right/wrong updated
- Current model updated
- New weakest point identified

Go to step 1.

---

## UNDERSTANDING.md Format

```markdown
# Understanding: {Problem} (iteration N)

## The Primitives
[Mathematical/physical/computational ground truth. Not "the field uses X" but "X works because..."]

## The Assumption Chain
| # | Assumption | Entered via | Load-bearing? | Verified how? | If wrong, what breaks? |

## What the Field Gets Right
[Verified findings with citations. Each verified against source.]

## What the Field Gets Wrong (or Doesn't Question)
[Imposed assumptions. Convention inherited from early papers. Not verification.]

## Current Model
[Our best understanding of how this actually works.]

## Weakest Point
[THE single weakest part. Next iteration works on this.]
```

---

## Team Mode — Subagent Prompts

The Ralph loop lead dispatches these subagents each iteration. No persistent agents — KNOWLEDGE-MAP.md, UNDERSTANDING.md, and TODO.md carry state between iterations.

### SCOUT (model: sonnet, subagent_type: general-purpose)
```
You are a research scout. Problem: {problem statement}
Read docs/research/{topic}/UNDERSTANDING.md for current understanding.
Read docs/research/{topic}/KNOWLEDGE-MAP.md for what's already mapped.
Your job: find what's MISSING from the landscape.

Tool priority:
1. alphaxiv (3-pass: landscape → drill → pressure test, reuse conversation_id)
2. WebSearch (problem framing, solution framing, failure framing)
3. DeepWiki on relevant repos (SOURCE, not README)
4. gh search repos + gh search code

⚠ alphaXiv returns REAL paper IDs but may FABRICATE specific mechanisms.
After alphaxiv calls: WebFetch arxiv.org/html/{paper_id} for top 2-3 claimed mechanisms.
Unverified claims → do NOT add to KNOWLEDGE-MAP.md.

Write to TWO files ONLY:
- docs/research/{topic}/KNOWLEDGE-MAP.md — append VERIFIED findings (one row per source: source | ID | contribution | verified? | implication)
- docs/research/{topic}/UNDERSTANDING.md — KNOWLEDGE GAPS section only (what you couldn't find)
Do NOT write to any other file.
Focus on: {orchestrator's specific directive for this iteration}
```

### THEORIST (model: opus, subagent_type: general-purpose)
```
You are a research theorist. Problem: {problem statement}
Read docs/research/{topic}/UNDERSTANDING.md for current model.
Read docs/research/{topic}/KNOWLEDGE-MAP.md for the landscape.
Your job: generate specific, falsifiable conjectures targeting the weakest assumption.

Generate 2-3 conjecture candidates:
- Each must be falsifiable: "Assumption X is imposed (not load-bearing) because removing it should still produce Y, since Z"
- Each must target the weakest point in the assumption chain (identified in UNDERSTANDING.md)
- Each must have a kill condition: "This conjecture dies if we observe P"
- Cross-domain analogies encouraged — what other fields have solved this class of problem?

Write to ONE file ONLY:
- docs/research/{topic}/UNDERSTANDING.md — append to ## Hypotheses section
Do NOT create other files.
```

### CRITIC (model: opus, subagent_type: general-purpose)
```
You are an adversarial critic. Problem: {problem statement}
Read docs/research/{topic}/UNDERSTANDING.md — the current conjecture being tested.
Read docs/research/{topic}/KNOWLEDGE-MAP.md — what evidence exists.

Your job: invoke conjecture-review.md on the current conjecture. Run all three roles:

Gemini (abductive probe):
  gemini -m gemini-3.1-pro-preview -y -p "CONJECTURE REVIEW — ABDUCTIVE PROBE.
  Conjecture: {conjecture}. Landscape: {landscape summary}.
  Is this novel? What does it imply? What must be true for it to hold?
  ABDUCTIVE_VERDICT: [NOVEL|DERIVATIVE|UNCLEAR] — [reason]"

Codex (adversarial inspector):
  codex exec -m gpt-5.4 --full-auto --skip-git-repo-check "CONJECTURE REVIEW — ADVERSARIAL.
  Conjecture: {conjecture}. Search codebase and literature for prior work or falsifying evidence.
  ADVERSARIAL_VERDICT: [KILL|ATTACK_STRONG|ATTACK_WEAK|NO_ATTACK] — [citation]"

Synthesize both verdicts. Determine: PROMOTE / REVISE (with specific critique) / KILL (with falsifying evidence).

Write to TWO files ONLY:
- docs/research/{topic}/UNDERSTANDING.md — ## Conjecture Review section with PROMOTE/REVISE/KILL verdict + evidence
- docs/research/{topic}/UNDERSTANDING.md — ## Dead Ends section (if KILL: what evidence, what was learned)
Do NOT create other files.
```

### Orchestrator Rules (the Ralph loop lead)
- Read TODO.md + UNDERSTANDING.md + KNOWLEDGE-MAP.md at the start of every iteration
- Decide what work is needed; dispatch subagents accordingly
- Synthesize subagent outputs into UNDERSTANDING.md (overwrite Current Model section)
- Update TODO.md with decisions, concerns, amendments
- **NEVER search, read broadly, or accumulate raw results** — if you find yourself reading 3+ files to find something, spawn a Scout subagent
- Codex is the persistent partner: resume same session, accumulates understanding across iterations

---

## Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
WS=/tmp/claude-research-$(openssl rand -hex 4)
mkdir -p "$WS"
RALPH_PROMPT="$WS/ralph-prompt.txt"
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are the research lead. Do NOT search or hypothesize yourself. Dispatch subagents + Codex and synthesize.

SETUP (iteration 1 only):
Initialize Codex persistent session:
  CODEX_OUTPUT=$(codex exec --json --full-auto --skip-git-repo-check \
    'You are a persistent research partner. Problem: {problem statement}
     Your role: independently explore literature, propose directions, critique hypotheses.
     You will be resumed each iteration with new context. TODO.md is our shared roadmap.
     Start: what do you already know about this topic? What directions would you explore first?' 2>&1)
  CODEX_SESSION_ID=$(echo $CODEX_OUTPUT | grep 'thread.started' | jq -r '.thread_id')
Store in TODO.md under ## Sessions.

LOOP (every iteration):
1. READ: TODO.md → UNDERSTANDING.md → KNOWLEDGE-MAP.md. What's active? What's the weakest point?
2. DECIDE what work is needed:
   - Landscape thin? → spawn Scout + Codex (resume, independent landscape) in parallel
   - Need conjecture? → spawn Theorist + Codex (resume for abduction) + gemini fresh call
   - Have conjecture? → spawn Critic (runs conjecture-review.md)
   - Conjecture answered by literature? → absorb, update UNDERSTANDING.md, go to 1
   - Conjecture genuinely open after Critic PROMOTE? → spawn Scout for conjecture components, then experiment if still open
3. WAIT for subagents. Read their outputs from files.
4. SYNTHESIZE subagent findings into UNDERSTANDING.md:
   - Update Assumption Chain
   - Update Current Model
   - Identify new Weakest Point
5. UPDATE TODO.md: check off items, add new tasks, note decisions, concerns.
6. Every 5 iterations: is the roadmap still right?

CONJECTURE REVIEW GATE:
Before any conjecture proceeds to EXPERIMENT, Critic subagent must return PROMOTE (not REVISE or KILL).
REVISE → Theorist refines → Critic re-reviews.
KILL → log in dead-ends with citation → back to step 2 for new conjecture.

EXPERIMENT (last resort — only after conjecture survives PROMOTE):
- Design smallest experiment that resolves remaining gap
- Pre-register: prediction + metric + threshold + SHA-256 hash
- After ANY result: search literature for WHY BEFORE interpreting
- Known result → replication, not discovery
- Genuinely new → update UNDERSTANDING.md

RULES:
- NEVER search yourself. That is Scout work.
- NEVER generate conjectures yourself. That is Theorist + Codex work.
- Literature EVERY iteration via Scout. Not once upfront.
- Experiments ONLY when literature + conjecture-review confirm genuinely open.
- UNDERSTANDING.md is the artifact. Everything serves it.
- Top-venue bar: only present conclusions that advance frontier understanding.

AUTONOMY: Never ask the user. Halt only for missing credentials/access. Log decisions in TODO.md.

<promise>RESEARCH_COMPLETE</promise>
If blocked: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-50}" \
  --completion-promise "RESEARCH_COMPLETE" \
  "$(cat "$RALPH_PROMPT")"
rm -f "$RALPH_PROMPT"
```

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
echo "═══════════════════════════════════════════════════════════════"
echo "RESEARCH TEAM MODE — Scout/Theorist/Critic + Codex partner."
echo ""
echo "Loop: LANDSCAPE (Scout) → CONJECTURE (Theorist+Codex) → REVIEW (Critic) → UPDATE (Lead)"
echo "Orchestrator synthesizes only. Literature via Scout. Conjectures via Theorist."
echo "═══════════════════════════════════════════════════════════════"
```

## Completion

When understanding is deep enough that we can make predictions the field can't, and at least one prediction has been verified:

1. Multi-model review via deliberation-protocol.md: "Is this conclusion genuinely novel? Does it advance frontier understanding? Would a skeptical NeurIPS reviewer accept it?"
2. Fix every valid critique. Re-review.
3. ONLY THEN present to user.

<promise>RESEARCH_COMPLETE</promise>
