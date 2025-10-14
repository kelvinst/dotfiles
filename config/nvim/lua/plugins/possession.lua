local function session_file(session_name)
	local dir = vim.fn.stdpath("data") .. "/tabnames"
	vim.fn.mkdir(dir, "p")
	return string.format("%s/%s.json", dir, session_name or "default")
end

local function save_tab_names(session_name)
	local names = {}
	-- Order matters: index 1..N corresponds to tabpage #1..#N
	for i = 1, #vim.api.nvim_list_tabpages() do
		names[i] = vim.t[i] and vim.t[i].name or nil
	end
	local ok, json = pcall(vim.json.encode, names)
	if ok then
		vim.fn.writefile({ json }, session_file(session_name))
	end
end

local function restore_tab_names(session_name)
	local file = session_file(session_name)
	if vim.fn.filereadable(file) == 0 then
		return
	end
	local lines = vim.fn.readfile(file)
	if not lines or not lines[1] then
		return
	end
	local ok, names = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok or type(names) ~= "table" then
		return
	end
	for i, name in ipairs(names) do
		if type(name) == "string" and name ~= "" then
			-- Bufferline reads this: :BufferLineTabRename sets the same var
			vim.t[i] = vim.t[i] or {}
			vim.t[i].name = name
		end
	end
end

return {
	"gennaro-tedesco/nvim-possession",
	lazy = false,
	dependencies = {
		{
			"tiagovla/scope.nvim",
			lazy = false,
			config = true,
		},
		"ibhagwan/fzf-lua",
	},
	keys = {
		{
			"<leader>sl",
			function()
				require("nvim-possession").list()
			end,
			desc = "[L]ist sessions",
		},
		{
			"<leader>ss",
			function()
				require("nvim-possession").new()
			end,
			desc = "Create new [s]ession",
		},
		{
			"<leader>su",
			function()
				require("nvim-possession").update()
			end,
			desc = "[U]pdate current session",
		},
		{
			"<leader>sd",
			function()
				require("nvim-possession").delete()
			end,
			desc = "[D]elete selected session",
		},
	},
	config = function()
		if vim.env.KITTY_SCROLLBACK_NVIM ~= "true" then
			require("nvim-possession").setup({
				autosave = true,
				autoload = true,
				autoprompt = true,
				autoswitch = { enable = true, notify = true },
				save_hook = function(session_name)
					ClearInvisibleBuffers()
					vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
					save_tab_names(session_name)
				end,
				post_hook = function(session_name)
					vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
					restore_tab_names(session_name)
				end,
			})
		end
	end,
}
