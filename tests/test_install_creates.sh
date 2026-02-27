#!/usr/bin/env bash
# Integration test: verify install.sh creates all expected files and directories
#
# Usage: ./tests/test_install_creates.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"

PASS=0
FAIL=0
TARGET=""

# --- Test helpers ---

setup() {
  TARGET="$(mktemp -d)"
  # Create a fake .git so the installer doesn't warn
  mkdir -p "$TARGET/.git"
}

teardown() {
  [ -n "$TARGET" ] && rm -rf "$TARGET"
}

assert_file_exists() {
  local label="$1" path="$2"
  if [ -f "$path" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — file not found: $path"
    FAIL=$((FAIL + 1))
  fi
}

assert_dir_exists() {
  local label="$1" path="$2"
  if [ -d "$path" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — directory not found: $path"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_contains() {
  local label="$1" path="$2" pattern="$3"
  if grep -q "$pattern" "$path" 2>/dev/null; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — pattern '$pattern' not found in $path"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_not_empty() {
  local label="$1" path="$2"
  if [ -s "$path" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — file is empty: $path"
    FAIL=$((FAIL + 1))
  fi
}

# --- Tests ---

test_full_install() {
  echo "test_full_install — fresh install into empty project"
  setup

  # Run installer
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # --- Skills (.claude/skills/<category>/<name>/) ---
  local skills_dir="$TARGET/.claude/skills"
  assert_dir_exists "skills directory exists" "$skills_dir"

  # Strategic skills
  assert_file_exists "plan-product SKILL.md installed" "$skills_dir/strategic/plan-product/SKILL.md"
  assert_file_exists "plan-product template.md installed" "$skills_dir/strategic/plan-product/template.md"
  assert_file_exists "plan-product example installed" "$skills_dir/strategic/plan-product/examples/saas-project-tracker.md"
  assert_file_exists "plan-roadmap SKILL.md installed" "$skills_dir/strategic/plan-roadmap/SKILL.md"
  assert_file_exists "plan-roadmap template.md installed" "$skills_dir/strategic/plan-roadmap/template.md"
  assert_file_exists "plan-roadmap example installed" "$skills_dir/strategic/plan-roadmap/examples/saas-project-tracker.md"
  assert_file_exists "define-standards SKILL.md installed" "$skills_dir/strategic/define-standards/SKILL.md"
  assert_file_exists "define-standards template.md installed" "$skills_dir/strategic/define-standards/template.md"
  assert_file_exists "define-standards example installed" "$skills_dir/strategic/define-standards/examples/python-fastapi-standards.md"

  # Tactical skills
  assert_file_exists "step1-write-spec SKILL.md installed" "$skills_dir/tactical/step1-write-spec/SKILL.md"
  assert_file_exists "step2-scope-tasks SKILL.md installed" "$skills_dir/tactical/step2-scope-tasks/SKILL.md"
  assert_file_exists "step3-implement-tasks SKILL.md installed" "$skills_dir/tactical/step3-implement-tasks/SKILL.md"

  # Templates co-located with skills
  assert_file_exists "step1 template.md installed" "$skills_dir/tactical/step1-write-spec/template.md"
  assert_file_exists "step2 template.md installed" "$skills_dir/tactical/step2-scope-tasks/template.md"

  # Examples co-located with skills
  assert_file_exists "step1 example installed" "$skills_dir/tactical/step1-write-spec/examples/user-profile-feature.md"
  assert_file_exists "step2 example installed" "$skills_dir/tactical/step2-scope-tasks/examples/user-profile-feature.md"

  # Verify SKILL.md count (3 strategic + 3 tactical = 6)
  local skill_count
  skill_count="$(find "$skills_dir" -name 'SKILL.md' | wc -l | tr -d ' ')"
  if [ "$skill_count" -eq 6 ]; then
    echo "  PASS: exactly 6 SKILL.md files installed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: expected 6 SKILL.md files, got $skill_count"
    FAIL=$((FAIL + 1))
  fi

  # --- agents-context/ (top-level) ---
  assert_dir_exists "agents-context/ exists" "$TARGET/agents-context"
  assert_dir_exists "agents-context/concepts/ exists" "$TARGET/agents-context/concepts"
  assert_dir_exists "agents-context/standards/ exists" "$TARGET/agents-context/standards"
  assert_dir_exists "agents-context/guides/ exists" "$TARGET/agents-context/guides"
  assert_file_exists "concepts/.gitkeep exists" "$TARGET/agents-context/concepts/.gitkeep"
  assert_file_exists "workflow.md installed" "$TARGET/agents-context/guides/workflow.md"
  assert_file_not_empty "workflow.md has content" "$TARGET/agents-context/guides/workflow.md"

  # --- lead-dev-os/ (specs only, no templates) ---
  assert_dir_exists "lead-dev-os/ exists" "$TARGET/lead-dev-os"
  assert_dir_exists "lead-dev-os/specs/ exists" "$TARGET/lead-dev-os/specs"

  # Specs .gitkeep
  assert_file_exists "specs/.gitkeep exists" "$TARGET/lead-dev-os/specs/.gitkeep"

  # --- CLAUDE.md ---
  assert_file_exists "CLAUDE.md created" "$TARGET/CLAUDE.md"
  assert_file_contains "CLAUDE.md has framework section" "$TARGET/CLAUDE.md" "## lead-dev-os Framework"

  teardown
}

test_skills_only_flag() {
  echo "test_skills_only_flag — --skills-only skips context"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --skills-only) > /dev/null 2>&1

  # Skills should exist
  assert_file_exists "skills installed" "$TARGET/.claude/skills/strategic/plan-product/SKILL.md"
  assert_file_exists "skills installed" "$TARGET/.claude/skills/tactical/step1-write-spec/SKILL.md"

  # Context, CLAUDE.md should NOT exist
  if [ ! -d "$TARGET/agents-context" ]; then
    echo "  PASS: agents-context/ not created with --skills-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: agents-context/ should not exist with --skills-only"
    FAIL=$((FAIL + 1))
  fi

  if [ ! -d "$TARGET/lead-dev-os" ]; then
    echo "  PASS: lead-dev-os/ not created with --skills-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: lead-dev-os/ should not exist with --skills-only"
    FAIL=$((FAIL + 1))
  fi

  if [ ! -f "$TARGET/CLAUDE.md" ]; then
    echo "  PASS: CLAUDE.md not created with --skills-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: CLAUDE.md should not exist with --skills-only"
    FAIL=$((FAIL + 1))
  fi

  teardown
}

test_claude_md_appended_to_existing() {
  echo "test_claude_md_appended_to_existing — appends to existing CLAUDE.md"
  setup

  echo "# My Project" > "$TARGET/CLAUDE.md"
  echo "Existing content here." >> "$TARGET/CLAUDE.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_contains "preserves existing content" "$TARGET/CLAUDE.md" "My Project"
  assert_file_contains "appends framework section" "$TARGET/CLAUDE.md" "## lead-dev-os Framework"

  teardown
}

test_no_git_directory_still_works() {
  echo "test_no_git_directory_still_works — installs without .git"
  setup

  # Remove the fake .git
  rm -rf "$TARGET/.git"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "skills still installed" "$TARGET/.claude/skills/strategic/plan-product/SKILL.md"
  assert_dir_exists "agents-context still created" "$TARGET/agents-context"

  teardown
}

# --- Run all tests ---

echo "=== Integration Tests: install.sh (fresh install) ==="
echo ""

test_full_install
test_skills_only_flag
test_claude_md_appended_to_existing
test_no_git_directory_still_works

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
