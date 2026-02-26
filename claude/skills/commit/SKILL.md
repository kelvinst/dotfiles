---
name: commit
description: Generate a Conventional Commit message from staged changes
---

Generate a git commit message for the staged changes.

Run `git diff --no-ext-diff --staged` to get the diff, then write a commit message following the Conventional Commit specification:

- **Subject**: short but descriptive summary, under 50 characters (max 72)
- **Body**: explain *why* the changes were made, not what was changed. Keep lines under 72 characters.
- **Format**: `type(scope): description` — common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`

Output ONLY the commit message with no extra commentary, code fences, or explanation.
