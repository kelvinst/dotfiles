local function copen()
	vim.cmd("Copen!")
end

local function zsh(command)
	return function()
		vim.cmd(command .. " zsh")
	end
end

return { -- Asynchronous tasks
	"tpope/vim-dispatch",
	event = "VimEnter",
	keys = {
		{ "mq", copen, desc = "[Q]uickfix" },
		{ "`q", copen, desc = "[Q]uickfix" },

		-- Open zsh in Dispatch/Start
		{ "`z<CR>", zsh("Dispatch"), desc = "Dispatch [z]sh" },
		{ "`z<Space>", ":Dispatch zsh ", desc = "Dispatch [z]sh <type here>" },
		{ "`z!", ":Dispatch! zsh", desc = "Dispatch [z]sh <type here> (background)" },
		{ "'z<CR>", zsh("Start"), desc = "Start [z]sh" },
		{ "'z<Space>", ":Start zsh ", desc = "Start [z]sh <type here>" },
		{ "'z!", ":Start! zsh", desc = "Start [z]sh <type here> (backgroud)" },

		-- Use selected text on visual mode
		{ "m<CR>", ":Make<CR>", desc = "[M]ake (selected text)", mode = "v" },
		{ "m<Space>", ":Make ", desc = "[M]ake <type here> (selected text)", mode = "v" },
		{ "m!", ":Make!", desc = "[M]ake <type here> (selected text) (background)", mode = "v" },
		{ "`<CR>", ":Dispatch<CR>", desc = "Dispatch (selected text)", mode = "v" },
		{ "`<Space>", ":Dispatch ", desc = "Dispatch <type here> (selected text)", mode = "v" },
		{ "`!", ":Dispatch!", desc = "Dispatch <type here> (selected text) (background)", mode = "v" },
	},
	config = function()
		-- Set tmux and quickfix windows height
		vim.g.dispatch_quickfix_height = 20

		-- Configure which-key with the dispatch mappings
		require("which-key").add({
			{ "m", group = "[M]ake / Set [m]ark" },
			{ "m<CR>", desc = "Make" },
			{ "m<Space>", desc = "Make <type here>" },
			{ "m!", desc = "Make <type here> (background)" },
			{ "m?", desc = "Show 'makeprg'" },

			{ "`", group = "Dispatch / Go to mark" },
			{ "`z", group = "Dispatch [z]sh..." },
			{ "`<CR>", desc = "Dispatch" },
			{ "`<Space>", desc = "Dispatch <type here>" },
			{ "`!", desc = "Dispatch <type here> (background)" },
			{ "`?", desc = "Show default Dispatch" },

			{ "'", group = "Start / Go to mark" },
			{ "'z", group = "Start [z]sh..." },
			{ "'<CR>", desc = "Start" },
			{ "'<Space>", desc = "Start <type here>" },
			{ "'!", desc = "Start <type here> (background)" },
			{ "'?", desc = "Show default Start" },

			{ "g", group = "Spawn / [G]o to" },
			{ "g'z", group = "Spawn [z]sh..." },
			{ "g'<CR>", desc = "Spawn" },
			{ "g'<Space>", desc = "Spawn <type here>" },
			{ "g'!", desc = "Spawn <type here> (background)" },
			{ "g'?", desc = "Show 'shell'" },
		})
	end,
}
