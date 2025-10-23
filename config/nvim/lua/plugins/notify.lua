return {
  -- Better looking notifications
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")

    notify.setup({
      render = "wrapped-compact",
      timeout = 300,
      max_width = 50,
      max_height = 10,
      merge_duplicates = true,
    })

    vim.notify = notify

    local telescope = require("telescope")
    telescope.load_extension("notify")

    vim.keymap.set(
      "n",
      "<leader>pn",
      telescope.extensions.notify.notify,
      { desc = "[N]otifications (nvim-notify)" }
    )
  end,
}
