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

### 1. LANDSCAPE — Decompose and search exhaustively

Orchestrator decomposes the current problem/question into sub-questions. Spawns sub-agents — as many as the decomposition demands.

**Each sub-agent searches exhaustively with ALL tools:**
- alphaxiv (all 3 tools, multiple query formulations — not one query)
- WebSearch (problem framing, solution framing, failure framing)
- DeepWiki on relevant repos (read SOURCE, not README)
- gh search repos + gh search code
- WebFetch on specific papers/pages when needed

Sub-agents return condensed findings (1-2k). Orchestrator synthesizes into UNDERSTANDING.md.

**First iteration** (broad): "What are the primitives? What are the dominant approaches? What assumptions do they share? What's the lineage — where did each key assumption enter the field?"

**Later iterations** (targeted): "Given our conjecture about X, what has the field found about component A? Component B? Has anyone stitched A+B together?"

**Depth is not fixed.** Some sub-questions need one sub-agent. Others need five. The orchestrator determines the decomposition based on its current understanding. Go as deep as the problem demands.

### 2. CONJECTURE — Question the weakest point

/collab deliberation: "Given our understanding, what is the weakest part? What assumption is most likely wrong? What would change the most if we resolved it?"

Form a SPECIFIC, falsifiable conjecture: not "X might be important" but "Assumption #3 is imposed (not load-bearing) because removing it should still produce Y, since Z."

The conjecture targets the weakest point in the assumption chain, not a grand hypothesis about the whole problem.

### 3. LANDSCAPE THE CONJECTURE — Can existing work answer this?

This is the step that prevents burning GPU time on answerable questions.

Orchestrator decomposes the conjecture into components. Spawns sub-agents for EACH component:
- "What has the field found about {component A}?" → sub-agent exhaustive search
- "What has the field found about {component B}?" → sub-agent exhaustive search
- "Has anyone combined A and B?" → sub-agent exhaustive search
- "Has anyone directly tested this assumption?" → sub-agent exhaustive search

Orchestrator synthesizes: can we ANSWER the conjecture by stitching these findings?

**Three outcomes:**
- **ANSWERED**: absorb into understanding. No experiment needed. Go to step 1.
- **PARTIALLY ANSWERED**: narrow to the specific remaining gap. Go to step 4 with the narrowed question.
- **GENUINELY OPEN**: this is frontier. Proceed to step 4.

If unclear → /collab deliberation: "Given these findings, does this answer our conjecture? What's still genuinely open?"

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

## Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
WS=/tmp/claude-research-$(openssl rand -hex 4)
mkdir -p "$WS"
RALPH_PROMPT="$WS/ralph-prompt.txt"
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are building understanding of a problem from first principles. The user is away.

LOOP (every iteration — no phases, same loop at iteration 1 and iteration 50):
1. LANDSCAPE: Decompose current question into sub-questions. Spawn sub-agents to search exhaustively (alphaxiv, WebSearch, DeepWiki, gh search). As many sub-agents as the decomposition demands. Synthesize into UNDERSTANDING.md.
2. CONJECTURE: /collab debate — what's the weakest point? Form specific, falsifiable conjecture targeting it.
3. LANDSCAPE THE CONJECTURE: Decompose conjecture into components. Spawn sub-agents for each. Can existing findings, stitched together, answer it?
   → ANSWERED: absorb, update understanding, go to 1.
   → PARTIALLY: narrow to the gap. Proceed to 4 with the narrowed question.
   → GENUINELY OPEN: proceed to 4.
4. EXPERIMENT (last resort): Smallest experiment for the remaining gap. Pre-register. /collab review. Run. After ANY result: search literature for the result BEFORE interpreting. Update understanding.
5. UPDATE: Rewrite UNDERSTANDING.md. New weakest point. Go to 1.

RULES:
- Literature EVERY iteration. Not once upfront.
- Experiments ONLY when literature can't answer the question.
- UNDERSTANDING.md is the artifact. Everything serves it.
- After negative results: search literature for WHY before interpreting. Known negative = replication, not discovery.
- Top-venue bar: only present conclusions that advance frontier understanding.
- Anti-rationalization: if you catch yourself dressing up a negative as novel, search literature. If it's known, kill the claim.

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
echo "RESEARCH MODE — Building understanding from first principles."
echo ""
echo "Loop: LANDSCAPE → CONJECTURE → LANDSCAPE THE CONJECTURE → EXPERIMENT (last resort) → UPDATE"
echo "Literature is the primary activity. Experiments only at genuine frontier."
echo "═══════════════════════════════════════════════════════════════"
```

## Completion

When understanding is deep enough that we can make predictions the field can't, and at least one prediction has been verified:

1. /collab review: "Is this conclusion genuinely novel? Does it advance frontier understanding? Would a skeptical NeurIPS reviewer accept it?"
2. Fix every valid critique. Re-review.
3. ONLY THEN present to user.

<promise>RESEARCH_COMPLETE</promise>
