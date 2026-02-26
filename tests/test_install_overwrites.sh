#!/usr/bin/env bash
# Integration test: verify install.sh overwrite/preserve behavior on re-run
#
# What gets OVERWRITTEN on re-install:
#   - Commands (.claude/commands/lead-dev-os/*.md)
#   - Templates (lead-dev-os/templates/*.md)
#   - Guides (agents-context/guides/*.md)
#
# What gets PRESERVED on re-install:
#   - agents-context/concepts/ user content
#   - agents-context/standards/ user content
#   - lead-dev-os/specs/ user content
#   - CLAUDE.md (not duplicated)
#
# Usage: ./tests/test_install_overwrites.sh

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
  mkdir -p "$TARGET/.git"
}

teardown() {
  [ -n "$TARGET" ] && rm -rf "$TARGET"
}

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
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

count_occurrences() {
  local path="$1" pattern="$2"
  grep -c "$pattern" "$path" 2>/dev/null || echo "0"
}

# --- Tests ---

test_commands_overwritten() {
  echo "test_commands_overwritten — commands are replaced on re-install with --force"
  setup

  # First install
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Modify a command file
  echo "user modified this" > "$TARGET/.claude/commands/lead-dev-os/plan-product.md"

  # Re-install with --force
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Should be overwritten with original content
  assert_file_contains "command overwritten with original" "$TARGET/.claude/commands/lead-dev-os/plan-product.md" "Plan Product"

  local content
  content="$(cat "$TARGET/.claude/commands/lead-dev-os/plan-product.md")"
  if echo "$content" | grep -q "user modified this"; then
    echo "  FAIL: command should not contain user modifications after re-install"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS: user modifications replaced"
    PASS=$((PASS + 1))
  fi

  teardown
}

test_templates_overwritten() {
  echo "test_templates_overwritten — templates are replaced on re-install with --force"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Modify a template
  echo "custom template" > "$TARGET/lead-dev-os/templates/spec-template.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Should be overwritten
  assert_file_contains "template overwritten" "$TARGET/lead-dev-os/templates/spec-template.md" "Spec:"

  teardown
}

test_guides_overwritten() {
  echo "test_guides_overwritten — guides are replaced on re-install with --force"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  echo "custom guide" > "$TARGET/agents-context/guides/workflow.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  assert_file_contains "guide overwritten" "$TARGET/agents-context/guides/workflow.md" "Workflow Guide"

  teardown
}

test_concepts_preserved() {
  echo "test_concepts_preserved — user concept files survive re-install"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # Add user concept files
  echo "# API Design Patterns" > "$TARGET/agents-context/concepts/api-design.md"
  echo "# Auth Conventions" > "$TARGET/agents-context/concepts/auth.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "api-design.md preserved" "$TARGET/agents-context/concepts/api-design.md"
  assert_file_exists "auth.md preserved" "$TARGET/agents-context/concepts/auth.md"
  assert_eq "api-design content intact" "# API Design Patterns" "$(cat "$TARGET/agents-context/concepts/api-design.md")"
  assert_eq "auth content intact" "# Auth Conventions" "$(cat "$TARGET/agents-context/concepts/auth.md")"

  teardown
}

test_standards_preserved() {
  echo "test_standards_preserved — user standard files survive re-install"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  echo "# Coding Style" > "$TARGET/agents-context/standards/coding-style.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "coding-style.md preserved" "$TARGET/agents-context/standards/coding-style.md"
  assert_eq "content intact" "# Coding Style" "$(cat "$TARGET/agents-context/standards/coding-style.md")"

  teardown
}

test_specs_preserved() {
  echo "test_specs_preserved — user spec folders survive re-install"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # Create a spec folder as the tactical commands would
  mkdir -p "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/planning"
  echo "# User Auth Spec" > "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/spec.md"
  echo "raw idea" > "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/planning/initialization.md"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "spec.md preserved" "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/spec.md"
  assert_file_exists "initialization.md preserved" "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/planning/initialization.md"
  assert_eq "spec content intact" "# User Auth Spec" "$(cat "$TARGET/lead-dev-os/specs/2026-02-25-user-auth/spec.md")"

  teardown
}

test_claude_md_not_duplicated() {
  echo "test_claude_md_not_duplicated — CLAUDE.md section not appended twice"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  local count_before
  count_before="$(count_occurrences "$TARGET/CLAUDE.md" "## lead-dev-os Framework")"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  local count_after
  count_after="$(count_occurrences "$TARGET/CLAUDE.md" "## lead-dev-os Framework")"

  assert_eq "framework section appears exactly once" "$count_before" "$count_after"
  assert_eq "count is 1" "1" "$count_after"

  teardown
}

test_commands_only_preserves_everything() {
  echo "test_commands_only_preserves_everything — --commands-only updates only commands"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Add user content everywhere
  echo "# My Concept" > "$TARGET/agents-context/concepts/my-concept.md"
  echo "custom guide" > "$TARGET/agents-context/guides/workflow.md"
  echo "custom template" > "$TARGET/lead-dev-os/templates/spec-template.md"

  # Modify a command
  echo "old command" > "$TARGET/.claude/commands/lead-dev-os/plan-product.md"

  # Re-install commands only with --force
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --commands-only) > /dev/null 2>&1

  # Command should be updated
  assert_file_contains "command updated" "$TARGET/.claude/commands/lead-dev-os/plan-product.md" "Plan Product"

  # Everything else should be untouched
  assert_eq "concept preserved" "# My Concept" "$(cat "$TARGET/agents-context/concepts/my-concept.md")"
  assert_eq "guide NOT overwritten" "custom guide" "$(cat "$TARGET/agents-context/guides/workflow.md")"
  assert_eq "template NOT overwritten" "custom template" "$(cat "$TARGET/lead-dev-os/templates/spec-template.md")"

  teardown
}

test_no_overwrite_without_force() {
  echo "test_no_overwrite_without_force — declining prompt preserves modified files"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Modify files in each overwrite category
  echo "my custom command" > "$TARGET/.claude/commands/lead-dev-os/plan-product.md"
  echo "my custom guide" > "$TARGET/agents-context/guides/workflow.md"
  echo "my custom template" > "$TARGET/lead-dev-os/templates/spec-template.md"

  # Re-install without --force, piping "n" to decline all prompts
  yes n | (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1 || true

  assert_eq "command preserved" "my custom command" "$(cat "$TARGET/.claude/commands/lead-dev-os/plan-product.md")"
  assert_eq "guide preserved" "my custom guide" "$(cat "$TARGET/agents-context/guides/workflow.md")"
  assert_eq "template preserved" "my custom template" "$(cat "$TARGET/lead-dev-os/templates/spec-template.md")"

  teardown
}

test_force_flag_overwrites() {
  echo "test_force_flag_overwrites — --force replaces modified files without prompting"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  # Modify files
  echo "my custom command" > "$TARGET/.claude/commands/lead-dev-os/plan-product.md"
  echo "my custom guide" > "$TARGET/agents-context/guides/workflow.md"
  echo "my custom template" > "$TARGET/lead-dev-os/templates/spec-template.md"

  # Re-install with --force
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --force --profile default) > /dev/null 2>&1

  assert_file_contains "command overwritten" "$TARGET/.claude/commands/lead-dev-os/plan-product.md" "Plan Product"
  assert_file_contains "guide overwritten" "$TARGET/agents-context/guides/workflow.md" "Workflow Guide"
  assert_file_contains "template overwritten" "$TARGET/lead-dev-os/templates/spec-template.md" "Spec:"

  teardown
}

# --- Run all tests ---

echo "=== Integration Tests: install.sh (overwrite behavior) ==="
echo ""

test_commands_overwritten
test_templates_overwritten
test_guides_overwritten
test_concepts_preserved
test_standards_preserved
test_specs_preserved
test_claude_md_not_duplicated
test_commands_only_preserves_everything
test_no_overwrite_without_force
test_force_flag_overwrites

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
