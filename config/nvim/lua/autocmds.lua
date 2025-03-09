-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Close old buffers
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.schedule(function()
			local buffers = vim.api.nvim_list_bufs()

			-- Sort buffers by last used (most recent first)
			table.sort(buffers, function(a, b)
				return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
			end)

			-- Keep only the 20 most recent buffers
			for i = 21, #buffers do
				vim.api.nvim_buf_delete(buffers[i], { force = true })
			end
		end)
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
