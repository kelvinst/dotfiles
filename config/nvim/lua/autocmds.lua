-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Automatically format Elixir files on save (sometimes the LS doesn't format)
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	pattern = "*.ex,*.exs,*.eex,*.leex,*.sface,*.sface.ex,*.sface.exs",
-- 	group = vim.api.nvim_create_augroup("auto-format", { clear = true }),
-- 	callback = function()
-- 		vim.system({ "mix", "format", vim.fn.expand("%") }, { text = true }, function()
-- 			vim.schedule(function()
-- 				vim.cmd.checktime()
-- 			end)
-- 		end)
-- 	end,
-- })
