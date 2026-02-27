---
name: init-plan
description: Plan a GH task into atomic commits saved to PLAN.md
---

Plan the GH issue $ARGUMENTS, detailing the step-by-step and saving it to PLAN.md. Each step will be a separate atomic commit, which should be the smallest commit possible and pass the project checks configured in CLAUDE.md, like tests, linters, and type checks. The steps should be clear and concise.
