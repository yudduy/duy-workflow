#!/bin/bash
# Install duy-workflow plugin for Claude Code
# Usage: ./install.sh

set -euo pipefail

PLUGIN_NAME="duy-workflow"
PLUGIN_VERSION="1.0.0"
CLAUDE_DIR="${HOME}/.claude"
CACHE_DIR="${CLAUDE_DIR}/plugins/cache/${PLUGIN_NAME}/${PLUGIN_NAME}/${PLUGIN_VERSION}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing ${PLUGIN_NAME}..."

# Create cache directory
mkdir -p "$CACHE_DIR"

# Copy plugin files
cp -r "$SCRIPT_DIR"/.claude-plugin "$CACHE_DIR/"
cp -r "$SCRIPT_DIR"/commands "$CACHE_DIR/"
cp -r "$SCRIPT_DIR"/hooks "$CACHE_DIR/"
cp -r "$SCRIPT_DIR"/scripts "$CACHE_DIR/"
cp -r "$SCRIPT_DIR"/templates "$CACHE_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR"/README.md "$CACHE_DIR/" 2>/dev/null || true

echo "✅ Copied plugin to cache"

# Update installed_plugins.json
PLUGINS_FILE="${CLAUDE_DIR}/plugins/installed_plugins.json"
if [ -f "$PLUGINS_FILE" ]; then
  # Check if already installed
  if grep -q "\"${PLUGIN_NAME}@${PLUGIN_NAME}\"" "$PLUGINS_FILE"; then
    echo "✅ Already registered in installed_plugins.json"
  else
    # Add to existing file using jq if available, otherwise use sed
    if command -v jq &>/dev/null; then
      TMP_FILE=$(mktemp)
      jq ".plugins[\"${PLUGIN_NAME}@${PLUGIN_NAME}\"] = [{
        \"scope\": \"user\",
        \"installPath\": \"$CACHE_DIR\",
        \"version\": \"$PLUGIN_VERSION\",
        \"installedAt\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"lastUpdated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"isLocal\": false
      }]" "$PLUGINS_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$PLUGINS_FILE"
      echo "✅ Registered in installed_plugins.json"
    else
      echo "⚠️  jq not found - please manually add to installed_plugins.json"
    fi
  fi
else
  # Create new file
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
        "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "isLocal": false
      }
    ]
  }
}
EOF
  echo "✅ Created installed_plugins.json"
fi

# Update settings.json
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "\"${PLUGIN_NAME}@${PLUGIN_NAME}\"" "$SETTINGS_FILE"; then
    echo "✅ Already enabled in settings.json"
  else
    if command -v jq &>/dev/null; then
      TMP_FILE=$(mktemp)
      jq ".enabledPlugins[\"${PLUGIN_NAME}@${PLUGIN_NAME}\"] = true" "$SETTINGS_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$SETTINGS_FILE"
      echo "✅ Enabled in settings.json"
    else
      echo "⚠️  jq not found - please manually enable in settings.json"
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
  echo "✅ Created settings.json"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Restart Claude Code, then use:"
echo "  /duy-workflow:gen-claude-md - Generate CLAUDE.md via exploration agents"
echo "  /duy-workflow:interview     - Create spec from interview"
echo "  /duy-workflow:execute       - Execute spec with subagents"
echo "  /duy-workflow:add-mistake   - Add anti-pattern to CLAUDE.md"
