return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration

		-- Only one of these is needed.
		"nvim-telescope/telescope.nvim", -- optional
	},
	keys = {
		{ "<leader>gg", vim.cmd.Neogit, desc = "[G]it Status" },
		{ "<leader>ghc", ":Dispatch .git/hooks/pre-commit<CR>", desc = "pre-[c]ommit" },
	},
	config = function()
		-- Configure which-key with the dispatch mappings
		require("which-key").add({
			{ "<leader>g", group = "[G]it", mode = { "n", "v" } },
			{ "<leader>gh", group = "[H]ooks" },
		})

		require("neogit").setup({
			kind = "floating",
			commit_editor = {
				kind = "tab",
				staged_diff_split_kind = "auto",
			},
		})
	end,
}
