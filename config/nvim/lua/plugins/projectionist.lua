return {
  "tpope/vim-projectionist",
  event = "VimEnter",
  config = function()
    vim.g.projectionist_heuristics = {
      ["mix.exs"] = {
        ["*"] = {
          make = "mix test",
          dispatch = "mix test",
          start = "iex -S mix phx.server",
        },
        ["lib/*.ex"] = {
          type = "lib",
          alternate = "test/{}_test.exs",
        },
        ["test/*_test.exs"] = {
          type = "test",
          alternate = "lib/{}.ex",
          dispatch = "mix test {file}`=v:lnum ? ':'.v:lnum : ''`",
        },
        ["mix.exs"] = { type = "mix" },
        ["config/*.exs"] = { type = "config" },
      },
      ["react-native.config.js"] = {
        ["*"] = {
          make = "yarn test",
          dispatch = "yarn test",
          start = "yarn start",
        },
      },
    }

    require("which-key").add({
      { "<leader>fa", group = "Alternate" },
    })
  end,
  keys = {
    { "<leader>faa", ":A<CR>", desc = "In current window", silent = true },
    {
      "<leader>fas",
      ":AS<CR>",
      desc = "In a horizontal split",
      silent = true,
    },
    { "<leader>fav", ":AV<CR>", desc = "In a vertical split", silent = true },
  },
}
