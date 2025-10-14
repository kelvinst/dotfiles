return {
	"akinsho/bufferline.nvim",
	event = "VimEnter",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	keys = {
		{ "gb", vim.cmd.BufferLineCycleNext, desc = "Go to next buffer" },
		{ "gB", vim.cmd.BufferLineCyclePrev, desc = "Go to previous buffer" },
		{ "ZB", ":bd<cr>", desc = "Delete current [b]uffer" },
		{ "<leader>bp", vim.cmd.BufferLinePick, desc = "[P]ick" },
		{ "<leader>bm", vim.cmd.BufferLineCycleNext, desc = "[M]ove" },
		{ "<leader>bd", vim.cmd.bd, desc = "[D]elete" },
		{ "<leader>bo", vim.cmd.BufferLineCloseOthers, desc = "[D]elete All" },
		{ "<leader>br", ":BufferLineTabRename ", desc = "[R]ename tab" },
	},
	config = function()
		require("which-key").add({
			{ "<leader>b", group = "[B]uffers" },
			{ "<leader>bt", group = "[T]abs" },
		})

		local bufferline = require("bufferline")
		bufferline.setup({})
	end,
}
