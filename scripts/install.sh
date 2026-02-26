#!/usr/bin/env bash
# agents-flight-deck — Install into a target project
#
# Usage:
#   ./scripts/install.sh [OPTIONS]
#
# Options:
#   --commands-only       Only update commands, skip context/standards/templates
#   --force               Overwrite existing files without prompting
#   --profile <name>      Use this profile (skip interactive prompt)
#   --verbose             Show detailed output
#   --help                Show this help message
#
# Run this script from inside the target project directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAD_DEV_OS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$LEAD_DEV_OS_ROOT/app"
TARGET_DIR="$(pwd)"

# Source shared utilities
source "$SCRIPT_DIR/common-functions.sh"

show_help() {
  cat <<'HELPTEXT'
agents-flight-deck installer

Installs the agents-flight-deck kit into a target project, giving you
structured slash commands for product planning, spec writing, task scoping,
and context-aware implementation with Claude Code.

USAGE
  cd /path/to/your-project
  /path/to/agents-flight-deck/scripts/install.sh [OPTIONS]

  Run this script from inside the target project directory.

OPTIONS
  --commands-only   Only install slash commands; skip context, standards,
                    templates, and CLAUDE.md updates.
  --profile <name>  Use the named config profile instead of prompting
                    interactively (e.g. --profile fullstack).
  --force           Overwrite existing files without prompting.
  --verbose         Show detailed output for every file operation.
  --help            Show this help message and exit.

WHAT GETS INSTALLED
  .claude/commands/agents-flight-deck/   Slash commands for Claude Code
  agents-context/concepts/               Project-specific domain knowledge
  agents-context/standards/              Coding standards (shared + stack-specific)
  agents-context/guides/                 Workflow how-to guides
  agents-flight-deck/templates/          Reusable document templates
  agents-flight-deck/specs/              Output directory for generated specs
  CLAUDE.md                              Framework instructions (appended)

EXAMPLES
  # Full install with interactive profile selection
  ./scripts/install.sh

  # Install only commands (useful for quick updates)
  ./scripts/install.sh --commands-only

  # Non-interactive install with a specific profile
  ./scripts/install.sh --profile fullstack

  # Full install with detailed logging
  ./scripts/install.sh --verbose
HELPTEXT
}

# Flags
COMMANDS_ONLY=false
PROFILE_OVERRIDE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --commands-only)
      COMMANDS_ONLY=true
      shift
      ;;
    --profile)
      PROFILE_OVERRIDE="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate target is a git repo (optional but recommended)
if [ ! -d "$TARGET_DIR/.git" ]; then
  print_warning "Target directory is not a git repository. Continuing anyway."
fi

print_status "Installing agents-flight-deck into: $TARGET_DIR"

# --- Install Commands ---
COMMANDS_DEST="$TARGET_DIR/.claude/commands/agents-flight-deck"
ensure_dir "$COMMANDS_DEST"

print_status "Installing commands..."

# Flatten strategic + tactical commands into one directory for slash-command access
for cmd_file in "$APP_DIR"/commands/strategic/*.md "$APP_DIR"/commands/tactical/*.md; do
  if [ -f "$cmd_file" ]; then
    filename="$(basename "$cmd_file")"
    dest_path="$COMMANDS_DEST/$filename"
    if confirm_overwrite "$dest_path"; then
      cp "$cmd_file" "$dest_path"
      print_verbose "  Installed command: $filename"
    else
      print_verbose "  Skipped command: $filename"
    fi
  fi
done

print_success "Commands installed to .claude/commands/agents-flight-deck/"

if [ "$COMMANDS_ONLY" = true ]; then
  print_success "Done (commands only)."
  exit 0
fi

# --- Install agents-context/ (top-level) ---
CONTEXT_DEST="$TARGET_DIR/agents-context"

print_status "Installing agents-context..."

ensure_gitkeep "$CONTEXT_DEST/concepts"
ensure_dir "$CONTEXT_DEST/standards"
ensure_dir "$CONTEXT_DEST/guides"

# --- Install stack-filtered standards ---
CONFIG_FILE="$(get_config_file)"
print_verbose "Using config: $CONFIG_FILE"

# Select profile: use --profile flag if provided, otherwise prompt interactively
if [ -n "$PROFILE_OVERRIDE" ]; then
  SELECTED_PROFILE="$PROFILE_OVERRIDE"
else
  SELECTED_PROFILE="$(prompt_for_profile "$CONFIG_FILE")"
fi
print_status "Using profile: $SELECTED_PROFILE"

# Always copy shared standards
for std_file in "$APP_DIR"/agents-context/standards/shared/*.md; do
  if [ -f "$std_file" ]; then
    copy_if_not_exists "$std_file" "$CONTEXT_DEST/standards/$(basename "$std_file")" || true
    print_verbose "  Installed shared standard: $(basename "$std_file")"
  fi
done

# Copy enabled stack standards (flattened into standards/)
ENABLED_STACKS="$(get_enabled_stacks "$CONFIG_FILE" "$SELECTED_PROFILE")"
if [ -n "$ENABLED_STACKS" ]; then
  while IFS= read -r stack; do
    local_stack_dir="$APP_DIR/agents-context/standards/$stack"
    if [ -d "$local_stack_dir" ]; then
      for std_file in "$local_stack_dir"/*.md; do
        if [ -f "$std_file" ]; then
          copy_if_not_exists "$std_file" "$CONTEXT_DEST/standards/$(basename "$std_file")" || true
          print_verbose "  Installed $stack standard: $(basename "$std_file")"
        fi
      done
    else
      print_warning "Stack directory not found: $local_stack_dir"
    fi
  done <<< "$ENABLED_STACKS"
  print_success "Standards installed for stacks: $(echo "$ENABLED_STACKS" | tr '\n' ' ')"
else
  print_status "No stacks enabled — only shared standards installed"
fi

# Copy guides (always overwrite — these are framework docs)
for guide_file in "$APP_DIR"/agents-context/guides/*.md; do
  if [ -f "$guide_file" ]; then
    copy_with_warning "$guide_file" "$CONTEXT_DEST/guides/$(basename "$guide_file")" "Guide"
  fi
done

print_success "Context installed to agents-context/"

# --- Install Templates & Specs (inside agents-flight-deck/) ---
FRAMEWORK_DEST="$TARGET_DIR/agents-flight-deck"

print_status "Installing framework files..."

# Templates (always overwrite — these are framework templates)
ensure_dir "$FRAMEWORK_DEST/templates"
for template_file in "$APP_DIR"/templates/*.md; do
  if [ -f "$template_file" ]; then
    copy_with_warning "$template_file" "$FRAMEWORK_DEST/templates/$(basename "$template_file")" "Template"
  fi
done

# Specs directory
ensure_gitkeep "$FRAMEWORK_DEST/specs"

print_success "Framework files installed to agents-flight-deck/"

# --- Install/Update CLAUDE.md ---
print_status "Updating CLAUDE.md..."

CLAUDE_MD_SRC="$APP_DIR/CLAUDE.md"
CLAUDE_MD_DEST="$TARGET_DIR/CLAUDE.md"

if [ -f "$CLAUDE_MD_SRC" ]; then
  if [ -f "$CLAUDE_MD_DEST" ]; then
    # Check if agents-flight-deck section already exists
    if grep -q "## agents-flight-deck Framework" "$CLAUDE_MD_DEST" 2>/dev/null; then
      print_warning "CLAUDE.md already contains agents-flight-deck section — skipping."
      print_warning "To update, remove the '## agents-flight-deck Framework' section and re-run."
    else
      # Append framework instructions to existing CLAUDE.md
      echo "" >> "$CLAUDE_MD_DEST"
      cat "$CLAUDE_MD_SRC" >> "$CLAUDE_MD_DEST"
      print_success "Appended agents-flight-deck instructions to existing CLAUDE.md"
    fi
  else
    cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
    print_success "Created CLAUDE.md with agents-flight-deck instructions"
  fi
fi

# --- Summary ---
echo ""
print_success "Installation complete!"
echo ""
print_status "Installed structure:"
print_status "  .claude/commands/agents-flight-deck/  — Slash commands"
print_status "  agents-context/                — Knowledge base (concepts, standards, guides)"
print_status "  agents-flight-deck/templates/         — Document templates"
print_status "  agents-flight-deck/specs/             — Spec output directory"
echo ""
print_status "Get started:"
print_status "  1. Run /plan-product to define your product mission"
print_status "  2. Run /define-standards to establish coding conventions"
print_status "  3. Run /step1-shape-spec to begin speccing a feature"
