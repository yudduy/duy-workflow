#!/bin/bash
# Parse /execute command arguments
# Outputs environment variable assignments that can be eval'd
# Usage: eval "$(./parse-execute-args.sh $ARGUMENTS)"

MAX_ITER=100
AGENT_ID=""
SETUP_ONLY=false
SPEC_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      # Validate: must have a following argument that's not another flag
      if [[ -z "${2:-}" || "$2" == --* ]]; then
        echo "# Warning: --max-iterations requires a number, using default" >&2
        shift
      else
        MAX_ITER="$2"
        shift 2
      fi
      ;;
    --agent-id)
      # Validate: must have a following argument that's not another flag
      if [[ -z "${2:-}" || "$2" == --* ]]; then
        echo "# Warning: --agent-id requires a value, ignoring" >&2
        shift
      else
        AGENT_ID="$2"
        shift 2
      fi
      ;;
    --setup-only)
      SETUP_ONLY=true
      shift
      ;;
    *)
      # Non-flag argument = spec path
      if [[ "$1" != --* && -z "$SPEC_PATH" ]]; then
        SPEC_PATH="$1"
      fi
      shift
      ;;
  esac
done

echo "MAX_ITER=$MAX_ITER"
echo "AGENT_ID=$AGENT_ID"
echo "SETUP_ONLY=$SETUP_ONLY"
echo "SPEC_PATH=$SPEC_PATH"
