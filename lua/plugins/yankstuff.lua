return {
  {
    "bassamsdata/loopyankDraft",
    -- lazy = true,
    event = "VeryLazy",
    dev = true,
    config = function()
      local loopyank = require("loopyank")
      loopyank.setup({
        -- Optional: override default configuration
        max_history = 100,
        save_persistent = true,
        cycle_keys = {
          forward = "<leader>n",
          backward = "<leader>p",
        },
        debug = true,
      })
    end,
  },
  {
    "hrsh7th/nvim-pasta",
    lazy = true,
    -- event = "VeryLazy",
    config = function()
      vim.keymap.set({ "n", "x" }, "p", require("pasta.mapping").p)
      vim.keymap.set({ "n", "x" }, "P", require("pasta.mapping").P)
      local pasta = require("pasta")
      pasta.config.next_key = vim.keycode("<C-p>")
      pasta.config.prev_key = vim.keycode("<C-n>")
      pasta.config.indent_key = vim.keycode(",")
      pasta.config.indent_fix = true
    end,
  },
  {
    "bfredl/nvim-miniyank",
    -- event = "VeryLazy",
    lazy = true,
    -- stylua: ignore start
    keys = {
      {
        "p",
        function()
          local ok, mc = pcall(require, "multicursor.nvim")
          if not ok or not mc.hasCursors() then
              -- stylua: ignore start
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes( "<Plug>(miniyank-autoput)", true, true, true), "n", false)
            -- stylua: ignore end
          else
            vim.cmd("normal! p")
          end
        end,
        desc = "autoput with miniyank",
      },
      {
        "P",
        "<plug>(miniyank-autoPut)",
        mode = "",
        desc = "autoput with miniyank",
      },
      { "<leader>n", "<Plug>(miniyank-cycle)", desc = "cycle through yanks" },
      { "<leader>p", "<Plug>(miniyank-cycle)", desc = "cycle through yanks" },
    },
    -- stylua: ignore end
    -- event = { "TextYankPost" },
  },
  {
    "gbprod/yanky.nvim",
    -- event = "VeryLazy",
    lazy = true,
    config = function()
      vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
      vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

      vim.keymap.set("n", "<leader>p", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<leader>n", "<Plug>(YankyNextEntry)")
      require("yanky").setup({
        highlight_group = "IncSearch",
        ring = {
          history_length = 10,
          storage = "shada",
          -- storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db", -- Only for sqlite storage
          -- sync_with_numbered_registers = true,
          cancel_event = "move",
          ignore_registers = { "_" },
          update_register_on_cycle = false,
        },
        system_clipboard = {
          sync_with_ring = true,
          clipboard_register = nil,
        },
        highlight = {
          on_put = true,
          off_yank = false,
          timer = 200,
        },
        preserve_cursor_position = {
          enabled = false,
        },
        textobj = {
          enabled = false,
        },
      })
    end,
  },
}
