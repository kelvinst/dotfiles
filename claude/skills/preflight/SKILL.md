---
name: preflight
description:
  Use when the user types /preflight, or asks whether the current branch is
  ready to land on the default branch ("tá pronto pra main?", "revisa a
  branch", "pode subir?"), or when another skill (ship, and close through ship)
  needs the branch checked before it moves.
---

# Preflight the branch

Preflight answers one question — **can this branch land on the default branch
without losing anything?** — and turns every loose end into a fix, a deferred
item (when the repo has an inbox for them), or an explicit dismissal. It is the
only place a review happens: `ship` and `close` run it, and never review on
their own.

**Language.** This skill is written in English; everything you produce follows
the language the user is speaking: replies, the findings list, ReportFindings
text, AskUserQuestion questions and option labels, and the content of every
note, task or commit body you write (labels included — a Portuguese arrival
says `Sessão do Claude:`).

## Repo type

Detect it once, before step 1, from the repository root
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

## Check marks

A checked commit carries a git note in `refs/notes/checks` reading `checked`,
written by step 2 right after its checks ran on that commit. The mark only
records that the checks ran — it is not an approval; the approval is the user's
"Ship" answer in `ship`. `ship` reads it; only preflight writes it.

## Progress

The user wants to see where a run is while it runs. When each step ends, print
one progress line (none when it starts; the only other line is the ❓ line
before a question, below), numbered across the whole run the user started (the
`<command>` of _Verdict_), not per skill. Each check of step 2 is a step of its
own:

| Step                                    | `/preflight` | `/ship` | `/close` |
| --------------------------------------- | ------------ | ------- | -------- |
| Rebase (1)                              | 1/10         | 1/14    | 1/16     |
| Code review (2a)                        | 2/10         | 2/14    | 2/16     |
| Conversation (2b)                       | 3/10         | 3/14    | 3/16     |
| Checklists (2c)                         | 4/10         | 4/14    | 4/16     |
| Tracker (2d)                            | 5/10         | 5/14    | 5/16     |
| Look ahead (2e)                         | 6/10         | 6/14    | 6/16     |
| Report (3)                              | 7/10         | 7/14    | 7/16     |
| Decide (4)                              | 8/10         | 8/14    | 8/16     |
| Fixes (5)                               | 9/10         | 9/14    | 9/16     |
| Verdict (6)                             | 10/10        | 10/14   | 10/16    |
| Confirm, Gate, Push, Check (`ship` 2–5) | —            | 11–14   | 11–14    |
| Mark task done, Archive (`close` 2a–2b) | —            | —       | 15–16    |

Each line starts with an emoji for the step's state, then `<n>/<total>` and the
step name:

| Emoji | When                                                                | Example                                               |
| ----- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| ✅    | the step finished and worked — with its result                      | `✅ 3/14 Conversation — 0 findings`                   |
| ⏭️    | the step does not apply                                             | `⏭️ 8/14 Decide — no findings`                        |
| ⚠️    | the run stops here and needs the user to act — say what             | `⚠️ 10/14 Verdict — changed: …`                       |
| ❓    | right before each question to the user — with a short summary of it | `❓ 8/14 Decide — finding 2: tally vs split`          |
| ⏳    | a Fixes job is dispatched to its background agent                   | `⏳ 9.1/14 Fixes — job 1/2: ❓ before every question` |

Fixes (progress step 9 in every run) numbers each job as a sub-step: `9.1`,
`9.2`, … Print its ⏳ line when the job is dispatched and its ✅ or ⚠️ line,
with the commit or task id, when the job reports done:
`✅ 9.1/14 Fixes — job 1/2: ❓ before every question (bb5098b)`. The step's own
✅ line follows the last job.

Before **every** AskUserQuestion — in any step of preflight, `ship` or `close`,
each one-by-one finding question and each discard-reason question included —
print a ❓ line right before calling the tool:
`❓ <n>/<total> <Step> — <very short summary of what is about to be asked>`
(e.g. `❓ 8/14 Decide — finding 2: tally vs split`,
`❓ 11/14 Confirm — ship these 3 commits?`,
`❓ 16/16 Archive — archive this session?`). The step still ends with its ✅ or
⚠️ line; Decide's ✅ line counts each kind of decision (e.g.
`✅ 8/14 Decide — 2 fixes queued, 1 skipped`).

A run that finishes ends with `✅ <total>/<total> done`.

Every step gets its own line, printed as that step ends — even when several
steps end with nothing to say. Never fold them into one summary ("steps 1–6
clear"):

```
✅ 1/14 Rebase — already on main
✅ 2/14 Code review — 0 findings
✅ 3/14 Conversation — asks 0 · unanswered 0/0 · deferred 0 · promised 0 · inferred 0
```

Each step runs at least one real command of its own (a grep, a `bd` search, a
`git` call — whatever the step actually needs), and its progress line goes out
right after that command, as its own message. Never put several steps' lines in
one text block: the app shrinks such a block into one summary line.

## 1. Rebase onto the default branch

Before any review, bring the branch up to date, so everything is reviewed on
top of the current `<default>`. On a dirty tree, commit first (project commit
procedure) — a rebase needs a clean tree.

**Notes guard.** Check marks must not survive a rebase: a rebased commit sits
on new code and needs a new review. Check:

```bash
git config --show-scope --get-all notes.rewriteRef
```

If any value is `refs/notes/checks`, or a glob that matches it
(`refs/notes/*`), unset that entry in the scope it came from —
`git config --<scope> --unset-all notes.rewriteRef '^<value>$'` (escape `*` as
`\*`) — and warn the user: which scope, which value, and that check marks would
otherwise follow rebased commits and fake the checks. A glob also stops
rewriting the other notes it covered; say so.

Fetch (the check marks too, so marks pushed from another clone count):

```bash
git fetch origin
git fetch origin refs/notes/checks:refs/notes/checks 2>/dev/null || true
```

Then rebase onto `<base>` with the `kix:rebase` skill when it is available — it
re-runs the pre-commit hook on every commit; slow, but worth the wait. Without
it, `git rebase <base>`. Then `git push --force-with-lease origin HEAD` (on
`<default>` itself there is no branch push).

A rebase that moved the branch leaves its old check marks behind on the old
commits: the code now sits on a new `<default>`, so it gets checked again. That
is intended.

If the rebase stops on a conflict, abort it (`git rebase --abort`) and stop
everything: "Before anything else, this branch needs a rebase onto `<default>`,
and it conflicts. Nothing lands until the branch sits on `<default>`."
Resolving the conflict is the user's call.

## 2. Collect findings

Run all five checks, in this order, before asking anything.

**a. Code review.** Find the newest checked commit (see _Check marks_):

```bash
git log --notes=checks --format='%H %N' <base>..HEAD | grep -m1 -E '^[0-9a-f]{40} checked$'
```

Run the `code-review` skill at level `medium` on everything after it — or on
the whole branch against `<base>` when there is none — plus any uncommitted
change. Skip this check when HEAD itself is checked and the tree is clean; then
carry over every finding from this session's latest ReportFindings call that
has no `outcome` — they are still open and go into the new report as they were.
Keep its findings for the combined report below.

**b. Conversation.** Read the whole session and list:

- things the user asked for that were not done, or were done only in part;
- questions you asked that the user never answered — an AskUserQuestion the
  user skipped, dismissed or rejected is unanswered;
- questions the user asked that you never answered, or answered only in part —
  a question buried in a longer message counts;
- things the user deferred ("later", "tomorrow", "I'll look at it");
- follow-ups you promised;
- inferred loose ends: what the work implies but nobody said (run it for real,
  update a doc or note the change contradicts, a memory to record; _(Kingdone)_
  test it in Obsidian). Say where each came from.

If the conversation was summarized earlier, say so: findings before the summary
are only as good as the summary.

This check's progress line tallies each of the six kinds, e.g.
`✅ 3/14 Conversation — asks 0 · unanswered 0/0 · deferred 0 · promised 0 · inferred 1`;
`unanswered x/y` is questions the user left unanswered / questions you left
unanswered.

**c. Checklists.** For every Markdown file the branch (or the dirty tree)
touched — _(Kingdone)_ every note outside `Gates/` — look at its unchecked
`- [ ]` items. Each one is a finding when the file is marked done (a completed
quest or plan, a closed status, a "done" heading) or the item is pending work
the session left behind. Usual causes: it was cancelled, it was deferred
somewhere nobody linked, or it was done and not ticked.

**d. Tracker.** Search the tracker for items related to the work — by the
files, the feature, the names and the terms the branch touches, not only by the
id in the branch name:

- _(Beads)_ open and in-progress bd issues (`bd list`, `bd search <term>`,
  `bd show <id>` for their dependencies);
- _(Kingdone)_ arrivals in `Gates/`, quests anywhere (in progress, planned or
  someday), and unchecked `- [ ]` items in any note, not only the touched ones;
- _(Neither)_ skip this check.

List each item the work affects, either way:

- this work does it, fully or in part — it can be closed, ticked or updated;
- it depends on this work, or is blocked by it — it should know this lands (a
  note, a link, an unblocked dependency);
- this work depends on it, or conflicts with work it plans;
- it plans something this work changes or makes obsolete.

Each is a finding with a concrete suggested fix: close or tick it, add a note
or link saying what landed, add or drop a dependency, or rewrite the plan. The
issue or quest the branch itself is about is not a finding: `close` marks it
done after the ship.

**e. Look ahead.** From the work done — the diff, the conversation, the touched
files — list what nobody raised: nothing already in the conversation or in the
tracker (check d) goes here:

- related things the change touches or should touch but nobody mentioned (other
  callers, sibling configs, docs, other repos or branches that depend on it);
- ideas the work suggests — improvements worth having, not needed now;
- next steps — the natural follow-up work;
- possible pitfalls — how it could break, be misused or surprise later (edge
  cases, environments, concurrency with other sessions or branches, upgrades).

Each is a finding like any other, with a concrete suggested fix: usually the
defer option (a task or an arrival), or doing it now when it is small. Only
real, specific items — no generic advice; say what triggered each.

**Mark the checks.** As soon as the five checks have run, mark the commit they
looked at — HEAD — as checked. The mark says only that: the checks ran on this
commit. It is not an approval; the approval is the user's "Ship" answer in
`ship`. Any later commit (a fix, an arrival) is not checked, and the next
preflight checks it.

```bash
git notes --ref=checks add -f -m "checked" HEAD
git push origin refs/notes/checks
```

If the notes push is rejected, run
`git fetch origin refs/notes/checks:refs/notes/checks-remote`,
`git notes --ref=checks merge -s union refs/notes/checks-remote`, and push
again.

## 3. Report

Make **one** ReportFindings call with every finding from the five checks, code
review first. It replaces any call the code-review skill made. Per finding:

- `file` / `line`: where it lives — the code, the file with the checklist, or
  the file the conversation item is about;
- `category`: for code-review findings, the category the code review gave;
  otherwise `conversation`, `checklist` or `tracker`, or for the look-ahead
  check `related`, `idea`, `next-step` or `pitfall`;
- `summary`: the problem, then the fix "apply all" will run, fenced so it
  stands out in one line of plain text (line breaks get eaten):
  `… |—| SUGGESTED FIX: <fix> |—|`;
- `failure_scenario`: what is lost or goes wrong if the branch lands now.

Then print the same list in chat, complete: the ReportFindings card renders
poorly on mobile (Remote Control), so the chat list must stand on its own —
nothing only the card shows. Per finding:

```
N. `<file>:<line>` — <problem>
   Fix: <suggested fix>
   If left: <failure scenario>
```

Zero findings → go to step 6 (Verdict).

## 4. Decide

First AskUserQuestion, a single question: "Apply all suggested fixes"
(Recommended) · "Go one by one".

- **Apply all:** queue every suggested fix (step 5). No more questions.
- **One by one:** walk **every** finding from the report — code review,
  conversation, checklist, tracker and look-ahead alike — one AskUserQuestion
  per finding, one question per call, so each answer is queued (step 5) before
  the next question. The question text carries the finding itself — its number,
  `file:line`, the problem and the suggested fix — never just "Finding N", so
  it reads on its own on mobile. Options, in this order, each with its
  description:
  - the suggested fix (Recommended);
  - each other real fix, when there is more than one — list them, keep your
    pick first;
  - the defer option, by repo type:
    - _(Kingdone)_ "Create arrival" — "Creates an arrival in your inbox (Gates)
      to do this another time; releases the ship after a re-run.";
    - _(Beads)_ "Create task" — "Creates a bd task to do this another time;
      releases the ship after a re-run.";
    - _(Neither)_ no defer option;
  - "Discard" — "ATTENTION: DISMISSES THE FINDING FOR GOOD AND RELEASES THE
    SHIP. It does not matter; ship anyway. Asks for the reason.";
  - "Leave for later" — "Not now, no decision yet. Keeps the finding open (no
    outcome) in ReportFindings, which blocks the ship until a later preflight
    resolves it."

  AskUserQuestion takes at most four options: when the fixes, the defer option,
  "Discard" and "Leave for later" do not fit, drop the least likely extra fix
  and mention it in the question text. "Other" is always there; follow whatever
  the user types.

  When the user picks "Discard", ask right away, in its own AskUserQuestion,
  why — the reason is required. Offer 2–3 likely reasons for this specific
  finding as options (e.g. "Not a real problem", "Intended behavior", "Not
  worth the cost"); "Other" takes free text. Only a discard with a reason
  counts: a skipped or empty answer leaves the finding undecided — ask again,
  or treat it as "Leave for later". Under "Apply all" nothing is discarded, so
  no reason is needed.

## 5. Run the queue

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
arrival or task. A discarded finding's `summary` ends with
`|—| DISCARDED: <reason> |—|`. A finding left for later gets no outcome: it
stays open. Reprint the chat list with each finding's result — fixed (with its
commit), deferred (arrival link or task id), discarded — <reason>, or still
open.

## 6. Verdict

End every run with exactly one verdict. Callers (`ship`, and `close` through
`ship`) move on only on **clear**. Below, `<command>` is the slash command of
the skill the user started — `/preflight`, `/ship` or `/close` — even when they
started it in plain words.

**Showing the diff.** Never tell the user a keyboard shortcut — on mobile
(Remote Control) there is none. Instead, open the diff for them: call
`mcp__ccd_view__show_pane` with `pane: "diff"`. For the branch diff, pass
`diff_scope: "all"`. For the commits this run made, `diff_scope` takes a single
commit SHA, so pass the **first** commit of the batch and tell the user to move
forward from there, commit by commit, up to HEAD. Also give the compare link
when the remote is on GitHub —
`https://github.com/<owner>/<repo>/compare/<from sha>...<HEAD sha>` — which
opens anywhere, phone included. If the pane call says the session is not open
in any window, the link is all there is; say so.

- **Changed** — step 5 committed anything (fixes, arrivals, checklist edits).
  The rebase and step 1's commit of a dirty tree do not count: step 2 checked
  them. Show the diff of the step 5 commits (above), then say: "There were
  changes. Review them yourself — skim the diff — and if they look like what
  you expect, run `<command>` again." Those commits are not checked yet; the
  next run checks them.
- **Open** — any finding in the latest ReportFindings has no `outcome` (left
  for later). List what is still open, then say: "Run `<command>` again when
  you are ready to decide them."
- **Clear** — HEAD carries `checked`, every finding in the latest
  ReportFindings has an `outcome`, and step 5 committed nothing. Say so. When
  preflight was run on its own, stop here — it never ships.

## Common mistakes

- Two ReportFindings lists (one from code-review, one of yours) instead of one.
- A chat list that leaves out what the ReportFindings card shows, or a
  one-by-one question that names a finding without saying what it is.
- One-by-one that skips the code-review findings.
- Skipping the look-ahead check, or padding it with generic advice.
- Searching the tracker only by the branch's issue id, or only in the touched
  files.
- Listing only the questions the user left unanswered, not the ones you did.
- Running two queue jobs at once, or bundling several fixes in one commit.
- Calling a run **clear** after it committed anything, or while any finding has
  no outcome.
- Shipping from here — preflight only gives a verdict.
- Telling the user a keyboard shortcut to open the diff instead of opening it
  (and linking it) for them.
- Treating "Leave for later" as a discard.
- Discarding without a reason, or inventing one for the user.
- Reviewing before the rebase, or rebasing with `notes.rewriteRef` still
  carrying check marks.
- Hardcoding `main` instead of the detected default branch.
- Numbering progress per skill (`1/10` inside a `/ship`) instead of across the
  whole run, or dropping the line for a skipped step, printing a line when a
  step starts instead of when it ends, or folding several steps into one line.
- Printing several steps' progress lines in one text block instead of one
  message per step, each right after that step's own command.
- Asking the user anything without printing the ❓ line first, or printing it
  after the question.
- Running Fixes jobs without their `<step>.<job>` ⏳ and ✅ lines.
- Offering a defer option in a repo that has no inbox, or Kingdone conventions
  (Gates, `Urgency:`, `R\$`) outside a Kingdone repo.
- Counting a skipped or dismissed question as answered.
- Naming an arrival without linking it, or a task without its id; leaving the
  source checklist item without a pointer back.
- Writing in English to a user who speaks Portuguese.
