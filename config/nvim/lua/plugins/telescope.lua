return { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = true },
    { "folke/which-key.nvim" },
  },
  config = function()
    local telescope = require("telescope")
    local themes = require("telescope.themes")
    local actions = require("telescope.actions")
    local previewers = require("telescope.previewers")
    local Job = require("plenary.job")

    local is_image = function(filepath)
      local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "webp" }
      local split_path = vim.split(filepath:lower(), ".", { plain = true })
      local extension = split_path[#split_path]
      return vim.tbl_contains(image_extensions, extension)
    end

    local new_maker = function(filepath, bufnr, opts)
      filepath = vim.fn.expand(filepath)

      Job:new({
        command = "file",
        args = { "--mime-type", "-b", filepath },
        on_exit = function(j)
          local mime_type = vim.split(j:result()[1], "/")[1]
          if mime_type == "text" or is_image(filepath) then
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          else
            -- Do not preview binary files
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
            end)
          end
        end,
      }):sync()
    end

    telescope.setup({
      defaults = {
        buffer_previewer_maker = new_maker,
        mappings = {
          i = {
            ["<C-s>"] = actions.cycle_previewers_next,
            ["<C-a>"] = actions.cycle_previewers_prev,
          },
        },
        preview = {
          filesize_limit = 0.1,
          -- Preview images
          mime_hook = function(filepath, bufnr, opts)
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d .. "\r\n")
                end
              end
              vim.fn.jobstart(
                {
                  "catimg",
                  filepath,
                },
                { on_stdout = send_output, stdout_buffered = true, pty = true }
              )
            else
              require("telescope.previewers.utils").set_preview_message(
                bufnr,
                opts.winid,
                "Binary cannot be previewed"
              )
            end
          end,
        },
      },
      extensions = {
        ["ui-select"] = {
          themes.get_dropdown(),
        },
      },
    })

    -- Enable Telescope extensions if they are installed
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>pp", builtin.builtin, { desc = "Pickers" })
    vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Help" })
    vim.keymap.set("n", "<leader>pk", builtin.keymaps, { desc = "Keymaps" })
    vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Grep" })
    vim.keymap.set("n", "<leader>pr", builtin.resume, { desc = "Resume" })
    vim.keymap.set("n", "<leader>pf", function()
      builtin.git_files({
        git_command = {
          "git",
          "ls-files",
          "--exclude-standard",
          "--cached",
          "--others",
        },
      })
    end, {
      desc = "Files (from git)",
    })
    vim.keymap.set("n", "<leader>pF", function()
      builtin.find_files({
        hidden = true,
        no_ignore = true,
        no_ignore_parent = true,
      })
    end, {
      desc = "Files (all)",
    })
    vim.keymap.set("n", "<leader>po", builtin.oldfiles, {
      desc = "Old files",
    })
    vim.keymap.set("n", "<leader>pd", builtin.diagnostics, {
      desc = "Diagnostics",
    })
    vim.keymap.set("n", "<leader>pw", builtin.grep_string, {
      desc = "Grep current word",
    })

    vim.keymap.set("n", "<leader>p/", function()
      builtin.current_buffer_fuzzy_find(themes.get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "Fuzzy search current file" })
  end,
}
