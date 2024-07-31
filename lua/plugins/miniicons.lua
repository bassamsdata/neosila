-- if vim.env.NVIM_TESTING then
--   return {}
-- end
return {
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
        require("mini.icons").tweak_lsp_kind()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
