-- NOTE: General Settings

-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set up shell so it does load the functions from .zshenv too
vim.opt.shell = "zsh -i"

-- NOTE: UI Settings

-- Hide line numbers
vim.opt.number = false
vim.opt.relativenumber = false

-- Do not wrap lines
vim.opt.wrap = false

-- Good colors
vim.opt.termguicolors = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Use OS clipboard
vim.opt.clipboard = "unnamedplus"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Always show tabs
vim.opt.showtabline = 2

-- Enable break indent
vim.opt.breakindent = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- NOTE: File and Backup Settings

-- Do not save backup/swap files
vim.opt.backup = false
vim.opt.swapfile = false

-- Save undo history
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- NOTE: Editing Behavior

-- Tab/indent settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Automatically read the file if it changes
vim.opt.autoread = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- NOTE: Searching

-- Case-insensitive searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- NOTE: Formatting

-- Show a colored line on the limit
vim.opt.colorcolumn = "100"
