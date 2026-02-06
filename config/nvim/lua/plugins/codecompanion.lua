return {
  -- Using AI to assist with coding
  "olimorris/codecompanion.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "lalitmee/codecompanion-spinners.nvim",
    "ravitemer/codecompanion-history.nvim",
  },
  keys = {
    {
      "<leader>aa",
      vim.cmd.CodeCompanionActions,
      desc = "Actions",
      mode = { "n", "v" },
    },
    {
      "<leader>a<space>",
      vim.cmd.CodeCompanion,
      desc = "Inline Prompt",
      mode = { "n", "v" },
    },
    {
      "<leader>ae",
      function()
        require("codecompanion").prompt("explain")
      end,
      desc = "Explain",
      mode = { "n", "v" },
    },
    {
      "<leader>ac",
      vim.cmd.CodeCompanionChat,
      desc = "Chat",
      mode = "v",
    },
    {
      "<leader>ac",
      function()
        require("codecompanion").toggle()
      end,
      desc = "Chat",
      mode = "n",
    },
    {
      "<leader>ag",
      function()
        require("codecompanion").prompt("commit")
      end,
      desc = "Git commit message",
      mode = "n",
      ft = { "gitcommit" },
    },
  },
  opts = {
    interactions = {
      chat = {
        adapter = "claude_code",
        keymaps = {
          close = {
            modes = { n = "q" },
          },
          send = {
            modes = { n = { "<C-Enter>", "<Enter>" }, i = "<C-Enter>" },
          },
          stop = {
            modes = { n = "<C-c>" },
          },
          fold_code = {
            modes = { n = "zM" },
          },
          goto_file_under_cursor = {
            modes = { n = "<c-w>gf" },
          },
          _acp_allow_always = {
            modes = { n = "<S-Enter>" },
          },
          _acp_allow_once = {
            modes = { n = "<Enter>" },
          },
          _acp_reject_once = {
            modes = { n = "<Esc>" },
          },
          _acp_reject_always = {
            modes = { n = "<S-Esc>" },
          },
        },
      },
      inline = {
        adapter = "copilot",
        keymaps = {
          accept_change = {
            modes = { n = "<Enter>" },
          },
          reject_change = {
            modes = { n = "<Esc>" },
          },
          always_accept = {
            modes = { n = "<S-Enter>" },
          },
        },
      },
    },
    adapters = {
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            opts = {
              vision = true,
              stream = true,
              trim_tool_output = true,
            },
          })
        end,
      },
      http = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            opts = {
              vision = true,
              stream = true,
            },
            schema = {
              model = {
                default = "gpt-4.1",
              },
            },
          })
        end,
      },
    },
    display = {
      action_palette = {
        opts = {
          show_preset_prompts = false,
        },
      },
      chat = {
        window = {
          width = 80,
        },
      },
    },
    extensions = {
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
          },
        },
      },
    },
    prompt_library = {
      ["Generate a Commit Message"] = {
        interaction = "inline",
        description = "Generate a commit message",
        condition = function()
          return vim.bo.filetype == "gitcommit"
        end,
        opts = {
          adapter = {
            name = "copilot",
            model = "gpt-4.1",
          },
          index = 10,
          is_default = true,
          is_slash_cmd = true,
          stop_context_insertion = true,
          alias = "commit",
          auto_submit = true,
          placement = "before",
          user_prompt = true,
          pre_hook = function()
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
          end,
        },
        prompts = {
          {
            role = "user",
            content = function()
              return string.format(
                [[
You are an expert at following the Conventional Commit specification.

Given the git diff listed below, please generate a commit message for me.

```diff
%s
```

The commit subject should be a short but descriptive summary of the changes,
try to keep it under 50 characters, but it's ok to go up to 72.

The body should provide a succinct context about the changes, focused on the
"why the changes were made", not on which changes were made per se. Keep the
body lines under 72 characters.

Here is some extra info to take into account when writing it:
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
