return {
  {
    "olimorris/codecompanion.nvim",
    -- "bassamsdata/codecompanion.nvim",
    -- dev = true,
    cmd = {
      "CodeCompanion",
      "CodeCompanionOpen",
      "CodeCompanionClose",
      "CodeCompanionToggle",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
    },
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
          slash_commands = {
            ["buffer"] = {
              callback = "helpers.slash_commands.buffer",
              description = "Share a loaded buffer's contents with the LLM",
              opts = {
                contains_code = true,
                provider = "default", -- default|telescope
              },
            },
            ["file"] = {
              callback = "helpers.slash_commands.file",
              description = "Share a file's contents with the LLM",
              opts = {
                contains_code = true,
                max_lines = 1000,
                provider = "mini_pick", -- telescope
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
        agent = {
          adapter = "anthropic",
        },
      },
      display = {
        chat = {
          show_settings = false,
        },
        inline = {
          -- If the inline prompt creates a new buffer, how should we display this?
          layout = "buffer", -- vertical|horizontal|buffer
          diff = {
            enabled = false,
            close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
            layout = "vertical", -- vertical|horizontal
            opts = {
              "internal",
              "filler",
              "closeoff",
              "algorithm:patience",
              "followwrap",
              "linematch:120",
            },
          },
        },
      },
    },
  },
}
