# Direct execution

*Applies to mode L, and mode H at/after the checkpoint.*

The main conversation executes each group itself so the user can watch and steer. For each incomplete task group, in dependency order, run this sub-cycle:

## a. Load group context

1. **Read every file listed in the group's `Read before starting:` header.** These supply project-specific guidance — concept files and standards. Don't skip.
2. **Read every file the group will modify or extend** (named in the plan's "File operations" section, or in the group's `Modifies:` header if present). Understand the starting state before changing it.
3. **Verify dependencies.** If this group depends on earlier groups, confirm those groups' tasks are checked off and their tests pass.

## b. Plan

- **H mode (at/after the checkpoint):** read `plans/group-<N>.md`. Treat it as the working plan. The user approved the batch, but they may also have edited the file — read it fresh. If earlier groups changed the code in ways the plan didn't anticipate, update the plan file to match reality before executing, and tell the user what drifted.
- **L mode:** enter Claude Code's native plan mode and produce a plan following [../template.md](../template.md) (Goal, Sub-tasks, File operations, Test approach, Verification, Risks). In the plan header, include this identifier so the agent stays aware of its workflow context after `ExitPlanMode` clears the conversation: "Running as part of `/lead-dev-os:step3-implement-tasks` for `<spec-path>/tasks.md`, task group N. Final step: return to tasks.md and check off completed tasks." Wait for the user to approve via `ExitPlanMode` before continuing.

## c. Execute

Work through each task in the group sequentially:

1. **Tests first.** Write tests before implementation. Tests should cover the specific behavior described in the task, follow the project's test patterns, and be runnable and failing before you write the code that satisfies them.
2. **Implementation.** Write code to make the tests pass. Follow the conventions from the concept and standard files loaded above. Reuse patterns identified in the spec. Stay within the task's scope — no scope creep.
3. **Verify.** Run only this group's tests, using the verification command in the plan. Do not run the entire test suite at this stage — slow feedback loops cost more than they save here.
4. **Mark tasks complete** by checking them off in `tasks.md` as soon as each task is done, not in a batch at the end.

## d. Self-fix on test failure

If a test fails:

1. Inspect the failure. Determine whether the issue is in the test, the implementation, or an assumption about the surrounding code.
2. Fix the most likely cause and re-run the group's tests.
3. **Retry limit: 2 attempts.** After two unsuccessful fixes, stop and report:
   - The failing test name and message
   - What you tried in each retry
   - Your hypothesis on the root cause
   - Whether the blocker likely sits in the spec, the existing code, or the new code

Do not loop indefinitely, and do not "fix" by deleting tests, weakening assertions, or skipping behavior.

## e. Verification pair

Once the group's tests pass, dispatch the implementation-reviewer and test-verifier in parallel per [../shared/verification-agents.md](../shared/verification-agents.md). In direct execution the orchestrator does NOT auto-run a fix cycle — collect the verdicts and findings and carry them into the review gate below, where the user decides what gets fixed. Fix what the user asks for in the main conversation, then re-run the group's tests.

## f. Update context

1. **Read `agents-context/README.md`** to see what concepts already exist.
2. **Create or update concept files** when the group's `Update after completing:` header calls for it, OR when implementation revealed a pattern future features will need to understand.
3. **Concept files capture general guidance, not code.** Describe approach, conventions, decision rationale, and file paths — not code snippets, not file-by-file documentation.
4. **Keep `agents-context/README.md` in sync.** When you create or update a concept file, add or update its entry under Core/Domain Concepts, refresh the "For AI Agents" task-to-concept mapping, and update cross-references in related concept entries. The README is the entry point — if it's stale, future agents won't find the concept.

## g. Commit

Atomic-commit policy:

- **Default: one commit per task group.** The commit message describes what the group shipped (not how) and references the spec folder name.
- **Optional sub-commits:** if a group has natural sub-units (e.g. a "primitives" sub-task that lands cleanly on its own, then "integration" on top), commit each sub-unit separately. Use judgment — if you can't summarize a sub-commit in one clean line, it isn't ready as its own commit.
- **Don't sweep up unrelated changes.** If the user has uncommitted edits in files outside this group's scope, ask before staging anything.

In **L** mode you may skip the auto-commit and let the user commit manually after the review gate.

## h. Review gate

1. Report:
   - Group N complete
   - Tests written / passing
   - Verification verdicts (reviewer, test-verifier) with their findings — blocking first, then advisory
   - Concept files created or updated
   - Diff overview
2. Stop and present the review gate:
   > **Review gate — Task Group N complete.**
   > Changes ready for review. Verification findings above.
   > - 🔍 Review the diff in your git GUI (GitLens, GitHub Desktop, `lazygit`, `git diff`)
   > - ✏️ Request changes — tell me what to modify (including any verification findings you want addressed)
   > - ✅ Say "commit" and I'll create a descriptive commit, or commit yourself
   > - ➡️ Say "continue" to proceed to the next group
3. Wait for explicit instruction. Do not advance until the user says to continue.
