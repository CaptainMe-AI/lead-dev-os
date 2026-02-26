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

  # --- Commands (flattened into .claude/commands/agents-flight-deck/) ---
  local cmd_dir="$TARGET/.claude/commands/agents-flight-deck"
  assert_dir_exists "commands directory exists" "$cmd_dir"

  # Strategic commands
  assert_file_exists "plan-product.md installed" "$cmd_dir/plan-product.md"
  assert_file_exists "plan-roadmap.md installed" "$cmd_dir/plan-roadmap.md"
  assert_file_exists "define-standards.md installed" "$cmd_dir/define-standards.md"

  # Tactical commands
  assert_file_exists "step1-shape-spec.md installed" "$cmd_dir/step1-shape-spec.md"
  assert_file_exists "step2-define-spec.md installed" "$cmd_dir/step2-define-spec.md"
  assert_file_exists "step3-scope-tasks.md installed" "$cmd_dir/step3-scope-tasks.md"
  assert_file_exists "step4-implement-tasks.md installed" "$cmd_dir/step4-implement-tasks.md"

  # Verify command count (3 strategic + 4 tactical = 7)
  local cmd_count
  cmd_count="$(find "$cmd_dir" -name '*.md' | wc -l | tr -d ' ')"
  if [ "$cmd_count" -eq 7 ]; then
    echo "  PASS: exactly 7 command files installed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: expected 7 command files, got $cmd_count"
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

  # --- agents-flight-deck/ (templates + specs) ---
  assert_dir_exists "agents-flight-deck/ exists" "$TARGET/agents-flight-deck"
  assert_dir_exists "agents-flight-deck/templates/ exists" "$TARGET/agents-flight-deck/templates"
  assert_dir_exists "agents-flight-deck/specs/ exists" "$TARGET/agents-flight-deck/specs"

  # Templates
  assert_file_exists "spec-template.md installed" "$TARGET/agents-flight-deck/templates/spec-template.md"
  assert_file_exists "tasks-template.md installed" "$TARGET/agents-flight-deck/templates/tasks-template.md"
  assert_file_exists "requirements-template.md installed" "$TARGET/agents-flight-deck/templates/requirements-template.md"
  assert_file_not_empty "spec-template.md has content" "$TARGET/agents-flight-deck/templates/spec-template.md"

  # Specs .gitkeep
  assert_file_exists "specs/.gitkeep exists" "$TARGET/agents-flight-deck/specs/.gitkeep"

  # --- CLAUDE.md ---
  assert_file_exists "CLAUDE.md created" "$TARGET/CLAUDE.md"
  assert_file_contains "CLAUDE.md has framework section" "$TARGET/CLAUDE.md" "## agents-flight-deck Framework"

  teardown
}

test_commands_only_flag() {
  echo "test_commands_only_flag — --commands-only skips context/templates"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --commands-only) > /dev/null 2>&1

  # Commands should exist
  assert_file_exists "commands installed" "$TARGET/.claude/commands/agents-flight-deck/plan-product.md"
  assert_file_exists "commands installed" "$TARGET/.claude/commands/agents-flight-deck/step1-shape-spec.md"

  # Context, templates, CLAUDE.md should NOT exist
  if [ ! -d "$TARGET/agents-context" ]; then
    echo "  PASS: agents-context/ not created with --commands-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: agents-context/ should not exist with --commands-only"
    FAIL=$((FAIL + 1))
  fi

  if [ ! -d "$TARGET/agents-flight-deck" ]; then
    echo "  PASS: agents-flight-deck/ not created with --commands-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: agents-flight-deck/ should not exist with --commands-only"
    FAIL=$((FAIL + 1))
  fi

  if [ ! -f "$TARGET/CLAUDE.md" ]; then
    echo "  PASS: CLAUDE.md not created with --commands-only"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: CLAUDE.md should not exist with --commands-only"
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
  assert_file_contains "appends framework section" "$TARGET/CLAUDE.md" "## agents-flight-deck Framework"

  teardown
}

test_no_git_directory_still_works() {
  echo "test_no_git_directory_still_works — installs without .git"
  setup

  # Remove the fake .git
  rm -rf "$TARGET/.git"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "commands still installed" "$TARGET/.claude/commands/agents-flight-deck/plan-product.md"
  assert_dir_exists "agents-context still created" "$TARGET/agents-context"

  teardown
}

# --- Run all tests ---

echo "=== Integration Tests: install.sh (fresh install) ==="
echo ""

test_full_install
test_commands_only_flag
test_claude_md_appended_to_existing
test_no_git_directory_still_works

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
