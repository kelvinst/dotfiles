return {
	"christoomey/vim-tmux-navigator",
	cond = (vim.env.TMUX ~= nil),
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},
	keys = {
		{
			"<c-h>",
			"<cmd><C-U>TmuxNavigateLeft<cr>",
			desc = "Go to the left window",
		},
		{
			"<c-j>",
			"<cmd><C-U>TmuxNavigateDown<cr>",
			desc = "Go to the down window",
		},
		{
			"<c-k>",
			"<cmd><C-U>TmuxNavigateUp<cr>",
			desc = "Go to the up window",
		},
		{
			"<c-l>",
			"<cmd><C-U>TmuxNavigateRight<cr>",
			desc = "Go to the right window",
		},
		{
			"<c-\\>",
			"<cmd><C-U>TmuxNavigatePrevious<cr>",
			desc = "Go to previous window",
		},
	},
}
