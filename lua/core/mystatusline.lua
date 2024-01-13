local git_add_color = vim.api.nvim_get_hl(0, { name = "GitSignsAdd" })
local git_change_color = vim.api.nvim_get_hl(0, { name = "GitSignsChange" })
local git_delete_color = vim.api.nvim_get_hl(0, { name = "GitSignsDelete" })
local statusline_color = vim.api.nvim_get_hl(0, { name = "StatusLine" })

git_add_color.background = statusline_color.background
git_change_color.background = statusline_color.background
git_delete_color.background = statusline_color.background
vim.api.nvim_set_hl(0, "StatusLineGitAdd", git_add_color)
vim.api.nvim_set_hl(0, "StatusLineGitChange", git_change_color)
vim.api.nvim_set_hl(0, "StatusLineGitDelete", git_delete_color)

local statusline_mode_color = {
	["bg"] = "white",
	["fg"] = "black",
	["bold"] = true,
}
vim.api.nvim_set_hl(0, "StatusLineNormal", statusline_mode_color)
statusline_mode_color.bg = "LightGreen"
vim.api.nvim_set_hl(0, "StatusLineInsert", statusline_mode_color)
statusline_mode_color.bg = "LightMagenta"
vim.api.nvim_set_hl(0, "StatusLineVisual", statusline_mode_color)
vim.api.nvim_set_hl(0, "StatusLineLsp", {
	["fg"] = "white",
	["bg"] = statusline_color.background,
})

local modes_map = {
	["n"] = "NORMAL",
	["i"] = "INSERT",
	["V"] = "V-LINE",
	[""] = "V-BLOCK",
	["c"] = "COMMAND",
}

local function get_mode_color()
	local current_mode = vim.api.nvim_get_mode().mode
	local mode_color = "%#StatusLineNormal#"
	if current_mode == "i" then
		mode_color = "%#StatusLineInsert#"
	elseif current_mode == "V" or current_mode == "" then
		mode_color = "%#StatusLineVisual#"
	end
	return mode_color
end

local function get_mode()
	local current_mode = vim.api.nvim_get_mode().mode
	return table.concat({
		get_mode_color(),
		" ",
		modes_map[current_mode] or "",
		" ",
		"%#StatusLine#",
	})
end

local function git_signs()
	local git_info = vim.b.gitsigns_status_dict
	if not git_info or git_info.head == "" then
		return ""
	end
	local added = git_info.added
			and ("%#StatusLineGitAdd#+" .. git_info.added .. " ")
		or ""
	local changed = git_info.changed
			and ("%#StatusLineGitChange#~" .. git_info.changed .. " ")
		or ""
	local removed = git_info.removed
			and ("%#StatusLineGitDelete#-" .. git_info.removed .. " ")
		or ""
	if git_info.added == 0 then
		added = ""
	end
	if git_info.changed == 0 then
		changed = ""
	end
	if git_info.removed == 0 then
		removed = ""
	end
	return table.concat({
		"[",
		" " .. git_info.head,
		"] ",
		added,
		changed,
		removed,
	})
end

local function get_lsp_clients()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, vim.bo.filetype) ~= -1 then
			return "[" .. client.name .. "]"
		end
	end
	return ""
end

local M = {}

M.global = function()
	local has_lsp_status, lsp_status = pcall(require, "lsp-status")
	return table.concat({
		get_mode(),
		" ",
		vim.fn.fnamemodify(vim.api.nvim_eval("getcwd()"), ":~"),
		" ",
		git_signs(),
		"%#StatusLine#%{'Line: '}%l/%L, %{'Col: '}%c",
		"%=",
		has_lsp_status and lsp_status.status() or "",
		" ",
		"%#StatusLineLsp#",
		get_lsp_clients(),
		" ",
	})
end

vim.o.statusline = "%!v:lua.require'core.mystatusline'.global()"

return M
