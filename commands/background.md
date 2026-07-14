---
description: "Launch /execute or /research in a detached tmux session. Fire-and-forget async execution — returns immediately, work continues in background."
argument-hint: "[--max-iterations N] [--research <topic>] [--session-name NAME]"
allowed-tools: Bash
---

# /background

Launch an autonomous loop in a detached tmux session. You get control back immediately. Work continues in the background.

## What it does

1. Checks a plan exists in `.claude/plans/` (runs execute) or takes a research topic (runs research)
2. Creates a named tmux session
3. Launches `claude` inside it
4. Fires `/duy-workflow:execute` or `/duy-workflow:research` automatically
5. Returns session name for monitoring

## Usage

```bash
# Engineering task (requires /interview first to create a plan)
/duy-workflow:background
/duy-workflow:background --max-iterations 30
/duy-workflow:background --session-name my-feature --max-iterations 50

# Research task
/duy-workflow:background --research "governance mechanisms in multi-agent systems"
/duy-workflow:background --research "LLM planning failures" --max-iterations 40
```

## Monitor without re-attaching

```bash
# See current Ralph loop iteration
cat .claude/ralph-loop.*.local.md 2>/dev/null | head -5

# Watch commits roll in
git log --oneline -10

# Attach to check on it
tmux attach -t <session-name>

# Detach again
Ctrl+B, D
```

## Launch

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

# Parse arguments
MAX_ITER=50
SESSION_NAME="ralph-$(date +%s)"
RESEARCH_TOPIC=""

# Read $ARGUMENTS (injected by Claude Code from the command line)
ARGS="${ARGUMENTS:-}"

# Extract --max-iterations
if echo "$ARGS" | grep -q '\-\-max-iterations'; then
  MAX_ITER=$(echo "$ARGS" | sed 's/.*--max-iterations[= ]\([0-9]*\).*/\1/')
fi

# Extract --session-name
if echo "$ARGS" | grep -q '\-\-session-name'; then
  SESSION_NAME=$(echo "$ARGS" | sed "s/.*--session-name[= ]\([^ ]*\).*/\1/")
fi

# Extract --research topic
if echo "$ARGS" | grep -q '\-\-research'; then
  RESEARCH_TOPIC=$(echo "$ARGS" | sed "s/.*--research[= ]['\"]\\?\\([^'\"]*\\)['\"]\\?.*/\1/")
fi

# Determine command
if [[ -n "$RESEARCH_TOPIC" ]]; then
  CMD="/duy-workflow:research \"$RESEARCH_TOPIC\""
  "${CLAUDE_PLUGIN_ROOT}/scripts/launch-background.sh" \
    --session-name "$SESSION_NAME" \
    --max-iterations "$MAX_ITER" \
    --command "$CMD"
else
  "${CLAUDE_PLUGIN_ROOT}/scripts/launch-background.sh" \
    --session-name "$SESSION_NAME" \
    --max-iterations "$MAX_ITER"
fi
```
