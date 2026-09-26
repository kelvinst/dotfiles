---
name: ship
description:
  Use when the user types /ship, or asks to put the current branch's work on
  the default branch ("manda pra main", "mergear na main", "sobe pra main",
  "ship"), or when another skill needs the branch's commits in the default
  branch.
---

# Ship to the default branch

"Merge into main" means GitHub's **rebase and merge**, done in two parts:
`close` rebases the branch onto the default branch before reviewing it, and
ship only fast-forwards the default branch to the reviewed branch — no merge
commit, flat history. Ship never rebases and never reviews; both are the
`close` skill's job.

**Language.** Reply in the language the user is speaking.

**Default branch.** Never assume `main`:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null \
  || { git remote set-head origin --auto >/dev/null && git symbolic-ref --short refs/remotes/origin/HEAD; }
```

Below, `<base>` is that ref (e.g. `origin/main`) and `<default>` is the branch
name without `origin/`.

## Review marks

A reviewed commit carries a git note in `refs/notes/review` reading `reviewed`,
written by `close` right after its checks ran on that commit.

```bash
git fetch origin refs/notes/review:refs/notes/review 2>/dev/null || true
```

## Steps

1. **Clean tree.** `git status --porcelain` must be empty. If not, stop: "There
   are uncommitted changes. Run `/close`."

2. **Up to date with the default branch.**

   ```bash
   git fetch origin
   git merge-base --is-ancestor <base> HEAD && echo UP_TO_DATE
   ```

   No `UP_TO_DATE` → someone pushed to `<default>` after `close` rebased. Stop
   — no rebase, no push: "Your branch is behind `<default>`. Run `/close` again
   to rebase and recheck everything." Pulling `<default>` in can break this
   branch's work, and that needs a new review.

3. **Review gate.**

   ```bash
   git notes --ref=review show HEAD 2>/dev/null | head -1
   ```

   Anything but `reviewed` → stop: "The last commit has not been reviewed. Run
   `/close`." Do not review here.

   Then, if this session's latest ReportFindings call still has any finding
   without an `outcome`, stop: "There are findings still open. Run `/close` to
   resolve or dismiss them." Ship still never reviews.

4. **Push the default branch, the branch and the notes.**

   ```bash
   git push origin HEAD:<default>
   git push --force-with-lease origin HEAD
   git push origin refs/notes/review
   ```

   The push to `<default>` is a fast-forward. If it is rejected, `<default>`
   moved: stop with the step 2 message. If the notes push is rejected, run
   `git fetch origin refs/notes/review:refs/notes/review-remote`,
   `git notes --ref=review merge -s union refs/notes/review-remote`, and push
   again.

   On `<default>` itself (no branch), push is just `git push` plus the notes.

5. **Check.**

   ```bash
   git fetch origin
   git merge-base --is-ancestor HEAD <base> && echo IN_DEFAULT
   ```

   Report the commits that landed (`git log --oneline <old base>..HEAD`).

## Common mistakes

- Rebasing or merging the default branch from here — send the user to `/close`
  instead.
- Running a review from here.
- Shipping a HEAD without a `reviewed` note.
- Shipping while the session has open findings.
- Hardcoding `main` instead of the detected default branch.
- Force-pushing the default branch — never.
