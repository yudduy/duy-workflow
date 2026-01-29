#!/bin/bash
# Parse /discover command arguments
# Outputs environment variable assignments that can be eval'd
# Usage: eval "$(./parse-discover-args.sh $ARGUMENTS)"
#
# The problem statement is NOT parsed here — the LLM reads it from
# the conversation context. Only flags are parsed.

MAX_ITER=30
KNOWLEDGE_PATH=""
RIGOR="adaptive"

while [[ $# -gt 0 ]]; do
  case $1 in
    --knowledge)
      if [[ -z "${2:-}" || "$2" == --* ]]; then
        echo "# Warning: --knowledge requires a path, ignoring" >&2
        shift
      else
        KNOWLEDGE_PATH="$2"
        shift 2
      fi
      ;;
    --max-iterations)
      if [[ -z "${2:-}" || "$2" == --* ]]; then
        echo "# Warning: --max-iterations requires a number, using default" >&2
        shift
      else
        MAX_ITER="$2"
        shift 2
      fi
      ;;
    --rigor)
      if [[ -z "${2:-}" || "$2" == --* ]]; then
        echo "# Warning: --rigor requires a value, using default" >&2
        shift
      else
        RIGOR="$2"
        shift 2
      fi
      ;;
    *)
      # Skip non-flag arguments (problem statement words — handled by LLM, not bash)
      shift
      ;;
  esac
done

echo "MAX_ITER=$MAX_ITER"
echo "KNOWLEDGE_PATH=$KNOWLEDGE_PATH"
echo "RIGOR=$RIGOR"
