return {
  {
    "2kabhishek/nerdy.nvim",
    dependencies = { "echasnovski/mini.pick" },
    cmd = "Nerdy",
  },

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
    "otavioschwanck/arrow.nvim",
    event = "BufReadPost",
    cmd = "Arrow open",
    keys = {
      { "<tab>" },
      { "," },
    },
    config = function()
      vim.g.arrow_enabled = true
      require("arrow").setup({
        show_icons = true,
        leader_key = "<tab>",
        buffer_leader_key = ",", -- Per Buffer Mappings
        separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
        always_show_path = true,
        window = {
          border = "rounded",
        },
      })
    end,
  },

  {
    "NStefan002/15puzzle.nvim",
    cmd = "Play15puzzle",
    config = true,
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  {
    "brenoprata10/nvim-highlight-colors",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = "BufReadPost",
    opts = {
      render = "virtual",
      virtual_symbol = "",
    },
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
    "sam4llis/nvim-tundra",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local hlgroups = {
        TermCursor = { fg = "#111827", bg = "#fca5a5" },
        MiniIndentscopeSymbol = { link = "Whitespace" },
      }

      for hlgroup_name, hlgroup_attr in pairs(hlgroups) do
        vim.api.nvim_set_hl(0, hlgroup_name, hlgroup_attr)
      end
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
    "MeanderingProgrammer/markdown.nvim",
    ft = { "markdown", "rmd", "quarto" },
    name = "render-markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  {
    "cbochs/portal.nvim",
    cmd = "Portal",
    opts = {},
  },

  -- {
  --  "Aityz/usage.nvim",
  --  event = "BufReadPost",
  --  config = function()
  --    require("usage").setup()
  --  end,
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
