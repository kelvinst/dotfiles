return {
	"akinsho/bufferline.nvim",
	event = "VimEnter",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	keys = {
		{ "gb", vim.cmd.BufferLineCycleNext, desc = "Go to next buffer" },
		{ "gB", vim.cmd.BufferLineCyclePrev, desc = "Go to previous buffer" },
		{ "ZB", ":w | bd<cr>", desc = "Delete current [b]uffer" },
		{ "<leader>bm", vim.cmd.BufferLineCycleNext, desc = "[M]ove" },
		{ "<leader>btr", ":BufferLineTabRename ", desc = "[R]ename" },
	},
	config = function()
		require("which-key").add({
			{ "<leader>b", group = "[B]uffers" },
			{ "<leader>bt", group = "[T]abs" },
		})

		require("bufferline").setup({})
	end,
}
