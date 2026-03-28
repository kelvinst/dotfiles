function GetFileReference(str)
  if str == nil then
    str = vim.fn.expand("<cWORD>")
  end

  -- Get the current WORD under the cursor
  local fname = str:gsub(":%d+$", "")

  -- Check if the word is a valid file
  if vim.fn.filereadable(fname) == 0 then
    vim.notify('"' .. fname .. '" is not a valid file', vim.log.levels.WARN)
    return
  end

  -- Get the current line and cursor position
  local line = vim.api.nvim_get_current_line()

  -- Here are the patterns to match the line number
  local lnum_patterns = {
    ":(%d+)", -- <file>:<line>
    "%s*@%s*(%d+)", -- <file> @ <line>
    "%s*%(%d+)", -- <file> (<line>)
    "%s*%(line%s*(%d+)", -- <file> (line <line>)
    "%s+(%d+)", -- file line
  }

  -- Now apply each pattern to find the line number
  for _, pat in ipairs(lnum_patterns) do
    local lnum = line:match(fname .. pat)
    if lnum then
      return { fname = fname, lnum = tonumber(lnum) }
    end
  end

  -- if no line number found, return only the filename
  return { fname = fname }
end

function CmdFn(cmd)
  return function()
    vim.cmd(cmd)
  end
end

function ClearInvisibleBuffers()
  -- Get visible buffers
  local visible_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible_buffers[vim.api.nvim_win_get_buf(win)] = true
  end

  local buflist = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(buflist) do
    -- Delete buffer if not visible
    if visible_buffers[bufnr] == nil then
      pcall(vim.cmd.bd, bufnr)
    end
  end
end

function BreakLine(max_length)
  -- Get the current line
  local line_num = vim.fn.line(".")
  local line = vim.fn.getline(line_num)

  -- Trim leading and trailing whitespace
  local indent = line:match("^%s*") or ""
  local content = line:match("^%s*(.-)%s*$") or ""

  -- If line is already short enough, do nothing
  if #line <= max_length then
    vim.notify(
      "Line is already " .. #line .. " characters (max: " .. max_length .. ")",
      vim.log.levels.WARN
    )
    return
  end

  -- Break the line into multiple lines
  local lines = {}
  local current_line = ""

  -- Split content into words
  for word in content:gmatch("%S+") do
    local test_line = current_line == "" and word
      or (current_line .. " " .. word)
    local test_line_with_indent = indent .. test_line

    if #test_line_with_indent <= max_length then
      current_line = test_line
    else
      -- If adding this word exceeds max length, start a new line
      if current_line ~= "" then
        table.insert(lines, indent .. current_line)
        current_line = word
      else
        -- Single word is longer than max length, add it anyway
        table.insert(lines, indent .. word)
      end
    end
  end

  -- Add the last line
  if current_line ~= "" then
    table.insert(lines, indent .. current_line)
  end

  -- Replace the current line with broken lines
  if #lines > 0 then
    vim.fn.setline(line_num, lines[1])
    for i = 2, #lines do
      vim.fn.append(line_num + i - 2, lines[i])
    end
    vim.notify(
      "Broke line into " .. #lines .. " lines (max: " .. max_length .. " chars)",
      vim.log.levels.INFO
    )
  end
end

local function find_window_by_cmd(pattern)
  local ls_output = vim.fn.system({ "kitty", "@", "ls" })
  local ok, data = pcall(vim.json.decode, ls_output)
  if ok and data then
    for _, os_window in ipairs(data) do
      local focused_tab = vim.iter(os_window.tabs or {}):find(function(t)
        return t.is_focused
      end)

      if focused_tab then
        local win = vim.iter(focused_tab.windows or {}):find(function(w)
          return vim.iter(w.foreground_processes or {}):find(function(p)
            return vim.iter(p.cmdline or {}):find(function(c)
              return c:match(pattern)
            end)
          end)
        end)

        return win
      end
    end
  end
  return nil
end

local function find_claude_window()
  return find_window_by_cmd("claude")
end

local function launch_ai(cmd)
  return vim.fn.system({
    "kitty",
    "@",
    "launch",
    "--type=window",
    "--location=vsplit",
    "--cwd=" .. vim.fn.getcwd(),
    "zsh",
    "-i",
    "-c",
    cmd,
  })
end

function NewClaude()
  return launch_ai("claude")
end

function NewDangerClaude()
  return launch_ai("claude --dangerously-skip-permissions")
end

function NewCodex()
  return launch_ai("codex")
end

function NewDangerCodex()
  return launch_ai("codex --full-auto")
end

function OpenClaude()
  local claude_window = find_claude_window()

  if claude_window then
    vim.fn.system({
      "kitty",
      "@",
      "focus-window",
      "--match",
      "id:" .. claude_window.id,
    })

    return claude_window.id
  end

  return launch_ai("claude")
end

function OpenCodex()
  local codex_window = find_window_by_cmd("codex")

  if codex_window then
    vim.fn.system({
      "kitty",
      "@",
      "focus-window",
      "--match",
      "id:" .. codex_window.id,
    })

    return codex_window.id
  end

  return launch_ai("codex")
end

function GetVisualContext()
  -- Escape visual mode first so that '< and '> marks are updated
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
    "x",
    false
  )
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local filename = vim.fn.expand("%:~:.")
  local filetype = vim.bo.filetype
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("\n", "\\n")
  end
  local content = table.concat(lines, "\n")
  return "Here is the selected code from `"
    .. filename
    .. "` (lines "
    .. start_line
    .. "-"
    .. end_line
    .. "):\n\n```"
    .. filetype
    .. "\n"
    .. content
    .. "\n```\n\n"
end

local function send_to_ai_window(window_id, text)
  if type(window_id) == "string" then
    window_id = vim.trim(window_id)
  end
  vim.fn.system({
    "kitty",
    "@",
    "send-text",
    "--match",
    "id:" .. tostring(window_id),
    text,
  })
end

function OpenClaudeWithContext()
  local context = GetVisualContext()
  local window_id = OpenClaude()
  vim.defer_fn(function()
    send_to_ai_window(window_id, context)
  end, 300)
end

function OpenCodexWithContext()
  local context = GetVisualContext()
  local window_id = OpenCodex()
  vim.defer_fn(function()
    send_to_ai_window(window_id, context)
  end, 300)
end

function NewClaudeWithContext()
  local context = GetVisualContext()
  local window_id = NewClaude()
  vim.defer_fn(function()
    send_to_ai_window(window_id, context)
  end, 2000)
end

function NewCodexWithContext()
  local context = GetVisualContext()
  local window_id = NewCodex()
  vim.defer_fn(function()
    send_to_ai_window(window_id, context)
  end, 2000)
end
