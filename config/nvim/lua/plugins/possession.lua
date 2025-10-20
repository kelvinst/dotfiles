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

local function session_file(file)
  local dir =
    string.format("%s/session_data/%s", vim.fn.stdpath("data"), vim.g.session)
  vim.fn.mkdir(dir, "p")
  return string.format("%s/%s.json", dir, file)
end

local function get_codecompanion_chat()
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
          -- Get the tab number where this window is located
          local tab = vim.api.nvim_win_get_tabpage(win)
          local tab_number = vim.api.nvim_tabpage_get_number(tab)

          -- Get the chat object from the buffer
          local chat_module = require("codecompanion.strategies.chat")
          local chat = chat_module.buf_get_chat(buf)
          if chat and chat.opts and chat.opts.save_id then
            return { id = chat.opts.save_id, tab = tab_number }
          end
          return { id = true, tab = tab_number } -- Chat is open but no save_id yet
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

local function get_focused_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(buf) then
    return {
      name = vim.api.nvim_buf_get_name(buf),
      filetype = vim.bo[buf].filetype,
    }
  end
  return nil
end

local function save_session_data()
  local session_data = {
    tab_names = tab_names(),
    codecompanion_chat = get_codecompanion_chat(),
    quickfix_open = vim.fn.getqflist({ winid = 0 }).winid ~= 0,
    focused_buffer = get_focused_buffer(),
  }

  local ok, json = pcall(vim.json.encode, session_data)
  if ok then
    vim.fn.writefile({ json }, session_file("data"))
  end
end

local function load_session_data()
  if not vim.g.session or vim.g.session == "" then
    return
  end

  local file = session_file("data")
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

local function restore_codecompanion_chat(saved_chat)
  if saved_chat then
    local codecompanion = require("codecompanion")

    -- Handle both old format (just chat_id) and new format (table with id and tab)
    local chat_id = type(saved_chat) == "table" and saved_chat.id
    local tab_number = type(saved_chat) == "table" and saved_chat.tab or nil

    -- Switch to the correct tab if specified
    if tab_number then
      local tabpages = vim.api.nvim_list_tabpages()
      if tab_number <= #tabpages then
        vim.api.nvim_set_current_tabpage(tabpages[tab_number])
      end
    end

    if chat_id == true then
      return
    end

    local history = codecompanion.extensions.history
    local chat_data = history.load_chat(chat_id) or {}
    local messages = chat_data.messages or {}

    local last_msg = messages[#messages]

    -- Ensure last message is from user to show header
    if
      last_msg
      and (
        last_msg.role ~= "user"
        or (last_msg.role == "user" and (last_msg.opts or {}).visible == false)
      )
    then
      table.insert(messages, {
        role = "user",
        content = "",
        opts = { visible = true },
      })
    end
    local context = require("codecompanion.utils.context").get(nil)

    local chat = require("codecompanion.strategies.chat").new({
      save_id = chat_id,
      messages = messages,
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

local function restore_focused_buffer(focused_buffer)
  if not focused_buffer then
    return
  end

  local buf_to_focus = nil

  -- First, try to find a buffer with the same name
  if focused_buffer.name and focused_buffer.name ~= "" then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_buf_get_name(buf) == focused_buffer.name
      then
        buf_to_focus = buf
        break
      end
    end
  end

  -- If not found by name, try to find a buffer with the same filetype
  if
    not buf_to_focus
    and focused_buffer.filetype
    and focused_buffer.filetype ~= ""
  then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_valid(buf)
        and vim.bo[buf].filetype == focused_buffer.filetype
      then
        buf_to_focus = buf
        break
      end
    end
  end

  -- Set the focus to the found buffer
  if buf_to_focus then
    -- Check if buffer is displayed in any window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if
        vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == buf_to_focus
      then
        -- Focus the window containing this buffer
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    -- Buffer exists but not visible, set it in current window
    vim.api.nvim_set_current_buf(buf_to_focus)
  end
end

local function restore_session_data()
  local session_data = load_session_data()
  if session_data then
    restore_tab_names(session_data.tab_names)
    restore_codecompanion_chat(session_data.codecompanion_chat)

    if session_data.quickfix_open then
      vim.cmd("bot copen")
    end

    restore_focused_buffer(session_data.focused_buffer)
  end
end

local function save_quickfix()
  require("quickfix").store(session_file("quickfix"))
end

local function restore_quickfix()
  require("quickfix").restore(session_file("quickfix"))
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
    "niuiic/quickfix.nvim",
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
          save_quickfix()
        end,
        post_hook = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            delete_bad_buffer(buf)
          end

          vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
          restore_session_data()
          restore_quickfix()
        end,
      })
    end
  end,
}
