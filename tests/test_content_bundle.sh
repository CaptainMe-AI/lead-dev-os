#!/usr/bin/env bash
# Test: Init skill content bundle is correct
#
# Verifies:
# - All global standards present in init skill
# - Template files exist and contain correct content
# - Example file exists
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

# --- Template files exist ---

SKILL_MD="$INIT_DIR/SKILL.md"

echo ""
echo "Template files:"

TEMPLATES=(
  "templates/claude.md"
  "templates/agents.md"
  "templates/readme.md"
  "templates/workflow.md"
)

for tmpl in "${TEMPLATES[@]}"; do
  if [ -f "$INIT_DIR/$tmpl" ]; then
    pass "$tmpl exists"
  else
    fail "$tmpl missing"
  fi
done

# --- SKILL.md references templates ---

echo ""
echo "SKILL.md references templates:"

for tmpl in "${TEMPLATES[@]}"; do
  if grep -q "$tmpl" "$SKILL_MD" 2>/dev/null; then
    pass "SKILL.md references $tmpl"
  else
    fail "SKILL.md missing reference to $tmpl"
  fi
done

# --- templates/claude.md content ---

echo ""
echo "templates/claude.md content:"

CLAUDE_TMPL="$INIT_DIR/templates/claude.md"

if grep -q '## lead-dev-os Framework' "$CLAUDE_TMPL" 2>/dev/null; then
  pass "template-claude.md has framework header"
else
  fail "template-claude.md missing framework header"
fi

if grep -q '/lead-dev-os:step1-write-spec' "$CLAUDE_TMPL" 2>/dev/null; then
  pass "template-claude.md has namespaced step1"
else
  fail "template-claude.md missing namespaced step1"
fi

if grep -q '/lead-dev-os:plan-product' "$CLAUDE_TMPL" 2>/dev/null; then
  pass "template-claude.md has namespaced plan-product"
else
  fail "template-claude.md missing namespaced plan-product"
fi

# --- templates/agents.md content ---

echo ""
echo "templates/agents.md content:"

AGENTS_TMPL="$INIT_DIR/templates/agents.md"

if grep -q 'Context Documentation Index' "$AGENTS_TMPL" 2>/dev/null; then
  pass "template-agents.md has index header"
else
  fail "template-agents.md missing index header"
fi

if grep -q 'README.md' "$AGENTS_TMPL" 2>/dev/null; then
  pass "template-agents.md references README.md"
else
  fail "template-agents.md missing README.md reference"
fi

# --- templates/readme.md content ---

echo ""
echo "templates/readme.md content:"

README_TMPL="$INIT_DIR/templates/readme.md"

if grep -q '{Project Name}' "$README_TMPL" 2>/dev/null; then
  pass "template-readme.md has project name placeholder"
else
  fail "template-readme.md missing project name placeholder"
fi

if grep -q '/lead-dev-os:define-standards' "$README_TMPL" 2>/dev/null; then
  pass "template-readme.md has namespaced define-standards"
else
  fail "template-readme.md missing namespaced define-standards"
fi

if grep -q '/lead-dev-os:step2-scope-tasks' "$README_TMPL" 2>/dev/null; then
  pass "template-readme.md has namespaced step2"
else
  fail "template-readme.md missing namespaced step2"
fi

if grep -q 'AGENTS.md' "$README_TMPL" 2>/dev/null; then
  pass "template-readme.md mentions AGENTS.md sync"
else
  fail "template-readme.md missing AGENTS.md mention"
fi

# --- templates/workflow.md content ---

echo ""
echo "templates/workflow.md content:"

WORKFLOW_TMPL="$INIT_DIR/templates/workflow.md"

if grep -q '# Workflow Guide' "$WORKFLOW_TMPL" 2>/dev/null; then
  pass "template-workflow.md has workflow header"
else
  fail "template-workflow.md missing workflow header"
fi

if grep -q '/lead-dev-os:step3-implement-tasks' "$WORKFLOW_TMPL" 2>/dev/null; then
  pass "template-workflow.md has namespaced step3"
else
  fail "template-workflow.md missing namespaced step3"
fi

# --- Example file ---

echo ""
echo "Example file:"

if [ -f "$INIT_DIR/examples/readme-filled.md" ]; then
  pass "examples/readme-filled.md exists"
else
  fail "examples/readme-filled.md missing"
fi

# --- step3 keeps README.md in sync ---

echo ""
echo "step3 README sync requirement:"

STEP3_MD="$REPO_ROOT/lead-dev-os/skills/step3-implement-tasks/SKILL.md"

if grep -q 'Keep.*agents-context/README.md.*in sync' "$STEP3_MD" 2>/dev/null; then
  pass "step3 requires keeping README.md in sync"
else
  fail "step3 missing README.md sync requirement"
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
