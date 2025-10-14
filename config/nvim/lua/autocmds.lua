-- Autoresize my windows when resizing the terminal
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		vim.cmd("wincmd =")
	end,
})

-- Create an augroup to keep things clean
local vimade_group = vim.api.nvim_create_augroup("VimadeAutoToggle", { clear = true })

-- Disable Vimade when Neovim loses focus
vim.api.nvim_create_autocmd("FocusLost", {
	group = vimade_group,
	callback = function()
		vim.cmd("VimadeFadeLevel 1")
		vim.cmd("VimadeRedraw")
	end,
})

-- Enable Vimade when Neovim gains focus
vim.api.nvim_create_autocmd("FocusGained", {
	group = vimade_group,
	callback = function()
		vim.cmd("VimadeFadeLevel 0.4")
	end,
})
