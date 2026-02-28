#!/usr/bin/env bash
# Test: Plugin structure is valid
#
# Verifies:
# - plugin.json exists and is valid JSON
# - All 7 skill directories exist with SKILL.md
# - content/ directory has correct structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/lead-dev-os"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

echo "Plugin Structure Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# --- plugin.json ---

echo ""
echo "plugin.json:"

if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

if command -v python3 &>/dev/null; then
  if python3 -c "import json; json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))" 2>/dev/null; then
    pass "plugin.json is valid JSON"
  else
    fail "plugin.json is invalid JSON"
  fi

  name=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['name'])" 2>/dev/null)
  if [ "$name" = "lead-dev-os" ]; then
    pass "plugin name is 'lead-dev-os'"
  else
    fail "plugin name is '$name', expected 'lead-dev-os'"
  fi

  version=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
  if [ -n "$version" ]; then
    pass "plugin has version ($version)"
  else
    fail "plugin missing version"
  fi
else
  echo "  (skipped JSON validation — python3 not found)"
fi

# --- Skill directories ---

echo ""
echo "Skills:"

EXPECTED_SKILLS=(
  "init"
  "plan-product"
  "plan-roadmap"
  "define-standards"
  "step1-write-spec"
  "step2-scope-tasks"
  "step3-implement-tasks"
)

for skill in "${EXPECTED_SKILLS[@]}"; do
  if [ -d "$PLUGIN_DIR/skills/$skill" ]; then
    pass "skills/$skill/ exists"
  else
    fail "skills/$skill/ missing"
  fi

  if [ -f "$PLUGIN_DIR/skills/$skill/SKILL.md" ]; then
    pass "skills/$skill/SKILL.md exists"
  else
    fail "skills/$skill/SKILL.md missing"
  fi
done

# Skills with templates
SKILLS_WITH_TEMPLATES=(
  "plan-product"
  "plan-roadmap"
  "define-standards"
  "step1-write-spec"
  "step2-scope-tasks"
)

echo ""
echo "Templates:"

for skill in "${SKILLS_WITH_TEMPLATES[@]}"; do
  if [ -f "$PLUGIN_DIR/skills/$skill/template.md" ]; then
    pass "skills/$skill/template.md exists"
  else
    fail "skills/$skill/template.md missing"
  fi
done

# Skills with examples
SKILLS_WITH_EXAMPLES=(
  "plan-product"
  "plan-roadmap"
  "define-standards"
  "step1-write-spec"
  "step2-scope-tasks"
)

echo ""
echo "Examples:"

for skill in "${SKILLS_WITH_EXAMPLES[@]}"; do
  if [ -d "$PLUGIN_DIR/skills/$skill/examples" ]; then
    pass "skills/$skill/examples/ exists"
  else
    fail "skills/$skill/examples/ missing"
  fi
done

# No nested directories (strategic/tactical should not exist)
echo ""
echo "Flat structure:"

if [ ! -d "$PLUGIN_DIR/skills/strategic" ]; then
  pass "no skills/strategic/ nesting"
else
  fail "skills/strategic/ still exists (should be flat)"
fi

if [ ! -d "$PLUGIN_DIR/skills/tactical" ]; then
  pass "no skills/tactical/ nesting"
else
  fail "skills/tactical/ still exists (should be flat)"
fi

# --- Content directory ---

echo ""
echo "Content bundle:"

if [ -f "$PLUGIN_DIR/content/CLAUDE.md" ]; then
  pass "content/CLAUDE.md exists"
else
  fail "content/CLAUDE.md missing"
fi

if [ -f "$PLUGIN_DIR/content/agents-context/README.md" ]; then
  pass "content/agents-context/README.md exists"
else
  fail "content/agents-context/README.md missing"
fi

if [ -d "$PLUGIN_DIR/content/agents-context/concepts" ]; then
  pass "content/agents-context/concepts/ exists"
else
  fail "content/agents-context/concepts/ missing"
fi

if [ -d "$PLUGIN_DIR/content/agents-context/standards" ]; then
  pass "content/agents-context/standards/ exists"
else
  fail "content/agents-context/standards/ missing"
fi

if [ -d "$PLUGIN_DIR/content/agents-context/guides" ]; then
  pass "content/agents-context/guides/ exists"
else
  fail "content/agents-context/guides/ missing"
fi

if [ -f "$PLUGIN_DIR/content/agents-context/guides/workflow.md" ]; then
  pass "content/agents-context/guides/workflow.md exists"
else
  fail "content/agents-context/guides/workflow.md missing"
fi

# --- Standards directories ---

echo ""
echo "Standards directories:"

EXPECTED_STANDARD_DIRS=(
  "global"
  "testing"
  "django"
  "docker"
  "express"
  "fastapi"
  "gunicorn"
  "javascript"
  "mongodb"
  "mysql"
  "nextjs"
  "nginx"
  "postgresql"
  "python"
  "rails"
  "react"
  "redis"
  "ruby"
  "typescript"
  "uvicorn"
  "vue"
)

for dir in "${EXPECTED_STANDARD_DIRS[@]}"; do
  if [ -d "$PLUGIN_DIR/content/agents-context/standards/$dir" ]; then
    pass "standards/$dir/ exists"
  else
    fail "standards/$dir/ missing"
  fi
done

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
