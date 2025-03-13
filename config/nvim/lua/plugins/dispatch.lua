local function quickfix()
	vim.cmd("Copen!")
end

local function dispatchTask(key, task, commandFun)
	if type(task) == "table" and task[1] then
		local baseCommand = type(commandFun) == "function" and commandFun(task[1]) or task[1]

		if not baseCommand then
			return
		end

		local dispatchCommand = ":Dispatch " .. baseCommand
		local command = task.wait and dispatchCommand .. " " or dispatchCommand .. "<CR>"
		local taskDesc = task.desc and task.desc .. " (" .. baseCommand .. ")" or nil

		vim.keymap.set("n", key, command, { desc = taskDesc })
	end
end

local function dispatchTasks(prefix, key, desc, default, tasks, parentTasks)
	local tasksPrefix = prefix .. key
	if tasks then
		if desc then
			require("which-key").add({ { tasksPrefix, group = desc } })
		end

		-- Set mappings for tasks
		if type(tasks) == "table" then
			for taskKey, taskConfig in pairs(tasks) do
				dispatchTask(tasksPrefix .. taskKey, taskConfig)
			end

			-- Set the default mapping if applicable
			if default and tasks[default] then
				local default_cmd = tasks[default][1]
				vim.keymap.set(
					"n",
					tasksPrefix .. key,
					":Dispatch " .. default_cmd .. "<CR>",
					{ desc = "Default (" .. default_cmd .. ")" }
				)
			end
		elseif type(tasks) == "function" then
			for taskKey, taskConfig in pairs(parentTasks) do
				dispatchTask(tasksPrefix .. taskKey, taskConfig, tasks)
			end
		end
	end
end

local function dispatchSubgroup(prefix, key, subgroup, parentTasks)
	if type(subgroup) == "table" then
		local tasks = subgroup.tasks
		dispatchTasks(prefix, key, subgroup.desc, subgroup.default, tasks, parentTasks)
		subgroup.desc = nil
		subgroup.default = nil
		subgroup.tasks = nil

		for subgroupKey, subgroupConfig in pairs(subgroup) do
			dispatchSubgroup(prefix .. key, subgroupKey, subgroupConfig, tasks)
		end
	end
end

-- Defines a group of dispatch commands
local function dispatchGroup(config)
	local function fileExists(pattern)
		local root_dir = vim.fn.getcwd()
		local files = vim.fn.glob(root_dir .. "/" .. pattern, true, true)
		return #files > 0
	end

	-- Get the root config and remove it from the table
	local filterByRootFiles = config.filterByRootFiles
	config.filterByRootFiles = nil
	local prefix = config.key
	config.key = nil
	local desc = config.desc
	config.desc = nil

	if filterByRootFiles and not fileExists(filterByRootFiles) then
		return
	end

	local whichkey = require("which-key")
	whichkey.add({ { prefix, group = desc } })

	for subgroupKey, subgroup in pairs(config) do
		dispatchSubgroup(prefix, subgroupKey, subgroup, {})
	end
end

return { -- Asynchronous tasks
	"tpope/vim-dispatch",
	event = "VimEnter",
	keys = {
		{ "mq", quickfix, desc = "[Q]uickfix (from Make)" },
		{ "`q", quickfix, desc = "[Q]uickfix (from Dispatch)" },
		{ "`<Up>", ":Dispatch<Up><CR>", desc = "Repeat previous dispatch" },

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
		vim.g.dispatch_compilers = { elixir = "exunit" }

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

		-- Define a dispatch group for Elixir projects
		dispatchGroup({
			key = "<leader>m",
			desc = "[M]ix tasks",
			filterByRootFiles = "mix.exs",
			c = {
				desc = "[C]ompile",
				default = "d",
				tasks = {
					d = { "mix compile", desc = "[D]ev" },
					t = { "MIX_ENV=test mix compile", desc = "[T]est" },
				},
				w = {
					desc = "[W]arnings as errors",
					default = "d",
					tasks = function(groupTask)
						return groupTask .. " --warnings-as-errors"
					end,
				},
			},
			d = {
				desc = "[D]eps",
				default = "g",
				tasks = {
					g = { "mix deps.get", desc = "[G]et" },
					a = { "mix deps.audit", desc = "[A]udit" },
					u = { "mix deps.unlock --check-unused", desc = "Check [u]nused" },
					r = { "mix hex.audit", desc = "Check [r]etired" },
					o = { "mix hex.outdated", desc = "Check [o]utdated" },
				},
			},
			e = {
				desc = "[E]cto",
				default = "<Up>",
				tasks = {
					["<Up>"] = { "mix ecto.migrate", desc = "[Up]" },
					["<Down>"] = { "mix ecto.rollback", desc = "[Down]" },
					d = { "mix ecto.drop", desc = "[D]rop" },
					c = { "mix ecto.create", desc = "[C]create" },
					s = { "mix ecto.setup", desc = "[S]etup" },
					r = { "mix ecto.reset", desc = "[R]eset" },
					l = { "mix ecto.load", desc = "[L]oad" },
					i = { "mix run priv/repo/seeds.exs", desc = "[I]nsert seeds" },
					g = { "mix ecto.gen.migration", desc = "[G]enerate migration", wait = true },
				},
				t = {
					desc = "[T]est",
					default = "a",
					tasks = function(groupTask)
						if groupTask == "mix ecto.gen.migration" then
							return nil
						end

						return "MIX_ENV=test " .. groupTask
					end,
				},
			},
			f = {
				desc = "[F]ormat",
				default = "a",
				tasks = {
					a = { "mix format", desc = "[A]ll files" },
					c = { "mix format %", desc = "[C]urrent file" },
				},
			},
			h = {
				desc = "[H]elp (docs)",
				default = "r",
				tasks = {
					r = { "mix doctor", desc = "Docto[r]" },
					w = { "mix docs --warnings-as-errors", desc = "Check [w]arnings" },
				},
			},
			l = {
				desc = "[L]inters",
				default = "c",
				tasks = {
					c = { "mix credo", desc = "[C]ode" },
					s = { "mix sobelow --config", desc = "[S]ecurity" },
					t = { "mix dialyzer", desc = "[T]ypes" },
				},
			},
			t = {
				desc = "[T]est",
				default = "h",
				tasks = {
					a = { "mix test", desc = "[A]ll" },
					c = { "mix coveralls", desc = "[C]overage" },
					h = { "mix coveralls.html", desc = "[H]TML coverage" },
				},
				w = {
					desc = "[W]arnings as errors",
					default = "h",
					tasks = function(groupTask)
						return groupTask .. " --warnings-as-errors"
					end,
				},
			},
		})
	end,
}
