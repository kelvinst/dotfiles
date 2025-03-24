return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		preset = "helix",

		win = {
			no_overlap = false,
			width = 60,
			col = vim.fn.winwidth(0) / 2 - 30,
			row = 12,
		},

		icons = {
			mappings = true, -- I have nerfont installed, so I want to use those icons
		},

		-- Existing keybindings
		spec = {
			{ "<leader>a", group = "[A]lternate" },
			{ "<leader>c", group = "[C]opy", mode = "nv" },
			{ "<leader>e", group = "[E]rror diagnostics" },
			{ "<leader>r", group = "[R]ename" },
		},

		triggers = {
			{ "<auto>", mode = "nxsoi" },
			{ "s" },
		},
	},
}
