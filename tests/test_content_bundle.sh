#!/usr/bin/env bash
# Test: Content bundle is correct
#
# Verifies:
# - All global standards present
# - CLAUDE.md uses namespaced references
# - README.md updated (no config.yml refs, namespaced)
# - workflow.md namespaced

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTENT_DIR="$REPO_ROOT/lead-dev-os/content"

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
  if [ -f "$CONTENT_DIR/agents-context/standards/global/$std" ]; then
    pass "global/$std exists"
  else
    fail "global/$std missing"
  fi
done

# --- Testing standards ---

echo ""
echo "Testing standards present:"

if [ -f "$CONTENT_DIR/agents-context/standards/testing/test-writing.md" ]; then
  pass "testing/test-writing.md exists"
else
  fail "testing/test-writing.md missing"
fi

# --- CLAUDE.md namespaced ---

echo ""
echo "CLAUDE.md content:"

CLAUDE_MD="$CONTENT_DIR/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  pass "CLAUDE.md exists"
else
  fail "CLAUDE.md missing"
fi

if grep -q 'lead-dev-os Framework' "$CLAUDE_MD" 2>/dev/null; then
  pass "CLAUDE.md has framework header"
else
  fail "CLAUDE.md missing framework header"
fi

if grep -q '/lead-dev-os:step1-write-spec' "$CLAUDE_MD" 2>/dev/null; then
  pass "CLAUDE.md has namespaced step1 reference"
else
  fail "CLAUDE.md missing namespaced step1 reference"
fi

if grep -q '/lead-dev-os:plan-product' "$CLAUDE_MD" 2>/dev/null; then
  pass "CLAUDE.md has namespaced plan-product reference"
else
  fail "CLAUDE.md missing namespaced plan-product reference"
fi

# Check no bare skill references in CLAUDE.md
BARE_SKILL_NAMES=("plan-product" "plan-roadmap" "define-standards" "step1-write-spec" "step2-scope-tasks" "step3-implement-tasks")
has_bare=false
for bare_name in "${BARE_SKILL_NAMES[@]}"; do
  # Match /skill-name but not /lead-dev-os:skill-name
  if grep -P "(?<!lead-dev-os:)(?<=/)${bare_name}" "$CLAUDE_MD" 2>/dev/null | head -1 >/dev/null 2>&1; then
    fail "CLAUDE.md has bare reference to /$bare_name"
    has_bare=true
  fi
done
if [ "$has_bare" = false ]; then
  pass "CLAUDE.md — all skill references namespaced"
fi

# Check no config.yml references
if grep -qi 'config\.local\.yml\|config\.default\.yml' "$CLAUDE_MD" 2>/dev/null; then
  fail "CLAUDE.md still references config.yml"
else
  pass "CLAUDE.md — no config.yml references"
fi

# --- README.md ---

echo ""
echo "agents-context/README.md:"

README="$CONTENT_DIR/agents-context/README.md"

if grep -qi 'config\.local\.yml' "$README" 2>/dev/null; then
  fail "README.md still references config.local.yml"
else
  pass "README.md — no config.local.yml reference"
fi

if grep -q '/lead-dev-os:define-standards' "$README" 2>/dev/null; then
  pass "README.md has namespaced define-standards reference"
else
  fail "README.md missing namespaced define-standards reference"
fi

if grep -q '/lead-dev-os:step2-scope-tasks' "$README" 2>/dev/null; then
  pass "README.md has namespaced step2 reference"
else
  fail "README.md missing namespaced step2 reference"
fi

# --- workflow.md ---

echo ""
echo "guides/workflow.md:"

WORKFLOW="$CONTENT_DIR/agents-context/guides/workflow.md"

if [ -f "$WORKFLOW" ]; then
  pass "workflow.md exists"
else
  fail "workflow.md missing"
fi

# Check all skill references are namespaced
WORKFLOW_SKILLS=(
  "plan-product"
  "plan-roadmap"
  "define-standards"
  "step1-write-spec"
  "step2-scope-tasks"
  "step3-implement-tasks"
)

workflow_has_bare=false
for skill_name in "${WORKFLOW_SKILLS[@]}"; do
  if grep -P "(?<!/lead-dev-os:)(?<=\`/)${skill_name}(?=\`)" "$WORKFLOW" 2>/dev/null | head -1 >/dev/null 2>&1; then
    fail "workflow.md has bare reference to /$skill_name"
    workflow_has_bare=true
  fi
done
if [ "$workflow_has_bare" = false ]; then
  pass "workflow.md — all skill references namespaced"
fi

# Check namespaced references exist
if grep -q '/lead-dev-os:plan-product' "$WORKFLOW" 2>/dev/null; then
  pass "workflow.md has namespaced plan-product"
else
  fail "workflow.md missing namespaced plan-product"
fi

if grep -q '/lead-dev-os:step1-write-spec' "$WORKFLOW" 2>/dev/null; then
  pass "workflow.md has namespaced step1"
else
  fail "workflow.md missing namespaced step1"
fi

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
