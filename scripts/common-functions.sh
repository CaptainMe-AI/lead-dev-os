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
FORCE=false

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

confirm_overwrite() {
  local path="$1"
  if [ ! -f "$path" ]; then
    return 0
  fi
  if [ "$FORCE" = true ]; then
    return 0
  fi
  local answer
  read -rp "$(echo -e "${YELLOW}[lead-dev-os]${NC}") Overwrite $path? [y/N] " answer
  case "$answer" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

copy_with_warning() {
  local src="$1"
  local dest="$2"
  local label="${3:-file}"
  if ! confirm_overwrite "$dest"; then
    print_verbose "Skipped (user declined): $dest"
    return 0
  fi
  cp "$src" "$dest"
  print_verbose "Copied: $src → $dest"
}

# Config helpers

# Returns path to config.local.yml if it exists, otherwise config.default.yml
# Expects LEAD_DEV_OS_ROOT to be set by the caller
get_config_file() {
  local root="${LEAD_DEV_OS_ROOT:-.}"
  if [ -f "$root/config.local.yml" ]; then
    echo "$root/config.local.yml"
  else
    echo "$root/config.default.yml"
  fi
}

# Returns the current_profile value from a config file
get_current_profile() {
  local config_file="$1"
  if [ ! -f "$config_file" ]; then
    echo "default"
    return
  fi
  local profile
  profile="$(sed -n 's/^current_profile:[[:space:]]*\([a-zA-Z0-9_-]*\).*/\1/p' "$config_file")"
  echo "${profile:-default}"
}

# Returns list of available profile names from a config file (one per line)
get_available_profiles() {
  local config_file="$1"
  if [ ! -f "$config_file" ]; then
    return
  fi
  local in_profiles=false
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^profiles:'; then
      in_profiles=true
      continue
    fi
    # Exit profiles section on non-indented, non-comment, non-empty line
    if $in_profiles && echo "$line" | grep -qE '^[^ #]'; then
      in_profiles=false
    fi
    if $in_profiles; then
      # Match profile names at 2-space indent: "  profile_name:"
      local name
      name="$(echo "$line" | sed -n 's/^  \([a-zA-Z0-9_-]*\):$/\1/p')"
      if [ -n "$name" ]; then
        echo "$name"
      fi
    fi
  done < "$config_file"
}

# Prompts the user to select a profile. Returns the chosen profile name.
# Usage: prompt_for_profile <config_file>
prompt_for_profile() {
  local config_file="$1"
  local current
  current="$(get_current_profile "$config_file")"

  echo ""
  read -rp "$(echo -e "${BLUE}[lead-dev-os]${NC}") Use default profile (${current})? [Y/n] " answer
  case "$answer" in
    [nN]|[nN][oO])
      # Show available profiles and let user pick
      local profiles
      profiles="$(get_available_profiles "$config_file")"
      if [ -z "$profiles" ]; then
        print_warning "No profiles found in config. Using default."
        echo "$current"
        return
      fi

      echo ""
      print_status "Available profiles:"
      local i=1
      local profile_array=()
      while IFS= read -r p; do
        profile_array+=("$p")
        local stacks
        stacks="$(get_enabled_stacks "$config_file" "$p" | tr '\n' ' ')"
        echo "  $i) $p — ${stacks:-no stacks enabled}"
        i=$((i + 1))
      done <<< "$profiles"

      echo ""
      read -rp "$(echo -e "${BLUE}[lead-dev-os]${NC}") Select profile [1-${#profile_array[@]}]: " choice

      if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#profile_array[@]}" ]; then
        echo "${profile_array[$((choice - 1))]}"
      else
        print_warning "Invalid choice. Using default profile ($current)."
        echo "$current"
      fi
      ;;
    *)
      echo "$current"
      ;;
  esac
}

# Returns "true" or "false" for a plan_mode step in a profile
# Usage: get_plan_mode <config_file> <step_key> [profile_name]
# Example: get_plan_mode config.default.yml step1_write_spec
get_plan_mode() {
  local config_file="$1"
  local step_key="$2"
  local profile="${3:-}"
  if [ ! -f "$config_file" ]; then
    echo "false"
    return
  fi
  if [ -z "$profile" ]; then
    profile="$(get_current_profile "$config_file")"
  fi

  # State machine to parse: profiles > {profile} > plan_mode > step_key: true/false
  local state="seek_profiles"
  while IFS= read -r line; do
    case "$state" in
      seek_profiles)
        if echo "$line" | grep -qE '^profiles:'; then
          state="seek_profile"
        fi
        ;;
      seek_profile)
        if echo "$line" | grep -qE '^[^ #]'; then
          echo "false"
          return
        fi
        if echo "$line" | grep -qE "^  ${profile}:$"; then
          state="seek_plan_mode"
        fi
        ;;
      seek_plan_mode)
        if echo "$line" | grep -qE '^[^ #]'; then
          echo "false"
          return
        fi
        if echo "$line" | grep -qE '^  [a-zA-Z0-9_-]*:$'; then
          echo "false"
          return
        fi
        if echo "$line" | grep -qE '^    plan_mode:'; then
          state="read_plan_mode"
        fi
        ;;
      read_plan_mode)
        if echo "$line" | grep -qE '^[^ #]'; then
          echo "false"
          return
        fi
        if echo "$line" | grep -qE '^  [a-zA-Z0-9_-]*:$'; then
          echo "false"
          return
        fi
        if echo "$line" | grep -qE '^    [a-zA-Z0-9_-]*:'; then
          echo "false"
          return
        fi
        # Match the specific step key
        if echo "$line" | grep -qE "^[[:space:]]*${step_key}:[[:space:]]*true"; then
          echo "true"
          return
        fi
        if echo "$line" | grep -qE "^[[:space:]]*${step_key}:[[:space:]]*false"; then
          echo "false"
          return
        fi
        ;;
    esac
  done < "$config_file"
  echo "false"
}

# Parses config file and returns enabled stack names for a profile (one per line)
# Usage: get_enabled_stacks <config_file> [profile_name]
# If profile_name is omitted, uses current_profile from the config file
get_enabled_stacks() {
  local config_file="$1"
  local profile="${2:-}"
  if [ ! -f "$config_file" ]; then
    return
  fi
  if [ -z "$profile" ]; then
    profile="$(get_current_profile "$config_file")"
  fi

  # State machine to parse: profiles > {profile} > stack > key: true
  local state="seek_profiles"
  while IFS= read -r line; do
    case "$state" in
      seek_profiles)
        if echo "$line" | grep -qE '^profiles:'; then
          state="seek_profile"
        fi
        ;;
      seek_profile)
        # Exit profiles on non-indented line
        if echo "$line" | grep -qE '^[^ #]'; then
          return
        fi
        # Match target profile at 2-space indent
        if echo "$line" | grep -qE "^  ${profile}:$"; then
          state="seek_stack"
        fi
        ;;
      seek_stack)
        # Exit profile on line at 2-space indent (next profile) or non-indented
        if echo "$line" | grep -qE '^[^ #]'; then
          return
        fi
        if echo "$line" | grep -qE '^  [a-zA-Z0-9_-]*:$'; then
          return
        fi
        if echo "$line" | grep -qE '^    stack:'; then
          state="read_stacks"
        fi
        ;;
      read_stacks)
        # Exit on line with less than 6 spaces of indent (back to profile or section level)
        if echo "$line" | grep -qE '^[^ #]'; then
          return
        fi
        if echo "$line" | grep -qE '^  [a-zA-Z0-9_-]*:$'; then
          return
        fi
        if echo "$line" | grep -qE '^    [a-zA-Z0-9_-]*:'; then
          # Hit a new section at 4-space indent within the profile
          return
        fi
        # Match "      key: true"
        local key
        key="$(echo "$line" | sed -n 's/^[[:space:]]*\([a-zA-Z0-9_-]*\):[[:space:]]*true.*/\1/p')"
        if [ -n "$key" ]; then
          echo "$key"
        fi
        ;;
    esac
  done < "$config_file"
}
