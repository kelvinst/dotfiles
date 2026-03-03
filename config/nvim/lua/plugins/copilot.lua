return { -- Github Copilot suggestions AI
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<Right>",
        next = "<Down>",
        prev = "<Up>",
        dismiss = "<C-]>",
      },
    },
    panel = { enabled = false },
  },
}
