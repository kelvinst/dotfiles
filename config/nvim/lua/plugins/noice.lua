return {
  -- Better looking messagse and cmdline
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "hrsh7th/nvim-cmp",
  },
  keys = {
    {
      "<leader>nh",
      CmdFn("Noice history"),
      desc = "[H]istory",
    },
    {
      "<leader>nl",
      CmdFn("Noice last"),
      desc = "[L]ast",
    },
    {
      "<leader>na",
      CmdFn("Noice all"),
      desc = "[A]ll",
    },
    {
      "<leader>ne",
      CmdFn("Noice errors"),
      desc = "[E]rrors",
    },
    {
      "<S-Enter>",
      function()
        require("noice").redirect(vim.fn.getcmdline())
      end,
      desc = "Redirect CmdLine",
      mode = "c",
    },
  },
  opts = {
    cmdline = {
      format = {
        lua = {
          pattern = { "^:%s*lua%s+", "^:%s*=%s*" },
        },
      },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
  config = function(_, opts)
    local noice = require("noice")
    noice.setup(opts)

    local telescope = require("telescope")
    telescope.load_extension("noice")

    vim.keymap.set(
      "n",
      "<leader>np",
      telescope.extensions.noice.noice,
      { desc = "[P]ick" }
    )
  end,
}
