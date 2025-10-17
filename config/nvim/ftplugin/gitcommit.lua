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

local function multi_keymap(mode, keys, command, options)
  for i, key in ipairs(keys) do
    vim.keymap.set(mode, key, command, options)
  end
end

-- Keymaps for git commit workflow
local opts = { buffer = true, silent = true }

-- Commit
multi_keymap(
  "n",
  { "<cr>", "<leader><cr>" },
  "<cmd>wq<CR>",
  vim.tbl_extend("force", opts, { desc = "Commit" })
)

-- Abort commit
multi_keymap(
  "n",
  { "q", "<leader>q" },
  "<cmd>cq<CR>",
  vim.tbl_extend("force", opts, { desc = "[A]bort" })
)
