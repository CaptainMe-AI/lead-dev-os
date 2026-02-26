---
layout: default
title: Installation
nav_order: 2
---

# Installation

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A git repository for your target project

## Install into a project

Clone this repo somewhere on your machine, then run the install script from inside your target project:

```bash
# Clone lead-dev-os (one-time)
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os

# Navigate to your project
cd /path/to/your-project

# Run the installer
~/lead-dev-os/scripts/install.sh
```

## Installer options

```bash
# Full install (commands + context + templates)
~/lead-dev-os/scripts/install.sh

# Update commands only (preserves your context and standards)
~/lead-dev-os/scripts/install.sh --commands-only

# Verbose output for debugging
~/lead-dev-os/scripts/install.sh --verbose
```

The installer is idempotent — safe to re-run. It will:

- Overwrite commands, templates, and guides (framework-managed files)
- Preserve your `agents-context/concepts/` and `agents-context/standards/` content
- Append to your existing `CLAUDE.md` without duplicating if the section already exists

## What gets installed

```
your-project/
│
├── .claude/
│   └── commands/
│       └── lead-dev-os/                    # Slash commands available in Claude Code
│           ├── plan-product.md             # /plan-product
│           ├── plan-roadmap.md             # /plan-roadmap
│           ├── define-standards.md         # /define-standards
│           ├── step1-shape-spec.md         # /step1-shape-spec
│           ├── step2-define-spec.md        # /step2-define-spec
│           ├── step3-scope-tasks.md        # /step3-scope-tasks
│           └── step4-implement-tasks.md    # /step4-implement-tasks
│
├── agents-context/                         # Top-level knowledge base
│   ├── concepts/                           # Project-specific domain guidance
│   ├── standards/                          # Coding style, architecture, testing conventions
│   └── guides/
│       └── workflow.md                     # Workflow overview
│
├── lead-dev-os/
│   ├── templates/                          # Document structure templates
│   │   ├── spec-template.md
│   │   ├── tasks-template.md
│   │   └── requirements-template.md
│   └── specs/                              # Generated specs live here
│
└── CLAUDE.md                               # Updated with framework instructions
```

## Directory purposes

| Directory | Purpose | Managed by |
|-----------|---------|------------|
| **.claude/commands/lead-dev-os/** | Slash commands in Claude Code | Installer (overwritten on update) |
| **agents-context/concepts/** | Domain knowledge and general guidance | You + commands + implementation |
| **agents-context/standards/** | Coding standards, conventions, patterns | /define-standards command |
| **agents-context/guides/** | Workflow documentation | Installer (overwritten on update) |
| **lead-dev-os/templates/** | Reusable document templates | Installer (overwritten on update) |
| **lead-dev-os/specs/** | Dated spec folders from the workflow | /step1-shape-spec and subsequent steps |

## Updating commands

When lead-dev-os releases new command versions, update without touching your project's context:

```bash
~/lead-dev-os/scripts/install.sh --commands-only
```
