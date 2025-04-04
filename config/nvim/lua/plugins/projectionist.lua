return {
	"tpope/vim-projectionist",
	event = "VimEnter",
	config = function()
		vim.g.projectionist_heuristics = {
			["mix.exs"] = {
				["*"] = {
					make = "mix test",
					dispatch = "mix test",
					start = "iex -S mix phx.server",
				},
				["lib/*.ex"] = {
					type = "lib",
					alternate = "test/{}_test.exs",
				},
				["test/*_test.exs"] = {
					type = "test",
					alternate = "lib/{}.ex",
					dispatch = "mix test {file}`=v:lnum ? ':'.v:lnum : ''`",
				},
				["mix.exs"] = { type = "mix" },
				["config/*.exs"] = { type = "config" },
			},
			["react-native.config.js"] = {
				["*"] = {
					make = "yarn test",
					dispatch = "yarn test",
					start = "yarn start",
				},
			},
		}
	end,
	keys = {
		{ "<leader>aa", ":A<CR>", desc = "In current window", silent = true },
		{ "<leader>as", ":AS<CR>", desc = "In a horizontal [s]plit", silent = true },
		{ "<leader>av", ":AV<CR>", desc = "In a [v]ertical split", silent = true },
	},
}
