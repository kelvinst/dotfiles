---
name: ship
description:
  Use when the user types /ship, or asks to put the current branch's work on
  the default branch ("manda pra main", "mergear na main", "sobe pra main",
  "ship"), or when another skill needs the branch's commits in the default
  branch.
---

# Ship to the default branch

"Merge into main" means GitHub's **rebase and merge**, done in two parts: the
`preflight` skill rebases the branch onto the default branch and reviews it,
and ship only fast-forwards the default branch to the checked branch — no merge
commit, flat history. Ship never rebases and never reviews on its own; it runs
`preflight` for both.

**Language.** Reply in the language the user is speaking.

**Default branch.** Never assume `main`:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null \
  || { git remote set-head origin --auto >/dev/null && git symbolic-ref --short refs/remotes/origin/HEAD; }
```

Below, `<base>` is that ref (e.g. `origin/main`) and `<default>` is the branch
name without `origin/`.

## Steps

Print a progress line before each step, as preflight's _Progress_ says: the
preflight steps are 1–6, and steps 2–5 below are 7–10 of 10 (of 12 when `close`
called ship).

1. **Preflight.** Run the `preflight` skill, every time — even when HEAD
   already carries a check mark (preflight skips the code review then, but
   still rebases and reruns every other check). Its verdict decides:

   - **Changed** or **Open** → stop here. Preflight already told the user what
     to do; add nothing, ship nothing.
   - **Clear** → go on.

2. **Confirm.** Show the branch diff from `<base>` the way preflight's _Showing
   the diff_ says, then ask with AskUserQuestion: "Did you review the changes?
   Can I ship?", with the compare link in the question text. Options:

   - "Ship" — "Not a merge: no merge commit. The branch was already rebased
     onto `<default>`, so its commits land on top of it as they are — flat
     history.";
   - "Not yet" — "I still have other things to do in this session."

   Anything but "Ship" → stop.

3. **Gate.** Right before pushing, recheck — the user may have taken a while:

   ```bash
   git status --porcelain
   git fetch origin
   git fetch origin refs/notes/checks:refs/notes/checks 2>/dev/null || true
   git merge-base --is-ancestor <base> HEAD && echo UP_TO_DATE
   git notes --ref=checks show HEAD 2>/dev/null | head -1
   ```

   A dirty tree, no `UP_TO_DATE`, or a first note line other than `checked` →
   stop: "Something changed since the preflight. Run `<command>` again." —
   `<command>` as preflight's _Verdict_ defines it (`/close` when close called
   ship). Never rebase or review here to fix it.

4. **Push the default branch, the branch and the notes.**

   ```bash
   git push origin HEAD:<default>
   git push --force-with-lease origin HEAD
   git push origin refs/notes/checks
   ```

   The push to `<default>` is a fast-forward. If it is rejected, `<default>`
   moved: stop with the step 3 message. If the notes push is rejected, run
   `git fetch origin refs/notes/checks:refs/notes/checks-remote`,
   `git notes --ref=checks merge -s union refs/notes/checks-remote`, and push
   again.

   On `<default>` itself (no branch), push is just `git push` plus the notes.

5. **Check.**

   ```bash
   git fetch origin
   git merge-base --is-ancestor HEAD <base> && echo IN_DEFAULT
   ```

   Report the commits that landed (`git log --oneline <old base>..HEAD`).

## Common mistakes

- Skipping preflight because HEAD already carries `checked`.
- Going past a **changed** or **open** verdict.
- Rebasing, merging the default branch, or reviewing from ship itself instead
  of through preflight.
- Pushing without the "Ship" answer.
- Shipping a HEAD without a `checked` note. Old `reviewed` notes in
  `refs/notes/review` no longer count.
- Hardcoding `main` instead of the detected default branch.
- Restarting the progress count at ship's own steps instead of going on from
  preflight's.
- Force-pushing the default branch — never.
