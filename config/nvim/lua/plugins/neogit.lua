return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
    "folke/which-key.nvim",
  },
  config = function()
    local neogit_previous_tab = nil

    -- Helper to save previous tab and run a callback
    local function with_saved_tab(callback)
      return function()
        neogit_previous_tab = vim.api.nvim_get_current_tabpage()
        callback()
      end
    end

    -- Set up keymaps
    vim.keymap.set(
      "n",
      "<leader>gg",
      with_saved_tab(vim.cmd.Neogit),
      { desc = "Git Status" }
    )
    vim.keymap.set(
      "n",
      "<leader>gl",
      with_saved_tab(vim.cmd.NeogitLogCurrent),
      { desc = "Log (current file)" }
    )
    vim.keymap.set(
      "n",
      "<leader>gc",
      ":Dispatch claude /commit<CR>",
      { desc = "Git commit (claude)" }
    )
    vim.keymap.set(
      "n",
      "<leader>gxc",
      ":Dispatch .git/hooks/pre-commit<CR>",
      { desc = "pre-commit" }
    )
    vim.keymap.set(
      "n",
      "<leader>gxp",
      ":Dispatch .git/hooks/pre-push<CR>",
      { desc = "pre-push" }
    )

    local floating_width = math.min(80, vim.o.columns)
    local floating_col = math.max(vim.o.columns - floating_width, 0)
    local floating_height = math.max(math.floor(vim.o.lines * 0.18), 1)
    local floating_row = math.max(
      vim.o.lines
        - floating_height
        - vim.o.cmdheight
        - (vim.o.laststatus > 0 and 1 or 0),
      0
    )

    require("neogit").setup({
      console_timeout = 1000,
      auto_show_console_on = "output",
      preview_buffer = {
        kind = "floating",
      },
      floating = {
        relative = "editor",
        width = floating_width,
        height = floating_height,
        col = floating_col,
        row = floating_row,
        style = "minimal",
        border = "rounded",
      },
      disable_insert_on_commit = true,
      remember_settings = false,
      commit_editor = {
        kind = "split",
        staged_diff_split_kind = "auto",
      },
      integrations = {
        telescope = true,
        diffview = true,
      },
      mappings = {
        status = {
          ["<esc>"] = "Close",
          ["<C-c>"] = "Close",
          ["<c-s>"] = false,
          ["S"] = "StageAll",
        },
        popup = {
          ["Z"] = false,
          ["<c-s>"] = "StashPopup",
        },
      },
    })

    -- Hide Neogit's process preview once the commit editor opens.
    -- The underlying git process can remain active until the commit message is saved.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if
            vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].filetype == "NeogitConsole"
          then
            for _, win in ipairs(vim.fn.win_findbuf(buf)) do
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
      end,
    })

    -- Return to previous tab when Neogit tab is closed
    vim.api.nvim_create_autocmd("TabClosed", {
      callback = function()
        vim.schedule(function()
          if
            neogit_previous_tab
            and vim.api.nvim_tabpage_is_valid(neogit_previous_tab)
          then
            vim.api.nvim_set_current_tabpage(neogit_previous_tab)
            neogit_previous_tab = nil
          end
        end)
      end,
    })
  end,
}
