if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "echasnovski/mini-git",
    cmd = "Git",
    config = function()
      require("mini.git").setup({})
    end,
  },
  {
    "NeogitOrg/neogit",
    -- branch = "nightly",
    cmd = "Neogit",
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" } },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      disable_signs = false,
      disable_context_highlighting = true,
      disable_commit_confirmation = false,
      kind = "vsplit",
      signs = {
        -- { CLOSED, OPENED }
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
      integrations = { diffview = true },
      commit_editor = {
        kind = "split",
      },
      commit_select_view = {
        kind = "tab",
      },
      commit_view = {
        kind = "split",
      },
      popup = {
        kind = "split",
      },
      status = {
        recent_commit_count = 20,
      },
      mappings = {
        -- modify status buffer mappings
        status = {
          -- Adds a mapping with "B" as key that does the "BranchPopup" command
          -- ["B"] = "BranchPopup",
          -- ["C"] = "CommitPopup",
          -- ["P"] = "PullPopup",
          -- ["S"] = "Stage",
          -- ["D"] = "Discard",
          -- Removes the default mapping of "s"
          -- ["s"] = "",
        },
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    enabled = function()
      return not vim.b.bigfile
    end,
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    opts = {
      view = {
        use_icons = true,
        default = {
          -- layout = "diff2_horizontal",
          winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
        },
      },
    },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview [O]pen" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Diffview [C]lose" },
    },
  },

  {
    "echasnovski/mini.diff",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    keys = {
      {
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "▎",
          change = "▎",
          delete = "",
        },
      },
    },
  },
}
