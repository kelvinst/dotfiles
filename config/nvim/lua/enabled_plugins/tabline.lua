return {
	"tiagovla/scope.nvim",
	config = true,
	init = function()
		require("scope").setup({})
		require("telescope").load_extension("scope")
	end,
}
