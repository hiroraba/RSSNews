---
name: rssnews-post-change-review
description: Use for coding tasks in the RSSNews repository when you make code changes and need an independent code review pass from another model before finalizing.
---

# RSSNews Post-Change Review

After you finish implementing a code change in this repository, run an independent review pass with another model before the final response.

## Workflow

1. Complete the intended code change first.
2. Review your own diff and identify the smallest relevant file set.
3. Spawn a sub-agent with a different model for review.
4. Ask the reviewer to focus on bugs, regressions, edge cases, and missing tests.
5. Give the reviewer only the task summary, changed file paths, and any constraints needed for the review.
6. If the reviewer finds a real issue, fix it before finalizing when feasible.
7. In the final response, state whether the secondary review found anything important.

## Reviewer Prompt Shape

Use a prompt close to this:

```text
Review the recent RSSNews changes. Focus on bugs, regressions, edge cases, and missing tests. Report findings first with file references. Keep summaries brief.
```

## Notes

- Prefer a small, fast model for routine review and a stronger model when the change is risky.
- Keep the review independent. Do not preload your own conclusions unless they are necessary constraints.
- If sub-agents are unavailable, say that the secondary review could not be performed.
