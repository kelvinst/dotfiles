local function without_vimade(cmd)
  return function()
    vim.cmd.VimadeDisable()
    cmd()
    vim.cmd.VimadeEnable()
  end
end

return { -- Easily jump around in your file
  "smoka7/hop.nvim",
  event = "VimEnter",
  version = "v2.7.2",
  keys = {
    {
      "<leader><space><space>",
      without_vimade(vim.cmd.HopChar1),
      desc = "Hop to a char",
    },
    {
      "<leader><space>/",
      without_vimade(vim.cmd.HopPattern),
      desc = "Search like /",
    },
    {
      "<leader><space>1",
      without_vimade(vim.cmd.HopChar1),
      desc = "1 Char",
    },
    {
      "<leader><space>2",
      without_vimade(vim.cmd.HopChar2),
      desc = "2 Char",
    },
    {
      "<leader><space>a",
      without_vimade(vim.cmd.HopAnywhere),
      desc = "Anywhere",
    },
    {
      "<leader><space>h",
      without_vimade(vim.cmd.HopChar1),
      desc = "Default (1 char)",
    },
    { "<leader><space>l", without_vimade(vim.cmd.HopLine), desc = "Line" },
    {
      "<leader><space>n",
      function()
        require("hop").hint_patterns({}, vim.fn.getreg("/"))
      end,
      desc = "Next pattern (based on what was searched on /)",
    },
    {
      "<leader><space>t",
      without_vimade(vim.cmd.HopNodes),
      desc = "Treesiter nodes",
    },
    { "<leader><space>w", without_vimade(vim.cmd.HopWord), desc = "Word" },
  },
  config = function()
    local hop = require("hop")

    hop.setup({
      multi_windows = true,
      quit_key = "<leader>",
    })

    local modes = { "n", "v" }

    vim.keymap.set(modes, "f", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, { desc = "Hop for char (forward)" })

    vim.keymap.set(modes, "F", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, { desc = "Hop for char (backward)" })

    vim.keymap.set(modes, "t", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end, { desc = "Hop 'til char (forward)" })

    vim.keymap.set(modes, "T", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end, { desc = "Hop 'til char (backward)" })
  end,
}
