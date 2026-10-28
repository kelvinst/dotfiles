#!/bin/bash
# UserPromptSubmit hook: on every prompt, remind the session that a link
# with a non-https scheme never goes bare in a reply. The Claude app renders
# obsidian:// links but blocks the click, so they go through Katapult. A
# memory alone was not followed by fresh sessions, so the rule rides on
# every prompt instead.

cat <<'TXT'
Links in replies: a link whose scheme is not https (obsidian://, x-things://, …) never goes bare — the app won't click it. Wrap it in Katapult: run `katapult <uri>` and paste what it prints. An Obsidian note opens in a new tab: for a Stingdom note, `(cd ~/Developer/Stingdom && _scripts/note-link.py <id or name>...)`; for another vault, `katapult note <vault> <name>[#heading]...`. Both print ready Markdown links; batch every link of the reply into one call.
TXT
