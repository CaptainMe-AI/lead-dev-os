---
layout: default
title: Installation
nav_order: 2
---

# Installation

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A git repository for your target project

## Install as a Claude Code Plugin

Clone this repo somewhere on your machine, then start Claude Code with the plugin:

```bash
# Clone lead-dev-os (one-time)
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os

# Start Claude Code with the plugin
claude --plugin-dir ~/lead-dev-os/lead-dev-os
```

## Initialize your project

Navigate to your project and run the init skill:

```bash
cd /path/to/your-project
/lead-dev-os:init
```

The init skill will:

1. Check for existing lead-dev-os artifacts
2. Ask about your technology stacks (languages, frameworks, databases, infrastructure)
3. Create the `agents-context/` directory structure with standards, guides, AGENTS.md, and README.md
4. Create the `lead-dev-os/specs/` directory
5. Update your `CLAUDE.md` with framework instructions

The init skill uses bundled templates (for AGENTS.md, README.md, workflow guide, CLAUDE.md) and copies global and testing standards from the plugin into your project.

## What gets created

```
your-project/
│
├── agents-context/                            # Top-level knowledge base
│   ├── AGENTS.md                              # Context documentation index (points to README.md)
│   ├── README.md                              # Full index of concepts, standards, and usage
│   ├── concepts/                              # Project-specific domain guidance
│   ├── standards/                             # Coding style, architecture, testing conventions
│   │   ├── coding-style.md                    # Global standard (always included)
│   │   ├── commenting.md                      # Global standard (always included)
│   │   ├── conventions.md                     # Global standard (always included)
│   │   ├── error-handling.md                  # Global standard (always included)
│   │   ├── validation.md                      # Global standard (always included)
│   │   ├── test-writing.md                    # Testing standard (always included)
│   │   └── {stack}/                           # Stack-specific dirs (based on selection)
│   └── guides/
│       └── workflow.md                        # Workflow overview
│
├── lead-dev-os/
│   └── specs/                                 # Generated specs live here
│
└── CLAUDE.md                                  # Updated with framework instructions
```

## Available skills

All skills are accessed via the `/lead-dev-os:` namespace:

| Skill | Purpose |
|-------|---------|
| `/lead-dev-os:init` | Initialize framework in your project |
| `/lead-dev-os:plan-product` | Define product mission, vision, tech stack |
| `/lead-dev-os:plan-roadmap` | Create phased feature roadmap |
| `/lead-dev-os:define-standards` | Establish coding and architecture standards |
| `/lead-dev-os:step1-write-spec` | Interactive Q&A + formalize into spec |
| `/lead-dev-os:step2-scope-tasks` | Break spec into context-aware task groups |
| `/lead-dev-os:step3-implement-tasks` | Context-aware implementation of task groups |

## Directory purposes

| Directory | Purpose | Managed by |
|-----------|---------|------------|
| **agents-context/concepts/** | Domain knowledge and general guidance | You + skills + implementation |
| **agents-context/standards/** | Coding standards, conventions, patterns | `/lead-dev-os:define-standards` skill |
| **agents-context/guides/** | Workflow documentation | `/lead-dev-os:init` skill |
| **lead-dev-os/specs/** | Dated spec folders from the workflow | `/lead-dev-os:step1-write-spec` and subsequent steps |

## Updating

When lead-dev-os releases updates, pull the latest and restart Claude Code with the plugin:

```bash
cd ~/lead-dev-os
git pull
claude --plugin-dir ~/lead-dev-os/lead-dev-os
```

Skills are loaded from the plugin directory — no need to re-run init.

