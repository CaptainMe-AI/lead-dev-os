#!/usr/bin/env bash
# lead-dev-os — Shared shell utilities

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERBOSE=false

# Print functions
print_status() {
  echo -e "${BLUE}[lead-dev-os]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[lead-dev-os]${NC} $1"
}

print_error() {
  echo -e "${RED}[lead-dev-os]${NC} $1" >&2
}

print_warning() {
  echo -e "${YELLOW}[lead-dev-os]${NC} $1"
}

print_verbose() {
  if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}[lead-dev-os]${NC} (verbose) $1"
  fi
}

# Directory helpers
ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    print_verbose "Created directory: $dir"
  fi
}

# File helpers
ensure_gitkeep() {
  local dir="$1"
  ensure_dir "$dir"
  if [ ! -f "$dir/.gitkeep" ]; then
    touch "$dir/.gitkeep"
    print_verbose "Created .gitkeep in: $dir"
  fi
}

copy_if_not_exists() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$dest" ]; then
    cp "$src" "$dest"
    print_verbose "Copied: $src → $dest"
    return 0
  else
    print_verbose "Skipped (already exists): $dest"
    return 1
  fi
}

copy_with_warning() {
  local src="$1"
  local dest="$2"
  local label="${3:-file}"
  if [ -f "$dest" ]; then
    print_warning "$label already exists at $dest — overwriting"
  fi
  cp "$src" "$dest"
  print_verbose "Copied: $src → $dest"
}
