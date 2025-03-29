return { -- Easily jump around in your file
	"smoka7/hop.nvim",
	version = "v2.7.2",
	config = function()
		local hop = require("hop")

		hop.setup({
			multi_windows = true,
			uppercase_labels = true,
			quit_key = "<leader>",
		})

		vim.keymap.set({ "n", "v" }, "f", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.AFTER_CURSOR,
				current_line_only = true,
			})
		end, { desc = "Hop for char (forward)" })

		vim.keymap.set({ "n", "v" }, "F", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
				current_line_only = true,
			})
		end, { desc = "Hop for char (backward)" })

		vim.keymap.set({ "n", "v" }, "t", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.AFTER_CURSOR,
				current_line_only = true,
				hint_offset = -1,
			})
		end, { desc = "Hop 'til char (forward)" })

		vim.keymap.set({ "n", "v" }, "T", function()
			hop.hint_char1({
				direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
				current_line_only = true,
				hint_offset = -1,
			})
		end, { desc = "Hop 'til char (backward)" })
	end,
}
