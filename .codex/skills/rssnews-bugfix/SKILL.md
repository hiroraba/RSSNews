---
name: rssnews-bugfix
description: Use for bug-fix tasks in the RSSNews repository when the goal is to repair incorrect behavior with minimal scope and verify regressions carefully.
---

# RSSNews Bugfix

Use this skill when the task is fixing broken behavior, a regression, or an incorrect edge case in RSSNews.

## Priorities

1. Reproduce or at least localize the failure before editing code.
2. Prefer the smallest behavior-preserving fix.
3. Avoid mixing new features, renames, or broad refactors into the same change.
4. Check whether the bug should be covered by an existing or new test.
5. Run the mandatory post-change review with another model before finalizing.

## Implementation Guidance

- Trace the failure to one layer first: `View`, `ViewModel`, `Service`, `Repository`, or `Model`.
- Keep responsibilities separated. Do not fix a parsing issue by adding UI-state workarounds, and do not fix view behavior by moving parsing into a view model.
- If the bug crosses layers, still patch only the minimum set of files needed for a correct fix.
- If the change also improves diagnostics or comments, keep that secondary and tightly scoped to the bug.

## Validation

- Confirm the original symptom is removed.
- Check nearby regressions, especially persistence, refresh timing, selection state, and read/favorite state.
- State clearly whether tests were added, updated, or intentionally not changed.

## Commit Shape

- Keep bug fixes in their own commit when feasible.
- Do not bundle README edits unless the user explicitly requested them.
