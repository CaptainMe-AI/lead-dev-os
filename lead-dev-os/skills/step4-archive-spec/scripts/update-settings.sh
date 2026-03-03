#!/usr/bin/env bash
#
# update-settings.sh — Add a deny rule for archived specs to .claude/settings.json
#
# Usage: bash update-settings.sh [project-root]
#
# Idempotent: skips if the rule already exists.

set -euo pipefail

PROJECT_ROOT="${1:-.}"
SETTINGS_DIR="${PROJECT_ROOT}/.claude"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
DENY_RULE='Read(/lead-dev-os/specs-archived/**)'

# Check jq is available
if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required but not installed. Install it with: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi

# Create .claude directory if needed
if [ ! -d "$SETTINGS_DIR" ]; then
  mkdir -p "$SETTINGS_DIR"
  echo "Created ${SETTINGS_DIR}/"
fi

# Case 1: settings.json doesn't exist — create it
if [ ! -f "$SETTINGS_FILE" ]; then
  jq -n --arg rule "$DENY_RULE" '{"deny": [$rule]}' > "$SETTINGS_FILE"
  echo "Created ${SETTINGS_FILE} with deny rule: ${DENY_RULE}"
  exit 0
fi

# Case 2: settings.json exists — check for deny rule
EXISTING=$(cat "$SETTINGS_FILE")

# Check if rule already exists
if echo "$EXISTING" | jq -e --arg rule "$DENY_RULE" '.deny // [] | index($rule) != null' &>/dev/null; then
  echo "Deny rule already exists in ${SETTINGS_FILE} — skipping."
  exit 0
fi

# Case 3: deny array exists but rule is missing — append
if echo "$EXISTING" | jq -e '.deny' &>/dev/null; then
  echo "$EXISTING" | jq --arg rule "$DENY_RULE" '.deny += [$rule]' > "${SETTINGS_FILE}.tmp"
  mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
  echo "Added deny rule to existing array: ${DENY_RULE}"
  exit 0
fi

# Case 4: no deny array — add one
echo "$EXISTING" | jq --arg rule "$DENY_RULE" '. + {"deny": [$rule]}' > "${SETTINGS_FILE}.tmp"
mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
echo "Added deny array with rule: ${DENY_RULE}"
