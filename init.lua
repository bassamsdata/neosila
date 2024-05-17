vim.loader.enable()
require("core.options")
require("core.autcommands")
require("core.lazy")
require("core.keymaps")
require("core.intro")
if vim.fn.has("nvim-0.10") == 1 then -- remove this when stable
	pcall(require, "core.mystatusline")
end

if vim.g.vscode ~= nil then
	require("core.vscode")
end
