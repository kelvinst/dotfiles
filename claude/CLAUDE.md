# Global instructions

## Response style

- No explanations unless asked. Give the result, not the reasoning behind it;
  the user asks explicitly when they want the why.

## Session title

- Run the `kix:title` skill whenever the session's state changes: a tracker
  item gets filed, a design or plan gets approved, the item's work starts (code
  in a code repo, the deliverable notes, research or documents in a notes
  repo). The `kix:close` skill runs it itself for 📦 and 🏁.

## Links

- A link whose scheme is not https (`obsidian://` above all) never goes bare in
  a reply: the app won't click it. It goes through Katapult — `katapult <uri>`
  prints the link, `katapult note <vault> <name>` a new-tab link to an Obsidian
  note. A global UserPromptSubmit hook repeats this on every prompt.
