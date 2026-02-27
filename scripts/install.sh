#!/usr/bin/env bash
# lead-dev-os — Install into a target project
#
# Usage:
#   ./scripts/install.sh [OPTIONS]
#
# Options:
#   --skills-only         Only update skills, skip context/standards
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
lead-dev-os installer

Installs the lead-dev-os kit into a target project, giving you
structured skills for product planning, spec writing, task scoping,
and context-aware implementation with Claude Code.

USAGE
  cd /path/to/your-project
  /path/to/lead-dev-os/scripts/install.sh [OPTIONS]

  Run this script from inside the target project directory.

OPTIONS
  --skills-only   Only install skills; skip context, standards,
                  and CLAUDE.md updates.
  --profile <name>  Use the named config profile instead of prompting
                    interactively (e.g. --profile fullstack).
  --force           Overwrite existing files without prompting.
  --verbose         Show detailed output for every file operation.
  --help            Show this help message and exit.

WHAT GETS INSTALLED
  .claude/skills/                      Skills for Claude Code
  agents-context/concepts/             Project-specific domain knowledge
  agents-context/standards/            Coding standards (shared + stack-specific)
  agents-context/guides/               Workflow how-to guides
  lead-dev-os/specs/                   Output directory for generated specs
  CLAUDE.md                            Framework instructions (appended)

EXAMPLES
  # Full install with interactive profile selection
  ./scripts/install.sh

  # Install only skills (useful for quick updates)
  ./scripts/install.sh --skills-only

  # Non-interactive install with a specific profile
  ./scripts/install.sh --profile fullstack

  # Full install with detailed logging
  ./scripts/install.sh --verbose
HELPTEXT
}

# Flags
SKILLS_ONLY=false
PROFILE_OVERRIDE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --skills-only)
      SKILLS_ONLY=true
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

print_status "Installing lead-dev-os into: $TARGET_DIR"

# --- Install Skills ---
SKILLS_DEST="$TARGET_DIR/.claude/skills"

print_status "Installing skills..."

# Install each skill preserving directory structure
for skill_dir in "$APP_DIR"/skills/strategic/*/  "$APP_DIR"/skills/tactical/*/; do
  if [ ! -d "$skill_dir" ]; then
    continue
  fi
  # Extract category (strategic/tactical) and skill name
  local_path="${skill_dir#"$APP_DIR"/skills/}"
  local_path="${local_path%/}"  # Remove trailing slash
  dest_dir="$SKILLS_DEST/$local_path"
  ensure_dir "$dest_dir"

  # Copy all files in this skill directory (SKILL.md, template.md, etc.)
  for skill_file in "$skill_dir"*; do
    if [ -f "$skill_file" ]; then
      filename="$(basename "$skill_file")"
      dest_path="$dest_dir/$filename"
      if confirm_overwrite "$dest_path"; then
        cp "$skill_file" "$dest_path"
        print_verbose "  Installed skill file: $local_path/$filename"
      else
        print_verbose "  Skipped skill file: $local_path/$filename"
      fi
    fi
  done

  # Copy subdirectories (e.g., examples/)
  for subdir in "$skill_dir"*/; do
    if [ ! -d "$subdir" ]; then
      continue
    fi
    subdir_name="$(basename "$subdir")"
    dest_subdir="$dest_dir/$subdir_name"
    ensure_dir "$dest_subdir"
    for sub_file in "$subdir"*; do
      if [ -f "$sub_file" ]; then
        filename="$(basename "$sub_file")"
        dest_path="$dest_subdir/$filename"
        if confirm_overwrite "$dest_path"; then
          cp "$sub_file" "$dest_path"
          print_verbose "  Installed skill file: $local_path/$subdir_name/$filename"
        else
          print_verbose "  Skipped skill file: $local_path/$subdir_name/$filename"
        fi
      fi
    done
  done
done

# --- Inject Plan Mode into tactical skills ---
PM_CONFIG_FILE="$(get_config_file)"
PM_PROFILE="${PROFILE_OVERRIDE:-$(get_current_profile "$PM_CONFIG_FILE")}"

inject_plan_mode() {
  local skill_path="$1"
  local step_key="$2"
  local dest_path="$SKILLS_DEST/tactical/$skill_path/SKILL.md"
  if [ ! -f "$dest_path" ]; then
    return
  fi
  local plan_enabled
  plan_enabled="$(get_plan_mode "$PM_CONFIG_FILE" "$step_key" "$PM_PROFILE")"
  if [ "$plan_enabled" = "true" ]; then
    # Replace placeholder with plan mode instruction
    local tmpfile
    tmpfile="$(mktemp)"
    sed 's/{{\.\.\.INSERT-PLAN-MODE-HERE\.\.\.}}/## Planning\
**Use plan mode for per task group when implementing** - This will allow to further break down the task into sub-tasks and plan them out./' "$dest_path" > "$tmpfile"
    mv "$tmpfile" "$dest_path"
    print_verbose "  Plan mode injected: $skill_path"
  else
    # Remove placeholder line
    local tmpfile
    tmpfile="$(mktemp)"
    sed '/{{\.\.\.INSERT-PLAN-MODE-HERE\.\.\.}}/d' "$dest_path" > "$tmpfile"
    mv "$tmpfile" "$dest_path"
    print_verbose "  Plan mode removed: $skill_path"
  fi
}

inject_plan_mode "step1-shape-spec" "step1_shape_spec"
inject_plan_mode "step2-define-spec" "step2_define_spec"
inject_plan_mode "step3-scope-tasks" "step3_scope_tasks"
inject_plan_mode "step4-implement-tasks" "step4_implement_tasks"

print_success "Skills installed to .claude/skills/"

if [ "$SKILLS_ONLY" = true ]; then
  print_success "Done (skills only)."
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

# --- Install Specs directory (inside lead-dev-os/) ---
FRAMEWORK_DEST="$TARGET_DIR/lead-dev-os"

print_status "Installing framework files..."

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
print_status "  .claude/skills/                — Skills for Claude Code"
print_status "  agents-context/                — Knowledge base (concepts, standards, guides)"
print_status "  lead-dev-os/specs/             — Spec output directory"
echo ""
print_status "Get started:"
print_status "  1. Run /plan-product to define your product mission"
print_status "  2. Run /define-standards to establish coding conventions"
print_status "  3. Run /step1-shape-spec to begin speccing a feature"
