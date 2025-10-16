-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

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

local function copyFilenameWithLines()
  local filename = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local currentLine = filename .. ":" .. line
  vim.fn.setreg("*", currentLine)
  vim.api.nvim_input("<Esc>")
  print("Copied to clipboard: " .. currentLine)
end

local function copyFilename()
  local filename = vim.fn.expand("%")
  vim.fn.setreg("*", filename)
  print("Copied to clipboard: " .. filename)
end

-- Copy file info to clipboard
vim.keymap.set("n", "<leader>yf", copyFilename, { desc = "[Y]ank [f]ilename" })
vim.keymap.set(
  "n",
  "<leader>yl",
  copyFilenameWithLines,
  { desc = "[Y]ank filename and [l]ine" }
)

-- Paste without cutting the current selection
vim.keymap.set("x", "π", [["_dP]]) -- Alt+p

-- Rename a word under cursor
vim.keymap.set(
  "n",
  "<leader>cr",
  [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]],
  { desc = "[R]ename word" }
)

-- Grep a word under cursor
vim.keymap.set(
  "n",
  "<leader>cg",
  [[:grep <C-r><C-w><cr>]],
  { desc = "[G]rep word" }
)

-- Load the LSP errors to the quickfix list
vim.keymap.set(
  "n",
  "<leader>eq",
  vim.diagnostic.setqflist,
  { desc = "[E]errors [Q]uickfix" }
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
vim.keymap.set("n", "<leader>vr", restart_vim, { desc = "[R]estart Vim" })

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
        print("Invalid length: must be a positive number")
      end
    end
  end)
end, { desc = "[B]reak line" })
