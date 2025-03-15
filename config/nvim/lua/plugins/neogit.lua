return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
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
			console_timeout = 1000,
			disable_insert_on_commit = true,
			kind = "floating",
			remember_settings = false,
			commit_editor = {
				kind = "tab",
				staged_diff_split_kind = "auto",
			},
			integrations = {
				telescope = true,
				diffview = true,
			},
		})
	end,
}
