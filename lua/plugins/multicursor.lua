return {
  {
    "jake-stewart/multicursor.nvim",
    lazy = true,
    keys = { "<c-n>", "<c-p>", "<up>", "<down>" },
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      -- use MultiCursorCursor and MultiCursorVisual to customize
      -- additional cursors appearance
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "TermCursor" })
      vim.api.nvim_set_hl(
        0,
        "MultiCursorVisual",
        { link = "DiagnosticVirtualTextOk" }
      )

      vim.keymap.set("n", "<esc>", function()
        if mc.hasCursors() then
          mc.firstCursor()
          mc.clearCursors()
          vim.cmd.noh()
        else
          vim.cmd.noh()
        end
      end)

      -- stylua: ignore start 
      -- add cursors above/below the main cursor
      vim.keymap.set({ "n","v" },  "<up>",   function() mc.addCursor("k") end)
      vim.keymap.set({ "n","v" },  "<down>", function() mc.addCursor("j") end)
      -- add a cursor and jump to the next word under cursor
      vim.keymap.set({ "n","v" },  "<c-n>",  function() mc.addCursor("*") end)
      -- jump to the next word under cursor but do not add a cursor
      vim.keymap.set({ "n","v" },  "<c-s>",  function() mc.skipCursor("*") end)
      -- rotate the main cursor
      vim.keymap.set({"n", "v"},     "<left>",    mc.nextCursor)
      vim.keymap.set({"n", "v"},     "<right>",   mc.prevCursor)
      -- delete the main cursor
      vim.keymap.set({"n", "v"},     "<leader>x", mc.deleteCursor)
      -- add and remove cursors with control + left click
      vim.keymap.set("n",  "<c-leftmouse>", mc.handleMouse)
      -- stylua: ignore end
    end,
  },
}
