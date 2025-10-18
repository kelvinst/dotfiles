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
      vim.cmd.CodeCompanion,
      desc = "Inline Prompt",
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
        require("codecompanion").toggle()
      end,
      desc = "[C]hat",
      mode = "n",
    },
    {
      "<leader>ag",
      function()
        require("codecompanion").prompt("commit")
      end,
      desc = "[G]it commit message",
      mode = "n",
      ft = { "gitcommit" },
    },
  },
  opts = {
    strategies = {
      chat = {
        adapter = "claude_code",
        keymaps = {
          close = {
            modes = { n = { "q" }, i = "<C-c>" },
          },
          stop = {
            modes = { n = "<C-c>" },
          },
          _acp_allow_always = {
            modes = { n = "<S-Enter>" },
          },
          _acp_allow_once = {
            modes = { n = "<cr>" },
          },
          _acp_reject_once = {
            modes = { n = "<esc>" },
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
            modes = { n = "<cr>" },
          },
          reject_change = {
            modes = { n = "<esc>" },
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
      chat = {
        window = {
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
          },
        },
      },
    },
    prompt_library = {
      ["Generate a Commit Message"] = {
        strategy = "inline",
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
          stop_context_insertion = false,
          short_name = "commit",
          auto_submit = true,
          user_prompt = true,
        },
        prompts = {
          {
            role = "user",
            content = function(context)
              return string.format(
                [[
You are an expert at following the Conventional Commit specification. 

Given the git diff listed below, please generate a commit message for me and 
insert it at the first line of #{buffer} using the @{insert_edit_into_file} 
tool.

```diff
%s
```

The commit subject should be a short but descriptive summary of the changes,
try to keep it under 50 characters, but it's ok to go above that. 

The body should provide additional context about the changes, starting with
bullet points of the multiple changes made in the commit, and finishing it
with an explanation of why the changes were made. Keep the body lines under
72 characters, it's ok to break bullet items in multiple lines, as well as
paragraphs, just use 2 line breaks to separate paragraphs.

To build the "why this changes were made" section, here's a bit of context:
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
