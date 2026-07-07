#!/usr/bin/env bash
# Test: update-settings.sh behaves correctly across all cases
#
# Verifies:
# - Creates .claude/settings.json from scratch with the rule under permissions.deny
# - Adds permissions.deny to existing settings without one
# - Appends rule to existing permissions.deny array
# - Skips when rule already exists (idempotent)
# - Preserves existing settings keys and deny rules
# - Migrates the rule out of a legacy top-level "deny" array

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

# Helper: check if deny rule exists under permissions.deny
has_deny_rule() {
  read_settings | jq -e --arg rule "$DENY_RULE" '.permissions.deny // [] | index($rule) != null' &>/dev/null
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
  pass "deny rule present under permissions.deny"
else
  fail "deny rule missing from permissions.deny"
fi

if read_settings | jq -e '.permissions.deny | length == 1' &>/dev/null; then
  pass "permissions.deny has exactly 1 entry"
else
  fail "permissions.deny has unexpected length"
fi

if read_settings | jq -e 'has("deny") | not' &>/dev/null; then
  pass "no top-level deny key created"
else
  fail "top-level deny key created (Claude Code ignores it)"
fi

if echo "$output" | grep -q "Created"; then
  pass "output reports creation"
else
  fail "output missing creation message"
fi

teardown

# --- Case 2: .claude/settings.json exists without permissions key ---

echo ""
echo "Case 2: Existing settings without permissions key:"

setup
mkdir -p "$TMP_DIR/.claude"
echo '{"env": {"FOO": "bar"}, "timeout": 30}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if has_deny_rule; then
  pass "deny rule added under permissions.deny"
else
  fail "deny rule missing"
fi

if read_settings | jq -e '.env.FOO == "bar"' &>/dev/null; then
  pass "preserved existing env key"
else
  fail "existing env key lost"
fi

if read_settings | jq -e '.timeout == 30' &>/dev/null; then
  pass "preserved existing timeout key"
else
  fail "existing timeout key lost"
fi

teardown

# --- Case 3: Existing permissions.deny array without the rule ---

echo ""
echo "Case 3: Existing permissions.deny without archive rule:"

setup
mkdir -p "$TMP_DIR/.claude"
echo '{"permissions": {"allow": ["Read(**)"], "deny": ["Write(/secrets/**)"]}}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if has_deny_rule; then
  pass "deny rule appended"
else
  fail "deny rule missing"
fi

if read_settings | jq -e '.permissions.deny | length == 2' &>/dev/null; then
  pass "permissions.deny has 2 entries"
else
  fail "permissions.deny has unexpected length (expected 2)"
fi

if read_settings | jq -e '.permissions.deny[0] == "Write(/secrets/**)"' &>/dev/null; then
  pass "preserved existing deny rule"
else
  fail "existing deny rule lost"
fi

if read_settings | jq -e '.permissions.allow[0] == "Read(**)"' &>/dev/null; then
  pass "preserved existing permissions.allow"
else
  fail "existing permissions.allow lost"
fi

teardown

# --- Case 4: Rule already exists (idempotent) ---

echo ""
echo "Case 4: Rule already exists (idempotent):"

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"permissions": {"deny": [$rule]}}' > "$TMP_DIR/.claude/settings.json"

output=$(run_script)

if read_settings | jq -e '.permissions.deny | length == 1' &>/dev/null; then
  pass "permissions.deny still has exactly 1 entry (no duplicate)"
else
  fail "permissions.deny has unexpected length (duplicate added?)"
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
jq -n --arg rule "$DENY_RULE" '{"permissions": {"deny": ["Write(/secrets/**)", $rule, "Bash(rm -rf *)"]}}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if read_settings | jq -e '.permissions.deny | length == 3' &>/dev/null; then
  pass "permissions.deny unchanged (3 entries)"
else
  fail "permissions.deny modified unexpectedly"
fi

teardown

# --- Case 6: Legacy migration — rule in top-level deny array ---

echo ""
echo "Case 6: Migrates rule from legacy top-level deny:"

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"deny": [$rule]}' > "$TMP_DIR/.claude/settings.json"

output=$(run_script)

if has_deny_rule; then
  pass "rule now under permissions.deny"
else
  fail "rule missing from permissions.deny after migration"
fi

if read_settings | jq -e 'has("deny") | not' &>/dev/null; then
  pass "empty legacy top-level deny removed"
else
  fail "legacy top-level deny still present"
fi

teardown

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"deny": ["Write(/secrets/**)", $rule]}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if has_deny_rule; then
  pass "rule migrated to permissions.deny (mixed legacy array)"
else
  fail "rule missing from permissions.deny (mixed legacy array)"
fi

if read_settings | jq -e '.deny == ["Write(/secrets/**)"]' &>/dev/null; then
  pass "foreign top-level deny entry left untouched"
else
  fail "foreign top-level deny entry modified"
fi

teardown

setup
mkdir -p "$TMP_DIR/.claude"
jq -n --arg rule "$DENY_RULE" '{"deny": [$rule], "permissions": {"deny": [$rule]}}' > "$TMP_DIR/.claude/settings.json"

run_script >/dev/null

if read_settings | jq -e '.permissions.deny | length == 1' &>/dev/null; then
  pass "no duplicate when rule exists in both locations"
else
  fail "duplicate created when rule exists in both locations"
fi

if read_settings | jq -e 'has("deny") | not' &>/dev/null; then
  pass "legacy top-level copy removed"
else
  fail "legacy top-level copy still present"
fi

teardown

# --- Case 7: Valid JSON output ---

echo ""
echo "Case 7: Output is always valid JSON:"

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
echo '{"permissions":{"allow":["Read(**)"],"deny":["Write(/secrets/**)"]},"timeout":30}' > "$TMP_DIR/.claude/settings.json"

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
