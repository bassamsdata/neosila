-- if vim.env.NVIM_TESTING then
--   return {}
-- end
return {
  {
    "echasnovski/mini.icons",
    opts = {
      lsp = {
        ellipsis_char = { glyph = "… ", hl = "MiniIconsRed" },
        copilot = { glyph = "", hl = "MiniIconsOrange" },
        supermaven = { glyph = "", hl = "MiniIconsYellow" },
        codeium = { glyph = "", hl = "MiniIconsGreen" },
        otter = { glyph = " ", hl = "MiniIconsCyan" },
        cody = { glyph = "", hl = "MiniIconsAzure" },
        cmp_r = { glyph = "󰟔 ", hl = "MiniIconsBlue" },
        ["function"] = { glyph = "", hl = "MiniIconsAzure" },
      },
    },
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
}
