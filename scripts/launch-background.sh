#!/bin/bash
# launch-background.sh
# Launches Claude Code in a detached tmux session and fires /duy-workflow:execute.
# On completion: auto-launches adversarial review-loop.sh (claude -p + --resume),
# then sends macOS notification when review passes.

set -euo pipefail
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

SESSION_NAME="ralph-$(date +%s)"
MAX_ITERATIONS=50
MAX_REVIEW_ITER=10
COMMAND="/duy-workflow:execute"
CWD="$(pwd)"
PLUGIN_ROOT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --session-name)      SESSION_NAME="$2";      shift 2 ;;
    --max-iterations)    MAX_ITERATIONS="$2";    shift 2 ;;
    --max-review-iter)   MAX_REVIEW_ITER="$2";   shift 2 ;;
    --command)           COMMAND="$2";           shift 2 ;;
    --plugin-root)       PLUGIN_ROOT="$2";       shift 2 ;;
    *) shift ;;
  esac
done

# Resolve plugin root (needed so notify script can call review-loop.sh)
if [[ -z "$PLUGIN_ROOT" ]]; then
  PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
REVIEW_SCRIPT="$PLUGIN_ROOT/scripts/review-loop.sh"

# ─── Preflight ────────────────────────────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
  echo "❌ tmux not found. Install with: brew install tmux"; exit 1
fi
if ! command -v claude &>/dev/null; then
  echo "❌ claude CLI not found in PATH"; exit 1
fi
if ! command -v jq &>/dev/null; then
  echo "❌ jq not found. Install with: brew install jq"; exit 1
fi

if [[ "$COMMAND" == *"execute"* ]]; then
  PLAN=$(ls -t "$CWD/.claude/plans/"*.md 2>/dev/null | head -1 || echo "")
  if [[ -z "$PLAN" ]]; then
    echo "❌ No plan found in .claude/plans/"
    echo "   Run /duy-workflow:interview first."
    exit 1
  fi
  echo "📋 Plan: $(basename "$PLAN")"
fi

# ─── Write the post-execute script (runs inside tmux after claude exits) ───────
# This chains: execute done → review-loop.sh → macOS notification
AFTER_EXECUTE=$(mktemp /tmp/ralph-after-XXXXXX.sh)
chmod +x "$AFTER_EXECUTE"

cat > "$AFTER_EXECUTE" << AFTER_EOF
#!/bin/bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:\$PATH"
CWD="$CWD"
SESSION_NAME="$SESSION_NAME"
REVIEW_SCRIPT="$REVIEW_SCRIPT"
MAX_REVIEW_ITER="$MAX_REVIEW_ITER"
LOG="\$CWD/.claude/review-\${SESSION_NAME}.log"

# Clean up any lingering ralph state file
rm -f "\$CWD/.claude/ralph-loop."*.local.md 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Execute loop done. Starting adversarial review..."
echo "  Log: \$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ ! -x "\$REVIEW_SCRIPT" ]]; then
  echo "❌ review-loop.sh not found at: \$REVIEW_SCRIPT"
  # Fall back to plain notification
  osascript -e "display notification \"Execute done — review script missing\" with title \"Ralph: \$SESSION_NAME\" sound name \"Basso\"" 2>/dev/null || true
  exit 1
fi

# Run review loop (blocks until complete or max iter)
bash "\$REVIEW_SCRIPT" \
  --cwd "\$CWD" \
  --session-name "\$SESSION_NAME" \
  --max-iterations "\$MAX_REVIEW_ITER" \
  --log "\$LOG"

EXIT_CODE=\$?
rm -f "$AFTER_EXECUTE"
exit \$EXIT_CODE
AFTER_EOF

# ─── Launch tmux session ───────────────────────────────────────────────────────
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
tmux new-session -d -s "$SESSION_NAME" -x 220 -y 50

FULL_COMMAND="$COMMAND --max-iterations $MAX_ITERATIONS"

# Chain: claude (execute) → after_execute script
tmux send-keys -t "$SESSION_NAME" \
  "cd \"$CWD\" && claude; bash \"$AFTER_EXECUTE\"" Enter

# Wait for Claude to initialize then send the command
sleep 4
tmux send-keys -t "$SESSION_NAME" "$FULL_COMMAND" Enter

cat <<EOF

🚀 Background session: $SESSION_NAME

   Execute:  $FULL_COMMAND (up to $MAX_ITERATIONS iterations)
   Review:   adversarial claude -p loop (up to $MAX_REVIEW_ITER iterations)
   Cwd:      $CWD

   Attach:   tmux attach -t $SESSION_NAME
   Detach:   Ctrl+B, D
   Kill:     tmux kill-session -t $SESSION_NAME

   Pipeline: execute → adversarial review → macOS notification
   On completion: review passes → Glass chime + notification
   On failure:    review blocked → Basso chime + notification

   Monitor:
     tail -f .claude/review-${SESSION_NAME}.log   (review progress)
     git log --oneline -10                         (execute progress)
     cat .claude/ralph-loop.*.local.md 2>/dev/null | head -3

EOF
