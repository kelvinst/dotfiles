local function copen()
  vim.cmd 'Copen!'
end

return { -- Asynchronous tasks
  'tpope/vim-dispatch',
  event = 'VimEnter',
  keys = {
    { 'mq', copen, desc = '[Q]uickfix' },
    { '`q', copen, desc = '[Q]uickfix' },
    { "'q", copen, desc = '[Q]uickfix' },
    { 'gq', copen, desc = '[Q]uickfix' },

    { '`<CR>', ':Dispatch<CR>', desc = ":'<,'>Dispatch<CR>", mode = 'v' },
    { '`<Space>', ':Dispatch ', desc = ":'<,'>Dispatch<CR>", mode = 'v' },
    { '`!', ':Dispatch!', desc = ":'<,'>Dispatch<CR>", mode = 'v' },
  },
  config = function()
    -- Set tmux and quickfix windows height
    vim.g.dispatch_quickfix_height = 20

    -- Configure which-key with the dispatch mappings
    require('which-key').add {
      { 'm', group = '[M]ake  Set [m]ark' },
      { 'm<CR>', desc = ':Make<CR>' },
      { 'm<Space>', desc = ':Make<Space>' },
      { 'm!', desc = ':Make!' },
      { 'm?', desc = "Show 'makeprg'" },

      { '`', group = 'Dispatch  Go to mark' },
      { '`<CR>', desc = ':Dispatch<CR>' },
      { '`<Space>', desc = ':Dispatch<Space>' },
      { '`!', desc = ':Dispatch!' },
      { '`?', desc = ':FocusDispatch<CR>' },

      { "'", group = 'Start  Go to marg' },
      { "'<CR>", desc = ':Start<CR>' },
      { "'<Space>", desc = ':Start<Space>' },
      { "'!", desc = ':Start!' },
      { "'?", desc = 'Show b:start' },

      { 'g', group = 'Spawn  [G]o to' },
      { "g'<CR>", desc = ':Spawn<CR>' },
      { "g'<Space>", desc = ':Spawn<Space>' },
      { "g'!", desc = ':Spawn!' },
      { "g'?", desc = "Show 'shell'" },
    }
  end,
}
