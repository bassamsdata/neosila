local utils = require("utils")
local colors_file = string.format(vim.fn.stdpath("state") .. "colors.json")
-- 1. Restore dark/light background and colorscheme from json so that nvim
--    "remembers" the background and colorscheme when it is restarted.
-- 2. Spawn setbg/setcolors on colorscheme change to make other nvim instances
--    and system color consistent with the current nvim instance.

local saved = utils.read(colors_file)
saved.colors_name = saved.colors_name or "dragon"

if saved.bg and saved.bg ~= vim.go.bg then
	vim.go.bg = saved.bg
end

if saved.colors_name and saved.colors_name ~= vim.g.colors_name then
	vim.cmd.colorscheme({
		args = { saved.colors_name },
		mods = { emsg_silent = true },
	})
end

vim.api.nvim_create_autocmd("Colorscheme", {
	group = vim.api.nvim_create_augroup("ColorSwitch", {}),
	desc = "Spawn setbg/setcolors on colorscheme change.",
	callback = function()
		local data = utils.read(colors_file)
		if data.colors_name ~= vim.g.colors_name or data.bg ~= vim.go.bg then
			data.colors_name = vim.g.colors_name
			data.bg = vim.go.bg
			if not utils.write(colors_file, data) then
				return
			end
		end
	end,
})
