return {
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = {
    "KittyScrollbackGenerateKittens",
    "KittyScrollbackCheckHealth",
    "KittyScrollbackGenerateCommandLineEditing",
  },
  event = { "User KittyScrollbackLaunch" },
  version = "*",
  config = function()
    require("kitty-scrollback").setup()
  end,
}
