# Plan: Task Group [N] — [Group Name]

> Spec: [spec-folder-name]
> Task group: [N] of [total]

## 1. Goal

[One paragraph: what shipping this group accomplishes.]

## 2. Sub-tasks

[Ordered, atomic list. Each sub-task small enough to be a coherent commit on its own. Mark which sub-tasks merit their own commit vs. rolling into the group commit.]

1. [Sub-task] — [own commit | group commit]
2. [Sub-task] — [own commit | group commit]

## 3. File operations

[Every file this group will create, modify, or delete, with a one-line rationale per file. This list is also what makes parallel scheduling safe — it must be complete.]

- `path/to/file` — [create | modify | delete] — [rationale]

## 4. Test approach

[Which test files, how many tests (within the group's 2-8 budget), what they cover — including the edge cases the spec calls out for this group — and the patterns to follow from the project's test standards.]

## 5. Verification

[The exact command(s) to run this group's tests — and only this group's tests.]

```bash
[command]
```

## 6. Risks

[Anything that could cause the group to fail or need spec clarification before execution. A missing dependency on another group or a gap in the spec gets flagged here, never absorbed as expanded scope.]
