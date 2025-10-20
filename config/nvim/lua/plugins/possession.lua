local function delete_bad_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    local buftype = vim.bo[buf].filetype
    if vim.tbl_contains({ "", "gitcommit" }, buftype) then
      vim.api.nvim_buf_delete(buf, { force = true })
      return
    end

    -- Delete all NeoGit buffers
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("Neogit") then
      vim.api.nvim_buf_delete(buf, { force = true })
      return
    end
  end
end

local function session_file()
  local dir = vim.fn.stdpath("data") .. "/tabnames"
  vim.fn.mkdir(dir, "p")
  return string.format("%s/%s.json", dir, vim.g.session)
end

local function get_codecompanion_chat_id()
  -- Check if any buffer has codecompanion filetype
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].filetype == "codecompanion"
    then
      -- Check if the buffer is visible in any window
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if
          vim.api.nvim_win_is_valid(win)
          and vim.api.nvim_win_get_buf(win) == buf
        then
          -- Get the chat object from the buffer
          local chat_module = require("codecompanion.strategies.chat")
          local chat = chat_module.buf_get_chat(buf)
          if chat and chat.opts and chat.opts.save_id then
            return chat.opts.save_id
          end
          return true -- Chat is open but no save_id yet
        end
      end
    end
  end
  return nil
end

local function tab_names()
  if not vim.g.session or vim.g.session == "" then
    return
  end

  local names = {}
  -- Order matters: index 1..N corresponds to tabpage #1..#N
  for _, i in ipairs(vim.api.nvim_list_tabpages()) do
    names[i] = vim.t[i] and vim.t[i].name or nil
  end

  return names
end

local function save_session_data()
  local session_data = {
    tab_names = tab_names(),
    codecompanion_chat_id = get_codecompanion_chat_id(),
  }

  local ok, json = pcall(vim.json.encode, session_data)
  if ok then
    vim.fn.writefile({ json }, session_file())
  end
end

local function load_session_data()
  if not vim.g.session or vim.g.session == "" then
    return
  end

  local file = session_file()
  if vim.fn.filereadable(file) == 0 then
    return
  end
  local lines = vim.fn.readfile(file)
  if not lines or not lines[1] then
    return
  end
  local ok, session_data = pcall(vim.json.decode, table.concat(lines, "\n"))

  if not ok or type(session_data) ~= "table" then
    return
  end

  return session_data
end

local function restore_tab_names(names)
  if type(names) == "table" then
    for i, name in ipairs(names) do
      if type(name) == "string" and name ~= "" then
        -- Bufferline reads this: :BufferLineTabRename sets the same var
        vim.t[i] = vim.t[i] or {}
        vim.t[i].name = name
      end
    end
  end
end

local function restore_codecompanion_chat(chat_id)
  if chat_id then
    local codecompanion = require("codecompanion")

    if chat_id == true then
      vim.notify(
        "Restoring CodeCompanion chat...",
        vim.log.levels.INFO,
        { title = "CodeCompanion" }
      )

      codecompanion.chat()
      return
    end

    vim.notify(
      string.format("Restoring CodeCompanion chat #%s...", chat_id),
      vim.log.levels.INFO,
      { title = "CodeCompanion" }
    )

    local history = codecompanion.extensions.history
    local chat_data = history.load_chat(chat_id) or {}
    local context = require("codecompanion.utils.context").get(nil)

    local chat = require("codecompanion.strategies.chat").new({
      save_id = chat_id,
      messages = chat_data.messages or {},
      buffer_context = context,
      settings = chat_data.settings or {},
      adapter = chat_data.adapter,
      title = chat_data.title,
      callbacks = {},
      last_role = "user",
    })

    -- Handle both old (refs) and new (context_items) storage formats
    local stored_context_items = chat_data.context_items or chat_data.refs or {}
    local chat_context_items = chat.context_items or {}
    for _, item in ipairs(stored_context_items) do
      -- Avoid adding duplicates related to #48
      local is_duplicate = vim.tbl_contains(
        chat_context_items,
        function(chat_item)
          return chat_item.id == item.id
        end,
        { predicate = true }
      )
      if not is_duplicate then
        chat.context:add(item)
      end
    end
    chat.tool_registry.schemas = chat_data.schemas or {}
    chat.tool_registry.in_use = chat_data.in_use or {}
    chat.cycle = chat_data.cycle or 1
  end
end

local function restore_session()
  local session_data = load_session_data()
  if session_data then
    restore_tab_names(session_data.tab_names)
    restore_codecompanion_chat(session_data.codecompanion_chat_id)
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
    "olimorris/codecompanion.nvim",
    "ravitemer/codecompanion-history.nvim",
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
        autoprompt = false,
        autoswitch = { enable = true, notify = true },
        save_hook = function()
          ClearInvisibleBuffers()

          vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
          save_session_data()
        end,
        post_hook = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            delete_bad_buffer(buf)
          end

          vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
          restore_session()
        end,
      })
    end
  end,
}
