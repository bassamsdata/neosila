require("core.options")
require("core.autcommands")
require("core.lazy")
require("core.intro")
require("core.keymaps")
require("core.mystatusline")
-- TODO: MOVE all handmade modules to localModules
require("localModules.nvterminal")
require("core.commands")

vim.api.nvim_create_autocmd("BufReadPost", {
  once = true,
  callback = function()
    require("localModules.newcodediff").setup({
      revert_delay = 5 * 60 * 1000, -- 5 minutes, adjust as needed
    })
  end,
})

if vim.g.vscode ~= nil then
  require("core.vscode")
end
