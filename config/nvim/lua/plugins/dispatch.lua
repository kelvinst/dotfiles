local function quickfix()
  vim.cmd("Copen!")
end

local function dispatchTask(key, task, commandFun, vimCommand)
  if type(task) == "table" and task[1] then
    local baseCommand = type(commandFun) == "function" and commandFun(task[1])
      or task[1]

    if not baseCommand then
      return
    end

    local dispatchCommand = ":" .. vimCommand .. " " .. baseCommand
    local command = task.wait and dispatchCommand .. " "
      or dispatchCommand .. "<CR>"
    local taskDesc = task.desc and task.desc .. " (" .. baseCommand .. ")"
      or nil

    vim.keymap.set("n", key, command, { desc = taskDesc })
  end
end

local function dispatchTasks(prefix, key, desc, default, tasks, parentTasks, vimCommand)
  local tasksPrefix = prefix .. key
  if tasks then
    if desc then
      require("which-key").add({ { tasksPrefix, group = desc } })
    end

    -- Set mappings for tasks
    if type(tasks) == "table" then
      for taskKey, taskConfig in pairs(tasks) do
        dispatchTask(tasksPrefix .. taskKey, taskConfig, nil, vimCommand)
      end

      -- Set the default mapping if applicable
      if default and tasks[default] then
        local default_cmd = tasks[default][1]
        vim.keymap.set(
          "n",
          tasksPrefix .. key,
          ":" .. vimCommand .. " " .. default_cmd .. "<CR>",
          { desc = "Default (" .. default_cmd .. ")" }
        )
      end
    elseif type(tasks) == "function" then
      for taskKey, taskConfig in pairs(parentTasks) do
        dispatchTask(tasksPrefix .. taskKey, taskConfig, tasks, vimCommand)
      end
    end
  end
end

local function dispatchSubgroup(prefix, key, subgroup, parentTasks, vimCommand)
  local function fileExists(pattern)
    local root_dir = vim.fn.getcwd()
    local files = vim.fn.glob(root_dir .. "/" .. pattern, true, true)
    return #files > 0
  end

  local filterByRootFiles = subgroup.filterByRootFiles
  subgroup.filterByRootFiles = nil

  if filterByRootFiles and not fileExists(filterByRootFiles) then
    return
  end

  if type(subgroup) == "table" then
    local tasks = subgroup.tasks
    dispatchTasks(
      prefix,
      key,
      subgroup.desc,
      subgroup.default,
      tasks,
      parentTasks,
      vimCommand
    )
    subgroup.desc = nil
    subgroup.default = nil
    subgroup.tasks = nil

    for subgroupKey, subgroupConfig in pairs(subgroup) do
      dispatchSubgroup(prefix .. key, subgroupKey, subgroupConfig, tasks, vimCommand)
    end
  end
end

-- Deep copies a table so each command type gets its own copy
local function deepCopy(orig)
  if type(orig) ~= "table" then
    return orig
  end

  local copy = {}
  for k, v in pairs(orig) do
    copy[k] = deepCopy(v)
  end

  return copy
end

-- Defines a group of dispatch commands for each vim-dispatch command type
local function dispatchGroup(config)
  local commands = config.commands
  config.commands = nil

  for _, cmd in ipairs(commands) do
    local prefix = cmd.key
    local vimCommand = cmd.command

    local configCopy = deepCopy(config)

    for subgroupKey, subgroup in pairs(configCopy) do
      dispatchSubgroup(prefix, subgroupKey, subgroup, {}, vimCommand)
    end
  end
end

return { -- Asynchronous tasks
  "trekdemo/vim-dispatch",
  dependencies = {
    "folke/which-key.nvim",
  },
  branch = "kitty-support",
  -- 'tpope/vim-dispatch',
  -- dev = true,
  -- path = '~/projects/vim-dispatch',
  event = "VimEnter",
  keys = {
    { "mq", quickfix, desc = "Quickfix (from Make)" },
    { "`q", quickfix, desc = "Quickfix (from Dispatch)" },
    { "`<Up>", ":Dispatch<Up><CR>", desc = "Repeat previous dispatch" },

    -- Open zsh in Dispatch (like Spawn does for Start, hence the "g`" mnemonics)
    { "g`<CR>", ":Dispatch zsh<CR>", desc = "Dispatch zsh" },
    { "g`<Space>", ":Dispatch zsh ", desc = "Dispatch zsh <type here>" },
    {
      "g`!",
      ":Dispatch! zsh",
      desc = "Dispatch zsh <type here> (background)",
    },

    -- Use selected text on visual mode
    { "m<CR>", ":Make<CR>", desc = "Make (selected text)", mode = "v" },
    {
      "m<Space>",
      ":Make ",
      desc = "Make <type here> (selected text)",
      mode = "v",
    },
    {
      "m!",
      ":Make!",
      desc = "Make <type here> (selected text) (background)",
      mode = "v",
    },
    { "`<CR>", ":Dispatch<CR>", desc = "Dispatch (selected text)", mode = "v" },
    {
      "`<Space>",
      ":Dispatch ",
      desc = "Dispatch <type here> (selected text)",
      mode = "v",
    },
    {
      "`!",
      ":Dispatch!",
      desc = "Dispatch <type here> (selected text) (background)",
      mode = "v",
    },
  },
  config = function()
    -- Set tmux and quickfix windows height
    vim.g.dispatch_quickfix_height = 30
    vim.g.dispatch_kitty_bias = 30
    vim.g.dispatch_compilers = { elixir = "exunit" }

    -- Configure which-key with the dispatch mappings
    require("which-key").add({
      { "m<CR>", desc = "Make" },
      { "m<Space>", desc = "Make <type here>" },
      { "m!", desc = "Make <type here> (background)" },
      { "m?", desc = "Show 'makeprg'" },

      { "`<CR>", desc = "Dispatch" },
      { "`<Space>", desc = "Dispatch <type here>" },
      { "`!", desc = "Dispatch <type here> (background)" },
      { "`?", desc = "Show default Dispatch" },

      { "'<CR>", desc = "Start" },
      { "'<Space>", desc = "Start <type here>" },
      { "'!", desc = "Start <type here> (background)" },
      { "'?", desc = "Show default Start" },

      { "g'<CR>", desc = "Spawn" },
      { "g'<Space>", desc = "Spawn <type here>" },
      { "g'!", desc = "Spawn <type here> (background)" },
      { "g'?", desc = "Show 'shell'" },
    })

    dispatchGroup({
      commands = {
        { key = "<leader>`", command = "Dispatch" },
        { key = "<leader>m", command = "Make" },
        { key = "<leader>'", command = "Start" },
      },
      p = {
        filterByRootFiles = "mix.exs",
        desc = "Phoenix (Elixir)",
        default = "s",
        tasks = {
          s = { "iex -S mix phx.server", desc = "Server" },
          t = { "mix phx.routes", desc = "Test routes" },
        },
        g = {
          desc = "Gen",
          default = "c",
          tasks = {
            c = { "mix phx.gen.context", desc = "Context", wait = true },
            h = { "mix phx.gen.html", desc = "HTML", wait = true },
            j = { "mix phx.gen.json", desc = "JSON", wait = true },
            l = { "mix phx.gen.live", desc = "LiveView", wait = true },
          },
        },
      },
      c = {
        filterByRootFiles = "mix.exs",
        desc = "Compile (Elixir)",
        default = "d",
        tasks = {
          d = { "mix compile", desc = "Dev" },
          t = { "MIX_ENV=test mix compile", desc = "Test" },
        },
        w = {
          desc = "Warnings as errors",
          default = "d",
          tasks = function(groupTask)
            return groupTask .. " --warnings-as-errors"
          end,
        },
      },
      d = {
        filterByRootFiles = "mix.exs",
        desc = "Deps (Elixir)",
        default = "g",
        tasks = {
          g = { "mix deps.get", desc = "Get" },
          a = { "mix deps.audit", desc = "Audit" },
          u = { "mix deps.unlock --check-unused", desc = "Check unused" },
          r = { "mix hex.audit", desc = "Check retired" },
          o = { "mix hex.outdated", desc = "Check outdated" },
        },
      },
      e = {
        filterByRootFiles = "mix.exs",
        desc = "Ecto (Elixir)",
        default = "<Up>",
        tasks = {
          ["<Up>"] = { "mix ecto.migrate", desc = "Up" },
          ["<Down>"] = { "mix ecto.rollback", desc = "Down" },
          d = { "mix ecto.drop", desc = "Drop" },
          c = { "mix ecto.create", desc = "Ccreate" },
          s = { "mix ecto.setup", desc = "Setup" },
          r = { "mix ecto.reset", desc = "Reset" },
          l = { "mix ecto.load", desc = "Load" },
          i = { "mix run priv/repo/seeds.exs", desc = "[I]nsert seeds" },
          g = {
            "mix ecto.gen.migration",
            desc = "[G]enerate migration",
            wait = true,
          },
        },
        t = {
          desc = "Test",
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
        filterByRootFiles = "mix.exs",
        desc = "Format (Elixir)",
        default = "a",
        tasks = {
          a = { "mix format", desc = "All files" },
          c = { "mix format %", desc = "Current file" },
        },
      },
      h = {
        filterByRootFiles = "mix.exs",
        desc = "Help (Elixir)",
        default = "s",
        tasks = {
          r = { "mix doctor", desc = "Doctor" },
          s = { "mix hex.search", desc = "Search docs" },
          w = { "mix docs --warnings-as-errors", desc = "Check warnings" },
        },
      },
      l = {
        filterByRootFiles = "mix.exs",
        desc = "Linters (Elixir)",
        default = "c",
        tasks = {
          c = { "mix credo", desc = "Code" },
          s = { "mix sobelow --config", desc = "Security" },
          t = { "mix dialyzer", desc = "Types" },
        },
      },
      t = {
        filterByRootFiles = "mix.exs",
        desc = "Test (Elixir)",
        default = "h",
        tasks = {
          a = { "mix test", desc = "All" },
          c = { "mix coveralls", desc = "Coverage" },
          h = { "mix coveralls.html", desc = "HTML coverage" },
          i = { "mix test.interactive", desc = "Interactive" },
        },
        w = {
          desc = "Warnings as errors",
          default = "h",
          tasks = function(groupTask)
            return groupTask .. " --warnings-as-errors"
          end,
        },
      },
    })
  end,
}
