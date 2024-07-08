if vim.env.NVIM_TESTING then
  return {}
end
return {
  -- build themes
  { "rktjmp/lush.nvim", cmd = { "LushRunTutorial", "LushImport" } },
  -- { "echasnovski/mini.base16", opts = {} },
}
