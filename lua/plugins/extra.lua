if vim.env.NVIM_TESTING then
  return {}
end
return {
  -- lua with lazy.nvim
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {},
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
      -- TODO: need to change the statusline higlights
      -- change minidiff amd minimap colors
      groups = {
        all = {
          NormalFloat = { link = "Normal" },
        },
        -- orignial colors
        -- hi Normal guifg=#cdcecf guibg=#2e3440
        -- hi NormalFloat guifg=#cdcecf guibg=#232831
      },
    },
  },
  {
    "2kabhishek/nerdy.nvim",
    dependencies = { "echasnovski/mini.pick" },
    cmd = "Nerdy",
  },

  {
    "chrisgrieser/nvim-rip-substitute",
    keys = {
      {
        "<leader>sf",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
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
    "sho-87/kanagawa-paper.nvim",
    lazy = false,
    priority = 500,
    opts = {},
  },

  { "catppuccin/nvim", name = "catppuccin", event = "VeryLazy" },
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
    "otavioschwanck/arrow.nvim",
    event = "BufReadPost",
    cmd = "Arrow open",
    keys = {
      { "<C-,>" },
      { "," },
    },
    config = function()
      vim.g.arrow_enabled = true
      require("arrow").setup({
        show_icons = true,
        leader_key = "<C-,>",
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
    "echasnovski/mini.icons",
    opts = {},
    lazy = true,
    -- specs = {
    --   { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    -- },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        -- needed since it will be false when loading and mini will fail
        -- package.loaded["nvim-web-devicons"] = {}
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
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
