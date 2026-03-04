return {
  -- AI agentic workflow plugin
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    _99.setup({
      provider = _99.Providers.ClaudeCodeProvider,
      tmp_dir = "./tmp",
      completion = {
        custom_rules = {
          ".claude/skills/",
        },
        source = "cmp",
      },
      in_fligh_options = {},
      md_files = { "AGENTS.md", "CLAUDE.md" },
    })

    vim.keymap.set("v", "<leader>a<space>", _99.visual, { desc = "Replace" })
    vim.keymap.set("n", "<leader>a<space>", _99.search, { desc = "Search" })
    vim.keymap.set("n", "<leader>al", _99.view_logs, { desc = "Logs" })
    vim.keymap.set(
      "n",
      "<leader>a<bs>",
      _99.stop_all_requests,
      { desc = "Stop requests" }
    )
    vim.keymap.set("n", "<leader>am", function()
      require("99.extensions.fzf_lua").select_model()
    end, { desc = "Select model" })
    vim.keymap.set("n", "<leader>ap", function()
      require("99.extensions.fzf_lua").select_provider()
    end, { desc = "Select provider" })
    vim.keymap.set("n", "<leader>ac", OpenClaude, { desc = "Focus Claude" })
    vim.keymap.set("n", "<leader>ax", OpenCodex, { desc = "Focus Codex" })
    vim.keymap.set("n", "<leader>anc", NewClaude, { desc = "New Claude" })
    vim.keymap.set("n", "<leader>anx", NewCodex, { desc = "New Codex" })
  end,
}
