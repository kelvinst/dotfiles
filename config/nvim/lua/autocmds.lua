-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- NOTE: This causes some "Buffer not found" errors when opening files from
-- the quickfix list. I'm not sure why, but I'm disabling it for now.
--
-- Close old buffers
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	callback = function()
-- 		vim.schedule(function()
-- 			local buffers = vim.api.nvim_list_bufs()
--
-- 			-- Sort buffers by last used (most recent first)
-- 			table.sort(buffers, function(a, b)
-- 				return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
-- 			end)
--
-- 			-- Keep only the 20 most recent buffers
-- 			for i = 21, #buffers do
-- 				vim.api.nvim_buf_delete(buffers[i], { force = true })
-- 			end
-- 		end)
-- 	end,
-- })
