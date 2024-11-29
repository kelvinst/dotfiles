local function quickfix()
	vim.cmd("Copen!")
end

return { -- Asynchronous tasks
	"tpope/vim-dispatch",
	event = "VimEnter",
	keys = {
		{ "mq", quickfix, desc = "[Q]uickfix (from Make)" },
		{ "`q", quickfix, desc = "[Q]uickfix (from Dispatch)" },

		-- Open zsh in Dispatch (like Spawn does for Start, hence the "g`" mnemonics)
		{ "g`<CR>", ":Dispatch zsh<CR>", desc = "Dispatch [z]sh" },
		{ "g`<Space>", ":Dispatch zsh ", desc = "Dispatch [z]sh <type here>" },
		{ "g`!", ":Dispatch! zsh", desc = "Dispatch [z]sh <type here> (background)" },

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
