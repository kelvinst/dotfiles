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

-- Keymaps for git commit workflow
local opts = { buffer = true, silent = true }

-- Commit
vim.keymap.set(
  "n",
  "<C-Enter>",
  "<cmd>wq<CR>",
  vim.tbl_extend("force", opts, { desc = "Commit" })
)
