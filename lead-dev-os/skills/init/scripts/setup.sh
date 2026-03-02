#!/usr/bin/env bash
set -euo pipefail

# setup.sh — Scaffold the lead-dev-os framework in a target project.
#
# Usage:
#   setup.sh --project <name> [--stacks <csv>] --plugin-root <path> [--overwrite]
#
# This script runs from the TARGET PROJECT directory (cwd).

# --- Argument parsing -----------------------------------------------------------

PROJECT_NAME=""
STACKS=""
PLUGIN_ROOT=""
OVERWRITE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --stacks)
      STACKS="$2"
      shift 2
      ;;
    --plugin-root)
      PLUGIN_ROOT="$2"
      shift 2
      ;;
    --overwrite)
      OVERWRITE=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: --project is required" >&2
  exit 1
fi

if [[ -z "$PLUGIN_ROOT" ]]; then
  echo "Error: --plugin-root is required" >&2
  exit 1
fi

# --- Paths ----------------------------------------------------------------------

INIT_DIR="${PLUGIN_ROOT}/skills/init"
STANDARDS_GLOBAL_DIR="${INIT_DIR}/standards-global"
STANDARDS_TESTING_DIR="${INIT_DIR}/standards-testing"
TEMPLATES_DIR="${INIT_DIR}/templates"

# --- Collectors for output sections --------------------------------------------

CREATED_DIRS=()
COPIED_STANDARDS=()
RENDERED_TEMPLATES=()
CREATED_STACKS=()
SKIPPED_FILES=()

# --- Helper: copy or skip a file ------------------------------------------------
# Returns 0 if copied, 1 if skipped.

copy_or_skip() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ -f "$dest" && "$OVERWRITE" == false ]]; then
    SKIPPED_FILES+=("${label} (already exists)")
    return 1
  fi

  cp "$src" "$dest"
  return 0
}

# --- 1. Create directories ------------------------------------------------------

DIRS=(
  "agents-context/concepts"
  "agents-context/standards"
  "agents-context/guides"
  "lead-dev-os/specs"
)

for dir in "${DIRS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    CREATED_DIRS+=("$dir")
  fi
done

# --- 2. Copy global standards ----------------------------------------------------

for src_file in "${STANDARDS_GLOBAL_DIR}"/*.md; do
  [[ -f "$src_file" ]] || continue
  filename="$(basename "$src_file")"
  dest="agents-context/standards/${filename}"

  if copy_or_skip "$src_file" "$dest" "$filename"; then
    COPIED_STANDARDS+=("$filename")
  fi
done

# --- 3. Copy testing standards ---------------------------------------------------

for src_file in "${STANDARDS_TESTING_DIR}"/*.md; do
  [[ -f "$src_file" ]] || continue
  filename="$(basename "$src_file")"
  dest="agents-context/standards/${filename}"

  if copy_or_skip "$src_file" "$dest" "$filename"; then
    COPIED_STANDARDS+=("$filename")
  fi
done

# --- 4. Create stack placeholder dirs --------------------------------------------

if [[ -n "$STACKS" ]]; then
  IFS=',' read -ra STACK_ARRAY <<< "$STACKS"
  for stack in "${STACK_ARRAY[@]}"; do
    # Trim whitespace
    stack="$(echo "$stack" | xargs)"
    [[ -z "$stack" ]] && continue

    stack_dir="agents-context/standards/${stack}"
    if [[ ! -d "$stack_dir" ]]; then
      mkdir -p "$stack_dir"
      touch "${stack_dir}/.gitkeep"
      CREATED_STACKS+=("${stack_dir}/")
    fi
  done
fi

# --- 5. Render templates ---------------------------------------------------------

# Template: workflow.md -> agents-context/guides/workflow.md (copy as-is)
if copy_or_skip "${TEMPLATES_DIR}/workflow.md" "agents-context/guides/workflow.md" "agents-context/guides/workflow.md"; then
  RENDERED_TEMPLATES+=("agents-context/guides/workflow.md")
fi

# Template: agents.md -> agents-context/AGENTS.md (copy as-is)
if copy_or_skip "${TEMPLATES_DIR}/agents.md" "agents-context/AGENTS.md" "agents-context/AGENTS.md"; then
  RENDERED_TEMPLATES+=("agents-context/AGENTS.md")
fi

# Template: readme.md -> agents-context/README.md (replace {Project Name})
README_DEST="agents-context/README.md"
if [[ -f "$README_DEST" && "$OVERWRITE" == false ]]; then
  SKIPPED_FILES+=("agents-context/README.md (already exists)")
else
  # Use bash parameter expansion for safe replacement (handles &, \, etc.)
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "${line//\{Project Name\}/$PROJECT_NAME}"
  done < "${TEMPLATES_DIR}/readme.md" > "$README_DEST"
  RENDERED_TEMPLATES+=("agents-context/README.md")
fi

# --- 6. Output structured results -----------------------------------------------

if [[ ${#CREATED_DIRS[@]} -gt 0 ]]; then
  echo "===DIRS==="
  for d in "${CREATED_DIRS[@]}"; do
    echo "$d"
  done
fi

if [[ ${#COPIED_STANDARDS[@]} -gt 0 ]]; then
  echo "===STANDARDS==="
  for s in "${COPIED_STANDARDS[@]}"; do
    echo "$s"
  done
fi

if [[ ${#RENDERED_TEMPLATES[@]} -gt 0 ]]; then
  echo "===TEMPLATES==="
  for t in "${RENDERED_TEMPLATES[@]}"; do
    echo "$t"
  done
fi

if [[ ${#CREATED_STACKS[@]} -gt 0 ]]; then
  echo "===STACKS==="
  for st in "${CREATED_STACKS[@]}"; do
    echo "$st"
  done
fi

if [[ ${#SKIPPED_FILES[@]} -gt 0 ]]; then
  echo "===SKIPPED==="
  for sk in "${SKIPPED_FILES[@]}"; do
    echo "$sk"
  done
fi

echo "===DONE==="
