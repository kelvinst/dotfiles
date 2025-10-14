return {
	-- Using AI to assist with coding
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ravitemer/mcphub.nvim",
	},
	keys = {
		{
			"<leader>ac",
			function()
				vim.cmd.CodeCompanionChat("Toggle")
			end,
			desc = "[C]hat",
		},
		{
			"<leader>ag",
			function()
				vim.cmd.CodeCompanion("/commit")
			end,
			desc = "[G]it commit message",
		},
	},
	opts = {},
}
