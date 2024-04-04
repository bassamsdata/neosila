if vim.loader then
	vim.loader.enable()
end
require("core.options")
require("core.keymaps")
require("core.lazy")
require("core.intro")
require("core.autcommands")
if vim.fn.has("nvim-0.10") == 1 then -- remove this when stable
	pcall(require, "core.mystatusline")
end

if vim.g.vscode ~= nil then
	require("core.vscode")
end
