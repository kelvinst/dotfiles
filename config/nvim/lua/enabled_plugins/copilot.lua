return { -- Github Copilot suggestions AI
	"github/copilot.vim",
	init = function()
		vim.keymap.set("i", "<Right>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Accept Copilot suggestion",
		})

		vim.keymap.set("i", "<Down>", "<Plug>(copilot-next)", {
			desc = "Next Copilot suggestion",
		})

		vim.keymap.set("i", "<Up>", "<Plug>(copilot-previous)", {
			desc = "Previous Copilot suggestion",
		})

		vim.g.copilot_no_tab_map = true
	end,
}
