#!/usr/bin/env bash
# Integration tests: stack-based config system with profiles
#
# Tests that install.sh reads config profiles and only copies matching stack standards.
#
# Usage: ./tests/test_stack_config.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"

source "$ROOT_DIR/scripts/common-functions.sh"
export LEAD_DEV_OS_ROOT="$ROOT_DIR"

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
  # Clean up any test standards we created
  rm -f "$ROOT_DIR/app/agents-context/standards/shared/coding-style.md"
  rm -f "$ROOT_DIR/app/agents-context/standards/python/python-conventions.md"
  rm -f "$ROOT_DIR/app/agents-context/standards/fastapi/fastapi-api.md"
  rm -f "$ROOT_DIR/app/agents-context/standards/rails/rails-conventions.md"
  rm -f "$ROOT_DIR/config.local.yml"
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

# --- Tests ---

test_get_config_file_defaults() {
  echo "test_get_config_file_defaults — falls back to config.default.yml"
  rm -f "$ROOT_DIR/config.local.yml"

  local result
  result="$(get_config_file)"
  assert_eq "returns config.default.yml" "$ROOT_DIR/config.default.yml" "$result"
}

test_get_config_file_local_override() {
  echo "test_get_config_file_local_override — prefers config.local.yml"
  echo "version: 1.0" > "$ROOT_DIR/config.local.yml"

  local result
  result="$(get_config_file)"
  assert_eq "returns config.local.yml" "$ROOT_DIR/config.local.yml" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_get_current_profile() {
  echo "test_get_current_profile — reads current_profile from config"

  local result
  result="$(get_current_profile "$ROOT_DIR/config.default.yml")"
  assert_eq "default profile from config.default.yml" "default" "$result"

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: backend

profiles:
  backend:
    stack:
      python: true
EOF

  result="$(get_current_profile "$ROOT_DIR/config.local.yml")"
  assert_eq "backend profile from config.local.yml" "backend" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_get_available_profiles() {
  echo "test_get_available_profiles — lists all profile names"
  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: backend

profiles:
  backend:
    stack:
      python: true
      fastapi: true
  frontend:
    stack:
      react: true
      typescript: true
EOF

  local result
  result="$(get_available_profiles "$ROOT_DIR/config.local.yml")"
  local expected
  expected="$(printf 'backend\nfrontend')"
  assert_eq "returns both profiles" "$expected" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_get_enabled_stacks_default_profile() {
  echo "test_get_enabled_stacks_default_profile — default config enables all stacks"

  local result
  result="$(get_enabled_stacks "$ROOT_DIR/config.default.yml")"
  # Should contain all 20 stacks
  local count
  count="$(echo "$result" | wc -l | tr -d ' ')"
  assert_eq "all 19 stacks enabled in default" "19" "$count"
}

test_get_enabled_stacks_specific_profile() {
  echo "test_get_enabled_stacks_specific_profile — parses enabled stacks from named profile"
  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: backend

profiles:
  backend:
    stack:
      fastapi: true
      python: true
      rails: false
      postgresql: true
  frontend:
    stack:
      react: true
      typescript: true
EOF

  # Test current profile (backend)
  local result
  result="$(get_enabled_stacks "$ROOT_DIR/config.local.yml")"
  local expected
  expected="$(printf 'fastapi\npython\npostgresql')"
  assert_eq "current profile stacks" "$expected" "$result"

  # Test explicit profile (frontend)
  result="$(get_enabled_stacks "$ROOT_DIR/config.local.yml" "frontend")"
  expected="$(printf 'react\ntypescript')"
  assert_eq "explicit frontend profile stacks" "$expected" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_default_config_installs_all() {
  echo "test_default_config_installs_all — default config installs all stack standards"
  setup

  # Create sample standards in multiple stacks
  echo "# Coding Style" > "$ROOT_DIR/app/agents-context/standards/shared/coding-style.md"
  echo "# Python Conventions" > "$ROOT_DIR/app/agents-context/standards/python/python-conventions.md"
  echo "# Rails Conventions" > "$ROOT_DIR/app/agents-context/standards/rails/rails-conventions.md"

  # No config.local.yml — uses default (all stacks enabled)
  rm -f "$ROOT_DIR/config.local.yml"

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  assert_file_exists "shared standard installed" "$TARGET/agents-context/standards/coding-style.md"
  assert_file_exists "python standard installed" "$TARGET/agents-context/standards/python-conventions.md"
  assert_file_exists "rails standard installed" "$TARGET/agents-context/standards/rails-conventions.md"

  teardown
}

test_local_config_filters_stacks() {
  echo "test_local_config_filters_stacks — local config filters to enabled stacks only"
  setup

  # Create sample standards
  echo "# Coding Style" > "$ROOT_DIR/app/agents-context/standards/shared/coding-style.md"
  echo "# Python Conventions" > "$ROOT_DIR/app/agents-context/standards/python/python-conventions.md"
  echo "# FastAPI API" > "$ROOT_DIR/app/agents-context/standards/fastapi/fastapi-api.md"
  echo "# Rails Conventions" > "$ROOT_DIR/app/agents-context/standards/rails/rails-conventions.md"

  # Enable python and fastapi only
  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: backend

profiles:
  backend:
    stack:
      fastapi: true
      python: true
      rails: false
EOF

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile backend) > /dev/null 2>&1

  # Shared always present
  assert_file_exists "shared standard installed" "$TARGET/agents-context/standards/coding-style.md"
  # Enabled stacks present
  assert_file_exists "python standard installed" "$TARGET/agents-context/standards/python-conventions.md"
  assert_file_exists "fastapi standard installed" "$TARGET/agents-context/standards/fastapi-api.md"
  # Disabled stack absent
  assert_file_not_exists "rails standard NOT installed" "$TARGET/agents-context/standards/rails-conventions.md"

  teardown
}

test_standards_not_overwritten_by_installer() {
  echo "test_standards_not_overwritten_by_installer — user-modified standards preserved on re-install"
  setup

  echo "# Python Conventions" > "$ROOT_DIR/app/agents-context/standards/python/python-conventions.md"

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
EOF

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # User modifies the installed standard
  echo "# My Custom Python Standards" > "$TARGET/agents-context/standards/python-conventions.md"

  # Re-install
  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # Should preserve user content (copy_if_not_exists)
  local content
  content="$(cat "$TARGET/agents-context/standards/python-conventions.md")"
  assert_eq "user content preserved" "# My Custom Python Standards" "$content"

  teardown
}

test_shared_always_installed() {
  echo "test_shared_always_installed — shared standards always copied even with empty profile"
  setup

  echo "# Coding Style" > "$ROOT_DIR/app/agents-context/standards/shared/coding-style.md"

  # Profile with no stacks enabled
  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: minimal

profiles:
  minimal:
    stack:
      python: false
EOF

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile minimal) > /dev/null 2>&1

  assert_file_exists "shared standard installed" "$TARGET/agents-context/standards/coding-style.md"

  teardown
}

test_plan_mode_does_not_pollute_stacks() {
  echo "test_plan_mode_does_not_pollute_stacks — plan_mode keys excluded from get_enabled_stacks"

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
      fastapi: true
    plan_mode:
      step1_shape_spec: true
      step2_define_spec: true
      step3_scope_tasks: true
      step4_implement_tasks: true
EOF

  local result
  result="$(get_enabled_stacks "$ROOT_DIR/config.local.yml")"
  local expected
  expected="$(printf 'python\nfastapi')"
  assert_eq "plan_mode keys not in stacks" "$expected" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_get_plan_mode_enabled() {
  echo "test_get_plan_mode_enabled — returns true when plan_mode step is true"

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
    plan_mode:
      step1_shape_spec: true
      step2_define_spec: false
EOF

  local result
  result="$(get_plan_mode "$ROOT_DIR/config.local.yml" "step1_shape_spec")"
  assert_eq "step1 plan mode true" "true" "$result"

  result="$(get_plan_mode "$ROOT_DIR/config.local.yml" "step2_define_spec")"
  assert_eq "step2 plan mode false" "false" "$result"

  result="$(get_plan_mode "$ROOT_DIR/config.local.yml" "step3_scope_tasks")"
  assert_eq "missing step returns false" "false" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_get_plan_mode_missing_section() {
  echo "test_get_plan_mode_missing_section — returns false when plan_mode section missing"

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
EOF

  local result
  result="$(get_plan_mode "$ROOT_DIR/config.local.yml" "step1_shape_spec")"
  assert_eq "no plan_mode section returns false" "false" "$result"

  rm -f "$ROOT_DIR/config.local.yml"
}

test_plan_mode_injected_on_install() {
  echo "test_plan_mode_injected_on_install — installer replaces placeholder when plan_mode is true"
  setup

  cat > "$ROOT_DIR/config.local.yml" <<'EOF'
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
    plan_mode:
      step1_shape_spec: true
      step4_implement_tasks: false
EOF

  (cd "$TARGET" && bash "$INSTALL_SCRIPT" --profile default) > /dev/null 2>&1

  # step1 should have plan mode injected (placeholder replaced)
  if grep -q "## Planning" "$TARGET/.claude/commands/lead-dev-os/step1-shape-spec.md"; then
    echo "  PASS: step1 has plan mode injected"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: step1 should have plan mode injected"
    FAIL=$((FAIL + 1))
  fi

  # step1 should NOT have the placeholder anymore
  if grep -q "INSERT-PLAN-MODE-HERE" "$TARGET/.claude/commands/lead-dev-os/step1-shape-spec.md"; then
    echo "  FAIL: step1 still has placeholder"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS: step1 placeholder removed"
    PASS=$((PASS + 1))
  fi

  # step4 should have placeholder removed (plan_mode false)
  if grep -q "INSERT-PLAN-MODE-HERE" "$TARGET/.claude/commands/lead-dev-os/step4-implement-tasks.md"; then
    echo "  FAIL: step4 still has placeholder"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS: step4 placeholder removed"
    PASS=$((PASS + 1))
  fi

  if grep -q "## Planning" "$TARGET/.claude/commands/lead-dev-os/step4-implement-tasks.md"; then
    echo "  FAIL: step4 should NOT have plan mode injected"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS: step4 does not have plan mode"
    PASS=$((PASS + 1))
  fi

  teardown
}

# --- Run all tests ---

echo "=== Tests: Stack-Based Config System (Profiles) ==="
echo ""

test_get_config_file_defaults
test_get_config_file_local_override
test_get_current_profile
test_get_available_profiles
test_get_enabled_stacks_default_profile
test_get_enabled_stacks_specific_profile
test_default_config_installs_all
test_local_config_filters_stacks
test_standards_not_overwritten_by_installer
test_shared_always_installed
test_plan_mode_does_not_pollute_stacks
test_get_plan_mode_enabled
test_get_plan_mode_missing_section
test_plan_mode_injected_on_install

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

[ "$FAIL" -eq 0 ] || exit 1
