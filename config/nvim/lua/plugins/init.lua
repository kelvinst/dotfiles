-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }

  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup({
  require 'plugins.auto-session', -- Save and load session
  require 'plugins.cmp', -- Autocompletion
  require 'plugins.conform', -- Autoformat
  require 'plugins.copilot', -- Github Copilot suggestions AI
  require 'plugins.dispatch', -- Asynchronous tasks
  require 'plugins.gitsigns', -- Adds gitsigns recommend keymaps
  require 'plugins.indent_line', -- The vertical lines for indentation levels
  require 'plugins.mini', -- Collection of various small plugins/modules
  require 'plugins.neo-tree', -- Better file tree
  require 'plugins.neogit', -- Git UI in Neovim
  require 'plugins.projectionist', -- Project specific settings
  require 'plugins.sleuth', -- Detect tabstop and shiftwidth automatically
  require 'plugins.telescope', -- Fuzzy Finder (files, lsp, etc)
  require 'plugins.todo-comments', -- Highlight todo, notes, etc in comments
  require 'plugins.tokyonight', -- Colorscheme
  require 'plugins.treesitter', -- Highlight, edit, and navigate code
  require 'plugins.undotree', -- Better undo history
  require 'plugins.vim-tmux-navigator', -- Navigate between Vim and Tmux panes
  require 'plugins.which-key', -- Useful plugin to show you pending keybinds.
  -- require 'plugins.debug', -- Debugging
  -- require 'plugins.lint', -- Linting
  -- require 'plugins.autopairs', -- Autopairs

  -- LSP Plugins
  require 'plugins.lazydev', -- Lua LSP for your config, runtime and plugins
  require 'plugins.lspconfig', -- Main LSP Configuration
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
