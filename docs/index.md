---
layout: default
title: Home
nav_order: 1
---

![lead-dev-os banner]({{ site.baseurl }}/assets/images/banner.png)

# lead-dev-os

A spec & context-aware framework for Claude Code development on large projects. It provides structured commands for product planning, spec writing, task scoping, and context-aware implementation.

Think of it as a lead developer's main tool for guiding a team of AI agents in a project. When a Lead Developer has a team of engineers, their responsibility is to guide them in the right direction — explaining only the specific context and domain knowledge needed for the spec at hand.

---

## Key Principles

### Spec-Driven Development

- Spec is the contract, code follows
- Requirements before implementation, always
- Agents execute against testable acceptance criteria
- Eliminates ambiguity-driven rework

### Context-Aware Implementation

- **Composable** — Load only what you need for the current task
- **Self-referencing** — Concepts link to related concepts
- **Version-controlled** — Track evolution of ideas over time
- **AI-friendly** — Agents load specific concepts as context before working

### PARA for AI Agents

Organization follows the [PARA method](https://www.buildingasecondbrain.com/) adapted for agent workflows — Projects, Areas, Resources, Archives — ordered by actionability.

---

## Quick Start

```bash
# Clone lead-dev-os (one-time)
git clone https://github.com/CaptainMe-AI/lead-dev-os.git ~/lead-dev-os

# Navigate to your project
cd /path/to/your-project

# Run the installer
~/lead-dev-os/scripts/install.sh
```

See [Installation]({{ site.baseurl }}/installation) for full details and options.

---

## Workflow Overview

| Phase | Command | What it does |
|-------|---------|--------------|
| Shape | `/step1-shape-spec` | Interactive Q&A to gather requirements |
| Define | `/step2-define-spec` | Formalize into spec with numbered requirements (FR-###) |
| Scope | `/step3-scope-tasks` | Break into task groups with context directives |
| Implement | `/step4-implement-tasks` | Context-aware execution of task groups |

See [Workflow]({{ site.baseurl }}/workflow) for the full 4-step process, and [Implementation]({{ site.baseurl }}/implementation) for execution modes.
