-- this protected require function borrowed from venom https://github.com/RaafatTurki/venom/
-- local util = require("utils")
--
-- function Prequire(name)
-- 	local ok, var = pcall(require, name)
-- 	if ok then
-- 		return var
-- 	else
-- 		util.custom_notify(name .. " has an issue, please check :)", "Warn")
-- 		return nil
-- 	end
-- end

if vim.loader then
	vim.loader.enable()
end
require("core.options")
require("core.keymaps")
require("core.lazy")
require("core.autcommands")
-- require("core.intro2").open()
if vim.fn.has("nvim-0.10") == 1 then -- remove this when stable
	pcall(require, "core.mystatusline")
end

if vim.g.vscode ~= nil then
	require("core.vscode")
end
