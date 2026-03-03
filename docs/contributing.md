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
│   └── step3-implement-tasks/        # Tactical: task execution
```

## Testing

Tests live in `tests/` and cover both the plugin structure and legacy install behavior.

### Run all tests

```bash
./tests/run_all.sh
```

### Test suites

| Suite | File | What it tests |
|-------|------|---------------|
| Plugin structure | `tests/test_plugin_structure.sh` | plugin.json valid, all 8 skill dirs exist, configure-project skill has bundled standards |
| Skill content | `tests/test_skill_content.sh` | No placeholders, all cross-refs namespaced, no config.yml refs, valid frontmatter |
| Content bundle | `tests/test_content_bundle.sh` | All global standards present, CLAUDE.md namespaced, README updated |
| Unit | `tests/test_common_functions.sh` | `ensure_dir`, `ensure_gitkeep`, `copy_if_not_exists`, `copy_with_warning`, `print_verbose` |
| Integration: creates | `tests/test_install_creates.sh` | Fresh install produces all expected files (legacy installer) |
| Integration: overwrites | `tests/test_install_overwrites.sh` | Re-install overwrites skills/guides, preserves concepts/standards (legacy installer) |
| Integration: help | `tests/test_install_help.sh` | --help flag behavior (legacy installer) |
| Integration: stack config | `tests/test_stack_config.sh` | Stack config, profiles, plan mode (legacy installer) |

### Conventions

- Plugin skills use flat directories (no `strategic/` or `tactical/` nesting)
- All skill cross-references use the `/lead-dev-os:` namespace
- Templates and examples are co-located with their skills
- No `config.yml` references in plugin skills — stack selection is interactive

## Support

For support, please open a [GitHub issue](https://github.com/CaptainMe-AI/lead-dev-os/issues). We welcome bug reports, feature requests, and questions about using Spec-Driven Development.

## License

MIT License
