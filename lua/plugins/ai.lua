if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "Exafunction/codeium.nvim",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = { "InsertEnter" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- cmd = "Codeium",
    build = ":Codeium Auth",
    opts = {
      enable_chat = true,
      enable_local_search = true,
      enable_index_service = true,
    },
  },

  {
    "sourcegraph/sg.nvim",
    enabled = function()
      return not vim.b.bigfile
    end,
    event = { "LspAttach", "InsertEnter" },
    cmd = "CodyToggle",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = { enable_cody = true },
  },

  -- add this to the file where you setup your other plugins:
  {
    "monkoose/neocodeium",
    cond = not vim.g.vscode,
    event = "BufReadPost",
    config = function()
      local neocodeium = require("neocodeium")
      local map = vim.keymap.set
      neocodeium.setup({
        silent = true,
        filetypes = {
          sh = false,
          env = false,
        },
      })

      map("i", "<C-y>", neocodeium.accept)
      map("i", "<C-e>", neocodeium.accept)
      map("i", "<M-l>", neocodeium.accept_line)
      map("i", "<M-w>", neocodeium.accept_word)
      map("i", "<M-c>", neocodeium.clear)
      map("i", "<M-]>", neocodeium.cycle_or_complete)
      map("i", "<M-[>", function()
        neocodeium.cycle_or_complete(-1)
      end)
    end,
  },

  -- TODO: try this one
  {
    "supermaven-inc/supermaven-nvim",
    cond = not vim.g.vscode,
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup({
        -- keymaps = {
        --   accept_suggestion = "<C-y>",
        --   clear_suggestion = "<C-]>",
        --   accept_word = "<C-i>",
        -- },
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      })
    end,
  },

  { -- JUST for Chat option
    "Exafunction/codeium.vim",
    cond = not vim.g.vscode,
    enabled = function()
      return not vim.b.bigfile
    end,
    -- event = { "BufReadPost", "InsertEnter" },
    cmd = "Codeium",
    config = function()
      vim.g.codeium_disable_bindings = 1
      -- stylua: ignore start
      -- vim.keymap.set("i", "<C-y>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
      vim.keymap.set("n", "<M-t>", function() return vim.fn["codeium#Chat"]() end, { expr = true, silent = true })
      -- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
      -- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
      -- NOTE: here duble 2 C-e will hide cmp and show the suggestions
      -- vim.keymap.set("i", "<C-e>", function() return vim.fn["codeium#Complete"]() end, { expr = true, silent = true })
      -- stylua: ignore end
      vim.g.codeium_filetypes = {
        text = false, -- for password files like `pass`
      }
    end,
  },
}
