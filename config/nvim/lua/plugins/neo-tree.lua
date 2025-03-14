-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
	-- If you want neo-tree's file operations to work with LSP (updating imports, etc.), you can use a plugin like
	-- https://github.com/antosha417/nvim-lsp-file-operations:
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim",
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			{ "3rd/image.nvim", opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
			{
				"s1n7ax/nvim-window-picker", -- for open_with_window_picker keymaps
				version = "2.*",
				config = function()
					require("window-picker").setup({
						filter_rules = {
							include_current_win = false,
							autoselect_one = true,
							-- filter using buffer options
							bo = {
								-- if the file type is one of following, the window will be ignored
								filetype = { "neo-tree", "neo-tree-popup", "notify" },
								-- if the buffer type is one of following, the window will be ignored
								buftype = { "terminal", "quickfix" },
							},
						},
					})
				end,
			},
		},
		keys = {
			{ "<leader>ft", ":Neotree toggle<CR>", desc = "[T]ree" },
			{ "<leader>fr", ":Neotree reveal<CR>", desc = "[R]eveal file in tree" },
		},
		config = function()
			require("which-key").add({
				{ "<leader>f", group = "[F]ile" },
			})
			-- If you want icons for diagnostic errors, you'll need to define them somewhere:
			vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

			require("neo-tree").setup({
				close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
				popup_border_style = "rounded",
				event_handlers = {
					{
						-- whenever a file is opened
						event = "file_opened",
						handler = function()
							-- auto close
							require("neo-tree.command").execute({ action = "close" })
							-- clear search
							require("neo-tree.sources.filesystem").reset_search()
						end,
					},
					{
						event = "neo_tree_window_after_open",
						handler = function()
							vim.cmd("wincmd =")
						end,
					},
					{
						event = "neo_tree_window_after_close",
						handler = function()
							vim.cmd("wincmd =")
						end,
					},
				},
				window = {
					auto_close = true,
					mappings = {
						["S"] = "split_with_window_picker",
						["s"] = "vsplit_with_window_picker",
						["Z"] = "expand_all_nodes",
					},
				},
				nesting_rules = {},
				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
					},
					hide_by_name = {
						".git",
					},
				},
			})
		end,
	},
}
