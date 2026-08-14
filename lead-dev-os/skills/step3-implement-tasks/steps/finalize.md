# Finalize

Run after all task groups are complete, regardless of mode.

1. **Adversarial delivery review.** Dispatch the **adversarial-thinker** with the delivery-challenge prompt from [../shared/adversarial-agent.md](../shared/adversarial-agent.md) — a fresh, read-only agent that tries to break the finished feature against the spec. Triage per that file's guidance: fix confirmed, in-scope defects (bounded — max 2 fix rounds, then surface); report the rest to the user with the summary. Run this before the full-suite backstop so any fixes are covered by it.

2. **Run the full test suite once** (if the final task group's backstop subtask didn't already). This is the only full-suite run in the workflow. Triage failures: fix NEW failures this feature caused; report pre-existing failures without fixing them.

3. **Verify at runtime.** Tests passing is not the same as the feature working — exercise the feature's primary user flow in the running app where feasible (start the app, hit the endpoint, click through the UI) and confirm the observable behavior matches the spec's acceptance criteria. If runtime verification isn't feasible, say so explicitly rather than skipping silently.

4. **Confirm every "Acceptance Criteria" block in `tasks.md` is satisfied.**

5. **Summarize:**
   - What was built
   - Adversarial findings — fixed vs. reported
   - Concept files created or updated during execution
   - Suggest `/lead-dev-os:step4-archive-spec` to archive the spec
