---
name: init-plan
description: Plan a GH task into atomic commits saved to PLAN.md
---

Plan the GH issue $ARGUMENTS, detailing the step-by-step and saving it to PLAN.md. 

At the beginning of the plan, include the link, a summary of the issue, the overall approach, and the table of contents as a checklist with links for all steps subtitles.

Then later, define a subtitle for each step, describing the step in detail, and how to implement it.

Each step will be a separate atomic commit, which should be the smallest commit possible and pass the project checks configured in CLAUDE.md, like tests, linters, and type checks. 

