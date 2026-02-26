local function delete_bad_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    -- Reopen NeogitStatus if it was saved to the session
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("NeogitStatus") then
      vim.cmd.Neogit()
    end

    local buftype = vim.bo[buf].filetype
    if vim.tbl_contains({ "", "gitcommit" }, buftype) then
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
    "niuiic/quickfix.nvim",
    "NeogitOrg/neogit",
  },
  keys = {
    {
      "<leader>sl",
      function()
        require("nvim-possession").list()
      end,
      desc = "List sessions",
    },
    {
      "<leader>ss",
      function()
        require("nvim-possession").new()
      end,
      desc = "Create new session",
    },
    {
      "<leader>su",
      function()
        require("nvim-possession").update()
      end,
      desc = "Update current session",
    },
    {
      "<leader>sd",
      function()
        require("nvim-possession").delete()
      end,
      desc = "Delete selected session",
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
