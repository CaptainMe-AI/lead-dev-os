#!/usr/bin/env bash
# Run all lead-dev-os tests
#
# Usage: ./tests/run_all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED=0
PASSED=0

for test_file in "$SCRIPT_DIR"/test_*.sh; do
  name="$(basename "$test_file")"
  echo ""
  echo "━━━ $name ━━━"
  if bash "$test_file" </dev/null; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Suites: $PASSED passed, $FAILED failed ($(( PASSED + FAILED )) total)"
if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
