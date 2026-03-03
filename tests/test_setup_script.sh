#!/usr/bin/env bash
# Test: configure-project skill setup.sh script
#
# Functionally tests setup.sh by running it in a temporary directory
# and verifying the scaffolded output.
#
# Verifies:
# - Required arguments are enforced
# - Directories are created
# - Standards are copied
# - Templates are rendered with substitution
# - Stack placeholder dirs are created
# - Overwrite / skip behavior works
# - Structured output sections are correct
# - Idempotent re-runs skip existing files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/lead-dev-os"
SETUP_SH="$PLUGIN_DIR/skills/configure-project/scripts/setup.sh"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

# Create a fresh temp directory for each test group
TMPBASE="$(mktemp -d)"
trap 'rm -rf "$TMPBASE"' EXIT

# Helper: create a fresh target dir and cd into it
fresh_target() {
  local dir="$TMPBASE/$1"
  mkdir -p "$dir"
  echo "$dir"
}

echo "Setup Script Tests"
echo "━━━━━━━━━━━━━━━━━━"

# =============================================================================
# Required arguments
# =============================================================================

echo ""
echo "Required arguments:"

# Missing --project
if output=$("$SETUP_SH" --plugin-root "$PLUGIN_DIR" 2>&1) && false; then
  fail "--project not required (should fail)"
else
  if echo "$output" | grep -q "project.*required"; then
    pass "fails without --project"
  else
    fail "missing --project error message unclear: $output"
  fi
fi

# Missing --plugin-root
if output=$("$SETUP_SH" --project "TestApp" 2>&1) && false; then
  fail "--plugin-root not required (should fail)"
else
  if echo "$output" | grep -q "plugin-root.*required"; then
    pass "fails without --plugin-root"
  else
    fail "missing --plugin-root error message unclear: $output"
  fi
fi

# Unknown argument
if output=$("$SETUP_SH" --project "TestApp" --plugin-root "$PLUGIN_DIR" --bogus 2>&1) && false; then
  fail "accepts unknown arguments (should fail)"
else
  if echo "$output" | grep -q "Unknown argument"; then
    pass "rejects unknown arguments"
  else
    fail "unknown argument error message unclear: $output"
  fi
fi

# =============================================================================
# Fresh run — directories, standards, templates
# =============================================================================

echo ""
echo "Fresh run:"

TARGET1="$(fresh_target fresh-run)"
output=$(cd "$TARGET1" && "$SETUP_SH" --project "My Cool App" --plugin-root "$PLUGIN_DIR" 2>&1)

# Directories created
for dir in "agents-context/concepts" "agents-context/standards" "agents-context/guides" "lead-dev-os/specs"; do
  if [ -d "$TARGET1/$dir" ]; then
    pass "created $dir"
  else
    fail "missing $dir"
  fi
done

# Output contains ===DIRS=== section
if echo "$output" | grep -q "===DIRS==="; then
  pass "output includes ===DIRS=== section"
else
  fail "output missing ===DIRS=== section"
fi

# =============================================================================
# Standards copied
# =============================================================================

echo ""
echo "Standards:"

EXPECTED_STANDARDS=(
  "coding-style.md"
  "commenting.md"
  "conventions.md"
  "error-handling.md"
  "validation.md"
  "test-writing.md"
)

for std in "${EXPECTED_STANDARDS[@]}"; do
  if [ -f "$TARGET1/agents-context/standards/$std" ]; then
    pass "copied $std"
  else
    fail "missing $std"
  fi
done

# Verify copied content matches source
SAMPLE_SRC="$PLUGIN_DIR/skills/configure-project/standards-global/coding-style.md"
SAMPLE_DEST="$TARGET1/agents-context/standards/coding-style.md"
if diff -q "$SAMPLE_SRC" "$SAMPLE_DEST" &>/dev/null; then
  pass "copied standards match source content"
else
  fail "copied standards differ from source"
fi

# Output contains ===STANDARDS=== section
if echo "$output" | grep -q "===STANDARDS==="; then
  pass "output includes ===STANDARDS=== section"
else
  fail "output missing ===STANDARDS=== section"
fi

# =============================================================================
# Templates rendered
# =============================================================================

echo ""
echo "Templates:"

if [ -f "$TARGET1/agents-context/guides/workflow.md" ]; then
  pass "rendered workflow.md"
else
  fail "missing workflow.md"
fi

if [ -f "$TARGET1/agents-context/AGENTS.md" ]; then
  pass "rendered AGENTS.md"
else
  fail "missing AGENTS.md"
fi

if [ -f "$TARGET1/agents-context/README.md" ]; then
  pass "rendered README.md"
else
  fail "missing README.md"
fi

# README substitution: {Project Name} replaced with "My Cool App"
if grep -q "My Cool App" "$TARGET1/agents-context/README.md"; then
  pass "README.md has project name substituted"
else
  fail "README.md still contains placeholder or missing project name"
fi

if ! grep -q '{Project Name}' "$TARGET1/agents-context/README.md"; then
  pass "README.md has no leftover {Project Name} placeholder"
else
  fail "README.md still contains {Project Name} placeholder"
fi

# Output contains ===TEMPLATES=== section
if echo "$output" | grep -q "===TEMPLATES==="; then
  pass "output includes ===TEMPLATES=== section"
else
  fail "output missing ===TEMPLATES=== section"
fi

# =============================================================================
# ===DONE=== marker
# =============================================================================

echo ""
echo "Completion:"

if echo "$output" | grep -q "===DONE==="; then
  pass "output ends with ===DONE==="
else
  fail "output missing ===DONE==="
fi

# =============================================================================
# Stack placeholders
# =============================================================================

echo ""
echo "Stack directories:"

TARGET2="$(fresh_target stacks-run)"
output=$(cd "$TARGET2" && "$SETUP_SH" --project "StackApp" --stacks "react,python,postgres" --plugin-root "$PLUGIN_DIR" 2>&1)

for stack in "react" "python" "postgres"; do
  stack_dir="$TARGET2/agents-context/standards/$stack"
  if [ -d "$stack_dir" ]; then
    pass "created stack dir $stack"
  else
    fail "missing stack dir $stack"
  fi

  if [ -f "$stack_dir/.gitkeep" ]; then
    pass "$stack has .gitkeep"
  else
    fail "$stack missing .gitkeep"
  fi
done

# Output contains ===STACKS=== section
if echo "$output" | grep -q "===STACKS==="; then
  pass "output includes ===STACKS=== section"
else
  fail "output missing ===STACKS=== section"
fi

# =============================================================================
# No stacks — no ===STACKS=== section
# =============================================================================

echo ""
echo "No stacks flag:"

# Re-check first run output (no --stacks)
output_no_stacks=$(cd "$(fresh_target no-stacks)" && "$SETUP_SH" --project "NoStackApp" --plugin-root "$PLUGIN_DIR" 2>&1)
if ! echo "$output_no_stacks" | grep -q "===STACKS==="; then
  pass "no ===STACKS=== when --stacks omitted"
else
  fail "===STACKS=== present without --stacks flag"
fi

# =============================================================================
# Idempotent re-run — files skipped
# =============================================================================

echo ""
echo "Idempotent re-run (skip existing):"

TARGET3="$(fresh_target idempotent)"
# First run
cd "$TARGET3" && "$SETUP_SH" --project "IdempotentApp" --plugin-root "$PLUGIN_DIR" >/dev/null 2>&1

# Second run — should skip existing files
output2=$(cd "$TARGET3" && "$SETUP_SH" --project "IdempotentApp" --plugin-root "$PLUGIN_DIR" 2>&1)

if echo "$output2" | grep -q "===SKIPPED==="; then
  pass "second run reports ===SKIPPED=== section"
else
  fail "second run missing ===SKIPPED=== section"
fi

# Dirs already exist so ===DIRS=== should NOT appear
if ! echo "$output2" | grep -q "===DIRS==="; then
  pass "second run does not re-report ===DIRS==="
else
  fail "second run incorrectly reports ===DIRS==="
fi

# Standards should be skipped (already exist)
if ! echo "$output2" | grep -q "===STANDARDS==="; then
  pass "second run skips standards (already exist)"
else
  fail "second run re-copied standards"
fi

# Templates should be skipped (already exist)
if ! echo "$output2" | grep -q "===TEMPLATES==="; then
  pass "second run skips templates (already exist)"
else
  fail "second run re-copied templates"
fi

# =============================================================================
# Overwrite flag
# =============================================================================

echo ""
echo "Overwrite flag:"

TARGET4="$(fresh_target overwrite)"
# First run
cd "$TARGET4" && "$SETUP_SH" --project "OverwriteApp" --plugin-root "$PLUGIN_DIR" >/dev/null 2>&1

# Modify a file to verify overwrite replaces it
echo "MODIFIED" > "$TARGET4/agents-context/standards/coding-style.md"

# Second run with --overwrite
output3=$(cd "$TARGET4" && "$SETUP_SH" --project "OverwriteApp" --plugin-root "$PLUGIN_DIR" --overwrite 2>&1)

# Standards should be re-copied
if echo "$output3" | grep -q "===STANDARDS==="; then
  pass "overwrite re-copies standards"
else
  fail "overwrite did not re-copy standards"
fi

# The modified file should be restored to original
if ! grep -q "MODIFIED" "$TARGET4/agents-context/standards/coding-style.md"; then
  pass "overwrite restored modified file"
else
  fail "overwrite did not restore modified file"
fi

# No ===SKIPPED=== with overwrite
if ! echo "$output3" | grep -q "===SKIPPED==="; then
  pass "overwrite has no ===SKIPPED=== section"
else
  fail "overwrite still shows ===SKIPPED==="
fi

# =============================================================================
# Special characters in project name
# =============================================================================

echo ""
echo "Special characters in project name:"

TARGET5="$(fresh_target special-chars)"
output4=$(cd "$TARGET5" && "$SETUP_SH" --project "Tom & Jerry's \"App\"" --plugin-root "$PLUGIN_DIR" 2>&1)

if grep -q "Tom & Jerry" "$TARGET5/agents-context/README.md"; then
  pass "handles ampersand in project name"
else
  fail "ampersand in project name broken"
fi

if echo "$output4" | grep -q "===DONE==="; then
  pass "completes with special characters"
else
  fail "failed with special characters in project name"
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
