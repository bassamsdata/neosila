if vim.env.NVIM_TESTING then
  return {}
end
return {
  "otavioschwanck/arrow.nvim",
  event = "BufReadPost",
  cmd = "Arrow open",
  keys = {
    { "<C-,>" },
    { "m" },
    { "," },
  },
  config = function()
    vim.g.arrow_enabled = true
    require("arrow").setup({
      show_icons = true,
      leader_key = ",",
      buffer_leader_key = "m", -- Per Buffer Mappings
      separate_save_and_remove = true, -- if true, will remove the toggle and create the save/remove keymaps.
      always_show_path = true,
      window = {
        border = "rounded",
      },
    })
  end,
}
