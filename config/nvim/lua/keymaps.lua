-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  vim.cmd.Noice("dismiss")
end)

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Do not move cursor when merging lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor centered when scrolling/searching
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Make `gf` go to line by default
vim.keymap.set("n", "gf", "gF")

local function open_file_in_editor(ref)
  if ref then
    local command = { "open", "-t", ref.fname }
    local msg = "Opening file editor: %s"

    if ref.lnum then
      table.insert(command, "--args")
      table.insert(command, string.format("--line=%d", ref.lnum))
      msg = msg .. " (line %d)"
    end

    vim.notify(string.format(msg, ref.fname, ref.lnum), vim.log.levels.INFO)
    vim.notify(
      string.format("Opening command: ", vim.inspect(command)),
      vim.log.levels.DEBUG
    )

    vim.fn.system(command)
  end
end

-- Open file under cursor in default text editor (macOS)
vim.keymap.set("n", "gF", function()
  open_file_in_editor(GetFileReference())
end, { desc = "Open file under cursor in system's editor" })

local function get_selected_text()
  local _, csrow, cscol = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol = unpack(vim.fn.getpos("'>"))

  if csrow == cerow then
    local line = vim.fn.getline(csrow)
    return string.sub(line, cscol, cecol)
  end

  return ""
end

-- Open selected text as file in default text editor (macOS)
vim.keymap.set("v", "gF", function()
  open_file_in_editor(GetFileReference(get_selected_text()))
end, { desc = "Open selected text as file in system's editor" })

local function copyFilenameWithLines()
  local filename = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local currentLine = filename .. ":" .. line
  vim.fn.setreg("*", currentLine)
  vim.api.nvim_input("<Esc>")
  vim.notify("Copied to clipboard: " .. currentLine, vim.log.levels.INFO)
end

local function copyFilename()
  local filename = vim.fn.expand("%")
  vim.fn.setreg("*", filename)
  vim.notify("Copied to clipboard: " .. filename, vim.log.levels.INFO)
end

-- Copy file info to clipboard
vim.keymap.set("n", "<leader>yf", copyFilename, { desc = "Yank filename" })
vim.keymap.set(
  "n",
  "<leader>yl",
  copyFilenameWithLines,
  { desc = "Yank filename and line" }
)

-- Paste without cutting the current selection
vim.keymap.set("x", "π", [["_dP]]) -- Alt+p

-- Rename a word under cursor
vim.keymap.set(
  "n",
  "<leader>cr",
  [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]],
  { desc = "Rename word" }
)

-- Grep a word under cursor
vim.keymap.set(
  "n",
  "<leader>cg",
  [[:grep <C-r><C-w><cr>]],
  { desc = "Grep word" }
)

-- Load the LSP errors to the quickfix list
vim.keymap.set(
  "n",
  "<leader>eq",
  vim.diagnostic.setqflist,
  { desc = "Eerrors Quickfix" }
)

local function any_unsaved_real_files()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local o = vim.bo[buf]
      -- Only consider normal file buffers that are modifiable
      if o.buftype == "" and o.modifiable and o.modified then
        return true
      end
    end
  end
  return false
end

local function restart_vim()
  -- Check for unsaved buffers

  if any_unsaved_real_files() then
    local choice = vim.fn.confirm(
      "⚠️  WARNING: There are unsaved changes!\n Do you really want to continue?",
      "&Yes\n&No",
      2
    )
    if choice ~= 1 then
      return
    end
  end

  require("nvim-possession").update()

  local cwd = vim.fn.getcwd()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")

  local esc = vim.fn.fnameescape
  local start_cmd
  if file == "" then
    start_cmd = string.format("Dispatch -dir=%s nvim", esc(cwd))
  else
    start_cmd =
      string.format("Dispatch -dir=%s nvim +%d %s", esc(cwd), line, esc(file))
  end

  vim.cmd(start_cmd)
  vim.fn.system("kitty @ close-window --self")
end

-- Restart vim
vim.keymap.set("n", "<leader>vr", restart_vim, { desc = "Restart Vim" })

-- Break long line into multiple lines
vim.keymap.set("n", "<leader>cb", function()
  vim.ui.input({
    prompt = "Max line length: ",
    default = "79",
  }, function(input)
    if input then
      local max_length = tonumber(input)
      if max_length and max_length > 0 then
        BreakLine(max_length)
      else
        vim.notify(
          "Invalid length: must be a positive number",
          vim.log.levels.ERROR
        )
      end
    end
  end)
end, { desc = "Break line" })

-- Tmp scripts
local function new_tmp_script(ext)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  vim.cmd("edit tmp/" .. timestamp .. "." .. ext)
end

vim.keymap.set("n", "<leader>fte", function()
  new_tmp_script("exs")
end, { desc = "Elixir" })

vim.keymap.set("n", "<leader>fts", function()
  new_tmp_script("sh")
end, { desc = "Shell" })

vim.keymap.set("n", "<leader>ftg", function()
  local builtin = require("telescope.builtin")
  builtin.live_grep({
    cwd = "./tmp",
  })
end, { desc = "Grep" })

vim.keymap.set("n", "<leader>ftp", function()
  local builtin = require("telescope.builtin")
  builtin.find_files({
    cwd = "./tmp",
  })
end, { desc = "Pick" })

vim.keymap.set("n", "<leader>tfj", function()
  new_tmp_script("js")
end, { desc = "New JavaScript" })

vim.keymap.set("n", "<leader>ft<cr>", function()
  vim.ui.input({ prompt = "Extension: " }, function(ext)
    if ext then
      local timestamp = os.date("%Y%m%d_%H%M%S")
      vim.cmd("edit tmp/scripts/" .. timestamp .. "." .. ext)
    end
  end)
end, { desc = "New" })
