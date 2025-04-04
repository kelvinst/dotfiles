-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Do not move cursor when merging lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor centered when scrolling/searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

local function copyFilenameWithLines()
	local filename = vim.fn.expand("%")
	local line = vim.fn.line(".")
	local currentLine = filename .. ":" .. line
	vim.fn.setreg("*", currentLine)
	vim.api.nvim_input("<Esc>")
	print("Copied to clipboard: " .. currentLine)
end

local function copyFilename()
	local filename = vim.fn.expand("%")
	vim.fn.setreg("*", filename)
	print("Copied to clipboard: " .. filename)
end

-- Copy file info to clipboard
vim.keymap.set("n", "<leader>yf", copyFilename, { desc = "[Y]ank [f]ilename" })
vim.keymap.set("n", "<leader>yl", copyFilenameWithLines, { desc = "[Y]ank filename and [l]ine" })

-- Paste without cutting the current selection
vim.keymap.set("x", "π", [["_dP]]) -- Alt+p

-- Replace word under cursor
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "[R]eplace [w]ord" })

-- Load the LSP errors to the quickfix list
vim.keymap.set("n", "<leader>eq", vim.diagnostic.setqflist, { desc = "[E]errors [Q]uickfix" })
