---
name: rssnews-feature
description: Use for feature work in the RSSNews repository when adding or extending behavior while preserving the existing architecture and keeping scope controlled.
---

# RSSNews Feature

Use this skill when the task is adding a user-facing capability or extending existing behavior in RSSNews.

## Priorities

1. Define the smallest user-visible outcome that satisfies the request.
2. Fit the change into the existing `Models / Services / ViewModels / Views / Repositories` split.
3. Avoid speculative abstractions and broad cleanup while implementing the feature.
4. Check whether documentation was requested before touching README files.
5. Run the mandatory post-change review with another model before finalizing.

## Implementation Guidance

- Put UI state and interaction flow in `ViewModels`.
- Put fetch, parse, classify, and side-effectful business logic in `Services`.
- Route persistence changes through existing `Repositories`.
- Add model fields only when the feature truly needs persisted state.
- Prefer incremental UI additions over redesigning existing screens.

## Validation

- Verify the feature works from the user entry point through persistence and reload.
- Check adjacent flows that may be affected, especially feed refresh, article filtering, selection state, settings, and local persistence.
- State clearly whether tests were added, updated, or intentionally not changed.

## Commit Shape

- Separate feature commits from bug-fix commits when feasible.
- Keep unrelated cleanup out of the feature commit.
- Do not bundle README edits unless the user explicitly requested them.
