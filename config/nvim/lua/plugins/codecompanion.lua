return {
	-- Using AI to assist with coding
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ravitemer/mcphub.nvim",
	},
	keys = {
		{
			"<leader>aa",
			vim.cmd.CodeCompanionActions,
			desc = "[A]ctions",
			mode = { "n", "v" },
		},
		{
			"<leader>a<space>",
			":CodeCompanionChat ",
			desc = "Chat prompt",
			mode = { "n", "v" },
		},
		{
			"<leader>ac",
			vim.cmd.CodeCompanionChat,
			desc = "[C]hat",
			mode = "v",
		},
		{
			"<leader>ac",
			function()
				vim.cmd.CodeCompanionChat("Toggle")
			end,
			desc = "[C]hat",
			mode = "n",
		},
		{
			"<leader>ag",
			function()
				vim.cmd.CodeCompanionChat("commit")
			end,
			desc = "[G]it commit",
		},
		{
			"<leader>af",
			function()
				vim.cmd.CodeCompanion("/fix")
			end,
			desc = "[F]ix code",
			mode = { "n", "v" },
		},
	},
	opts = {
		strategies = {
			chat = { adapter = "claude_code" },
		},
		adapters = {
			acp = {
				claude_code = function()
					return require("codecompanion.adapters").extend("claude_code", {})
				end,
			},
		},
		display = {
			chat = {
				window = {
					layout = "float",
					width = 80,
				},
			},

			diff = {
				provider = "mini_diff",
			},
		},
	},
}
