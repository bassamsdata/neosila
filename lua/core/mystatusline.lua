-- Statusline setup
_G.statusline = {}

--- Thanks to MariaSolOs for this hilight function
--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
local function get_or_create_hl(hl)
  local hl_name = "Statusline" .. hl

  if not statusline_hls[hl] then
    -- If not in the cache, create the highlight group using the icon's foreground color
    -- and the statusline's background color.
    local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
    local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
    vim.api.nvim_set_hl(
      0,
      hl_name,
      { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) }
    )
    statusline_hls[hl] = true
  end

  return hl_name
end

-- Function to get the current mode text
-- stylua: ignore start
local function get_mode()
	local modes = {
		["n"]      = "NO",
		["no"]     = "OP",
		["nov"]    = "OC",
		["noV"]    = "OL",
		["no\x16"] = "OB",
		["nt"]     = "NT",
		["ntT"]    = "TM",
		["v"]      = "VI",
		[""]     = "I",
		["V"]      = "VL",
		["s"]      = "SE",
		["S"]      = "SL",
		["\x13"]   = "SB",
		["i"]      = "IN",
		["ic"]     = "IC",
		["ix"]     = "IX",
		["R"]      = "RE",
		["Rc"]     = "RC",
		["Rx"]     = "RX",
		["Rv"]     = "RV",
		["Rvc"]    = "RC",
		["Rvx"]    = "RX",
		["c"]      = "CO",
		["cv"]     = "CV",
		["r"]      = "PR",
		["rm"]     = "PM",
		["r?"]     = "P?",
		["!"]      = "SH",
		["t"]      = "TE",
	}
  -- stylua: ignore end 
  local hl = vim.bo.mod and 'StatusLineHeaderModified' or 'StatusLineHeader'
	return string.format(
		"%%#%s# %s",
		hl,
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
	local cwd = vim.fn.getcwd() -- Get the current working directory{{{
	local modified = vim.bo.modified and "  " or ""-- }}}

	-- Calculate the relative path by removing the CWD from the full path
	local relative_path = file:gsub(cwd .. "/", "")
  vim.b.filename_statusline = relative_path

	-- If the file is directly inside the CWD, show only the file name
	if relative_path == file then
		relative_path = vim.fn.expand("%:t")
	end

	return string.format("%%#StatusLineFile# %s%%#StatusLineModified#%s ", relative_path, modified)
end

---@return string
local function get_git_status()
	local minidiff = vim.b.minidiff_summary
  local branch_name = vim.b.git_branch and "  " .. vim.b.git_branch or ""
	if not minidiff then
		return string.format(
			"%%#StatusLineGitBranch#%s ",
			branch_name
		)
	 end
    -- this is a modfified logic from NvChad statusline ui (thank you) to show only if > 0.
    -- stylua: ignore start
    local added   = minidiff.add and minidiff.add       ~= 0 and string.format("%%#StatusLineGitAdded# +%d",   minidiff.add) or ""
    local changed = minidiff.change and minidiff.change ~= 0 and string.format("%%#StatusLineGitChanged# ~%d", minidiff.change) or ""
    local removed = minidiff.delete and minidiff.delete ~= 0 and string.format("%%#StatusLineGitRemoved# -%d", minidiff.delete) or ""
		-- stylua: ignore end
		return string.format(
			"%%#StatusLineGitBranch#%s %s%s%s",
			branch_name,
			added,
			changed,
			removed
		)
end


-- Function to get the LSP status
local function get_lsp_status()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		---@diagnostic disable-next-line: undefined-field
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, vim.bo.filetype) ~= -1 then
			return " [" .. client.name .. "]"
		end
	end
	return ""
end

-- Function to get the line and column info
local function get_line_info()
	-- local line = vim.fn.line(".")
	local column = vim.fn.col(".")
	local total_lines = vim.fn.line("$")
	-- local percent = math.floor((line / total_lines) * 100) .. tostring("%%")
	return string.format(
		" %%#StatusLinePosition#%d/%d ",
		column,
		-- line,
		total_lines
		-- percent
	)
end

-- Function to get the file type
-- SUG: change this to only icon
local function get_filetype()
    -- local special_icons = {
    --     DiffviewFileHistory = {  'Number' },
    --     DiffviewFiles = {  'Number' },
    --     DressingInput = { '󰍩', 'Comment' },
    --     DressingSelect = { '', 'Comment' },
    --     OverseerForm = { '󰦬', 'Special' },
    --     OverseerList = { '󰦬', 'Special' },
    --     ['ccc-ui'] = { '', 'Comment' },
    --     dapui_breakpoints = {  'DapUIRestart' },
    --     dapui_scopes = {  'DapUIRestart' },
    --     dapui_stacks = {  'DapUIRestart' },
    --     fzf = { '', 'Special' },
    --     gitcommit = {  'Number' },
    --     gitrebase = {  'Number' },
    --     lazy = {  'Special' },
    --     lazyterm = { '', 'Special' },
    --     minifiles = {  'Directory' },
    --     qf = {  'Conditional' },
    --     spectre_panel = {  'Constant' },
    -- }

    -- local filetype = vim.bo.filetype
    -- if filetype == '' then
    --     filetype = '[No Name]'
    -- end

    -- local icon, icon_hl
    -- if special_icons[filetype] then
    --     icon, icon_hl = unpack(special_icons[filetype])
    --   end
    -- icon_hl = get_or_create_hl(icon_hl)

    -- return string.format('%%#%s#%s %%#StatuslineTitle#%s', icon_hl, icon, filetype)
	return string.format(" %%#StatusLineFiletype#%s ", vim.bo.filetype:upper())
end

-- Function to get diagnostics count
-- Function to get diagnostics count with improved efficiency
-- TODO: use vim.diagnostic.count() when it is stable
local function get_diagnostics()
  if not vim.diagnostic.is_enabled() then
  return ""
  end
	local diagnostics = vim.diagnostic.get(0)
	local counts = { 0, 0, 0, 0 }

	for _, d in ipairs(diagnostics) do
		counts[d.severity] = (counts[d.severity] or 0) + 1
	end

	local result = {}
	local severities = { "Error", "Warn", "Info", "Hint" }
	local icons = { " ", " ", " ", " " } -- Replace with your preferred icons

	for i, severity in ipairs(severities) do
		if counts[i] > 0 then
			table.insert(
				result,
				string.format(
					"%%#StatusLineDiagnostic%s#%s %d",
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

local function arrow_not()
	-- Check if arrow.nvim is loaded
	if vim.g.arrow_enabled == nil then
		return ""
	end
	-- local current_file = vim.fn.expand("%")
  local current_file = vim.b.filename_statusline
	local arrow_files = vim.g.arrow_filenames
	-- Check if current file is in the Arrow list
	local file_in_arrow = false
	for _, filename in ipairs(arrow_files) do
		if filename == current_file then
			file_in_arrow = true
			break -- Found it, no need to continue the loop
		end
	end

	if not file_in_arrow then
		return ""
	end -- Only proceed if file is in the list
	local total_items = #arrow_files

	if total_items == 0 then
		return ""
	end

	local icon = { "󱡁 " }
  for index = 1, math.min(total_items, 3) do -- Iterate up to a maximum of 3 (whatever is less)
    local hl
    if arrow_files[index] == current_file then
      hl = "StatusLineArrow"
    else
      hl = "StatusLine"
    end

    table.insert(icon, string.format("%%#%s#%d", hl, index))
  end

  return table.concat(icon, "")
end

-- Setup the statusline
function statusline.active()
	return table.concat({
		get_mode(),
		get_cwd(),
		get_git_status(),
    " %<",
		"%=",
		get_filename(),
    "%<",
		"%=",
		arrow_not(),
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
