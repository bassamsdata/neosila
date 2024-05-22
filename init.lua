vim.loader.enable()
require("core.options")
require("core.autcommands")
require("core.lazy")
require("core.keymaps")
require("core.intro")
require("core.mystatusline")

if vim.g.vscode ~= nil then
  require("core.vscode")
end
