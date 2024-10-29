if vim.env.NVIM_TESTING then
  return {}
end

return {
  {
    "nvchad/showkeys",
    cmd = "ShowkeysToggle",
    opts = {
      timeout = 3,
      maxkeys = 5,
      position = "bottom-right",
    },
  },
  {
    "frankroeder/parrot.nvim",
    cmd = { "PrtChatToggle", "PrtRewrite", "PrtAsk", "PrtAsk" },
    tag = "v0.3.9",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          pplx = {
            api_key = os.getenv("PERPLEXITY_API_KEY"),
            -- OPTIONAL
            -- gpg command
            -- api_key = { "gpg", "--decrypt", vim.fn.expand("$HOME") .. "/pplx_api_key.txt.gpg"  },
            -- macOS security tool
            -- api_key = { "/usr/bin/security", "find-generic-password", "-s pplx-api-key", "-w" },
          },
          openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
          },
          anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },
          mistral = {
            api_key = os.getenv("MISTRAL_API_KEY"),
          },
          gemini = {
            api_key = os.getenv("GEMINI_API_KEY"),
          },
          ollama = {}, -- provide an empty list to make provider available
        },
      })
    end,
  },

  {

    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      default_mappings = false,
      mappings = {
        i = {
          j = {
            -- These can all also be functions
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        c = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        t = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        s = {
          j = {
            k = "<Esc>",
          },
        },
      },
    },
  },
  {
    "2kabhishek/nerdy.nvim",
    dependencies = { "echasnovski/mini.pick" },
    cmd = "Nerdy",
  },

  -- somewhere in your config:
  -- { "RayenMnif/tgpt.nvim", opts = {} },
  {
    "andymass/vim-matchup",
    event = { "BufReadPost" },
    config = function()
      vim.api.nvim_set_hl(
        0,
        "OffScreenPopup",
        { fg = "#fe8019", bg = "#181e2c", italic = true }
      )
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",

        highlight = "OffScreenPopup",
      }
    end,
  },

  {
    "lewis6991/hover.nvim",
    event = "BufReadPost",
    config = function()
      require("hover").setup({
        init = function()
          -- Require providers
          require("hover.providers.lsp")
          -- require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          -- require('hover.providers.dap')
          require("hover.providers.man")
          require("hover.providers.dictionary")
        end,
        preview_opts = {
          border = "rounded",
          max_width = 80,
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
        mouse_providers = {
          "LSP",
        },
        mouse_delay = 1000,
      })

      -- stylua: ignore start
      vim.keymap.set("n",  "K",  require("hover").hover,        { desc = "hover.nvim" })
      vim.keymap.set( "n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
      -- vim.keymap.set("n",  "<C-p>", function() require("hover").hover_switch("previous") end, { desc = "hover.nvim (previous source)" })
      -- vim.keymap.set("n",  "<C-n>", function() require("hover").hover_switch("next") end,     { desc = "hover.nvim (next source)" })
      -- stylua: ignore end

      -- Mouse support
      vim.keymap.set(
        "n",
        "<MouseMove>",
        require("hover").hover_mouse,
        { desc = "hover.nvim (mouse)" }
      )
      vim.o.mousemoveevent = true
    end,
  },

  { "lewis6991/whatthejump.nvim", keys = { "<C-o>", "<C-i>", "<Backspace>" } },

  {
    "wildfunctions/myeyeshurt",
    event = "VeryLazy",
    opts = {
      initialFlakes = 10,
      flakeOdds = 20,
      maxFlakes = 750,
      nextFrameDelay = 175,
      useDefaultKeymaps = false,
      flake = { "󰼪 ", "󰜗 ", "" },
      minutesUntilRest = 20,
    },
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  {
    "VidocqH/lsp-lens.nvim",
    cmd = { "LspLensToggle", "LspLensOn" },
    config = function()
      local SymbolKind = vim.lsp.protocol.SymbolKind
      require("lsp-lens").setup({
        target_symbol_kinds = {
          SymbolKind.Function,
          SymbolKind.Method,
          SymbolKind.Interface,
          SymbolKind.Class,
          SymbolKind.Struct,
        },
      })
    end,
  },

  {
    "kawre/neotab.nvim",
    cond = not vim.g.vscode or not vim.b.bigfile,
    event = "InsertEnter",
    opts = {},
  },

  { "laytan/cloak.nvim", cmd = "CloakToggle", ft = "sh", opts = {} },
}
