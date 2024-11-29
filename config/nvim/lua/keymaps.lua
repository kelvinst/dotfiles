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
	local line1 = vim.fn.line("'<")
	local line2 = vim.fn.line("'>")
	local lines = line1 == line2 and line1 or line1 .. "," .. line2

	local result = filename .. ":" .. lines
	vim.fn.setreg("*", result)
end

local function copyFilename()
	local filename = vim.fn.expand("%")
	print(filename)
	vim.fn.setreg("*", filename)
end

-- Copy file info to clipboard
vim.keymap.set("n", "<leader>cf", copyFilename, { desc = "[C]opy [f]ilename" })
vim.keymap.set("v", "<leader>cf", copyFilenameWithLines, { desc = "[C]opy [f]ilename (with selected lines)" })

-- Paste without cutting the current selection
vim.keymap.set("x", "π", [["_dP]]) -- Alt+p

vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "[R]eplace [w]ord" })
vim.keymap.set("n", "<leader>eq", vim.diagnostic.setqflist, { desc = "[E]errors [Q]uickfix" })
