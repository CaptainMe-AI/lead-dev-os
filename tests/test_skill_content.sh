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
  "step4-archive-spec"
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

# --- Plan mode content lives where it belongs ---

echo ""
echo "Plan mode content:"

# step3 owns implementation planning: pre-generated plan files + native plan mode
step3_md="$PLUGIN_DIR/skills/step3-implement-tasks/SKILL.md"
if grep -q 'plans/group-' "$step3_md" 2>/dev/null && grep -qi 'plan mode' "$step3_md" 2>/dev/null; then
  pass "step3-implement-tasks/SKILL.md has per-group planning (plan files + plan mode)"
else
  fail "step3-implement-tasks/SKILL.md missing per-group planning instructions"
fi

# step1 is spec-writing only — must NOT carry implementation plan-mode boilerplate
step1_md="$PLUGIN_DIR/skills/step1-write-spec/SKILL.md"
if grep -q 'Use plan mode per task group' "$step1_md" 2>/dev/null; then
  fail "step1-write-spec/SKILL.md carries step3's plan-mode boilerplate"
else
  pass "step1-write-spec/SKILL.md free of misplaced plan-mode boilerplate"
fi

# step2 explains plan-mode-optional invocation (writes tasks.md after plan approval)
step2_md="$PLUGIN_DIR/skills/step2-scope-tasks/SKILL.md"
if grep -q 'plan mode is optional' "$step2_md" 2>/dev/null; then
  pass "step2-scope-tasks/SKILL.md documents plan-mode-optional invocation"
else
  fail "step2-scope-tasks/SKILL.md missing plan-mode-optional note"
fi

# --- step3: orchestrated execution via executor subagents ---

echo ""
echo "step3 orchestrated execution:"

STEP3_MD="$PLUGIN_DIR/skills/step3-implement-tasks/SKILL.md"
STEP3_DIR="$PLUGIN_DIR/skills/step3-implement-tasks"

if grep -q 'executor subagent' "$STEP3_MD" 2>/dev/null; then
  pass "step3 delegates group execution to executor subagents"
else
  fail "step3 missing executor subagent delegation"
fi

if grep -q 'the orchestrator commits after verifying' "$STEP3_MD" 2>/dev/null; then
  pass "step3 executors never commit — orchestrator verifies then commits"
else
  fail "step3 missing orchestrator verify-then-commit rule"
fi

if grep -rq 'Reconcile before you code' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 executor prompt reconciles stale plans against reality"
else
  fail "step3 executor prompt missing stale-plan reconcile instruction"
fi

if grep -rq 'Parallel dispatch' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 allows parallel dispatch of independent groups"
else
  fail "step3 missing parallel dispatch of independent groups"
fi

# --- step3: structured shape (orchestrator + steps/ + shared/) ---

echo ""
echo "step3 structured shape:"

for step_file in load-context select-mode pre-plan execute-orchestrated execute-direct finalize; do
  if [ -f "$STEP3_DIR/steps/$step_file.md" ]; then
    pass "step3 steps/$step_file.md exists"
  else
    fail "step3 steps/$step_file.md missing"
  fi
done

if [ -f "$STEP3_DIR/template.md" ]; then
  pass "step3 template.md (plans/group-N.md format) exists"
else
  fail "step3 template.md missing"
fi

# --- step3: verification agents ---

echo ""
echo "step3 verification agents:"

if grep -rq 'implementation-reviewer' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 has an implementation-reviewer agent"
else
  fail "step3 missing implementation-reviewer agent"
fi

if grep -rq 'test-verifier' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 has a test-verifier agent"
else
  fail "step3 missing test-verifier agent"
fi

if grep -rq 'adversarial-thinker' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 has an adversarial-thinker agent"
else
  fail "step3 missing adversarial-thinker agent"
fi

if grep -rq 'READ-ONLY' "$STEP3_DIR/shared/verification-agents.md" 2>/dev/null; then
  pass "step3 verification agents are read-only"
else
  fail "step3 verification agents missing read-only constraint"
fi

if grep -rq 'Limit: 2 rounds' "$STEP3_DIR/shared/verification-agents.md" 2>/dev/null; then
  pass "step3 verification fix cycle is bounded"
else
  fail "step3 verification fix cycle missing bound"
fi

# --- Parallel execution waves ---

echo ""
echo "Parallel execution waves:"

if grep -q 'Execution Waves' "$PLUGIN_DIR/skills/step2-scope-tasks/template.md" 2>/dev/null; then
  pass "step2 template includes Execution Waves subsection"
else
  fail "step2 template missing Execution Waves subsection"
fi

if grep -rq 'Execution Waves' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 consumes step2's Execution Waves"
else
  fail "step3 does not reference Execution Waves"
fi

# --- Full-suite backstop gate ---

echo ""
echo "Full-suite backstop gate:"

STEP2_TEMPLATE="$PLUGIN_DIR/skills/step2-scope-tasks/template.md"

if grep -q 'Run the full test suite once as a final backstop' "$STEP2_TEMPLATE" 2>/dev/null; then
  pass "step2 template final group includes full-suite backstop subtask"
else
  fail "step2 template missing full-suite backstop subtask"
fi

if grep -rq 'Run the full test suite once' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 after-all-groups includes full-suite run"
else
  fail "step3 missing full-suite run after all groups"
fi

if grep -rq 'Verify at runtime' "$STEP3_DIR" 2>/dev/null; then
  pass "step3 includes runtime verification of the feature"
else
  fail "step3 missing runtime verification step"
fi

# --- Summary ---

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASSED passed, $FAILED failed"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
