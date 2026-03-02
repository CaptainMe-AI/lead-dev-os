---
name: init
description: Initialize lead-dev-os framework in your project — sets up agents-context, specs directory, and CLAUDE.md.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write
---

# Initialize lead-dev-os

Set up the lead-dev-os framework in the current project.

## Instructions

You are a project setup assistant. Initialize the lead-dev-os framework by running the bundled setup script, then configuring the project's CLAUDE.md.

### Phase 1: Check Existing Setup

Check if any lead-dev-os artifacts already exist:
- `agents-context/` directory
- `lead-dev-os/specs/` directory
- `CLAUDE.md` with `## lead-dev-os Framework` section

If any exist, inform the user what was found and ask: **"Some lead-dev-os artifacts already exist. Should I skip existing files (preserve your changes) or overwrite them with fresh defaults?"**

Remember their choice — you will pass it to the setup script.

### Phase 2: Ask About Technology Stack

Ask the user: **"What technology stacks does your project use? Select all that apply:"**

Present these categories:
- **Languages:** Python, Ruby, TypeScript, JavaScript
- **Backend frameworks:** FastAPI, Django, Rails, Express
- **Databases:** PostgreSQL, MySQL, MongoDB, Redis
- **Frontend frameworks:** React, Next.js, Vue
- **Infrastructure:** Nginx, Gunicorn, Uvicorn, Docker

This determines which stack-specific standard directories to create. Global standards (coding style, conventions, error handling, commenting, validation) and testing standards are always included.

### Phase 3: Run Setup Script

Resolve the plugin root path:

```bash
echo ${CLAUDE_PLUGIN_ROOT}
```

Determine the project name from the current directory name or ask the user.

Run the setup script with the collected arguments:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/init/scripts/setup.sh \
  --project "<project-name>" \
  --stacks "<comma-separated-stacks>" \
  --plugin-root "${CLAUDE_PLUGIN_ROOT}" \
  [--overwrite]
```

Add `--overwrite` only if the user chose to overwrite in Phase 1. If the user selected no stacks, pass `--stacks ""`.

Save the script output — you will parse it in Phase 5.

### Phase 4: Update CLAUDE.md

Read the [templates/claude.md](templates/claude.md) template to get the framework instructions.

- If `CLAUDE.md` does not exist in the project root, create it with the template content.
- If `CLAUDE.md` exists but does NOT contain `## lead-dev-os Framework`, append the template content to the end of the file.
- If `CLAUDE.md` exists and already contains `## lead-dev-os Framework`, skip this step (unless the user chose to overwrite).

### Phase 5: Summary

Parse the setup script output (delimited by `===SECTION===` markers) and present a grouped summary. Only show sections that have entries.

Format the output exactly like this:

```
📁 Directories created (N)
   dir1/
   dir2/

📄 Standards copied (N)
   file1.md
   file2.md

📝 Templates generated (N)
   path/to/file1.md
   path/to/file2.md

📦 Stack directories created (N)
   agents-context/standards/stack1/
   agents-context/standards/stack2/

⏭️  Skipped (N)
   file.md (already exists)

📋 CLAUDE.md — <created | updated | skipped (already configured)>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ lead-dev-os initialized successfully!

👉 Next step: Run /lead-dev-os:create-or-update-concepts to scan your
   codebase and populate concept files.
```

For the CLAUDE.md line, report what actually happened in Phase 4 (created, updated, or skipped).

Omit any section with zero entries (e.g., don't show "Skipped" if nothing was skipped, don't show "Stack directories" if no stacks were selected).
