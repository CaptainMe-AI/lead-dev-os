---
name: init
description: Initialize lead-dev-os framework in your project — sets up agents-context, specs directory, and CLAUDE.md.
disable-model-invocation: true
---

# Initialize lead-dev-os

Set up the lead-dev-os framework in the current project.

## Instructions

You are a project setup assistant. Initialize the lead-dev-os framework by creating the required directory structure, copying standards from this skill's bundled files, generating guides and config, and configuring the project's CLAUDE.md.

### Phase 1: Check Existing Setup

Check if any lead-dev-os artifacts already exist:
- `agents-context/` directory
- `lead-dev-os/specs/` directory
- `CLAUDE.md` with `## lead-dev-os Framework` section

If any exist, inform the user what was found and ask: **"Some lead-dev-os artifacts already exist. Should I skip existing files (preserve your changes) or overwrite them with fresh defaults?"**

### Phase 2: Ask About Technology Stack

Ask the user: **"What technology stacks does your project use? Select all that apply:"**

Present these categories:
- **Languages:** Python, Ruby, TypeScript, JavaScript
- **Backend frameworks:** FastAPI, Django, Rails, Express
- **Databases:** PostgreSQL, MySQL, MongoDB, Redis
- **Frontend frameworks:** React, Next.js, Vue
- **Infrastructure:** Nginx, Gunicorn, Uvicorn, Docker

This determines which stack-specific standard directories to create. Global standards (coding style, conventions, error handling, commenting, validation) and testing standards are always included.

### Phase 3: Create Directory Structure

Create the following directories:

```bash
mkdir -p agents-context/concepts
mkdir -p agents-context/standards
mkdir -p agents-context/guides
mkdir -p lead-dev-os/specs
```

### Phase 4: Copy Standards

Locate the skill's bundled standards using the `CLAUDE_PLUGIN_ROOT` environment variable:

```bash
echo ${CLAUDE_PLUGIN_ROOT}
```

**Always copy global standards** from `${CLAUDE_PLUGIN_ROOT}/skills/init/standards-global/` into `agents-context/standards/`:
- `coding-style.md`
- `commenting.md`
- `conventions.md`
- `error-handling.md`
- `validation.md`

**Always copy testing standards** from `${CLAUDE_PLUGIN_ROOT}/skills/init/standards-testing/` into `agents-context/standards/`:
- `test-writing.md`

**For each stack the user selected**, create an empty directory at `agents-context/standards/{stack}/` with a `.gitkeep` file. These directories are placeholders where `/lead-dev-os:define-standards` will generate stack-specific standards.

When copying, use the Read tool to read each file from the skill's standards directory, then use the Write tool to create the file in the project. **Do not overwrite existing files** unless the user chose to overwrite in Phase 1.

### Phase 5: Generate Guides, AGENTS.md, and README

Use the templates co-located with this skill to generate the project files. For each template, read the template file, fill in any placeholders, then write it to the target location.

**Templates and their destinations:**

| Template | Destination | Notes |
|----------|-------------|-------|
| [templates/workflow.md](templates/workflow.md) | `agents-context/guides/workflow.md` | Copy as-is |
| [templates/agents.md](templates/agents.md) | `agents-context/AGENTS.md` | Copy as-is |
| [templates/readme.md](templates/readme.md) | `agents-context/README.md` | Replace `{Project Name}` with the actual project name |

For the README, determine the project name from the project directory name or ask the user. Replace all occurrences of `{Project Name}` with the actual name.

For a filled-in example of what a mature README.md looks like, see [examples/readme-filled.md](examples/readme-filled.md).

### Phase 6: Update CLAUDE.md

Read the [templates/claude.md](templates/claude.md) template to get the framework instructions.

- If `CLAUDE.md` does not exist in the project root, create it with the template content.
- If `CLAUDE.md` exists but does NOT contain `## lead-dev-os Framework`, append the template content to the end of the file.
- If `CLAUDE.md` exists and already contains `## lead-dev-os Framework`, skip this step (unless the user chose to overwrite).

### Phase 7: Summary

Print a summary of what was created:

```
lead-dev-os initialized successfully!

Created:
  agents-context/
    AGENTS.md
    README.md
    concepts/
    standards/
      coding-style.md
      commenting.md
      conventions.md
      error-handling.md
      validation.md
      test-writing.md
      {stack dirs based on selection}
    guides/
      workflow.md
  lead-dev-os/specs/
  CLAUDE.md (updated)

Next steps:
  1. Run /lead-dev-os:plan-product to define your product mission
  2. Run /lead-dev-os:define-standards to establish coding standards
  3. Run /lead-dev-os:plan-roadmap to create your feature roadmap
  4. Pick a feature and run /lead-dev-os:step1-write-spec to start building!
```
