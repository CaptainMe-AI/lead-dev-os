# Finalize

Run after all task groups are complete, regardless of mode.

1. **Confirm every group is committed.** Run `git status --porcelain` and `git log --oneline` over the run. Every completed task group must have its own commit, and the tree must be clean apart from any run baseline the user chose to carry. If a group's work is still sitting in the working tree, commit it now — one commit per group, per the commit procedure in [execute-orchestrated.md](execute-orchestrated.md#commit-procedure) — before running anything below. Do not summarize a run as delivered while its work is uncommitted.

2. **Adversarial delivery review.** Dispatch the **adversarial-thinker** with the delivery-challenge prompt from [../shared/adversarial-agent.md](../shared/adversarial-agent.md) — a fresh, read-only agent that tries to break the finished feature against the spec. Triage per that file's guidance: fix confirmed, in-scope defects (bounded — max 2 fix rounds, then surface); report the rest to the user with the summary. Run this before the full-suite backstop so any fixes are covered by it.

3. **Run the full test suite once** (if the final task group's backstop subtask didn't already). This is the only full-suite run in the workflow. Triage failures: fix NEW failures this feature caused; report pre-existing failures without fixing them.

4. **Verify at runtime.** Tests passing is not the same as the feature working — exercise the feature's primary user flow in the running app where feasible (start the app, hit the endpoint, click through the UI) and confirm the observable behavior matches the spec's acceptance criteria. If runtime verification isn't feasible, say so explicitly rather than skipping silently.

5. **Confirm every "Acceptance Criteria" block in `tasks.md` is satisfied.**

6. **Summarize:**
   - What was built
   - Adversarial findings — fixed vs. reported
   - Concept files created or updated during execution
   - Suggest `/lead-dev-os:step4-archive-spec` to archive the spec
