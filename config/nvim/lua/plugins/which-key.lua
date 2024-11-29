return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		icons = {
			mappings = true, -- I have nerfont installed, so I want to use those icons
		},

		-- Existing keybindings
		spec = {
			{ "<leader>e", group = "[E]rror diagnostics" },
			{ "<leader>r", group = "[R]ename" },
		},

		triggers = {
			{ "<auto>", mode = "nxsoi" },
			{ "s" },
		},
	},
}
