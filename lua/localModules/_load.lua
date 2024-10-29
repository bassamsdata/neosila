-- local group = vim.api.nvim_create_augroup("lsp_signature", { clear = true })
--
-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = group,
--   pattern = "*",
--   callback = function()
--     require("localModules.lspSignature").setup()
--   end,
-- })
--
require("localModules.nvterminal")
require("localModules.floating")
require("localModules.runner").setup()
