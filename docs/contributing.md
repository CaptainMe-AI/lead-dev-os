---
layout: default
title: Contributing
nav_order: 5
---

# Contributing

We are open to contributions. Please open an issue or a pull request on [GitHub](https://github.com/CaptainMe-AI/lead-dev-os).

## Project Structure

lead-dev-os is distributed as a Claude Code plugin. The plugin lives at `lead-dev-os/` in the repository root:

```
lead-dev-os/                          # The plugin
├── .claude-plugin/
│   └── plugin.json                   # Plugin metadata
├── skills/                           # Flat skill directories (no nesting)
│   ├── configure-project/             # Project configuration
│   │   ├── SKILL.md
│   │   ├── templates/                # Templates for target project files
│   │   │   ├── agents.md             # → agents-context/AGENTS.md
│   │   │   ├── claude.md             # → CLAUDE.md framework section
│   │   │   ├── readme.md             # → agents-context/README.md
│   │   │   └── workflow.md           # → agents-context/guides/workflow.md
│   │   ├── examples/
│   │   │   └── readme-filled.md      # Example of a mature README.md
│   │   ├── standards-global/         # Global standards (always copied)
│   │   └── standards-testing/        # Testing standards (always copied)
│   ├── plan-product/                 # Strategic: product mission
│   ├── plan-roadmap/                 # Strategic: feature roadmap
│   ├── define-standards/             # Strategic: coding standards
│   ├── create-or-update-concepts/   # Strategic: codebase → concept files
│   ├── step1-write-spec/             # Tactical: requirements → spec
│   ├── step2-scope-tasks/            # Tactical: spec → task groups
│   ├── step3-implement-tasks/        # Tactical: task execution
│   ├── step4-archive-spec/          # Tactical: archive completed spec
│   └── create-pr/                   # Utility: open a GitHub PR for current branch
```

## Testing

Tests live in `tests/`. Each suite is a standalone bash script; run them individually:

```bash
bash tests/test_plugin_structure.sh
bash tests/test_skill_content.sh
bash tests/test_content_bundle.sh
bash tests/test_update_settings.sh
bash tests/test_setup_script.sh
```

CI (`.github/workflows/actions.yml`) runs all suites on every push.

### Test suites

| Suite | File | What it tests |
|-------|------|---------------|
| Plugin structure | `tests/test_plugin_structure.sh` | plugin.json valid, all 9 skill dirs exist, flat layout, executable scripts |
| Skill content | `tests/test_skill_content.sh` | No placeholders, cross-refs namespaced, valid frontmatter, planning content placement, orchestrated execution and full-suite gate present |
| Content bundle | `tests/test_content_bundle.sh` | All global standards present, CLAUDE.md namespaced, README updated |
| Update settings | `tests/test_update_settings.sh` | update-settings.sh writes the archive deny rule under `permissions.deny`, migrates the legacy top-level rule, idempotent |
| Setup script | `tests/test_setup_script.sh` | configure-project's setup.sh scaffolds directories, copies standards, renders templates, handles `--stacks`/`--overwrite` |

### Conventions

- Plugin skills use flat directories (no `strategic/` or `tactical/` nesting)
- All skill cross-references use the `/lead-dev-os:` namespace
- Templates and examples are co-located with their skills
- No `config.yml` references in plugin skills — stack selection is interactive

## Support

For support, please open a [GitHub issue](https://github.com/CaptainMe-AI/lead-dev-os/issues). We welcome bug reports, feature requests, and questions about using Spec-Driven Development.

## License

MIT License
