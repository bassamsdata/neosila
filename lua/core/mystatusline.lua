-- Statusline setup
_G.statusline = {}

-- Helper function to get the highlight for the current mode
-- TODO: there are modes needs to be added
local function mode_highlight()
	local mode_color = {
		n = "Normal",
		i = "Insert",
		v = "Visual",
		[""] = "VisualBlock",
		V = "VisualLine",
		c = "Command",
		no = "NormalOperatorPending",
		s = "Select",
		S = "SelectLine",
		[""] = "SelectBlock",
		ic = "InsertCompletion",
		R = "Replace",
		Rv = "VirtualReplace",
		cv = "VisualEx",
		ce = "NormalEx",
		r = "HitEnter",
		rm = "More",
		["r?"] = "Confirm",
		["!"] = "Shell",
		t = "Terminal",
	}
	local current_mode = vim.api.nvim_get_mode().mode
	return "StatusLineMode" .. (mode_color[current_mode] or "Normal")
end

-- Function to get the current mode text
local function get_mode()
	local modes = {
		n = "NO",
		i = "IN",
		v = "VI",
		[""] = "I",
		V = "VI_",
		c = "CO",
	}
	return string.format(
		"%%#%s# %s ",
		mode_highlight(),
		modes[vim.api.nvim_get_mode().mode] or "UNKNOWN"
	)
end

-- Function to get the current working directory name
local function get_cwd()
	return string.format(
		" %%<%%#StatusLinePath# %s ",
		vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	)
end

-- Function to get the current file path relative to CWD and modified status
local function get_filename()
	local file = vim.fn.expand("%:p") -- Get the full path of the current file
	local cwd = vim.fn.getcwd() -- Get the current working directory
	local modified = vim.bo.modified and "[+]" or ""

	-- Calculate the relative path by removing the CWD from the full path
	local relative_path = file:gsub(cwd .. "/", "")

	-- If the file is directly inside the CWD, show only the file name
	if relative_path == file then
		relative_path = vim.fn.expand("%:t")
	end

	return string.format("%%#StatusLineFile# %s%s ", relative_path, modified)
end

-- Function to get the Git branch and status
local function get_git_status()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
    -- this is a modfified logic from NvChad statusline ui (thank you) to show only if > 0.
    -- stylua: ignore start 
    local added   = gitsigns.added and gitsigns.added     ~= 0 and string.format("%%#StatusLineGitAdded# +%d",   gitsigns.added) or ""
    local changed = gitsigns.changed and gitsigns.changed ~= 0 and string.format("%%#StatusLineGitChanged# ~%d", gitsigns.changed) or ""
    local removed = gitsigns.removed and gitsigns.removed ~= 0 and string.format("%%#StatusLineGitRemoved# -%d", gitsigns.removed) or ""
		-- stylua: ignore end
		local branch_name = "  " .. gitsigns.head
		return string.format(
			"%%#StatusLineGitBranch#%s %s %s %s",
			branch_name,
			added,
			changed,
			removed
		)
	end
	return ""
end

-- Function to get the LSP status
local function get_lsp_status()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, vim.bo.filetype) ~= -1 then
			return "[" .. client.name .. "]"
		end
	end
	return ""
end

-- Function to get the line and column info
local function get_line_info()
	local line = vim.fn.line(".")
	local column = vim.fn.col(".")
	local total_lines = vim.fn.line("$")
	local percent = math.floor((line / total_lines) * 100) .. tostring("%%")
	return string.format(
		" %%#StatusLinePosition#%d:%d/%d %s",
		column,
		line,
		total_lines,
		percent
	)
end

-- Function to get the file type
local function get_filetype()
	return string.format(" %%#StatusLineFiletype#%s ", vim.bo.filetype:upper())
end

-- Function to get diagnostics count
-- Function to get diagnostics count with improved efficiency
-- TODO: use vim.diagnostic.count() when it is stable
local function get_diagnostics()
	local diagnostics = vim.diagnostic.get(0)
	local counts = { 0, 0, 0, 0 }

	for _, d in ipairs(diagnostics) do
		counts[d.severity] = (counts[d.severity] or 0) + 1
	end

	local result = {}
	local severities = { "Error", "Warn", "Info", "Hint" }
	local icons = { "", "", "", "" } -- Replace with your preferred icons

	for i, severity in ipairs(severities) do
		if counts[i] > 0 then
			table.insert(
				result,
				string.format(
					"%%#StatusLineDiagnostic%s#%s %d ",
					severity,
					icons[i],
					counts[i]
				)
			)
		end
	end

	return table.concat(result, " ")
end

-- Function to get word count for markdown files
local function get_word_count()
	if vim.bo.filetype == "markdown" then
		local word_count = vim.fn.wordcount().words
		return string.format(" %%#StatusLineWordCount#%d words ", word_count)
	end
	return ""
end

-- Setup the statusline
function statusline.active()
	return table.concat({
		get_mode(),
		get_cwd(),
		get_git_status(),
		"%=",
		get_filename(),
		"%=",
		get_diagnostics(),
		get_lsp_status(),
		get_filetype(),
		get_line_info(),
		get_word_count(),
	})
end

-- Set the statusline
vim.o.statusline = "%!v:lua.statusline.active()"

-- Define highlight groups
-- vim.cmd([[
--   highlight StatusLineModeNormal guifg=#ffffff guibg=#5f00af
--   highlight StatusLineModeInsert guifg=#ffffff guibg=#00af5f
--   highlight StatusLineModeVisual guifg=#ffffff guibg=#af5f00
--   highlight StatusLineModeVisualBlock guifg=#ffffff guibg=#af5f00
--   highlight StatusLineModeVisualLine guifg=#ffffff guibg=#af5f00
--   highlight StatusLineModeCommand guifg=#ffffff guibg=#af0000
--   highlight StatusLinePath guifg=#ffaf00 guibg=#005faf
--   highlight StatusLineFile guifg=#afd700 guibg=#005f87
--   highlight StatusLineGitBranch guifg=#ffaf00 guibg=#005f5f
--   highlight StatusLineGitAdded guifg=#87d700 guibg=#005f5f
--   highlight StatusLineGitChanged guifg=#d7af5f guibg=#005f5f
--   highlight StatusLineGitRemoved guifg=#d75f5f guibg=#005f5f
--   highlight StatusLineLsp guifg=#d7d7d7 guibg=#5f5f5f
--   highlight StatusLinePosition guifg=#d7d7d7 guibg=#5f5f5f
--   highlight StatusLineFiletype guifg=#d7d7d7 guibg=#5f5f5f
--   highlight StatusLineDiagnosticError guifg=#ff5f5f guibg=#5f5f5f
--   highlight StatusLineDiagnosticWarn guifg=#ffaf5f guibg=#5f5f5f
--   highlight StatusLineDiagnosticInfo guifg=#5fafff guibg=#5f5f5f
--   highlight StatusLineDiagnosticHint guifg=#5fd7af guibg=#5f5f5f
--   highlight StatusLineWordCount guifg=#afd7d7 guibg=#5f5f5f
-- ]])
