#!/usr/bin/env bash
# lead-dev-os — Install into a target project
#
# Usage:
#   ./scripts/install.sh [OPTIONS]
#
# Options:
#   --commands-only   Only update commands, skip context/standards/templates
#   --verbose         Show detailed output
#   --help            Show this help message
#
# Run this script from inside the target project directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAD_DEV_OS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$LEAD_DEV_OS_ROOT/app"
TARGET_DIR="$(pwd)"

# Source shared utilities
source "$SCRIPT_DIR/common-functions.sh"

# Flags
COMMANDS_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --commands-only)
      COMMANDS_ONLY=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      head -15 "$0" | tail -13 | sed 's/^# \?//'
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

print_status "Installing lead-dev-os into: $TARGET_DIR"

# --- Install Commands ---
COMMANDS_DEST="$TARGET_DIR/.claude/commands/lead-dev-os"
ensure_dir "$COMMANDS_DEST"

print_status "Installing commands..."

# Flatten strategic + tactical commands into one directory for slash-command access
for cmd_file in "$APP_DIR"/commands/strategic/*.md "$APP_DIR"/commands/tactical/*.md; do
  if [ -f "$cmd_file" ]; then
    filename="$(basename "$cmd_file")"
    cp "$cmd_file" "$COMMANDS_DEST/$filename"
    print_verbose "  Installed command: $filename"
  fi
done

print_success "Commands installed to .claude/commands/lead-dev-os/"

if [ "$COMMANDS_ONLY" = true ]; then
  print_success "Done (commands only)."
  exit 0
fi

# --- Install agents-context/ (top-level) ---
CONTEXT_DEST="$TARGET_DIR/agents-context"

print_status "Installing agents-context..."

ensure_gitkeep "$CONTEXT_DEST/concepts"
ensure_gitkeep "$CONTEXT_DEST/standards"
ensure_dir "$CONTEXT_DEST/guides"

# Copy guides (always overwrite — these are framework docs)
for guide_file in "$APP_DIR"/agents-context/guides/*.md; do
  if [ -f "$guide_file" ]; then
    copy_with_warning "$guide_file" "$CONTEXT_DEST/guides/$(basename "$guide_file")" "Guide"
  fi
done

print_success "Context installed to agents-context/"

# --- Install Templates & Specs (inside lead-dev-os/) ---
FRAMEWORK_DEST="$TARGET_DIR/lead-dev-os"

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

print_success "Framework files installed to lead-dev-os/"

# --- Install/Update CLAUDE.md ---
print_status "Updating CLAUDE.md..."

CLAUDE_MD_SRC="$APP_DIR/CLAUDE.md"
CLAUDE_MD_DEST="$TARGET_DIR/CLAUDE.md"

if [ -f "$CLAUDE_MD_SRC" ]; then
  if [ -f "$CLAUDE_MD_DEST" ]; then
    # Check if lead-dev-os section already exists
    if grep -q "## lead-dev-os Framework" "$CLAUDE_MD_DEST" 2>/dev/null; then
      print_warning "CLAUDE.md already contains lead-dev-os section — skipping."
      print_warning "To update, remove the '## lead-dev-os Framework' section and re-run."
    else
      # Append framework instructions to existing CLAUDE.md
      echo "" >> "$CLAUDE_MD_DEST"
      cat "$CLAUDE_MD_SRC" >> "$CLAUDE_MD_DEST"
      print_success "Appended lead-dev-os instructions to existing CLAUDE.md"
    fi
  else
    cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
    print_success "Created CLAUDE.md with lead-dev-os instructions"
  fi
fi

# --- Summary ---
echo ""
print_success "Installation complete!"
echo ""
print_status "Installed structure:"
print_status "  .claude/commands/lead-dev-os/  — Slash commands"
print_status "  agents-context/                — Knowledge base (concepts, standards, guides)"
print_status "  lead-dev-os/templates/         — Document templates"
print_status "  lead-dev-os/specs/             — Spec output directory"
echo ""
print_status "Get started:"
print_status "  1. Run /plan-product to define your product mission"
print_status "  2. Run /define-standards to establish coding conventions"
print_status "  3. Run /step1-shape-spec to begin speccing a feature"
