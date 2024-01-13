-- ensure the colorscheme is loaded so we do not see erorrs
local colorscheme = "cockatoo"
---@diagnostic disable-next-line: param-type-mismatch
local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- TODO: remove this from the options file
vim.o.background = "dark" -- or "light" for light mode
if not ok then
	-- Set a default colorscheme.
	vim.cmd.colorscheme("habamax")
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end
