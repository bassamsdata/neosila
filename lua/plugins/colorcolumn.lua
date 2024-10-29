if vim.env.NVIM_TESTING then
  return {}
end
return {
  "Bekaboo/deadcolumn.nvim",
  -- dev = true,
  enabled = function()
    return not vim.b.bigfile
  end,
  ft = { "go", "r", "python", "v", "json", "yaml", "toml" },
  config = function()
    -- vim.opt.colorcolumn = "80"
    -- local opts = {
    --   enable_toggle = true,
    --   modes = { "i" }, -- add normal mode when this gets solved: https://github.com/neovim/neovim/issues/27470
    --   blending = {
    --     threshold = 0.75,
    --   },
    --   warning = {
    --     alpha = 0.1,
    --   },
    -- }
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "help",
    --   callback = function()
    --     vim.opt_local.colorcolumn = ""
    --   end,
    -- })
    -- require("deadcolumn").setup(opts)
  end,
}
