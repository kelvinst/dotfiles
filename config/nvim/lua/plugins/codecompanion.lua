return {
  -- Using AI to assist with coding
  "olimorris/codecompanion.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ravitemer/mcphub.nvim",
    "lalitmee/codecompanion-spinners.nvim",
    "ravitemer/codecompanion-history.nvim",
  },
  keys = {
    {
      "<leader>aa",
      vim.cmd.CodeCompanionActions,
      desc = "[A]ctions",
      mode = { "n", "v" },
    },
    {
      "<leader>a<space>",
      ":CodeCompanionChat ",
      desc = "Chat prompt",
      mode = { "n", "v" },
    },
    {
      "<leader>ac",
      vim.cmd.CodeCompanionChat,
      desc = "[C]hat",
      mode = "v",
    },
    {
      "<leader>ac",
      function()
        require("codecompanion").toggle({
          window_opts = { layout = "float", width = 80 },
        })
      end,
      desc = "[C]hat",
      mode = "n",
    },
    {
      "<leader>as",
      function()
        require("codecompanion").toggle({
          window_opts = { layout = "horizontal" },
        })
      end,
      desc = "Horizontal [S]plit Chat",
      mode = "n",
    },
    {
      "<leader>av",
      function()
        require("codecompanion").toggle({
          window_opts = { layout = "vertical" },
        })
      end,
      desc = "[V]ertical Split Chat",
      mode = "n",
    },
    {
      "<leader>ag",
      function()
        vim.cmd.CodeCompanion("/commit")
      end,
      desc = "[G]it commit message",
      mode = "n",
    },
  },
  opts = {
    strategies = {
      chat = {
        adapter = "claude_code",
        keymaps = {
          close = {
            modes = { n = { "<Esc>", "q" }, i = "<C-c>" },
          },
          stop = {
            modes = { n = "<C-c>" },
          },
        },
      },
    },
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {})
        end,
      },
    },
    display = {
      chat = {
        window = {
          layout = "float",
          height = 25,
          width = 80,
        },
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true,
        },
      },
      spinner = {
        enabled = true,
        opts = {
          ["cursor-relative"] = {
            text = "",
            hl_positions = {
              { 0, 3 }, -- First circle
              { 3, 6 }, -- Second circle
              { 6, 9 }, -- Third circle
            },
            interval = 100,
            hl_group = "Title",
            hl_dim_group = "NonText",
          },
        },
      },
      history = {
        enabled = true,
        opts = {
          auto_generate_title = true,
          title_generation_opts = {
            adapter = "copilot",
            model = "gpt-4o",
          },
        },
      },
    },
    prompt_library = {
      ["Generate a Commit Message"] = {
        strategy = "chat",
        description = "Generate a commit message",
        opts = {
          index = 10,
          is_default = true,
          is_slash_cmd = true,
          short_name = "commit",
          auto_submit = true,
        },
        prompts = {
          {
            role = "user",
            content = function()
              return string.format(
                [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me and insert it in #{buffer} using the @{insert_edit_into_file} tool:

```diff
%s
```
]],
                vim.fn.system("git diff --no-ext-diff --staged")
              )
            end,
            opts = {
              contains_code = true,
            },
          },
        },
      },
    },
  },
}
