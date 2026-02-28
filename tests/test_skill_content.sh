#!/usr/bin/env bash
# Test: Skill content is correct for plugin distribution
#
# Verifies:
# - No placeholder tokens remain
# - All cross-references use plugin namespace
# - No config.yml references in skills
# - Valid frontmatter in all SKILL.md files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/lead-dev-os"

PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✓ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ✗ $1"; }

echo "Skill Content Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# --- No placeholders ---

echo ""
echo "Placeholder removal:"

for skill_md in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  if grep -q '{{.*INSERT.*PLAN.*MODE.*HERE.*}}' "$skill_md" 2>/dev/null; then
    fail "$skill_name/SKILL.md still contains plan mode placeholder"
  else
    pass "$skill_name/SKILL.md — no placeholders"
  fi
done

# --- Namespaced cross-references ---

echo ""
echo "Namespaced cross-references:"

# Check that skill references use /lead-dev-os: namespace
# Look for bare /skill-name patterns that should be namespaced
SKILL_NAMES=(
  "plan-product"
  "plan-roadmap"
  "define-standards"
  "step1-write-spec"
  "step2-scope-tasks"
  "step3-implement-tasks"
)

for skill_md in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  has_bare_ref=false

  for ref_name in "${SKILL_NAMES[@]}"; do
    # Match /skill-name but not /lead-dev-os:skill-name
    # Use word boundary: backtick or space or quote before /
    if grep -P "(?<!/lead-dev-os:)(?<=\`/)${ref_name}(?=\`)" "$skill_md" 2>/dev/null | grep -v '^#' >/dev/null 2>&1; then
      fail "$skill_name/SKILL.md has bare reference to /$ref_name (should be /lead-dev-os:$ref_name)"
      has_bare_ref=true
    fi
  done

  if [ "$has_bare_ref" = false ]; then
    pass "$skill_name/SKILL.md — all cross-refs namespaced"
  fi
done

# --- No config.yml references ---

echo ""
echo "Config.yml references removed:"

for skill_md in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  if grep -qi 'config\.local\.yml\|config\.default\.yml\|config\.yml' "$skill_md" 2>/dev/null; then
    fail "$skill_name/SKILL.md still references config.yml"
  else
    pass "$skill_name/SKILL.md — no config.yml refs"
  fi
done

# --- No app/ path references ---

echo ""
echo "No app/ path references:"

for skill_md in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$skill_md")")"
  if grep -q 'app/agents-context/' "$skill_md" 2>/dev/null; then
    fail "$skill_name/SKILL.md still references app/agents-context/"
  else
    pass "$skill_name/SKILL.md — no app/ paths"
  fi
done

# --- Valid frontmatter ---

echo ""
echo "Frontmatter validation:"

for skill_md in "$PLUGIN_DIR"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$skill_md")")"

  # Check starts with ---
  first_line=$(head -1 "$skill_md")
  if [ "$first_line" = "---" ]; then
    pass "$skill_name/SKILL.md starts with frontmatter"
  else
    fail "$skill_name/SKILL.md missing frontmatter (first line: '$first_line')"
  fi

  # Check has name field
  if grep -q '^name:' "$skill_md" 2>/dev/null; then
    pass "$skill_name/SKILL.md has name field"
  else
    fail "$skill_name/SKILL.md missing name field"
  fi

  # Check has description field
  if grep -q '^description:' "$skill_md" 2>/dev/null; then
    pass "$skill_name/SKILL.md has description field"
  else
    fail "$skill_name/SKILL.md missing description field"
  fi
done

# --- Plan mode content present in tactical skills ---

echo ""
echo "Plan mode content:"

TACTICAL_SKILLS=(
  "step1-write-spec"
  "step2-scope-tasks"
  "step3-implement-tasks"
)

for skill in "${TACTICAL_SKILLS[@]}"; do
  skill_md="$PLUGIN_DIR/skills/$skill/SKILL.md"
  if grep -q 'Use plan mode per task group' "$skill_md" 2>/dev/null; then
    pass "$skill/SKILL.md has plan mode instructions"
  else
    fail "$skill/SKILL.md missing plan mode instructions"
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
