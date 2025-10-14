return {
	"tiagovla/scope.nvim",
	config = function()
		require("scope").setup({})

		local telescope = require("telescope")
		telescope.load_extension("scope")
		vim.keymap.set("n", "<leader>pb", telescope.extensions.scope.buffers, { desc = "[B]uffers" })
	end,
}
