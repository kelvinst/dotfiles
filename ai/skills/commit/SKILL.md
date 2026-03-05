---
name: commit
description: Generate a Conventional Commit message from staged changes
---

Generate a git commit message for the staged changes, then open the editor for the user to review and confirm.

Here's the context provided by the user: "$ARGUMENTS". If provided, treat it as the reason/motivation behind the changes and use it to write the commit body.

1. Run `git status` to check for unstaged changes or untracked files.
   - If there are **no** unstaged/untracked files, skip to step 2.
   - If there **are** unstaged changes or untracked files, check `git diff --no-ext-diff`, give the user an overview of the changes and ask the user what to do. Use the interactive choice tool available in your environment (e.g. `AskUserQuestion` in Claude, `askUserChoice` in Codex) to present these options:
     - **Stage everything** — run `git add -A` then proceed
     - **Stash unstaged/untracked, commit only what's staged** — run `git stash --include-untracked --keep-index` then proceed
     - **Abort** — stop here, the user will give instructions of what to with it
2. Execute `git hook run pre-commit --ignore-missing` to check the commit before actually generating the message
   - If it works, skip to step 3
   - If it failse **ABORT THE COMMIT**, ask the user if it wants help to fix it, but do not automatically continue this after it's fixed
3. Run `git diff --no-ext-diff --staged` to get the diff to be commited.
4. Write a commit message following `Commit message` instructions in `AGENTS.md`/`CLAUDE.md`. If none, base yourself from `git log -1 --pretty=%B`. 
   - **NEVER ADD** `Co-Authored-By` footer note, as you're actually helping me generate the commit message, not writing the code yourself.
5. Display the generated commit message with a horizontal rule (`\n\n---\n\n`) before and after it so it stands out clearly.
6. Run `git commit -m "..."` using a heredoc to preserve formatting. Do not push.
7. If the user chose to stash in step 1, run `git stash pop` when ready to restore their unstashed changes.
8. If any error occurs during the commit process, display an error message and abort, **do not attempt to fix it yourself**.
