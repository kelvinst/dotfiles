return {
	-- Using AI to assist with coding
	"olimorris/codecompanion.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ravitemer/mcphub.nvim",
		"lalitmee/codecompanion-spinners.nvim",
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
				require("codecompanion").toggle({
					window_opts = { layout = "float", width = 80 },
				})
			end,
			desc = "[C]hat",
			mode = "n",
		},
		{
			"<leader>as",
			function()
				require("codecompanion").toggle({
					window_opts = { layout = "horizontal" },
				})
			end,
			desc = "Horizontal [S]plit Chat",
			mode = "n",
		},
		{
			"<leader>av",
			function()
				require("codecompanion").toggle({
					window_opts = { layout = "vertical" },
				})
			end,
			desc = "[V]ertical Split Chat",
			mode = "n",
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
					height = 25,
					width = 80,
				},
			},
		},
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_vars = true,
					make_slash_commands = true,
					show_result_in_chat = true,
				},
			},
			spinner = {
				enabled = true,
			},
		},
	},
}
