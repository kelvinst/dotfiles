---
name: plan
description: Manage a GH task plan — `init <url>`, `next`, `add <desc>`
---

## PLAN.md format

```
# Plan: <issue title>

**Issue:** <url>

## Summary
<brief description of what the issue is about>

## Approach
<overall implementation strategy>

## Steps

- [ ] [Step 1: <title>](#step-1-title)
- [ ] [Step 2: <title>](#step-2-title)
- ...

---

## Step 1: <title>

<detailed description of what to implement and how>

---

## Step 2: <title>

<detailed description of what to implement and how>
```

Each step is an atomic commit — the smallest change that passes the project
checks (tests, linters, type checks) configured in CLAUDE.md/AGENTS.md.

Completed steps have `- [x]` in the TOC checklist.

---

## Commands

Based on `$ARGUMENTS`, run one of the following:

### `init <gh-url>`

Plan the GH issue at `<gh-url>`. Fetch the issue details, then create PLAN.md
following the format above. Include the link, a summary of the issue, the
overall approach, a TOC checklist with anchor links, and a detailed section
for each step describing what to implement and how.

### `next`

Read PLAN.md and implement the next unchecked step. Run the project checks
configured in CLAUDE.md/AGENTS.md and fix any failures. Once they pass, mark
the step as done (`- [x]`) in the PLAN.md TOC and wait for 
review before committing.

### `add <description>`

Read PLAN.md to understand the existing step format and numbering. Insert a
new step following the same format at the position requested in the
`<description>` (if no position is given, assume it should be appended at the
end). The step should be atomic and clearly describe what will be committed.
Use `<description>` as the basis for the step content.
