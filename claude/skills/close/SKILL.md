---
name: close
description:
  Use when the user types /close, or says they want to close, finish, wrap up
  or archive the current Claude session ("fechar a sessão", "encerrar", "posso
  arquivar?").
---

# Close the session

The user opens more sessions than they close. `/close` answers one question —
**can this session be archived without losing anything?** — and turns every
loose end into a fix, a deferred item (when the repo has an inbox for them), or
an explicit dismissal. Only a session with nothing open gets shipped and
archived.

**Language.** This skill is written in English; everything you produce follows
the language the user is speaking: replies, the findings list, ReportFindings
text, AskUserQuestion questions and option labels, and the content of every
note, task or commit body you write (labels included — a Portuguese arrival
says `Sessão do Claude:`).

## Repo type

Detect it once, before step 0, from the repository root
(`git rev-parse --show-toplevel`). The first match wins:

1. **Kingdone** — `Gates/Gates.md` exists (the Obsidian vault layout). Deferred
   work becomes an **arrival** note in `Gates/`.
2. **Beads** — a `.beads/` directory exists and `command -v bd` succeeds.
   Deferred work becomes a **bd task**.
3. **Neither** — there is no inbox. Nothing gets deferred by this skill; the
   user handles open items their own way.

Everything marked _(Kingdone)_ or _(Beads)_ below applies only to that type. In
a Kingdone repo the vault's own conventions (its `CLAUDE.md`) apply to every
job: the `Urgency:` trailer on commits that touch a note, renames through the
Obsidian CLI, and so on.

**Default branch.** Never assume `main`:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null \
  || { git remote set-head origin --auto >/dev/null && git symbolic-ref --short refs/remotes/origin/HEAD; }
```

This prints e.g. `origin/main`. Below, `<base>` is that ref and `<default>` is
the branch name without `origin/`.

## 0. Rebase onto the default branch

Before any review, bring the branch up to date, so everything is reviewed on
top of the current `<default>`. On a dirty tree, commit first (project commit
procedure) — a rebase needs a clean tree.

**Notes guard.** Review marks must not survive a rebase: a rebased commit sits
on new code and needs a new review. Check:

```bash
git config --show-scope --get-all notes.rewriteRef
```

If any value is `refs/notes/review`, or a glob that matches it
(`refs/notes/*`), unset that entry in the scope it came from —
`git config --<scope> --unset-all notes.rewriteRef '^<value>$'` (escape `*` as
`\*`) — and warn the user: which scope, which value, and that review marks
would otherwise follow rebased commits and fake a review. A glob also stops
rewriting the other notes it covered; say so.

Fetch (the review marks too, so marks pushed from another clone count):

```bash
git fetch origin
git fetch origin refs/notes/review:refs/notes/review 2>/dev/null || true
```

Then rebase onto `<base>` with the `kix:rebase` skill when it is available — it
re-runs the pre-commit hook on every commit; slow, but worth the wait. Without
it, `git rebase <base>`. Then `git push --force-with-lease origin HEAD` (on
`<default>` itself there is no branch push).

A rebase that moved the branch leaves its old review marks behind on the old
commits: the code now sits on a new `<default>`, so it gets reviewed again.
That is intended.

If the rebase stops on a conflict, abort it (`git rebase --abort`) and stop
everything: "Before anything else, this branch needs a rebase onto `<default>`,
and it conflicts. The session can't close until its work is on `<default>`."
Resolving the conflict is the user's call.

## 1. Collect findings

Run all three checks, in this order, before asking anything.

**a. Code review.** Find the newest reviewed commit (see the `ship` skill,
_Review marks_):

```bash
git log --notes=review --format='%H %N' <base>..HEAD | grep -m1 -E '^[0-9a-f]{40} reviewed$'
```

Run the `code-review` skill at level `medium` on everything after it — or on
the whole branch against `<base>` when there is none — plus any uncommitted
change. Skip this check when HEAD itself is reviewed and the tree is clean;
then carry over every finding from this session's latest ReportFindings call
that has no `outcome` — they are still open and go into the new report as they
were. Keep its findings for the combined report below.

**b. Conversation.** Read the whole session and list:

- things the user asked for that were not done, or were done only in part;
- questions you asked that the user never answered — an AskUserQuestion the
  user skipped, dismissed or rejected is unanswered;
- things the user deferred ("later", "tomorrow", "I'll look at it");
- follow-ups you promised;
- inferred loose ends: what the work implies but nobody said (run it for real,
  update a doc or note the change contradicts, a memory to record; _(Kingdone)_
  test it in Obsidian). Say where each came from.

If the conversation was summarized earlier, say so: findings before the summary
are only as good as the summary.

**c. Checklists.** For every Markdown file the branch (or the dirty tree)
touched — _(Kingdone)_ every note outside `Gates/` — look at its unchecked
`- [ ]` items. Each one is a finding when the file is marked done (a completed
quest or plan, a closed status, a "done" heading) or the item is pending work
the session left behind. Usual causes: it was cancelled, it was deferred
somewhere nobody linked, or it was done and not ticked.

**Mark the review.** As soon as the three checks have run, mark the commit they
looked at — HEAD — as reviewed. The mark says only that: this commit was
reviewed. Any later commit (a fix, an arrival) is not, and the next `/close`
reviews it.

```bash
git notes --ref=review add -f -m "reviewed" HEAD
git push origin refs/notes/review
```

If the notes push is rejected, run
`git fetch origin refs/notes/review:refs/notes/review-remote`,
`git notes --ref=review merge -s union refs/notes/review-remote`, and push
again.

## 2. Report

Make **one** ReportFindings call with every finding from the three checks, code
review first. It replaces any call the code-review skill made. Per finding:

- `file` / `line`: where it lives — the code, the file with the checklist, or
  the file the conversation item is about;
- `category`: for code-review findings, the category the code review gave;
  otherwise `conversation` or `checklist`;
- `summary`: the problem, then the fix "apply all" will run, fenced so it
  stands out in one line of plain text (line breaks get eaten):
  `… |—| SUGGESTED FIX: <fix> |—|`;
- `failure_scenario`: what is lost or goes wrong if the session closes now.

Then print the same list in chat, complete: the ReportFindings card renders
poorly on mobile (Remote Control), so the chat list must stand on its own —
nothing only the card shows. Per finding:

```
N. `<file>:<line>` — <problem>
   Fix: <suggested fix>
   If left: <failure scenario>
```

Zero findings → go to step 5.

## 3. Decide

First AskUserQuestion, a single question: "Apply all suggested fixes"
(Recommended) · "Go one by one".

- **Apply all:** queue every suggested fix (step 4). No more questions.
- **One by one:** walk **every** finding from the report — code review,
  conversation and checklist alike — one AskUserQuestion per finding, one
  question per call, so each answer is queued (step 4) before the next
  question. The question text carries the finding itself — its number,
  `file:line`, the problem and the suggested fix — never just "Finding N", so
  it reads on its own on mobile. Options, in this order, each with its
  description:
  - the suggested fix (Recommended);
  - each other real fix, when there is more than one — list them, keep your
    pick first;
  - the defer option, by repo type:
    - _(Kingdone)_ "Create arrival" — "Creates an arrival in your inbox (Gates)
      to do this another time, and lets this session close.";
    - _(Beads)_ "Create task" — "Creates a bd task to do this another time, and
      lets this session close.";
    - _(Neither)_ no defer option;
  - "Discard" — "ATTENTION: DISMISSES THE FINDING FOR GOOD AND RELEASES THE
    SHIP. It does not matter; ship anyway.";
  - "Leave for later" — "Not now, no decision yet. Keeps the finding open (no
    outcome) in ReportFindings, which blocks the ship until a later `/close`
    resolves it."

  AskUserQuestion takes at most four options: when the fixes, the defer option,
  "Discard" and "Leave for later" do not fit, drop the least likely extra fix
  and mention it in the question text. "Other" is always there; follow whatever
  the user types.

## 4. Run the queue

Every decision that changes files or the tracker becomes one job. Jobs run
**one at a time**, in order, each in a background agent (Agent tool,
`run_in_background: true`): dispatch the next only when the previous one
reports done. Never run two at once — each commits, and a pre-commit hook may
reject a commit while other changes sit unstaged.

Each job's prompt is self-contained: the finding, the chosen action, the files,
the repo type, the language to write in, and these rules:

- **Fix:** apply it and make one atomic commit for it (project commit procedure
  — `kix:commit` when available), then push the branch.

- _(Kingdone)_ **Create arrival:** one note in `Gates/`:

  ```markdown
  # <Infinitive verb and what to do>

  Claude session: [<session title>](<session link>), on DD/MM.
  <Two or three lines of context: what was left and why.>

  ## Checklist

  - [ ] <Concrete step, linking the exact note when there is one>
  ```

  Write `R\$`, never a bare `$`. Then edit the note the finding came from,
  whenever there is one, so it points at the arrival: a checklist item becomes
  `[-]` with `→ arrival created: [[Gates/<title>|<title>]]` at its end;
  anything else (a paragraph, a heading, a decision) gets a line saying it left
  a pending item in that arrival, with the link. Commit the arrival and the
  source edit together (`docs(gates): add arrival for …`, `Urgency: action`)
  and push.

- _(Beads)_ **Create task:** find the current work first — the issue the branch
  is about: an id in the branch name, the issue claimed or worked on in this
  session, or one the conversation names. If none is identifiable, create the
  task unrelated and say so. Then:

  ```bash
  bd create --type=task --priority=2 \
    --title="<Imperative verb and what to do>" \
    --description="Claude session: [<session title>](<session link>)
  Source: <file>:<line>

  <Two or three lines of context: what was left and why.>" \
    <relation>
  ```

  `<relation>` is `--parent=<id>` when the current work is an epic, otherwise
  `--deps=discovered-from:<id>`; leave it out when there is none. When the
  finding is a checklist item, mark it `[-]` with `→ task created: <task id>`
  at its end, commit that edit (one commit) and push. Finish with
  `bd dolt push` when the repo has a Dolt remote.

- **Session title and link** (arrival or task) come from
  `mcp__ccd_session_mgmt__get_session` with `"self"`.

- **Discard / Leave for later:** no job.

When the queue is empty, call ReportFindings again with each decided finding's
`outcome`: `fixed` for an applied fix, `skipped` for a discard and for an
arrival or task. A finding left for later gets no outcome: it stays open.
Reprint the chat list with each finding's result — fixed (with its commit),
deferred (arrival link or task id), discarded, or still open.

## 5. Ship

Shipping is always the **last** thing a session does: nothing — no fix, no
arrival, no task, no other work — runs after it. The only exceptions are the
tracker bookkeeping of step 6 (closing the shipped issue on the user's yes) and
the archive. Before offering it, make sure nothing else is pending in the
session.

**Showing the diff.** Never tell the user a keyboard shortcut — on mobile
(Remote Control) there is none. Instead, open the diff for them: call
`mcp__ccd_view__show_pane` with `pane: "diff"` (`diff_scope: "all"`, or a
commit SHA for the commits this `/close` made). Also give the compare link when
the remote is on GitHub —
`https://github.com/<owner>/<repo>/compare/<from sha>...<HEAD sha>` — which
opens anywhere, phone included. If the pane call says the session is not open
in any window, the link is all there is; say so.

- **Anything committed during this `/close`** (fixes, arrivals, checklist
  edits) → do not offer the ship. Show the diff of those commits (above), then
  say: "There were changes. Review them yourself — skim the diff — and if they
  look like what you expect, run `/close` again."
- **Any finding in the latest ReportFindings without an `outcome`** (left for
  later) → do not offer the ship. List what is still open.
- **HEAD carries `reviewed`, no finding in the latest ReportFindings is left
  without an `outcome`, and nothing was committed during this `/close`** → show
  the branch diff (above, from `<base>`), then ask with AskUserQuestion: "Did
  you review the changes? Can I ship?", with the compare link in the question
  text. Options:
  - "Ship" — "Not a merge: no merge commit. The branch was already rebased onto
    `<default>`, so its commits land on top of it as they are — flat history.";
  - "Not yet" — "I still have other things to do in this session."

  On "Ship", run the `ship` skill; if it fails, report why and stop.

## 6. Archive

Tell the user what was done: fixes with their commits, what was deferred, what
was left or discarded, what was inferred and from where. Every arrival you
mention is a link to its note; every bd task and every closed issue is named by
its id.

_(Beads)_ Only after a successful ship, and before the archive question, handle
the issue(s) the branch was about — found the same way the Create task job
finds the current work: an id in the branch name, the issue claimed or worked
on in this session, or one the conversation names. If none is identifiable, say
so and ask nothing. Otherwise ask with AskUserQuestion whether to close them,
naming each id and title: "Close <id>" (Recommended) — "Closes the issue as
shipped: its work is now on `<default>`." · "Leave it open". Only on the user's
yes, run `bd close <id> --reason="shipped to <default>"`, then `bd dolt push`
when the repo has a Dolt remote. Never close an issue without that answer.

Only after a successful ship, ask with AskUserQuestion: "Archive this session
now?" — "Archive" (Recommended) · "Leave it open". On "Archive", call
`mcp__ccd_session_mgmt__archive_session` with `session_id: "self"`. Never
archive without that answer, or while the work is not in `<base>`.

## Common mistakes

- Two ReportFindings lists (one from code-review, one of yours) instead of one.
- A chat list that leaves out what the ReportFindings card shows, or a
  one-by-one question that names a finding without saying what it is.
- One-by-one that skips the code-review findings.
- Running two queue jobs at once, or bundling several fixes in one commit.
- Offering the ship after anything was committed, or while anything is left for
  later.
- Offering the ship while any finding has no outcome.
- Doing any work after the ship.
- Telling the user a keyboard shortcut to open the diff instead of opening it
  (and linking it) for them.
- Closing a bd issue without asking, or before the ship.
- Treating "Leave for later" as a discard.
- Reviewing before the rebase, or rebasing with `notes.rewriteRef` still
  carrying review marks.
- Hardcoding `main` instead of the detected default branch.
- Offering a defer option in a repo that has no inbox, or Kingdone conventions
  (Gates, `Urgency:`, `R\$`) outside a Kingdone repo.
- Counting a skipped or dismissed question as answered.
- Naming an arrival without linking it, or a task without its id; leaving the
  source checklist item without a pointer back.
- Writing in English to a user who speaks Portuguese.
