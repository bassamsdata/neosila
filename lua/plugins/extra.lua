if vim.env.NVIM_TESTING then
  return {}
end
return {
  { "folke/trouble.nvim", opts = {} },
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    -- priority = 1000,
    config = function()
      local palette = require("nordic.colors")
      require("nordic").load()
      require("nordic").setup({
        override = {
          MatchParen = {
            fg = palette.yellow.dim,
            italic = false,
            underline = false,
            undercurl = false,
          },
          ["@parameter"] = {
            fg = palette.white_alt,
            italic = false,
            underline = false,
            undercurl = false,
          },
          Search = {
            fg = palette.yellow.dim,
            bg = palette.black0,
            italic = false,
            underline = false,
            undercurl = false,
          },
        },
      })
    end,
  },

  {
    "vague2k/vague.nvim",
    config = function()
      require("vague").setup({
        -- optional configuration here
      })
    end,
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {
        "<leader>-",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory",
      },
    },
    opts = {},
    -- Optional dependencies
    dependencies = { "echasnovski/mini.icons" },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  {
    "echasnovski/mini.ai",
    enabled = function()
      return not vim.b.bigfile
    end,

    event = "BufReadPost",
    opts = function()
      local ai = require("mini.ai")
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          i = gen_ai_spec.indent(),
          g = gen_ai_spec.buffer(),
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
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
      vim.keymap.set("n",  "<C-p>", function() require("hover").hover_switch("previous") end, { desc = "hover.nvim (previous source)" })
      vim.keymap.set("n",  "<C-n>", function() require("hover").hover_switch("next") end,     { desc = "hover.nvim (next source)" })
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

  {
    "glacambre/firenvim",
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
  },

  { "lewis6991/whatthejump.nvim", keys = { "<C-o>", "<C-i>", "<Backspace>" } },

  {
    "wildfunctions/myeyeshurt",
    event = "VeryLazy",
    opts = {
      initialFlakes = 5,
      flakeOdds = 20,
      maxFlakes = 750,
      nextFrameDelay = 175,
      useDefaultKeymaps = false,
      flake = { "*", "󰜗", "." },
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

  -- {
  --  "b0o/incline.nvim",
  --  cond = not vim.g.vscode or not vim.b.bigfile,
  --  event = "BufReadPost",
  --  -- lazy = true,
  --  opts = {
  --    hide = {
  --      cursorline = "focused_win",
  --      focused_win = false,
  --      only_win = true,
  --    },
  --    render = function(props)
  --      local filename =
  --        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  --      local modified = vim.bo[props.buf].modified
  --      return {
  --        filename,
  --        modified and { " ", guifg = "#d67c8e", gui = "bold" } or "",
  --        -- guibg = "#111111",
  --        -- guifg = "#eeeeee",
  --      }
  --    end,
  --  },
  -- },

  {
    "bfredl/nvim-miniyank",
    -- stylua: ignore start
    keys = {
      { "p", "<plug>(miniyank-autoput)", mode = "", desc = "autoput with miniyank", },
      { "P", "<plug>(miniyank-autoPut)", mode = "", desc = "autoput with miniyank", },
    },
    -- stylua: ignore end
    event = { "TextYankPost" },
  },

  {
    "kawre/neotab.nvim",
    cond = not vim.g.vscode or not vim.b.bigfile,
    event = "InsertEnter",
    opts = {},
  },

  { "laytan/cloak.nvim", cmd = "CloakToggle", ft = "sh", opts = {} },
}
