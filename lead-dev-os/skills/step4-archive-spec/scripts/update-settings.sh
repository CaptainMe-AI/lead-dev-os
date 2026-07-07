#!/usr/bin/env bash
#
# update-settings.sh — Add a deny rule for archived specs to .claude/settings.json
#
# The rule is added under permissions.deny (the only location Claude Code
# reads deny rules from). Also migrates the rule out of a legacy top-level
# "deny" array if a previous version of this script put it there.
#
# Usage: bash update-settings.sh [project-root]
#
# Idempotent: skips if the rule already exists under permissions.deny.

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
  jq -n --arg rule "$DENY_RULE" '{"permissions": {"deny": [$rule]}}' > "$SETTINGS_FILE"
  echo "Created ${SETTINGS_FILE} with deny rule: ${DENY_RULE}"
  exit 0
fi

EXISTING=$(cat "$SETTINGS_FILE")

# Migration: a previous version of this script wrote the rule to a top-level
# "deny" array, which Claude Code ignores. Remove our rule from there (leave
# any other top-level entries untouched — they aren't ours).
MIGRATED=false
if echo "$EXISTING" | jq -e --arg rule "$DENY_RULE" '.deny // [] | index($rule) != null' &>/dev/null; then
  EXISTING=$(echo "$EXISTING" | jq --arg rule "$DENY_RULE" '.deny -= [$rule] | if .deny == [] then del(.deny) else . end')
  MIGRATED=true
fi

# Check if rule already exists under permissions.deny
if echo "$EXISTING" | jq -e --arg rule "$DENY_RULE" '.permissions.deny // [] | index($rule) != null' &>/dev/null; then
  if [ "$MIGRATED" = true ]; then
    echo "$EXISTING" > "${SETTINGS_FILE}.tmp"
    mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    echo "Removed legacy top-level deny rule; rule already exists under permissions.deny in ${SETTINGS_FILE}."
  else
    echo "Deny rule already exists in ${SETTINGS_FILE} — skipping."
  fi
  exit 0
fi

# Add the rule under permissions.deny, creating the objects as needed and
# preserving every other key.
echo "$EXISTING" | jq --arg rule "$DENY_RULE" '.permissions.deny = ((.permissions.deny // []) + [$rule])' > "${SETTINGS_FILE}.tmp"
mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

if [ "$MIGRATED" = true ]; then
  echo "Migrated legacy top-level deny rule to permissions.deny: ${DENY_RULE}"
else
  echo "Added deny rule to permissions.deny: ${DENY_RULE}"
fi
