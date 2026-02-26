---
name: commit
description: Generate a Conventional Commit message from staged changes
---

Generate a git commit message for the staged changes, then open the editor for the user to review and confirm.

Here's the context provided by the user: "$ARGUMENTS". If provided, treat it as the reason/motivation behind the changes and use it to write the commit body.

1. Run `git diff --no-ext-diff --staged` to get the diff.
2. Write a commit message following the Conventional Commit specification:
   - **Subject**: short but descriptive summary, under 50 characters (max 72)
   - **Body**: explain *why* the changes were made, not what was changed. If the user supplied context, incorporate it into the body. Keep lines under 72 characters.
   - **Format**: `type(scope): description` — common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`
3. Display the generated commit message in a code block for the user to review.
4. Use `AskUserQuestion` to ask: "Commit with this message?" with options: "Commit", "Edit" (user provides revised text via the notes field), and "Cancel".
5. If confirmed, run `git commit -m "..."` using a heredoc to preserve formatting. If the user edits, incorporate their changes and commit. If cancelled, abort.
