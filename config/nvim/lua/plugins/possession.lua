local function session_file()
  local dir = vim.fn.stdpath("data") .. "/tabnames"
  vim.fn.mkdir(dir, "p")
  return string.format("%s/%s.json", dir, vim.g.session)
end

local function save_tab_names()
  if not vim.g.session or vim.g.session == "" then
    return
  end

  local names = {}
  -- Order matters: index 1..N corresponds to tabpage #1..#N
  for i = 1, #vim.api.nvim_list_tabpages() do
    names[i] = vim.t[i] and vim.t[i].name or nil
  end
  local ok, json = pcall(vim.json.encode, names)
  if ok then
    vim.fn.writefile({ json }, session_file())
  end
end

local function restore_tab_names()
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
        save_hook = function()
          -- Delete all CodeCompanion buffers
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) then
              local buftype = vim.bo[buf].filetype
              if buftype == "codecompanion" then
                vim.api.nvim_buf_delete(buf, { force = true })
              end
            end
          end

          -- Delete all Neogit buffers
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("Neogit") then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end

          ClearInvisibleBuffers()

          vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
          save_tab_names()
        end,
        post_hook = function()
          vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
          restore_tab_names()
        end,
      })
    end
  end,
}
