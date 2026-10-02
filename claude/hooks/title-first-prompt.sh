#!/bin/bash
# SessionStart hook (matcher: startup) for the title skill (dot-mrr): a hook
# cannot pick the tracker item or the state, so it only asks the agent to run
# the title skill once the user's first message is in. Resumes, clears and
# compactions do not match, so a running session keeps its title.

printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Session title: right after the user'"'"'s first message in this session, before anything else, run the `title` skill (no arguments) so the session gets its `<emoji> <code>-<id> │ <description>` title. Do it once; later state changes follow the Session title rule in CLAUDE.md."}}'
