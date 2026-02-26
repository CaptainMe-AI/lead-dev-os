#!/usr/bin/env bash
# Unit tests for scripts/common-functions.sh
#
# Usage: ./tests/test_common_functions.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT_DIR/scripts/common-functions.sh"

PASS=0
FAIL=0
TMPDIR=""

# --- Test helpers ---

setup() {
  TMPDIR="$(mktemp -d)"
}

teardown() {
  [ -n "$TMPDIR" ] && rm -rf "$TMPDIR"
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

assert_file_not_exists() {
  local label="$1" path="$2"
  if [ ! -f "$path" ]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — file should not exist: $path"
    FAIL=$((FAIL + 1))
  fi
}

# --- Tests ---

test_ensure_dir() {
  echo "test_ensure_dir"
  setup

  ensure_dir "$TMPDIR/a/b/c"
  assert_dir_exists "creates nested directories" "$TMPDIR/a/b/c"

  # Running again should not fail
  ensure_dir "$TMPDIR/a/b/c"
  assert_dir_exists "idempotent on existing directory" "$TMPDIR/a/b/c"

  teardown
}

test_ensure_gitkeep() {
  echo "test_ensure_gitkeep"
  setup

  ensure_gitkeep "$TMPDIR/mydir"
  assert_dir_exists "creates directory" "$TMPDIR/mydir"
  assert_file_exists "creates .gitkeep" "$TMPDIR/mydir/.gitkeep"

  # Running again should not fail
  ensure_gitkeep "$TMPDIR/mydir"
  assert_file_exists "idempotent .gitkeep" "$TMPDIR/mydir/.gitkeep"

  teardown
}

test_copy_if_not_exists() {
  echo "test_copy_if_not_exists"
  setup

  echo "original" > "$TMPDIR/src.txt"

  copy_if_not_exists "$TMPDIR/src.txt" "$TMPDIR/dest.txt"
  assert_file_exists "copies file when dest missing" "$TMPDIR/dest.txt"
  assert_eq "content matches source" "original" "$(cat "$TMPDIR/dest.txt")"

  # Modify dest, run again — should NOT overwrite
  echo "modified" > "$TMPDIR/dest.txt"
  copy_if_not_exists "$TMPDIR/src.txt" "$TMPDIR/dest.txt" || true
  assert_eq "does not overwrite existing file" "modified" "$(cat "$TMPDIR/dest.txt")"

  teardown
}

test_copy_with_warning() {
  echo "test_copy_with_warning"
  setup

  echo "source content" > "$TMPDIR/src.txt"

  # First copy — no dest exists
  copy_with_warning "$TMPDIR/src.txt" "$TMPDIR/dest.txt" "TestFile"
  assert_file_exists "copies when dest missing" "$TMPDIR/dest.txt"
  assert_eq "content matches" "source content" "$(cat "$TMPDIR/dest.txt")"

  # Modify dest, run again with FORCE — SHOULD overwrite
  echo "old content" > "$TMPDIR/dest.txt"
  echo "new source" > "$TMPDIR/src.txt"
  FORCE=true
  copy_with_warning "$TMPDIR/src.txt" "$TMPDIR/dest.txt" "TestFile"
  FORCE=false
  assert_eq "overwrites existing file" "new source" "$(cat "$TMPDIR/dest.txt")"

  teardown
}

test_print_verbose_respects_flag() {
  echo "test_print_verbose_respects_flag"
  setup

  VERBOSE=false
  local output
  output="$(print_verbose "hidden message" 2>&1)"
  assert_eq "silent when VERBOSE=false" "" "$output"

  VERBOSE=true
  output="$(print_verbose "visible message" 2>&1)"
  if echo "$output" | grep -q "visible message"; then
    echo "  PASS: prints when VERBOSE=true"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: should print when VERBOSE=true"
    FAIL=$((FAIL + 1))
  fi
  VERBOSE=false

  teardown
}

# --- Run all tests ---

echo "=== Unit Tests: common-functions.sh ==="
echo ""

test_ensure_dir
test_ensure_gitkeep
test_copy_if_not_exists
test_copy_with_warning
test_print_verbose_respects_flag

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
