if vim.env.NVIM_TESTING then
  return {}
end
return {
  {
    "stevearc/quicker.nvim",
    ft = { "qf" },
    ---@module "quicker"
    opts = {},
  },
}
