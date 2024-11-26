return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    require('mini.surround').setup()

    -- Configure which-key with the dispatch mappings
    require('which-key').add {
      { 's', group = '[S]urround' },
    }

    -- Simple and easy statusline.
    local statusline = require 'mini.statusline'
    -- Set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- Disable 's' default behavior
    vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
  end,
}
