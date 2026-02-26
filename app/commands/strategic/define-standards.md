# Define Standards

Establish coding style, conventions, architecture patterns, and quality standards for the project.

## Instructions

You are a senior engineering lead. Help the user define project standards that will guide all future development.

### Phase 1: Discovery

Read any existing files in `agents-context/standards/` to avoid duplicating or contradicting established standards.

Read `agents-context/concepts/product-mission.md` if it exists to understand the technology stack.

Ask the user the following questions:

**Coding Style:**
1. Do you follow an existing style guide? (e.g., Airbnb JS, StandardRB, PEP 8, Google style guides)
2. What are your naming conventions? (camelCase vs snake_case for variables, files, components, etc.)
3. What formatter/linter do you use or want to use?

**Architecture:**
4. What architectural pattern does the project follow? (MVC, microservices, modular monolith, etc.)
5. How do you organize files? (By feature, by type, domain-driven?)
6. What patterns do you use for error handling? (Result types, exceptions, error boundaries?)

**Testing:**
7. What testing framework do you use?
8. What is your testing philosophy? (TDD, test-after, coverage targets?)
9. What should always be tested vs. what's optional?

**Quality & Process:**
10. What does your PR/review process look like?
11. Any specific security or performance standards?

### Phase 2: Generate Standards

Based on responses, create one or more standards files in `agents-context/standards/`:

**`agents-context/standards/coding-style.md`** — Naming, formatting, file organization, language-specific conventions.

**`agents-context/standards/architecture.md`** — Architectural patterns, module boundaries, dependency rules, API design conventions.

**`agents-context/standards/testing.md`** — Testing framework, conventions, what to test, fixture/mock patterns.

Each standards file should follow this format:

```markdown
# [Standard Name]

> Established: YYYY-MM-DD

## Conventions

### [Category]
- **Rule:** [Clear, actionable rule]
- **Example:** [Brief code example or reference]
- **Rationale:** [Why this matters]

### [Category]
- **Rule:** ...
- **Example:** ...
- **Rationale:** ...
```

### Phase 3: Output

Save files to `agents-context/standards/`.

Tell the user:
- Which standards files were created
- These standards will be automatically referenced by task groups generated via `/step3-scope-tasks`
- Standards can be updated at any time by re-running `/define-standards` or editing the files directly
