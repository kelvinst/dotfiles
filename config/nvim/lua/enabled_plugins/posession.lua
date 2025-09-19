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
		require("nvim-possession").setup({
			autosave = true,
			autoload = true,
			autoprompt = true,
			autoswitch = {
				enable = true,
			},
			save_hook = function()
				vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
			end,
			post_hook = function()
				vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
			end,
		})
	end,
}
