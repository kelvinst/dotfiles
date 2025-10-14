function ClearInvisibleBuffers()
	-- Get visible buffers
	local visible_buffers = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		visible_buffers[vim.api.nvim_win_get_buf(win)] = true
	end

	local buflist = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(buflist) do
		-- Delete buffer if not visible
		if visible_buffers[bufnr] == nil then
			pcall(vim.cmd.bd, bufnr)
		end
	end
end
