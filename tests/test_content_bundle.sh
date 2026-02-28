#!/usr/bin/env bash
# Test: Init skill content bundle is correct
#
# Verifies:
# - All global standards present in init skill
# - Init SKILL.md contains namespaced CLAUDE.md template
# - Init SKILL.md contains namespaced README and workflow templates
# - No config.yml references

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INIT_DIR="$REPO_ROOT/lead-dev-os/skills/init"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

echo "Content Bundle Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# --- Global standards ---

echo ""
echo "Global standards present:"

GLOBAL_STANDARDS=(
  "coding-style.md"
  "commenting.md"
  "conventions.md"
  "error-handling.md"
  "validation.md"
)

for std in "${GLOBAL_STANDARDS[@]}"; do
  if [ -f "$INIT_DIR/standards-global/$std" ]; then
    pass "standards-global/$std exists"
  else
    fail "standards-global/$std missing"
  fi
done

# --- Testing standards ---

echo ""
echo "Testing standards present:"

if [ -f "$INIT_DIR/standards-testing/test-writing.md" ]; then
  pass "standards-testing/test-writing.md exists"
else
  fail "standards-testing/test-writing.md missing"
fi

# --- Init SKILL.md has CLAUDE.md template ---

echo ""
echo "CLAUDE.md template in SKILL.md:"

SKILL_MD="$INIT_DIR/SKILL.md"

if grep -q '## lead-dev-os Framework' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has framework header in template"
else
  fail "SKILL.md missing framework header in template"
fi

if grep -q '/lead-dev-os:step1-write-spec' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has namespaced step1 reference"
else
  fail "SKILL.md missing namespaced step1 reference"
fi

if grep -q '/lead-dev-os:plan-product' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has namespaced plan-product reference"
else
  fail "SKILL.md missing namespaced plan-product reference"
fi

# --- Init SKILL.md has README template ---

echo ""
echo "README template in SKILL.md:"

if grep -q '# Agents Context' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has README template"
else
  fail "SKILL.md missing README template"
fi

if grep -q '/lead-dev-os:define-standards' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has namespaced define-standards in README"
else
  fail "SKILL.md missing namespaced define-standards in README"
fi

if grep -q '/lead-dev-os:step2-scope-tasks' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has namespaced step2 in README"
else
  fail "SKILL.md missing namespaced step2 in README"
fi

# --- Init SKILL.md has workflow template ---

echo ""
echo "Workflow template in SKILL.md:"

if grep -q '# Workflow Guide' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has workflow template"
else
  fail "SKILL.md missing workflow template"
fi

if grep -q '/lead-dev-os:step3-implement-tasks' "$SKILL_MD" 2>/dev/null; then
  pass "SKILL.md has namespaced step3 in workflow"
else
  fail "SKILL.md missing namespaced step3 in workflow"
fi

# --- No config.yml references ---

echo ""
echo "No config.yml references:"

if grep -qi 'config\.local\.yml\|config\.default\.yml' "$SKILL_MD" 2>/dev/null; then
  fail "SKILL.md still references config.yml"
else
  pass "SKILL.md — no config.yml references"
fi

# --- No content/ references ---

echo ""
echo "No content/ path references:"

if grep -q '${CLAUDE_PLUGIN_ROOT}/content/' "$SKILL_MD" 2>/dev/null; then
  fail "SKILL.md still references content/ path"
else
  pass "SKILL.md — no content/ path references"
fi

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
