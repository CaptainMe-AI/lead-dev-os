#!/usr/bin/env bash
# Test: verify install.sh --help prints usage info and exits cleanly
#
# Usage: ./tests/test_install_help.sh

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

assert_output_contains() {
  local label="$1" output="$2" pattern="$3"
  if echo "$output" | grep -q "$pattern"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — pattern '$pattern' not found in output"
    FAIL=$((FAIL + 1))
  fi
}

# --- Tests ---

test_help_prints_all_sections() {
  echo "test_help_prints_all_sections — --help output contains expected sections"
  setup

  local help_output
  help_output="$(cd "$TARGET" && bash "$INSTALL_SCRIPT" --help)"

  assert_output_contains "contains USAGE section" "$help_output" "USAGE"
  assert_output_contains "contains OPTIONS section" "$help_output" "OPTIONS"
  assert_output_contains "contains WHAT GETS INSTALLED section" "$help_output" "WHAT GETS INSTALLED"
  assert_output_contains "contains EXAMPLES section" "$help_output" "EXAMPLES"
  assert_output_contains "documents --commands-only flag" "$help_output" "\-\-commands-only"
  assert_output_contains "documents --profile flag" "$help_output" "\-\-profile"
  assert_output_contains "documents --force flag" "$help_output" "\-\-force"
  assert_output_contains "documents --verbose flag" "$help_output" "\-\-verbose"
  assert_output_contains "documents --help flag" "$help_output" "\-\-help"

  teardown
}

test_help_exits_zero() {
  echo "test_help_exits_zero — --help exits with code 0"
  setup

  if (cd "$TARGET" && bash "$INSTALL_SCRIPT" --help) > /dev/null 2>&1; then
    echo "  PASS: exits with code 0"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: exited with non-zero code"
    FAIL=$((FAIL + 1))
  fi

  teardown
}

test_help_does_not_install() {
  echo "test_help_does_not_install — --help does not create any files"
  setup

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --help) > /dev/null 2>&1

  if [ ! -d "$TARGET/.claude" ] && [ ! -d "$TARGET/agents-context" ] && [ ! -d "$TARGET/lead-dev-os" ] && [ ! -f "$TARGET/CLAUDE.md" ]; then
    echo "  PASS: no files installed"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: --help should not install any files"
    FAIL=$((FAIL + 1))
  fi

  teardown
}

# --- Run all tests ---

echo "=== Tests: install.sh --help ==="
echo ""

test_help_prints_all_sections
test_help_exits_zero
test_help_does_not_install

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
