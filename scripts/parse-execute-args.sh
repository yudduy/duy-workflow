#!/bin/bash
# Parse /execute command arguments
# Outputs environment variable assignments that can be eval'd
# Usage: eval "$(./parse-execute-args.sh $ARGUMENTS)"

MAX_ITER=100
AGENT_ID=""
SETUP_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      MAX_ITER="$2"
      shift 2
      ;;
    --agent-id)
      AGENT_ID="$2"
      shift 2
      ;;
    --setup-only)
      SETUP_ONLY=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "MAX_ITER=$MAX_ITER"
echo "AGENT_ID=$AGENT_ID"
echo "SETUP_ONLY=$SETUP_ONLY"
