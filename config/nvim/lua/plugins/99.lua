local function find_claude_window()
  local ls_output = vim.fn.system({ "kitty", "@", "ls" })
  local ok, data = pcall(vim.json.decode, ls_output)
  if ok and data then
    for _, os_window in ipairs(data) do
      local focused_tab = vim.iter(os_window.tabs or {}):find(function(t)
        return t.is_focused
      end)

      if focused_tab then
        local claude_win = vim.iter(focused_tab.windows or {}):find(function(w)
          return vim.iter(w.foreground_processes or {}):find(function(p)
            return vim.iter(p.cmdline or {}):find(function(c)
              return c:match("claude")
            end)
          end)
        end)

        return claude_win
      end
    end
  end
  return nil
end

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
      "<leader>ax",
      _99.stop_all_requests,
      { desc = "Stop requests" }
    )
    vim.keymap.set("n", "<leader>am", function()
      require("99.extensions.fzf_lua").select_model()
    end, { desc = "Select model" })
    vim.keymap.set("n", "<leader>ap", function()
      require("99.extensions.fzf_lua").select_provider()
    end, { desc = "Select provider" })
    vim.keymap.set("n", "<leader>aa", function()
      local claude_window = find_claude_window()

      if claude_window then
        vim.fn.system({
          "kitty",
          "@",
          "focus-window",
          "--match",
          "id:" .. claude_window.id,
        })

        return
      end

      vim.fn.system({
        "kitty",
        "@",
        "launch",
        "--type=window",
        "--location=vsplit",
        "--cwd=" .. vim.fn.getcwd(),
        "claude",
      })
    end, { desc = "Claude" })
  end,
}
