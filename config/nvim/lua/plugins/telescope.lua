return { -- Fuzzy Finder (files, lsp, etc)
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = true },
	},
	config = function()
		local telescope = require("telescope")
		local themes = require("telescope.themes")
		telescope.setup({
			extensions = {
				["ui-select"] = {
					themes.get_dropdown(),
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")
		pcall(telescope.load_extension, "notify")

		-- Configure which-key with the telescope mappings
		require("which-key").add({
			{ "<leader>p", group = "[P]ick" },
		})

		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>pp", builtin.builtin, { desc = "[P]ickers" })
		vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "[H]elp" })
		vim.keymap.set("n", "<leader>pk", builtin.keymaps, { desc = "[K]eymaps" })
		vim.keymap.set("n", "<leader>pn", telescope.extensions.notify.notify, { desc = "[N]otifications" })
		vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "[G]rep" })
		vim.keymap.set("n", "<leader>pr", builtin.resume, { desc = "[R]esume" })
		vim.keymap.set("n", "<leader>pb", builtin.buffers, { desc = "[B]uffers" })
		vim.keymap.set("n", "<leader>pf", function()
			builtin.git_files({
				git_command = {
					"git",
					"ls-files",
					"--exclude-standard",
					"--cached",
					"--others",
				},
			})
		end, {
			desc = "[F]iles (from git)",
		})
		vim.keymap.set("n", "<leader>pF", function()
			builtin.find_files({
				hidden = true,
				no_ignore = true,
				no_ignore_parent = true,
			})
		end, {
			desc = "[F]iles (all)",
		})
		vim.keymap.set("n", "<leader>po", builtin.oldfiles, {
			desc = "[O]ld files",
		})
		vim.keymap.set("n", "<leader>pd", builtin.diagnostics, {
			desc = "[D]iagnostics",
		})
		vim.keymap.set("n", "<leader>pw", builtin.grep_string, {
			desc = "Grep current [w]ord",
		})

		vim.keymap.set("n", "<leader>p/", function()
			builtin.current_buffer_fuzzy_find(themes.get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzy search current file" })
	end,
}
