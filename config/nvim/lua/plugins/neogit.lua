return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
  },
  keys = {
    {
      '<leader>gg',
      function()
        require('neogit').open { kind = 'floating' }
      end,
      desc = '[G]it Status (on root)',
    },
    {
      '<leader>g.',
      function()
        local function find_git_root(filepath)
          local function get_folder_from_filepath(fp)
            return fp:match '(.*/)'
          end

          filepath = get_folder_from_filepath(filepath)

          -- The Git command to find the top-level directory
          local git_cmd = 'git -C ' .. filepath .. ' rev-parse --show-toplevel'

          -- Execute the Git command
          local git_root = vim.fn.system(git_cmd)

          -- Handling errors (if the file is not in a Git repository or other issues)
          if vim.v.shell_error ~= 0 then
            return nil
          end

          -- Trim any newlines from the output
          git_root = git_root:gsub('%s+', '')

          return git_root
        end

        require('neogit').open { kind = 'floating', cwd = find_git_root(vim.fn.expand '%:p') }
      end,
      desc = '[G]it Status (on current submodule)',
    },
  },
  config = function()
    -- Configure which-key with the dispatch mappings
    require('which-key').add {
      { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
    }
  end,
}
