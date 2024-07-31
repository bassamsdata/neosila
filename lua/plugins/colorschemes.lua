return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    -- priority = 1000,
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
  { "catppuccin/nvim", name = "catppuccin", event = "VeryLazy" },
  {
    "sho-87/kanagawa-paper.nvim",
    lazy = false,
    -- priority = 500,
    opts = {},
  },
}
