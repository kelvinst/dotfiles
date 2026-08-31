# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on
this project.

## What this is

Personal macOS dotfiles. Edits happen here, then `make install` copies
everything into `$HOME` / `~/.config`. Targets are kelvin's machines only —
there are no other users, no portability layer, no Linux fallback.

## Layout

| Repo path                | Installed to              |
| ------------------------ | ------------------------- |
| `zshrc`, `zshenv`        | `~/.zshrc`, `~/.zshenv`   |
| `gitconfig`              | `~/.gitconfig`            |
| `global_gitignore`       | `~/.global_gitignore`     |
| `tmux.conf`              | `~/.tmux.conf`            |
| `aerospace.toml`         | `~/.aerospace.toml`       |
| `skhdrc`                 | `~/.skhdrc`               |
| `paneru.toml`            | `~/.paneru.toml`          |
| `ai-jail`                | `~/.ai-jail`              |
| `default-gems`           | `~/.default-gems`         |
| `config/<tool>/`         | `~/.config/<tool>/`       |
| `claude/`                | `~/.claude/`              |
| `hammerspoon/`           | `~/.hammerspoon/`         |
| `bin/`                   | `~/.local/bin/` (chmod +x)|
| `zsh/completions/`       | `~/.zsh/completions/`     |

The exact mapping lives in the `Makefile` — treat it as the source of truth.

## Workflow

```bash
make           # default target: same as `make install`
make install   # back up the installed copies, then copy everything into $HOME
make backup    # only move the installed copies into a timestamped backup
make clean     # remove the installed copies
make update    # copy from $HOME back into the repo (reverse direction)
```

`make install` first moves every path it is about to write into
`~/.dotfiles-backups/<YYYYmmdd-HHMMSS>/`, preserving the layout relative to
`$HOME`. Moving doubles as the removal step, so each install lands on a
clean slate without destroying whatever was there. The backed-up paths are
listed explicitly in the `Makefile` (`HOME_TARGETS`, plus one entry per file
in `bin/` and `claude/hooks/`) so neighbouring state — the rest of
`~/.claude`, other scripts in `~/.local/bin` — is never touched.

`make update` pulls live config out of `$HOME` and overwrites the repo
copies. Don't run it casually — it's for capturing changes you made directly
in `$HOME`, and it will clobber uncommitted edits in the repo. Default
direction is repo → `$HOME` via `make install`.

After editing a file in the repo, run `make install` (or copy the single
file) to see the change take effect; nothing is symlinked.

## Conventions

- **Formatters**: `prettier` for Markdown/JSON (`printWidth: 79`,
  `proseWrap: always`), `stylua` for Lua (`column_width: 80`, 2-space
  indent). Match these when editing.
- **Shell**: zsh on macOS only. `#!/usr/bin/env bash` is fine for scripts in
  `bin/`, but the interactive shell config (`zshrc`/`zshenv`) is zsh.
- **Commit messages**: Conventional Commits with a scope tied to the file or
  tool being touched — e.g. `feat(zshrc): ...`, `fix(aerospace): ...`,
  `feat(nvim): ...`, `chore(beads): ...`. Wrap bodies at ~72 chars. No
  `Co-Authored-By` trailer.
- **macOS-specific tools** in play: kitty, aerospace, skhd, paneru,
  hammerspoon, JankyBorders, ai-jail, worktrunk. Don't suggest Linux
  equivalents unless asked.

## Non-interactive shell commands

Some commands (`cp`, `mv`, `rm`) may be aliased to `-i` and will hang
waiting for confirmation. Use `-f` (and `-rf` for recursive) explicitly. For
`ssh`/`scp` use `-o BatchMode=yes`; for `apt`/`brew` use `-y` /
`HOMEBREW_NO_AUTO_UPDATE=1`.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->

## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full
workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or
  markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT
complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs
   follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**

- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
