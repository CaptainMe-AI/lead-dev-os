#!/usr/bin/env bash
# Test: update-settings.sh behaves correctly across all cases
#
# Verifies:
# - Creates .claude/settings.json from scratch with deny rule
# - Adds deny array to existing settings without one
# - Appends rule to existing deny array
# - Skips when rule already exists (idempotent)
# - Preserves existing settings keys and deny rules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UPDATE_SCRIPT="$REPO_ROOT/lead-dev-os/skills/step4-archive-spec/scripts/update-settings.sh"
DENY_RULE='Read(/lead-dev-os/specs-archived/**)'

PASSED=0
FAILED=0
TMP_DIR=""

pass() { PASSED=$((PASSED + 1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

setup() {
  TMP_DIR=$(mktemp -d)
}

teardown() {
  [ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}

# Helper: run script and capture output
run_script() {
  bash "$UPDATE_SCRIPT" "$TMP_DIR" 2>&1
}

# Helper: read settings.json
read_settings() {
  cat "$TMP_DIR/.claude/settings.json"
}

# Helper: check if deny rule exists in settings
has_deny_rule() {
  read_settings | jq -e --arg rule "$DENY_RULE" '.deny | index($rule) != null' &>/dev/null
}

echo "update-settings.sh Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"

# --- Prerequisite: jq available ---

echo ""
echo "Prerequisites:"

if command -v jq &>/dev/null; then
  pass "jq is installed"
else
  fail "jq is not installed — all tests will fail"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Results: $PASSED passed, $FAILED failed"
  exit 1
fi

if [ -f "$UPDATE_SCRIPT" ]; then
  pass "update-settings.sh exists"
else
  fail "update-settings.sh not found at $UPDATE_SCRIPT"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Results: $PASSED passed, $FAILED failed"
  exit 1
fi

# --- Case 1: No .claude directory, no settings.json ---

echo ""
echo "Case 1: No existing .claude directory:"

setup

output=$(run_script)

if [ -d "$TMP_DIR/.claude" ]; then
  pass "created .claude/ directory"
else
  fail ".claude/ directory not created"
fi

if [ -f "$TMP_DIR/.claude/settings.json" ]; then
  pass "created settings.json"
else
  fail "settings.json not created"
fi

if has_deny_rule; then
  pass "deny rule present"
else
  fail "deny rule missing"
fi

if read_settings | jq -e '.deny | length == 1' &>/dev/null; then
  pass "deny array has exactly 1 entry"
else
  fail "deny array has unexpected length"
fi

if echo "$output" | grep -q "Created"; then
  pass "output reports creation"
else
  fail "output missing creation message"
fi

teardown

# --- Case 2: .claude/settings.json exists without deny array ---

echo ""
echo "Case 2: Existing settings without deny array:"

setup
mkdir -p "$TMP_DIR/.claude"
echo '{"allow": ["Read(**)"], "timeout": 30}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if has_deny_rule; then
  pass "deny rule added"
else
  fail "deny rule missing"
fi

if read_settings | jq -e '.allow[0] == "Read(**)"' &>/dev/null; then
  pass "preserved existing allow array"
else
  fail "existing allow array lost"
fi

if read_settings | jq -e '.timeout == 30' &>/dev/null; then
  pass "preserved existing timeout key"
else
  fail "existing timeout key lost"
fi

teardown

# --- Case 3: Existing deny array without the rule ---

echo ""
echo "Case 3: Existing deny array without archive rule:"

setup
mkdir -p "$TMP_DIR/.claude"
echo '{"deny": ["Write(/secrets/**)"]}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if has_deny_rule; then
  pass "deny rule appended"
else
  fail "deny rule missing"
fi

if read_settings | jq -e '.deny | length == 2' &>/dev/null; then
  pass "deny array has 2 entries"
else
  fail "deny array has unexpected length (expected 2)"
fi

if read_settings | jq -e '.deny[0] == "Write(/secrets/**)"' &>/dev/null; then
  pass "preserved existing deny rule"
else
  fail "existing deny rule lost"
fi

teardown

# --- Case 4: Rule already exists (idempotent) ---

echo ""
echo "Case 4: Rule already exists (idempotent):"

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"deny": [$rule]}' > "$TMP_DIR/.claude/settings.json"

output=$(run_script)

if read_settings | jq -e '.deny | length == 1' &>/dev/null; then
  pass "deny array still has exactly 1 entry (no duplicate)"
else
  fail "deny array has unexpected length (duplicate added?)"
fi

if echo "$output" | grep -q "already exists"; then
  pass "output reports rule already exists"
else
  fail "output missing 'already exists' message"
fi

teardown

# --- Case 5: Idempotent with other rules present ---

echo ""
echo "Case 5: Idempotent with other deny rules present:"

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"deny": ["Write(/secrets/**)", $rule, "Bash(rm -rf *)"]}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if read_settings | jq -e '.deny | length == 3' &>/dev/null; then
  pass "deny array unchanged (3 entries)"
else
  fail "deny array modified unexpectedly"
fi

teardown

# --- Case 6: Valid JSON output ---

echo ""
echo "Case 6: Output is always valid JSON:"

setup

run_script >/dev/null

if read_settings | jq empty 2>/dev/null; then
  pass "output is valid JSON (fresh create)"
else
  fail "output is invalid JSON (fresh create)"
fi

teardown

setup
mkdir -p "$TMP_DIR/.claude"
echo '{"allow":["Read(**)"],"deny":["Write(/secrets/**)"],"timeout":30}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if read_settings | jq empty 2>/dev/null; then
  pass "output is valid JSON (append to existing)"
else
  fail "output is invalid JSON (append to existing)"
fi

teardown

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
