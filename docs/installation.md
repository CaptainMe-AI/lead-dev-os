---
layout: default
title: Installation
nav_order: 2
---

# Installation

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A git repository for your target project

## Install from the plugin marketplace (recommended)

`lead-dev-os` is distributed via the `captainme-ai` plugin marketplace. Inside Claude Code, run:

```
/plugin marketplace add CaptainMe-AI/lead-dev-os
/plugin install lead-dev-os@captainme-ai
```

The plugin then stays available across all your Claude Code sessions. To pick up new releases later, run `/plugin marketplace update captainme-ai`.

## Install for development

To work on the plugin itself (or try unreleased changes), clone this repo and start Claude Code with the plugin loaded from disk:

```bash
# Clone lead-dev-os (one-time)
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os

# Start Claude Code with the plugin
claude --plugin-dir ~/lead-dev-os/lead-dev-os
```

## Initialize your project

Navigate to your project and run the configure-project skill:

```bash
cd /path/to/your-project
/lead-dev-os:configure-project
```

The configure-project skill will:

1. Check for existing lead-dev-os artifacts
2. Ask about your technology stacks (languages, frameworks, databases, infrastructure)
3. Create the `agents-context/` directory structure with standards, guides, AGENTS.md, and README.md
4. Create the `lead-dev-os/specs/` directory
5. Update your `CLAUDE.md` with framework instructions

The configure-project skill uses bundled templates (for AGENTS.md, README.md, workflow guide, CLAUDE.md) and copies global and testing standards from the plugin into your project.

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

### Setup

| Skill | Purpose |
|-------|---------|
| `/lead-dev-os:configure-project` | Configure framework in your project |

### Strategic (run once to set up your project)

| Skill | Purpose |
|-------|---------|
| `/lead-dev-os:plan-product` | Define product mission, vision, tech stack |
| `/lead-dev-os:plan-roadmap` | Create phased feature roadmap |
| `/lead-dev-os:define-standards` | Establish coding and architecture standards |
| `/lead-dev-os:create-or-update-concepts` | Scan codebase to create/update concept files |

### Tactical (run per feature)

| Skill | Purpose |
|-------|---------|
| `/lead-dev-os:step1-write-spec` | Interactive Q&A + formalize into spec |
| `/lead-dev-os:step2-scope-tasks` | Break spec into context-aware task groups |
| `/lead-dev-os:step3-implement-tasks` | Context-aware implementation of task groups |
| `/lead-dev-os:step4-archive-spec` | Archive completed spec and block agent access |

### Utility (run anytime)

| Skill | Purpose |
|-------|---------|
| `/lead-dev-os:create-pr` | Open a GitHub PR for the current branch with a WHAT-focused description and emoji-prefixed title |

## Directory purposes

| Directory | Purpose | Managed by |
|-----------|---------|------------|
| **agents-context/concepts/** | Domain knowledge and general guidance | You + skills + implementation |
| **agents-context/standards/** | Coding standards, conventions, patterns | `/lead-dev-os:define-standards` skill |
| **agents-context/guides/** | Workflow documentation | `/lead-dev-os:configure-project` skill |
| **lead-dev-os/specs/** | Dated spec folders from the workflow | `/lead-dev-os:step1-write-spec` and subsequent steps |

## Updating

If you installed from the marketplace, refresh the catalog and Claude Code picks up the new release:

```
/plugin marketplace update captainme-ai
```

If you installed for development with `--plugin-dir`, pull the latest and restart Claude Code with the plugin:

```bash
cd ~/lead-dev-os
git pull
claude --plugin-dir ~/lead-dev-os/lead-dev-os
```

Skills are loaded from the plugin directory — no need to re-run init.

