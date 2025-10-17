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
    print(
      "Line is already " .. #line .. " characters (max: " .. max_length .. ")"
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
    print(
      "Broke line into " .. #lines .. " lines (max: " .. max_length .. " chars)"
    )
  end
end
