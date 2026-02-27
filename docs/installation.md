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

## Profiles configuration (prerequisite to installation)

The installer uses a YAML config to control what gets installed. The default config (`config.default.yml`) ships with a single `default` profile. To customize, copy it to `config.local.yml`:

```bash
cp ~/lead-dev-os/config.default.yml ~/lead-dev-os/config.local.yml
```

A profile has two sections:

**`stack`** — Controls which coding standards are installed. Only standards matching enabled stacks are copied to `agents-context/standards/`. Set a stack to `false` or remove it to exclude its standards.
Add or change any stack types based on your preferences.

**`plan_mode`** — Controls whether tactical skills activate Claude Code's plan mode before executing. When enabled for a step, the installed skill includes an instruction to present a plan and get user approval before proceeding. All steps default to `true`.

```yaml
version: 1.0
current_profile: default

profiles:
  default:
    stack:
      python: true
      fastapi: true
      react: true
      postgresql: true
    plan_mode:
      step1_write_spec: true
      step2_scope_tasks: true
      step3_implement_tasks: false   # skip planning for implementation
```

You can define multiple profiles and switch between them via `current_profile`:

```yaml
current_profile: backend

profiles:
  backend:
    stack:
      python: true
      fastapi: true
    plan_mode:
      step1_write_spec: true
      step2_scope_tasks: true
      step3_implement_tasks: true
  frontend:
    stack:
      react: true
      typescript: true
    plan_mode:
      step1_write_spec: false
      step2_scope_tasks: true
      step3_implement_tasks: true
```

Select a profile at install time with `--profile`:

```bash
~/lead-dev-os/scripts/install.sh --profile backend
```

If `--profile` is omitted, the installer prompts interactively.

## Installer options

```bash
# Full install (skills + context)
~/lead-dev-os/scripts/install.sh

# Update skills only (preserves your context and standards)
~/lead-dev-os/scripts/install.sh --skills-only

# Verbose output for debugging
~/lead-dev-os/scripts/install.sh --verbose
```

The installer is idempotent — safe to re-run. It will:

- Overwrite skills and guides (framework-managed files)
- Preserve your `agents-context/concepts/` and `agents-context/standards/` content
- Append to your existing `CLAUDE.md` without duplicating if the section already exists

## What gets installed

```
your-project/
│
├── .claude/
│   └── skills/                                # Skills available in Claude Code
│       ├── strategic/
│       │   ├── plan-product/                  # /plan-product
│       │   │   ├── SKILL.md
│       │   │   ├── template.md
│       │   │   └── examples/
│       │   ├── plan-roadmap/                  # /plan-roadmap
│       │   │   ├── SKILL.md
│       │   │   ├── template.md
│       │   │   └── examples/
│       │   └── define-standards/              # /define-standards
│       │       ├── SKILL.md
│       │       ├── template.md
│       │       └── examples/
│       └── tactical/
│           ├── step1-write-spec/              # /step1-write-spec
│           │   ├── SKILL.md
│           │   ├── template.md
│           │   └── examples/
│           ├── step2-scope-tasks/             # /step2-scope-tasks
│           │   ├── SKILL.md
│           │   ├── template.md
│           │   └── examples/
│           └── step3-implement-tasks/         # /step3-implement-tasks
│               └── SKILL.md
│
├── agents-context/                            # Top-level knowledge base
│   ├── concepts/                              # Project-specific domain guidance
│   ├── standards/                             # Coding style, architecture, testing conventions
│   └── guides/
│       └── workflow.md                        # Workflow overview
│
├── lead-dev-os/
│   └── specs/                                 # Generated specs live here
│
└── CLAUDE.md                                  # Updated with framework instructions
```

## Directory purposes

| Directory | Purpose | Managed by |
|-----------|---------|------------|
| **.claude/skills/** | Skills in Claude Code | Installer (overwritten on update) |
| **agents-context/concepts/** | Domain knowledge and general guidance | You + skills + implementation |
| **agents-context/standards/** | Coding standards, conventions, patterns | /define-standards skill |
| **agents-context/guides/** | Workflow documentation | Installer (overwritten on update) |
| **lead-dev-os/specs/** | Dated spec folders from the workflow | /step1-write-spec and subsequent steps |

## Updating skills

When lead-dev-os releases new skill versions, update without touching your project's context:

```bash
~/lead-dev-os/scripts/install.sh --skills-only
```
