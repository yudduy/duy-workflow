#!/bin/bash
source "${HOME}/.claude/hooks/env.sh" 2>/dev/null || export PATH="/Users/duy/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Ralph Wiggum Stop Hook
# Prevents session exit when a ralph-loop is active
# Two-stage verification: Haiku judge (text analysis) + HiQ verifier (reads actual artifacts)
# Feeds Claude's output back as input to continue the loop

set -euo pipefail

# --- Recursion guard ---
if [[ "${CLAUDE_HOOK_JUDGE_MODE:-}" = "true" ]]; then
  exit 0
fi

# --- Fast-path (REQ-12): check for Ralph loop BEFORE reading stdin ---
CLAUDE_SESSION_PID=$PPID
RALPH_STATE_FILE=".claude/ralph-loop.${CLAUDE_SESSION_PID}.local.md"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  # No active loop — skip stdin read entirely
  exit 0
fi

# Read hook input from stdin (only when Ralph loop is active)
HOOK_INPUT=$(/bin/cat)

# Parse markdown frontmatter (YAML between ---) and extract values
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# --- Configuration ---
JUDGE_MODEL="${RALPH_JUDGE_MODEL:-haiku}"
JUDGE_TIMEOUT="${RALPH_JUDGE_TIMEOUT:-30}"
VERIFY_MODEL="${RALPH_VERIFY_MODEL:-haiku}"
VERIFY_TIMEOUT="${RALPH_VERIFY_TIMEOUT:-90}"
THROTTLE_MAX="${RALPH_THROTTLE_MAX:-5}"
THROTTLE_WINDOW="${RALPH_THROTTLE_WINDOW:-300}"  # 5 minutes

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Ralph loop: State file corrupted (iteration='$ITERATION')" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Ralph loop: State file corrupted (max_iterations='$MAX_ITERATIONS')" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check if max iterations reached — hard limit, no verification
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 Ralph loop: Max iterations ($MAX_ITERATIONS) reached."
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  Ralph loop: Transcript not found ($TRANSCRIPT_PATH)" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# --- Throttle check ---
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
THROTTLE_FILE="/tmp/.ralph-throttle-${SESSION_ID:-$CLAUDE_SESSION_PID}"

if [[ -f "$THROTTLE_FILE" ]]; then
  THROTTLE_DATA=$(cat "$THROTTLE_FILE")
  THROTTLE_COUNT=$(echo "$THROTTLE_DATA" | cut -d: -f1)
  THROTTLE_TS=$(echo "$THROTTLE_DATA" | cut -d: -f2)
  NOW=$(date +%s)

  if [[ $((NOW - THROTTLE_TS)) -ge $THROTTLE_WINDOW ]]; then
    THROTTLE_COUNT=0
    THROTTLE_TS=$NOW
  fi

  if [[ $THROTTLE_COUNT -ge $THROTTLE_MAX ]]; then
    echo "🛑 Ralph loop: Throttle limit ($THROTTLE_MAX per ${THROTTLE_WINDOW}s) reached. Cooling down." >&2
    rm "$THROTTLE_FILE"
    rm "$RALPH_STATE_FILE"
    exit 0
  fi
else
  THROTTLE_COUNT=0
  THROTTLE_TS=$(date +%s)
fi

# Extract last assistant message
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "⚠️  Ralph loop: No assistant messages in transcript" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "⚠️  Ralph loop: Failed to extract last assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if ! LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>&1); then
  echo "⚠️  Ralph loop: Failed to parse assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "⚠️  Ralph loop: Empty assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Extract the original task prompt from state file
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "⚠️  Ralph loop: No prompt text in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# HiQ VERIFICATION FUNCTION
# Spawns a Haiku agent WITH tools that reads actual project
# artifacts to verify work quality. Not text analysis — file reads.
# ═══════════════════════════════════════════════════════════════

run_hiq_verifier() {
  local trigger_reason="$1"

  VERIFY_SYSTEM='You are a HiQ (High-Quality) verification agent. You READ ACTUAL FILES to verify work — not conversation text.

PROCEDURE:
1. Find the plan: look in .claude/plans/*.md, docs/plans/PLAN.md, or similar
2. Read the plan — extract ALL requirements (REQ-1, REQ-2, etc.) and acceptance criteria
3. Find TODO.md in the project root or docs/
4. Read TODO.md — check each requirement status and verification evidence
5. Check for a Walkthrough section in TODO.md (required by /execute workflow)
6. Check git status — any uncommitted work means incomplete
7. If build/test commands are in the plan, check TODO.md for logged output

VERIFIED (verified: true) ONLY when ALL of:
  - Every requirement from the plan has DONE status with logged verification evidence
  - TODO.md Walkthrough section exists and notes cross-agent review
  - git status shows clean working tree (all committed)
  - No BLOCKED or PENDING items remain

REJECTED (verified: false) when ANY of:
  - Any requirement lacks verification evidence in TODO.md
  - TODO.md missing, incomplete, or no Walkthrough
  - Uncommitted changes in git status
  - Evidence of skipped gates (no test output, no review logged)
  - Plan file not found (agent may not have created one)

Be SPECIFIC about what is missing. Name the requirement IDs and what evidence is absent.'

  VERIFY_SCHEMA='{
    "type": "object",
    "properties": {
      "verified": { "type": "boolean" },
      "missing": { "type": "array", "items": { "type": "string" } },
      "reasoning": { "type": "string" }
    },
    "required": ["verified", "missing", "reasoning"],
    "additionalProperties": false
  }'

  VERIFY_PROMPT="The autonomous agent claims completion ($trigger_reason).

Original task:
---
$PROMPT_TEXT
---

READ the actual project files to verify. Check plan, TODO.md, git status. Return your assessment."

  if ! command -v claude &>/dev/null; then
    echo "⚠️  Ralph loop: claude CLI not found for HiQ verifier. Allowing stop." >&2
    echo "PASS"
    return 0
  fi

  local verify_result=""
  local project_dir
  project_dir="$(pwd)"
  if verify_result=$(
    cd "$project_dir" && \
    printf '%s' "$VERIFY_PROMPT" | \
    CLAUDE_HOOK_JUDGE_MODE=true \
    CLAUDECODE="" \
    CLAUDE_CODE_ENTRYPOINT="" \
    timeout "$VERIFY_TIMEOUT" \
    claude --print \
      --model "$VERIFY_MODEL" \
      --output-format json \
      --json-schema "$VERIFY_SCHEMA" \
      --system-prompt "$VERIFY_SYSTEM" \
      --disallowedTools 'Write,Edit,NotebookEdit,Agent' \
      2>/dev/null
  ); then
    # --output-format json wraps result in envelope with .structured_output
    local verified
    verified=$(echo "$verify_result" | jq -r '.structured_output.verified // .verified // false')
    local missing
    missing=$(echo "$verify_result" | jq -r '(.structured_output.missing // .missing // []) | join("; ")' 2>/dev/null || echo "")
    local reasoning
    reasoning=$(echo "$verify_result" | jq -r '.structured_output.reasoning // .reasoning // "no reasoning"')

    if [[ "$verified" = "true" ]]; then
      echo "✅ HiQ VERIFIED: $reasoning" >&2
      echo "PASS"
    else
      echo "❌ HiQ REJECTED: $reasoning" >&2
      echo "   Missing: $missing" >&2
      # Return rejection with missing items (no special delimiters)
      echo "FAIL:${missing:0:500}"
    fi
  else
    # Verifier timed out or errored — fail open
    echo "⚠️  Ralph loop: HiQ verifier timed out. Allowing stop (fail-open)." >&2
    echo "PASS"
  fi
}

# Helper: block stop and continue loop with feedback
block_and_continue() {
  local feedback_msg="$1"
  local next_iter=$((ITERATION + 1))

  # Update throttle counter
  echo "$((THROTTLE_COUNT + 1)):$THROTTLE_TS" > "$THROTTLE_FILE"

  # Update iteration atomically
  local temp_file="${RALPH_STATE_FILE}.tmp.$$"
  trap "rm -f '$temp_file'" EXIT
  sed "s/^iteration: .*/iteration: $next_iter/" "$RALPH_STATE_FILE" > "$temp_file"
  mv "$temp_file" "$RALPH_STATE_FILE"
  trap - EXIT

  # Build system message
  local sys_msg
  if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
    sys_msg="🔄 Ralph iteration $next_iter | $feedback_msg | To stop: output <promise>$COMPLETION_PROMISE</promise> (ONLY when TRUE)"
  else
    sys_msg="🔄 Ralph iteration $next_iter | $feedback_msg"
  fi

  jq -n \
    --arg prompt "$PROMPT_TEXT" \
    --arg msg "$sys_msg" \
    '{
      "decision": "block",
      "reason": $prompt,
      "systemMessage": $msg
    }'
}

# Helper: allow stop and clean up
allow_stop() {
  local msg="$1"
  echo "$msg"
  rm -f "$THROTTLE_FILE"
  rm "$RALPH_STATE_FILE"
  exit 0
}

# ═══════════════════════════════════════════════════════════════
# STAGE 1: Promise tag detection (fast path check)
# ═══════════════════════════════════════════════════════════════

PROMISE_DETECTED=false
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=""
  if echo "$LAST_OUTPUT" | grep -q '<promise>'; then
    PROMISE_TEXT=$(echo "$LAST_OUTPUT" | sed -n 's/.*<promise>\([^<]*\)<\/promise>.*/\1/p' | head -1 | tr -s ' ' | sed 's/^ *//;s/ *$//')
  fi
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    PROMISE_DETECTED=true
  fi
fi

# ═══════════════════════════════════════════════════════════════
# STAGE 2: If promise detected, run HiQ verification before stop
# ═══════════════════════════════════════════════════════════════

if [[ "$PROMISE_DETECTED" = "true" ]]; then
  echo "🔍 Ralph loop: Promise tag detected. Running HiQ verification..." >&2

  HIQ_RESULT=$(run_hiq_verifier "promise tag: $COMPLETION_PROMISE")

  if [[ "$HIQ_RESULT" = "PASS" ]]; then
    allow_stop "✅ Ralph loop: Promise + HiQ verified (iteration $ITERATION)"
  else
    HIQ_MISSING="${HIQ_RESULT#FAIL:}"
    block_and_continue "HiQ REJECTED your completion claim. Missing: $HIQ_MISSING. Fix these before claiming done"
    exit 0
  fi
fi

# ═══════════════════════════════════════════════════════════════
# STAGE 3: Haiku judge (text analysis — should the loop continue?)
# ═══════════════════════════════════════════════════════════════

JUDGE_CONTEXT=$(tail -n 4 "$TRANSCRIPT_PATH" | jq -s '.' 2>/dev/null | head -c 16384)

JUDGE_SYSTEM="You are a strict completion verifier for an autonomous agent loop. Your job: determine if the agent has GENUINELY finished or is just CLAIMING to be done.

CRITICAL: Agents reward-hack completion. Saying 'done' is NOT evidence of being done. Default to CONTINUE when uncertain.

CONTINUE (should_continue: true) when the assistant:
  - States next steps it intends to take
  - Has pending items in a checklist or TODO
  - Encountered an error or test failure not yet resolved
  - Is partway through implementation
  - Claims completion without showing ALL gates passed
  - Says 'done' without evidence of verification gates passing

STOP (should_continue: false) ONLY when:
  - The assistant output contains <promise>COMPLETION_TAG</promise> with the exact expected tag
  - The assistant is genuinely BLOCKED and cannot proceed (missing credentials, access denied)

NEVER stop just because the assistant says it is done, shows tests passing, writes a summary, or asks the user.

The agent MUST output the explicit <promise> tag to stop. Everything else = CONTINUE."

JUDGE_SCHEMA='{
  "type": "object",
  "properties": {
    "should_continue": { "type": "boolean" },
    "reasoning": { "type": "string" }
  },
  "required": ["should_continue", "reasoning"],
  "additionalProperties": false
}'

JUDGE_PROMPT="Original task:
---
$PROMPT_TEXT
---

Assistant's latest output (last ~16KB of conversation):
---
$JUDGE_CONTEXT
---

Classify: should the loop continue or is the task done?"

SHOULD_CONTINUE="false"
JUDGE_REASONING=""

if command -v claude &>/dev/null; then
  JUDGE_DIR="${HOME}/.claude/ralph-judge"
  mkdir -p "$JUDGE_DIR"

  if JUDGE_RESULT=$(
    cd "$JUDGE_DIR" && \
    printf '%s' "$JUDGE_PROMPT" | \
    CLAUDE_HOOK_JUDGE_MODE=true \
    CLAUDECODE="" \
    CLAUDE_CODE_ENTRYPOINT="" \
    timeout "$JUDGE_TIMEOUT" \
    claude --print \
      --model "$JUDGE_MODEL" \
      --output-format json \
      --json-schema "$JUDGE_SCHEMA" \
      --system-prompt "$JUDGE_SYSTEM" \
      --disallowedTools '*' \
      2>/dev/null
  ); then
    SHOULD_CONTINUE=$(echo "$JUDGE_RESULT" | jq -r '.structured_output.should_continue // .should_continue // false')
    JUDGE_REASONING=$(echo "$JUDGE_RESULT" | jq -r '.structured_output.reasoning // .reasoning // "no reasoning"')
  else
    echo "⚠️  Ralph loop: Haiku judge timed out or failed. Allowing stop (fail-open)." >&2
    exit 0
  fi
else
  echo "⚠️  Ralph loop: claude CLI not found, falling back to auto-continue" >&2
  SHOULD_CONTINUE="true"
  JUDGE_REASONING="fallback: no judge available"
fi

# ═══════════════════════════════════════════════════════════════
# STAGE 4: If judge says done (BLOCKED), run HiQ before allowing stop
# ═══════════════════════════════════════════════════════════════

if [[ "$SHOULD_CONTINUE" != "true" ]]; then
  echo "🔍 Ralph loop: Judge says done. Running HiQ verification..." >&2

  HIQ_RESULT=$(run_hiq_verifier "judge verdict: $JUDGE_REASONING")

  if [[ "$HIQ_RESULT" = "PASS" ]]; then
    allow_stop "✅ Ralph loop: Judge + HiQ verified (iteration $ITERATION). $JUDGE_REASONING"
  else
    HIQ_MISSING="${HIQ_RESULT#FAIL:}"
    block_and_continue "HiQ REJECTED stop. Judge said done but artifacts incomplete. Missing: $HIQ_MISSING"
    exit 0
  fi
fi

# ═══════════════════════════════════════════════════════════════
# STAGE 5: Judge says continue — block stop, feed prompt back
# ═══════════════════════════════════════════════════════════════

block_and_continue "judge: continue — $JUDGE_REASONING"
exit 0
