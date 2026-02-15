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

    require("neogit").setup({
      console_timeout = 1000,
      auto_show_console_on = "output",
      preview_buffer = {
        kind = "floating",
      },
      floating = {
        relative = "editor",
        width = 0.5,
        height = 0.18,
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
