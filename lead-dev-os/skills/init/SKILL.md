---
name: init
description: Initialize lead-dev-os framework in your project — sets up agents-context, specs directory, and CLAUDE.md.
disable-model-invocation: true
---

# Initialize lead-dev-os

Set up the lead-dev-os framework in the current project.

## Instructions

You are a project setup assistant. Initialize the lead-dev-os framework by creating the required directory structure, copying standards and guides from the plugin's bundled content, and configuring the project's CLAUDE.md.

### Phase 1: Check Existing Setup

Check if any lead-dev-os artifacts already exist:
- `agents-context/` directory
- `specs/` directory
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
mkdir -p specs
```

### Phase 4: Copy Standards

Locate the plugin's bundled content using the `CLAUDE_PLUGIN_ROOT` environment variable:

```bash
echo ${CLAUDE_PLUGIN_ROOT}
```

The bundled content is at `${CLAUDE_PLUGIN_ROOT}/content/`.

**Always copy global standards** from `${CLAUDE_PLUGIN_ROOT}/content/agents-context/standards/global/` into `agents-context/standards/`:
- `coding-style.md`
- `commenting.md`
- `conventions.md`
- `error-handling.md`
- `validation.md`

**Always copy testing standards** from `${CLAUDE_PLUGIN_ROOT}/content/agents-context/standards/testing/` into `agents-context/standards/`:
- `test-writing.md`

**For each stack the user selected**, create an empty directory at `agents-context/standards/{stack}/` with a `.gitkeep` file. These directories are placeholders where `/lead-dev-os:define-standards` will generate stack-specific standards.

When copying, use the Read tool to read each file from the plugin content directory, then use the Write tool to create the file in the project. **Do not overwrite existing files** unless the user chose to overwrite in Phase 1.

### Phase 5: Copy Guides and README

Copy from the plugin's bundled content:

1. Read `${CLAUDE_PLUGIN_ROOT}/content/agents-context/guides/workflow.md` → Write to `agents-context/guides/workflow.md`
2. Read `${CLAUDE_PLUGIN_ROOT}/content/agents-context/README.md` → Write to `agents-context/README.md`

### Phase 6: Update CLAUDE.md

Read `${CLAUDE_PLUGIN_ROOT}/content/CLAUDE.md` to get the framework instructions template.

- If `CLAUDE.md` does not exist in the project root, create it with the framework instructions.
- If `CLAUDE.md` exists but does NOT contain `## lead-dev-os Framework`, append the framework instructions to the end of the file.
- If `CLAUDE.md` exists and already contains `## lead-dev-os Framework`, skip this step (unless the user chose to overwrite).

### Phase 7: Summary

Print a summary of what was created:

```
lead-dev-os initialized successfully!

Created:
  agents-context/
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
  specs/
  CLAUDE.md (updated)

Next steps:
  1. Run /lead-dev-os:plan-product to define your product mission
  2. Run /lead-dev-os:define-standards to establish coding standards
  3. Run /lead-dev-os:plan-roadmap to create your feature roadmap
  4. Pick a feature and run /lead-dev-os:step1-write-spec to start building!
```
