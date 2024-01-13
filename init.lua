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
require("core.options").initial()
require("core.lazy")
-- require("core.options").final()
require("core.keymaps")
require("core.autcommands")
pcall(require, "core.mystatusline")
-- if vim.g.vscode ~= nil then
-- 	require("core.vscode")
-- end
