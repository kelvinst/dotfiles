-- Git commit message settings
-- Optimize for writing conventional commit messages

-- Enable spell checking for commit messages
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- Set textwidth for automatic wrapping at 72 characters (common convention)
vim.opt_local.textwidth = 72

-- Wrap lines at word boundaries
vim.opt_local.linebreak = true

-- Show a visual guide at column 50 (subject line) and 72 (body wrap)
vim.opt_local.colorcolumn = "50,72"

-- Enable automatic formatting for text
vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth
vim.opt_local.formatoptions:append("c") -- Auto-wrap comments using textwidth
vim.opt_local.formatoptions:append("q") -- Allow formatting of comments with "gq"
vim.opt_local.formatoptions:append("j") -- Remove comment leader when joining lines

-- Autosave on each edit (TextChanged for normal mode, TextChangedI for insert mode)
local augroup =
  vim.api.nvim_create_augroup("GitCommitAutoSave", { clear = true })

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = augroup,
  buffer = 0,
  callback = function()
    if vim.bo.modified then
      vim.cmd("silent! write")
    end
  end,
  desc = "Auto-save git commit message on changes",
})

local function multi_keymap(mode, keys, command, options)
  for i, key in ipairs(keys) do
    vim.keymap.set(mode, key, command, options)
  end
end

-- Keymaps for git commit workflow
local opts = { buffer = true, silent = true }

-- Just quit
multi_keymap(
  "n",
  { "<cr>", "q", "<leader>q" },
  "<cmd>q<CR>",
  vim.tbl_extend("force", opts, { desc = "[Q]uit commit" })
)

-- Abort commit
multi_keymap(
  "n",
  { "Q", "<leader>Q" },
  "<cmd>cq<CR>",
  vim.tbl_extend("force", opts, { desc = "[A]bort commit" })
)
