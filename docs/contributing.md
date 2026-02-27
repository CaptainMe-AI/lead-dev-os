---
layout: default
title: Contributing
nav_order: 5
---

# Contributing

We are open to contributions. Please open an issue or a pull request on [GitHub](https://github.com/CaptainMe-AI/lead-dev-os).

## Testing

Tests live in `tests/` and cover both unit and integration behavior of the install script.

### Run all tests

```bash
./tests/test_common_functions.sh && ./tests/test_install_creates.sh && ./tests/test_install_overwrites.sh
```

### Test suites

| Suite | File | What it tests |
|-------|------|---------------|
| Unit | `tests/test_common_functions.sh` | `ensure_dir`, `ensure_gitkeep`, `copy_if_not_exists`, `copy_with_warning`, `print_verbose` |
| Integration: creates | `tests/test_install_creates.sh` | Fresh install produces all expected files, `--skills-only` flag, append to existing CLAUDE.md, install without .git |
| Integration: overwrites | `tests/test_install_overwrites.sh` | Re-install overwrites skills/guides, preserves concepts/standards/specs/CLAUDE.md, `--skills-only` only touches skills |

Each test suite creates a temporary directory, runs `install.sh` against it, asserts outcomes, and cleans up. No side effects on your working directory.

## Support

For support, please open a [GitHub issue](https://github.com/CaptainMe-AI/lead-dev-os/issues). We welcome bug reports, feature requests, and questions about using Spec-Driven Development.

## License

MIT License
