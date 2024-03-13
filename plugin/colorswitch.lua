-- total rewrite version, thanks to Bekaboo "https://github.com/Bekaboo/nvim/blob/master/plugin/colorswitch.lua"
-- thanks to nvchad as well for the idea of dofile and replace_word

-- local M = {}
local color_scheme = {
	bg = "dark",
	colors_name = "original_cockatoo",
}

if color_scheme.bg ~= vim.go.bg then
	vim.go.bg = color_scheme.bg
end

if color_scheme.colors_name ~= vim.g.colors_name then
	vim.cmd.colorscheme({
		args = { color_scheme.colors_name },
		mods = { emsg_silent = true },
	})
end

vim.api.nvim_create_autocmd("Colorscheme", {
	group = vim.api.nvim_create_augroup("ColorSwitch", {}),
	desc = "Update color scheme on colorscheme change.",
	callback = function()
		local replace_word = require("utils").replace_word
		-- we can utilize dofile() here but this option is better
		local old = color_scheme
		vim.schedule(function()
			local new = vim.g.colors_name
			local n_bg = vim.go.bg
			if new ~= old.colors_name or n_bg ~= old.bg then
				replace_word(old.bg, n_bg)
				replace_word(old.colors_name, new)
				pcall(vim.system, { "setbg", vim.go.bg })
				pcall(vim.system, { "setcolor", vim.g.colors_name })
				color_scheme = {
					bg = n_bg,
					colors_name = new,
				}
			end
		end)
	end,
})

-- return M
