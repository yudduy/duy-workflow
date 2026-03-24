#!/bin/bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

# Ralph Wiggum Stop Hook
# Prevents session exit when a ralph-loop is active
# Uses Haiku judge to verify completion instead of brittle string matching
# Feeds Claude's output back as input to continue the loop

set -euo pipefail

# --- Recursion guard ---
# If we ARE the Haiku judge, allow stop immediately
if [[ "${CLAUDE_HOOK_JUDGE_MODE:-}" = "true" ]]; then
  exit 0
fi

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(/bin/cat)

# Use PPID for session isolation
CLAUDE_SESSION_PID=$PPID
RALPH_STATE_FILE=".claude/ralph-loop.${CLAUDE_SESSION_PID}.local.md"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  # No active loop for THIS session - allow exit
  exit 0
fi

# Parse markdown frontmatter (YAML between ---) and extract values
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# --- Haiku judge configuration ---
JUDGE_MODEL="${RALPH_JUDGE_MODEL:-haiku}"
JUDGE_TIMEOUT="${RALPH_JUDGE_TIMEOUT:-30}"
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

# Check if max iterations reached
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
# Prevent runaway loops: max N continuations per time window
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty')
THROTTLE_FILE="/tmp/.ralph-throttle-${SESSION_ID:-$CLAUDE_SESSION_PID}"

if [[ -f "$THROTTLE_FILE" ]]; then
  THROTTLE_DATA=$(cat "$THROTTLE_FILE")
  THROTTLE_COUNT=$(echo "$THROTTLE_DATA" | cut -d: -f1)
  THROTTLE_TS=$(echo "$THROTTLE_DATA" | cut -d: -f2)
  NOW=$(date +%s)

  # Reset if window expired
  if [[ $((NOW - THROTTLE_TS)) -ge $THROTTLE_WINDOW ]]; then
    THROTTLE_COUNT=0
    THROTTLE_TS=$NOW
  fi

  # Hard stop if throttle exceeded
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

# --- Fast path: explicit completion promise ---
# If the promise tag is present with the exact text, skip Haiku judge
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=""
  if echo "$LAST_OUTPUT" | grep -q '<promise>'; then
    PROMISE_TEXT=$(echo "$LAST_OUTPUT" | sed -n 's/.*<promise>\([^<]*\)<\/promise>.*/\1/p' | head -1 | tr -s ' ' | sed 's/^ *//;s/ *$//')
  fi
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "✅ Ralph loop: Detected <promise>$COMPLETION_PROMISE</promise>"
    rm -f "$THROTTLE_FILE"
    rm "$RALPH_STATE_FILE"
    exit 0
  fi
fi

# --- Haiku judge: is the work actually done? ---
# Extract context for the judge (last few transcript entries, capped at 16KB)
JUDGE_CONTEXT=$(tail -n 4 "$TRANSCRIPT_PATH" | jq -s '.' 2>/dev/null | head -c 16384)

# Extract the original task prompt from state file
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "⚠️  Ralph loop: No prompt text in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Build the judge prompt
JUDGE_SYSTEM="You are a strict completion verifier for an autonomous agent loop. Your job: determine if the agent has GENUINELY finished or is just CLAIMING to be done.

CRITICAL: Agents reward-hack completion. Saying 'done' is NOT evidence of being done. Showing test output is NOT evidence unless ALL structural gates passed. Default to CONTINUE when uncertain.

CONTINUE (should_continue: true) when the assistant:
  - States next steps it intends to take
  - Has pending items in a checklist or TODO
  - Encountered an error or test failure not yet resolved
  - Is partway through implementation
  - Claims completion but the output shows incomplete work (missing tests, failing lint, no integration verification, no cross-agent review, no walkthrough written)
  - Claims completion but has NOT shown: all tests passing AND lint/types clean AND integration verified AND cross-agent review done AND TODO.md walkthrough written
  - Says 'done' without evidence of verification gates passing

STOP (should_continue: false) ONLY when:
  - The assistant output contains <promise>COMPLETION_TAG</promise> with the exact expected tag
  - The assistant is genuinely BLOCKED and cannot proceed (missing credentials, access denied, dependency unavailable)
  - Max iterations would be exceeded

NEVER stop just because the assistant:
  - Says it is done or complete
  - Shows tests passing (tests passing != feature working)
  - Writes a summary
  - Asks if the user wants anything else

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

# Call Haiku judge with recursion guard
JUDGE_RESULT=""
SHOULD_CONTINUE="false"
JUDGE_REASONING=""

if command -v claude &>/dev/null; then
  # Create isolated working dir for judge
  JUDGE_DIR="${HOME}/.claude/ralph-judge"
  mkdir -p "$JUDGE_DIR"

  if JUDGE_RESULT=$(
    CLAUDE_HOOK_JUDGE_MODE=true \
    timeout "$JUDGE_TIMEOUT" \
    claude --print \
      --model "$JUDGE_MODEL" \
      --output-format json \
      --json-schema "$JUDGE_SCHEMA" \
      --system-prompt "$JUDGE_SYSTEM" \
      --disallowedTools '*' \
      --cwd "$JUDGE_DIR" \
      "$JUDGE_PROMPT" 2>/dev/null
  ); then
    SHOULD_CONTINUE=$(echo "$JUDGE_RESULT" | jq -r '.should_continue // false')
    JUDGE_REASONING=$(echo "$JUDGE_RESULT" | jq -r '.reasoning // "no reasoning"')
  else
    # Judge failed — fail open (allow stop)
    echo "⚠️  Ralph loop: Haiku judge timed out or failed. Allowing stop (fail-open)." >&2
    exit 0
  fi
else
  # claude CLI not available — fall back to always-continue (original behavior)
  echo "⚠️  Ralph loop: claude CLI not found, falling back to auto-continue" >&2
  SHOULD_CONTINUE="true"
  JUDGE_REASONING="fallback: no judge available"
fi

# --- Judge says done: allow stop ---
if [[ "$SHOULD_CONTINUE" != "true" ]]; then
  echo "✅ Ralph loop: Haiku judge says complete (iteration $ITERATION)"
  echo "   Reasoning: $JUDGE_REASONING"
  rm -f "$THROTTLE_FILE"
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# --- Judge says continue: block stop ---
NEXT_ITERATION=$((ITERATION + 1))

# Update throttle counter
echo "$((THROTTLE_COUNT + 1)):$THROTTLE_TS" > "$THROTTLE_FILE"

# Update iteration in state file atomically
TEMP_FILE="${RALPH_STATE_FILE}.tmp.$$"
trap "rm -f '$TEMP_FILE'" EXIT
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"
trap - EXIT

# Build system message
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="🔄 Ralph iteration $NEXT_ITERATION (judge: continue) | To stop: output <promise>$COMPLETION_PROMISE</promise> (ONLY when TRUE)"
else
  SYSTEM_MSG="🔄 Ralph iteration $NEXT_ITERATION (judge: continue — $JUDGE_REASONING)"
fi

# Block stop and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
