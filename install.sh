#!/bin/bash
# Install duy-workflow plugin for Claude Code
# Clones to a persistent location, then registers with Claude Code.
# Safe to re-run — idempotent.

set -euo pipefail

PLUGIN_NAME="duy-workflow"
PLUGIN_VERSION="1.0.0"
CLAUDE_DIR="${HOME}/.claude"
MARKETPLACE_DIR="${CLAUDE_DIR}/plugins/marketplaces/${PLUGIN_NAME}"
CACHE_PARENT="${CLAUDE_DIR}/plugins/cache/${PLUGIN_NAME}/${PLUGIN_NAME}"
CACHE_DIR="${CACHE_PARENT}/${PLUGIN_VERSION}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing ${PLUGIN_NAME}..."

# --- Step 1: Ensure source is at marketplace location ---
# If running from a temp dir (e.g. /tmp), copy to permanent location first.
if [[ "$SCRIPT_DIR" != "$MARKETPLACE_DIR" ]]; then
  if [[ -e "$MARKETPLACE_DIR" ]] && [[ ! -L "$MARKETPLACE_DIR" ]]; then
    # Existing non-symlink dir — pull latest instead of overwriting
    if [[ -d "$MARKETPLACE_DIR/.git" ]]; then
      echo "Updating existing installation..."
      git -C "$MARKETPLACE_DIR" pull --ff-only 2>/dev/null || true
    else
      rm -rf "$MARKETPLACE_DIR"
      cp -r "$SCRIPT_DIR" "$MARKETPLACE_DIR"
    fi
  else
    rm -rf "$MARKETPLACE_DIR" 2>/dev/null || true
    mkdir -p "$(dirname "$MARKETPLACE_DIR")"
    cp -r "$SCRIPT_DIR" "$MARKETPLACE_DIR"
  fi
  echo "  Copied to $MARKETPLACE_DIR"
else
  echo "  Running from marketplace dir — no copy needed"
fi

# --- Step 2: Symlink cache → marketplace ---
# Claude Code resolves plugins via the cache path in installed_plugins.json.
if [[ -e "$CACHE_DIR" ]] || [[ -L "$CACHE_DIR" ]]; then
  rm -rf "$CACHE_DIR"
fi
mkdir -p "$CACHE_PARENT"
ln -s "$MARKETPLACE_DIR" "$CACHE_DIR"
echo "  Cache symlinked: $CACHE_DIR -> $MARKETPLACE_DIR"

# --- Step 3: Update installed_plugins.json ---
PLUGINS_FILE="${CLAUDE_DIR}/plugins/installed_plugins.json"
if [ -f "$PLUGINS_FILE" ]; then
  if grep -q "\"${PLUGIN_NAME}@${PLUGIN_NAME}\"" "$PLUGINS_FILE"; then
    echo "  Already registered in installed_plugins.json"
  else
    if command -v jq &>/dev/null; then
      TMP_FILE=$(mktemp)
      jq ".plugins[\"${PLUGIN_NAME}@${PLUGIN_NAME}\"] = [{
        \"scope\": \"user\",
        \"installPath\": \"$CACHE_DIR\",
        \"version\": \"$PLUGIN_VERSION\",
        \"installedAt\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"lastUpdated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
      }]" "$PLUGINS_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$PLUGINS_FILE"
      echo "  Registered in installed_plugins.json"
    else
      echo "  jq not found — add manually to installed_plugins.json"
    fi
  fi
else
  mkdir -p "$(dirname "$PLUGINS_FILE")"
  cat > "$PLUGINS_FILE" << EOF
{
  "version": 2,
  "plugins": {
    "${PLUGIN_NAME}@${PLUGIN_NAME}": [
      {
        "scope": "user",
        "installPath": "$CACHE_DIR",
        "version": "$PLUGIN_VERSION",
        "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      }
    ]
  }
}
EOF
  echo "  Created installed_plugins.json"
fi

# --- Step 4: Enable in settings.json ---
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "\"${PLUGIN_NAME}@${PLUGIN_NAME}\"" "$SETTINGS_FILE"; then
    echo "  Already enabled in settings.json"
  else
    if command -v jq &>/dev/null; then
      TMP_FILE=$(mktemp)
      jq ".enabledPlugins[\"${PLUGIN_NAME}@${PLUGIN_NAME}\"] = true" "$SETTINGS_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$SETTINGS_FILE"
      echo "  Enabled in settings.json"
    fi
  fi
else
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  cat > "$SETTINGS_FILE" << EOF
{
  "enabledPlugins": {
    "${PLUGIN_NAME}@${PLUGIN_NAME}": true
  }
}
EOF
  echo "  Created settings.json"
fi

echo ""
echo "Done! Restart Claude Code to load the plugin."
echo ""
echo "Commands:"
echo "  /duy-workflow:research       - Autonomous experimental research"
echo "  /duy-workflow:interview      - Deep exploration -> SPEC.md"
echo "  /duy-workflow:execute        - Ralph-powered TDD implementation"
echo "  /duy-workflow:discover       - Scientific discovery + hypothesis testing"
echo "  /duy-workflow:distill        - Compress questions into incompressible wisdom"
echo "  /duy-workflow:verify-poc     - Verify PoC with frontier research"
echo "  /duy-workflow:pair           - Pair with Codex as autonomous peer"
echo "  /duy-workflow:derive         - Multi-model mathematical derivation"
echo "  /duy-workflow:commit-push-pr - Commit, push, and create PR"
echo "  /duy-workflow:cancel-ralph   - Cancel active Ralph loop"
