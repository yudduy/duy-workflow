---
description: "Fully autonomous engineering loop with anti-reward-hacking scaffolding. Multi-model consultation at decisions. Process rewards via backpressure validators. Never asks the user."
argument-hint: "[--max-iterations N]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__get_page_text, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__tabs_context_mcp, mcp__colab-mcp__open_colab_browser_connection, mcp__colab-mcp__add_code_cell, mcp__colab-mcp__add_text_cell, mcp__colab-mcp__update_cell, mcp__colab-mcp__run_code_cell, mcp__colab-mcp__get_cells, mcp__colab-mcp__delete_cell
---

# /execute

Fully autonomous. The user is away. Build the thing, verify it works, walk them through decisions when they return.

## Foundational Rigors (apply before and during ALL work)

Before each requirement, run the **Three-Question Audit** from `${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`:
1. **DELETION**: What is the minimum viable implementation? Kill every step that can't survive "is this load-bearing?"
2. **PRESENCE**: Go to the actual failure/code/test. Read the raw source, not summaries. Reproduce before diagnosing.
3. **URGENCY**: What is the next action in the next 10 minutes? Ship the smallest thing that tests the hypothesis.

Before writing ANY new code, run the **Research Scaffold** from `${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`:
→ `gh search repos` + `gh search code` → DeepWiki on best candidates → alphaxiv (3 tools parallel) → git clone → copy → adapt.
**Never build from scratch when a reference exists.** Source Map in the plan has the references — use them FIRST.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
Every non-trivial decision → dispatch Codex + Gemini + Claude in parallel, iterate to convergence. The user is the LAST checkpoint. Exhaust web search, alphaxiv, DeepWiki, and multi-model deliberation BEFORE anything reaches the user.

## Pre-flight

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
PLAN=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)
if [ -z "$PLAN" ]; then
  echo "BLOCKED: No plan found in .claude/plans/"
  echo "Run /interview first to create a Product Intent Document."
  exit 1
fi
MISSING=""
for section in "## Requirements" "## Build Environment" "## Source Map" "## Principles" "## Boundaries"; do
  grep -q "$section" "$PLAN" || MISSING="$MISSING  - $section\n"
done
grep -q 'REQ-[0-9]' "$PLAN" || MISSING="$MISSING  - Enumerated requirements (REQ-1, REQ-2, ...)\n"
[ -n "$MISSING" ] && echo "WARNING: Plan missing:" && echo -e "$MISSING"
cat "$PLAN"
```

```bash
export PLAN_PATH="$PLAN"
```

```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
[ -d "$CLAUDE_PLUGIN_ROOT" ]
mkdir -p .claude/mission
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/sync-mission.py" --plan "$PLAN_PATH" --phase execute
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-phase execute >/dev/null
export MISSION_DIR=".claude/mission"
ls -la "$MISSION_DIR"
```

If pre-flight fails, STOP. Do not infer from git history. Tell the user: "No plan found. Run /interview first."

## Autonomy Rules

- **NEVER ask the user** for technical decisions. Dispatch to Codex/Gemini instead.
- **Only halt for**: missing credentials, missing access, genuinely unresolvable without human knowledge.
- **Log every decision** in TODO.md: what, why, alternatives, models consulted, agreement level.
- **At completion**: write WALKTHROUGH in TODO.md, reviewed by Codex/Gemini before the user sees it.
- **NEVER present unreviewed work.** Every cross-agent review is ITERATIVE, not one-shot.

## Escalation Protocol

When autonomy breaks down, **HALT and REPORT** -- no autonomous recovery loops.

- **Inaccessible source**: Search ONE alternative. Found -> proceed + document. Not found -> halt.
- **Missing build environment**: Detect stack -> create minimal config + document assumption. Ambiguous -> halt.
- **Model deadlock**: After 1 investigation round, apply Decision Precedence from plan. Max 2 rounds total.
- **Validator cannot run**: The command itself errors (not test failure) -> halt. Never skip validators.

Halting = write state to TODO.md + output `<promise>BLOCKED: [reason]</promise>` + stop.

Before halting:
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-blocked true >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-recent-failures 3 >/dev/null
```

## Anti-Reward-Hacking Rules (structural, not advisory)

1. **Backpressure validators** -- ALL validators from Build Environment must pass before ANY commit. No exceptions.
2. **Test hash verification** -- Snapshot test file hashes at requirement start. Verify before each validator run. Hash mismatch = BLOCKED (structural fraud).
3. **Decorrelation** -- Reviewer MUST be different model from implementer. Adversary MUST be different from both. NEVER self-review.
4. **Copy Before Rewrite** -- Check Source Map FIRST. Only build from scratch if no reference exists AND a different model confirms this independently. (See `${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`.)
5. **Never modify tests to pass** -- If tests fail, the code is wrong. To change a genuinely wrong test: document WHY in TODO.md Plan Amendments, get independent confirmation.
6. **Constraint re-injection** -- Every 5 iterations AND after every context compaction: re-read plan from `$PLAN_PATH`, re-read CLAUDE.md, re-read the plan's Principles + Boundaries sections. Check for drift.
7. **Execute-Verify-Report** (from OpenClaw) -- Every action follows this loop: DO the thing → VERIFY it worked (run it, check output, not "it looks right") → REPORT evidence to TODO.md (test output, integration result, review verdict). No action is complete without verification evidence logged.
8. **Pre-compaction memory flush** -- Before context compression, write current state to TODO.md: active requirement, what was just done, what's next, any open concerns. Context can be compressed; TODO.md survives.

## The 10-Step Engineering Loop

For each requirement by priority from the plan's Requirements table:

### 1. ORIENT
Re-read plan from `$PLAN_PATH` + TODO.md. What's next by priority?
Every 5 iterations: full constraint re-injection (rule 6 above).

At the start of each requirement:
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-branch "{REQ-ID}" >/dev/null  # replace {REQ-ID} with the active requirement, e.g. REQ-2
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-completion-claimed false >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-blocked false >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-goal-aligned true >/dev/null
```

### 2. RESEARCH
Check Source Map FIRST. Only re-research if entry is missing, inaccessible, or wrong after reading actual code.
Document source provenance in TODO.md per requirement.

### 3. DECIDE
**Every non-trivial decision triggers the Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`).
Dispatch Codex + Gemini + Claude subagent in parallel. Max 3 rounds. Convergence = all agree with evidence.
Deadlock → apply Decision Precedence from plan. Log positions + rationale in TODO.md Decisions section.
Skip deliberation ONLY for mechanical/reversible choices the plan already decided.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Exploration = sub-agents. Targeted reads = yourself. Heavy lifting = sub-agents. Decisions = yourself.

### 4. TEST FIRST (Adversarial TDD)
Spawn sub-agent (DIFFERENT model than implementer) with `${CLAUDE_PLUGIN_ROOT}/templates/adversarial-tdd.md`.
Pass: requirement text, acceptance criteria, Source Map reference.
Tests MUST include: property-based invariants, edge cases, negative tests, mutation-killing tests.
Sub-agent writes test files to disk + returns summary. Tests must run RED before step 5.
Snapshot test file hashes NOW (for backpressure verification).

### 5. BUILD
Spawn Claude sub-agent (Agent tool) or implement directly. FROM COPIED SOURCE -- never from memory.
Pass: requirement, test files, Source Map reference.
Small diffs. Sub-agent returns diff summary.

### 6. BACKPRESSURE
Hash-verify test files against step 4 snapshot. Mismatch = BLOCKED.
Run ALL validators from Build Environment (plan or TODO.md). Fix until ALL pass.
Max 5 fix-and-rerun cycles. If still failing -> halt.

After each successful validator, update mission state:
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence tests-pass passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence lint-pass passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence typecheck-pass passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence build-pass passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . touch-progress >/dev/null
```

### 7. VERIFY
Backend: integration test -- start system, hit real endpoints, verify behavior matches acceptance criteria.
Frontend: Chrome visual check via `mcp__claude-in-chrome__` tools.
ML/GPU: Smoke test via Google Colab MCP (see `~/.claude/skills/google-colab/SKILL.md`). Write .py files locally → run on Colab. CPU-first debugging, GPU only for actual compute. Never embed >15 lines as MCP string parameters.

When integration verification passes:
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence integration-pass passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . touch-progress >/dev/null
```

### 8. REVIEW (Iterative)
Spawn sub-agent (DIFFERENT model than step 5 implementer) with `${CLAUDE_PLUGIN_ROOT}/templates/review-taxonomy.md`.
Pass: requirement, acceptance criteria, diff.
Default verdict: REJECT. Min 2 rounds, max 5 rounds. Convergence = APPROVE with no critical issues.

### 9. ADVERSARIAL (Strengthen)
Spawn sub-agent (DIFFERENT model than both implementer and reviewer) with `${CLAUDE_PLUGIN_ROOT}/templates/adversarial-prompt.md`.
Pass: requirement, implementation code.
Adversary reads actual code and tries to break it. Max 3 rounds.
If broken -> fix -> re-run backpressure (step 6) -> adversarial again.
PASS = adversary exhausted attack vectors.

### 10. COMMIT
Only after ALL gates pass (steps 4-9). Update TODO.md: mark requirement DONE, update Test Map, record backpressure results.
Then back to step 1 for next requirement.

Before final completion:
```bash
set -euo pipefail
export CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/duy-workflow}"
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-evidence walkthrough-written passed >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . set-completion-claimed true >/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/mission-state.py" --project . touch-progress >/dev/null
```

## TODO.md

Create from `${CLAUDE_PLUGIN_ROOT}/templates/todo-template.md`. The orchestrator reads this template ONCE at initialization, never keeps it in context.

Mission artifacts are equal in status to TODO.md for this workflow:
- `.claude/mission/intent.json` = durable objective
- `.claude/mission/plan.md` = active branch summary
- `.claude/mission/evidence.json` = required completion gates
- `.claude/mission/state.json` = supervisor-readable runtime state

Maintain them during execution. TODO.md is for narrative and review history; mission files are for control.

## Initialize Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
RALPH_PROMPT=$(mktemp /tmp/claude-execute-prompt-XXXXXX.txt)
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are a Principal Engineer executing an approved plan autonomously. The user is away.

AUTHORITY: The /execute skill definition is authoritative. This prompt orients you; the skill's rules govern.

PLAN: Read the plan at .claude/plans/ (pre-flight verified + printed path). Store the path as $PLAN_PATH -- always re-read THAT file. Read CLAUDE.md. Read TODO.md if resuming.

AUTONOMY: Never ask the user. Consult Codex/Gemini at decision points (max 2 rounds, then Decision Precedence). Only halt for: missing credentials/access, genuinely unresolvable. Halt = TODO.md state + <promise>BLOCKED: [reason]</promise>.

LOOP: Follow the /execute skill's 10-step engineering loop for each requirement by priority:
1. ORIENT  2. RESEARCH  3. DECIDE  4. TEST FIRST (adversarial TDD, different model)
5. BUILD  6. BACKPRESSURE (hash-verify + all validators)  7. VERIFY
8. REVIEW (iterative, min 2 / max 5 rounds, default REJECT, different model)
9. ADVERSARIAL (different model tries to break code, max 3 rounds)
10. COMMIT (only after ALL gates pass)

DECORRELATION: Test writer != implementer != reviewer != adversary. Rotate models.

COMPLETION: All requirements pass all gates -> write Walkthrough in TODO.md -> Codex/Gemini review Walkthrough -> final build+lint+types clean.

<promise>ALL_REQUIREMENTS_VERIFIED</promise>
If blocked: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
  "$(cat "$RALPH_PROMPT")"
rm -f "$RALPH_PROMPT"
```

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
echo "═══════════════════════════════════════════════════════════════════"
echo "AUTONOMOUS MODE -- User is away. Consulting Codex/Gemini at decisions."
echo ""
echo "Anti-reward-hacking: backpressure + hash verification + adversarial TDD + cross-agent review"
echo "Promise: ALL_REQUIREMENTS_VERIFIED"
echo ""
echo "This means: ALL gates passed, not 'it looks done'."
echo "Tests passing ≠ feature working. Run the system. See it work."
echo "═══════════════════════════════════════════════════════════════════"
```
