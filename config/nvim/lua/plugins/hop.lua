return { -- Easily jump around in your file
	"smoka7/hop.nvim",
	event = "VimEnter",
	version = "v2.7.2",
	keys = {
		{ "<leader><space>", vim.cmd.HopChar1, desc = "Hop to a char" },
		{ "<leader>h/", vim.cmd.HopPattern, desc = "Search like [/]" },
		{ "<leader>hC", vim.cmd.HopChar2, desc = "2 [C]har" },
		{ "<leader>ha", vim.cmd.HopAnywhere, desc = "[A]nywhere" },
		{ "<leader>hc", vim.cmd.HopChar1, desc = "1 [C]har)" },
		{ "<leader>hh", vim.cmd.HopChar1, desc = "Default (1 char)" },
		{ "<leader>hl", vim.cmd.HopLine, desc = "[L]ine" },
		{
			"<leader>hn",
			function()
				require("hop").hint_patterns({}, vim.fn.getreg("/"))
			end,
			desc = "[N]ext pattern (based on what was searched on /)",
		},
		{ "<leader>ht", vim.cmd.HopNodes, desc = "[T]reesiter nodes" },
		{ "<leader>hw", vim.cmd.HopWord, desc = "[W]ord" },
	},
	config = function()
		local hop = require("hop")

		hop.setup({
			multi_windows = true,
			uppercase_labels = true,
			quit_key = "<leader>",
		})

		local modes = { "n", "v" }

		vim.keymap.set(modes, "f", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.AFTER_CURSOR,
				current_line_only = true,
			})
		end, { desc = "Hop [f]or char (forward)" })

		vim.keymap.set(modes, "F", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
				current_line_only = true,
			})
		end, { desc = "Hop [f]or char (backward)" })

		vim.keymap.set(modes, "t", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.AFTER_CURSOR,
				current_line_only = true,
				hint_offset = -1,
			})
		end, { desc = "Hop '[t]il char (forward)" })

		vim.keymap.set(modes, "T", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
				current_line_only = true,
				hint_offset = -1,
			})
		end, { desc = "Hop '[t]il char (backward)" })
	end,
}
