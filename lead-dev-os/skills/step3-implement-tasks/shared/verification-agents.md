# Verification pair: implementation-reviewer + test-verifier

Run this procedure when a task group's implementation is complete and its tests pass, before the group is committed. Both agents are **read-only** — they never modify files. The executor must not grade its own homework; these agents start fresh and judge only what's on disk.

## Dispatch

Dispatch both agents **in parallel, in a single tool-call batch**. Prefer a read-only agent type (`Explore`) when available; fall back to `general-purpose` (the prompts forbid writes either way). Because other groups may be executing concurrently in the same wave, both prompts scope their review to **Group N's file list** (the plan's "File operations" section) — never to the whole working tree.

### implementation-reviewer prompt

```
You are the implementation-reviewer for Task Group <N> of
<spec-path>/tasks.md — implemented but not yet committed. You are
READ-ONLY: never modify, create, or delete any file.

Read first:
- <spec-path>/plans/group-<N>.md — the working plan (if present)
- <spec-path>/tasks.md — Group N's section (subtasks + acceptance criteria)
- <spec-path>/spec.md — the requirements this group serves
- agents-context/README.md, then the standard/concept files Group N's
  "Read before starting" header names
- The group's uncommitted changes, scoped to its files:
  git diff HEAD -- <group-N file list>   (plus git status for new files)

Review the implementation against the plan, the spec, and the loaded
standards:
- Acceptance criteria — does the diff actually satisfy Group N's criteria?
- Completeness — is every entry in the plan's "File operations" accounted for?
- Scope — any changes beyond Group N's scope?
- Conventions — violations of the loaded standards or the patterns the plan
  named as exemplars?
- Quality — dead code, leftover debug output, TODO stubs presented as done,
  swallowed errors?
- Context updates — were the "Update after completing" concept files
  actually updated and agents-context/README.md kept in sync? (If this
  group ran in a parallel wave, the updates are proposed in
  <spec-path>/plans/group-<N>-updates.md instead — check that file.)

Do not report style nitpicks that no loaded standards file backs.

Final report (structured):
- Verdict: APPROVE or REQUEST_CHANGES
- Blocking findings — file:line, what's wrong, and which criterion,
  spec requirement, or standard it violates
- Advisory findings — worthwhile improvements that should not block commit
```

### test-verifier prompt

```
You are the test-verifier for Task Group <N> of <spec-path>/tasks.md.
You are READ-ONLY: never modify, create, or delete any file (running the
test command is allowed).

Read first:
- <spec-path>/tasks.md — Group N's section, especially its test subtasks
- <spec-path>/spec.md — requirements and edge cases the tests should cover
- <spec-path>/plans/group-<N>.md — the "Test approach" section (if present)
- The project's test-writing standard via agents-context/README.md
- Group N's test files, and the implementation files they exercise

Verify the tests are real:
- Meaningful assertions — each test would fail if the behavior it names
  broke. Flag tautologies, assertions on mocks of the code under test,
  and tests that can't fail.
- Coverage vs. intent — the critical behaviors and the edge cases the
  spec calls out for this group (empty states, error paths, boundaries)
  are covered within the group's 2-8 test budget. Name each uncovered
  scenario concretely.
- No weakening — nothing skipped, deleted, or loosened relative to the
  plan's test approach.
- Bloat — flag exhaustive-coverage creep beyond the budget too; this
  workflow wants few, sharp tests.
- Execute the group's verification command from the plan and confirm the
  pass/fail counts match what the tests claim.

Final report (structured):
- Verdict: APPROVE or REQUEST_CHANGES
- Blocking findings — missing critical/edge coverage (with the exact
  scenario), tautological or non-failing tests, weakened assertions
- Advisory findings — improvements that should not block commit
- Test run output summary (command, counts)
```

## Acting on the verdicts

- **Both APPROVE** (advisory findings only): proceed. Include advisory findings in the group report — they are recorded, never silently dropped.
- **Any REQUEST_CHANGES:**
  - **Orchestrated execution** — run the bounded fix cycle below.
  - **Direct execution** — no automatic fix cycle: carry all findings into the review gate and let the user decide what gets addressed.

## Bounded fix cycle (orchestrated execution)

1. Dispatch a fresh executor subagent scoped to the findings: give it the standard executor context reads plus the verbatim blocking findings, with the instruction "Address these blocking findings only — no other changes. Do not commit."
2. Re-run the group's verification command yourself.
3. Re-dispatch **only the verifier(s) that requested changes**, noting what was fixed.
4. **Limit: 2 rounds.** If blocking findings remain after two rounds, stop and surface them to the user per the error-handling rules — do not commit, do not loop.

A finding the fix cycle judges to be wrong (the verifier misread the spec) may be overridden — but say so explicitly in the group report with the reasoning, never silently.
