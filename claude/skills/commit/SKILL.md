---
name: commit
description: Generate a Conventional Commit message from staged changes
---

Generate a git commit message for the staged changes, then open the editor for the user to review and confirm.

Here's the context provided by the user: "$ARGUMENTS". If provided, treat it as the reason/motivation behind the changes and use it to write the commit body.

1. Run `git hook run pre-commit --ignore-missing` to ensure the commit will pass. If the hook fails, display the error message and abort the commit process. If it succeeds, proceed to the next step.
2. Run `git diff --no-ext-diff --staged` to get the diff.
3. Write a commit message following the Conventional Commit specification:
   - **Subject**: short but descriptive summary, under 50 characters (max 72)
   - **Body**: explain *why* the changes were made, not what was changed. If the user supplied context, incorporate it into the body. Keep lines under 72 characters.
   - **Format**: `type(scope): description` — common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`
6. Run `git commit -m "..."` using a heredoc to preserve formatting.
