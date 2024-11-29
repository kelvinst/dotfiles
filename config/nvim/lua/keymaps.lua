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

-- Paste without cutting the current selection
vim.keymap.set("x", "π", [["_dP]]) -- Alt+p

-- Copy/cut to system cllipboard
vim.keymap.set({ "n", "v" }, "¥", [["+y]]) -- Alt+y
vim.keymap.set("n", "Á", [["+Y]]) -- Alt+Shift+y
vim.keymap.set({ "n", "v" }, "∂", '"_d') -- Alt+d

vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "[R]eplace [w]ord" })
vim.keymap.set("n", "<leader>eq", vim.diagnostic.setqflist, { desc = "[E]errors [Q]uickfix" })
