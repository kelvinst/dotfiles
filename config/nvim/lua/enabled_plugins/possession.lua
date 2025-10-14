return {
	"gennaro-tedesco/nvim-possession",
	lazy = false,
	dependencies = {
		{
			"tiagovla/scope.nvim",
			lazy = false,
			config = true,
		},
		"ibhagwan/fzf-lua",
	},
	keys = {
		{
			"<leader>sl",
			function()
				require("nvim-possession").list()
			end,
			desc = "[L]ist sessions",
		},
		{
			"<leader>ss",
			function()
				require("nvim-possession").new()
			end,
			desc = "Create new [s]ession",
		},
		{
			"<leader>su",
			function()
				require("nvim-possession").update()
			end,
			desc = "[U]pdate current session",
		},
		{
			"<leader>sd",
			function()
				require("nvim-possession").delete()
			end,
			desc = "[D]elete selected session",
		},
	},
	config = function()
		if vim.env.KITTY_SCROLLBACK_NVIM ~= "true" then
			require("nvim-possession").setup({
				autosave = true,
				autoload = true,
				autoprompt = true,
				autoswitch = { enable = true, notify = true },
				save_hook = function()
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

					vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
				end,
				post_hook = function()
					vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
				end,
			})
		end
	end,
}
