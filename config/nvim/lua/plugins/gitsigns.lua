-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Jump to next git change" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Jump to previous git change" })

        -- Actions
        -- visual mode
        map("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "stage git hunk" })
        map("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "reset git hunk" })

        -- normal mode
        map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
        map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
        map(
          "n",
          "<leader>gS",
          gitsigns.stage_buffer,
          { desc = "Git Stage buffer" }
        )
        map(
          "n",
          "<leader>gu",
          gitsigns.undo_stage_hunk,
          { desc = "Git undo stage hunk" }
        )
        map(
          "n",
          "<leader>gR",
          gitsigns.reset_buffer,
          { desc = "Git Reset buffer" }
        )
        map(
          "n",
          "<leader>gp",
          gitsigns.preview_hunk,
          { desc = "Git preview hunk" }
        )
        map("n", "<leader>gb", gitsigns.blame_line, { desc = "Git blame line" })
        map(
          "n",
          "<leader>gd",
          gitsigns.diffthis,
          { desc = "Git diff against index" }
        )
        map("n", "<leader>gD", function()
          gitsigns.diffthis("@")
        end, { desc = "Git Diff against last commit" })

        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, {
          desc = "Toggle git show blame line",
        })
        map(
          "n",
          "<leader>tD",
          gitsigns.toggle_deleted,
          { desc = "Toggle git show Deleted" }
        )
      end,
    },
  },
}
