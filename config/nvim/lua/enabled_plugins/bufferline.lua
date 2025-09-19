return {
	"akinsho/bufferline.nvim",
	event = "VimEnter",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	keys = {
		{ "gb", vim.cmd.BufferLineCycleNext, desc = "Go to next buffer" },
		{ "gB", vim.cmd.BufferLineCyclePrev, desc = "Go to previous buffer" },
		{ "ZB", ":w | bd", desc = "Go to previous buffer" },
	},
	config = true,
}
