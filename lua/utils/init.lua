local M = {}

function M.custom_notify(message, level)
	local levels = {
		DEBUG = 1,
		ERROR = 4,
		INFO = 2,
		OFF = 5,
		TRACE = 0,
		WARN = 3,
	}
	local highlight = {
		[levels.ERROR] = "ErrorMsg",
		[levels.WARN] = "WarningMsg",
		[levels.INFO] = "None",
		[levels.DEBUG] = "Comment",
	}
	local style = {
		[levels.ERROR] = "✗",
		[levels.WARN] = "⚠",
		[levels.INFO] = "ℹ",
		[levels.DEBUG] = "☰",
	}
	-- Check if level is a string or a number
	local levelValue = type(level) == "number" and level or levels[level]
	local icon = style[levelValue] or "ℹ"
	local hl = highlight[levelValue] or "None"
	vim.notify(icon .. ": " .. message, levelValue, { highlight = hl })
end

local swap_pairs = {
	{ "true", "false" },
	{ "1", "0" },
	{ "foo", "bar" },
	{ "TRUE", "FALSE" },
	{ "True", "False" },
	{ "fg", "bg" },
}

function M.swapBooleanInLine()
	local line = vim.api.nvim_get_current_line()
	for _, pair in ipairs(swap_pairs) do
		local a, b = unpack(pair)
		if line:find(a) then
			line = line:gsub(a, b)
			break
		elseif line:find(b) then
			line = line:gsub(b, a)
			break
		end
	end
	vim.api.nvim_set_current_line(line)
end

M.file_path = vim.fn.stdpath("config") .. "/plugin/colorswitch.lua"

function M.replace_word(old, new)
	local file, err = io.open(M.file_path, "r")
	if not file then
		vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
		return
	end
	local content = file:read("*all")
	file:close()
	-- TODO: vim.g.colors_name only output the first word - try to implemtnt vim.fn.getcompletion('', 'color')
	-- local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
	local new_content = content:gsub(old, new)
	file, err = io.open(M.file_path, "w")
	if not file then
		vim.notify("Failed to open file for writing: " .. err, vim.log.levels.ERROR)
		return
	end
	file:write(new_content)
	file:close()
end

-- idea taken from MariaSolOs:
-- https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/commands.lua#L36
-- Define GxHandler function
function M.gxhandler()
	local file = vim.fn.expand("<cfile>")
	-- Consider anything that looks like string/string a GitHub link.
	local link = file:match("%w[%w%-]+/[%w%-%._]+")
	if link then
		vim.fn.system("open https://www.github.com/" .. link)
	else
		vim.notify("Failed to open link: " .. file, vim.log.levels.ERROR)
	end
end

function M.gxdotfyle()
	local file = vim.fn.expand("<cfile>")
	-- Consider anything that looks like string/string a GitHub link.
	local link = file:match("%w[%w%-]+/[%w%-%._]+")
	if link then
		vim.fn.system("open https://www.dotfyle.com/plugins/" .. link)
	else
		vim.notify("Failed to open link: " .. file, vim.log.levels.ERROR)
	end
end

-- TODO: move all of these to a separate file and autocmd file
-- Utility function to perform checks
local function is_valid_git_repo(buf_id)
	-- Check if it's a valid buffer
	local path = vim.api.nvim_buf_get_name(buf_id)
	if path == "" or vim.fn.filereadable(path) ~= 1 then
		return false
	end

	-- Check if the current directory is a Git repository
	if vim.fn.isdirectory(".git") == 0 then
		return false
	end

	return true
end

local branch_cache = {}

-- Function to clear the Git branch cache
local function clear_git_branch_cache()
	-- Clear by doing an empty table :)
	branch_cache = {}
end

-- Autocommand to clear the Git branch cache when the directory changes
vim.api.nvim_create_autocmd("DirChanged", {
	callback = clear_git_branch_cache,
})

local function update_git_branch(data)
	if not is_valid_git_repo(data.buf) then
		return
	end

	-- Check if branch is already cached
	local cached_branch = branch_cache[data.buf]
	if cached_branch then
		vim.b.git_branch = cached_branch
		return
	end

	local stdout = vim.uv.new_pipe(false)
	local handle, pid
	handle, pid = vim.uv.spawn(
		"git",
		{
			args = { "-C", vim.fn.expand("%:p:h"), "branch", "--show-current" },
			stdio = { nil, stdout, nil },
		},
		vim.schedule_wrap(function(code, signal)
			if code == 0 then
				stdout:read_start(function(err, content)
					if content then
						vim.b.git_branch = content:gsub("\n", "") -- Remove newline character
						branch_cache[data.buf] = vim.b.git_branch -- Cache the branch name
						stdout:close()
					end
				end)
			else
				stdout:close()
			end
		end)
	)
end

-- Call this function when the buffer is opened in a window
vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = update_git_branch,
})

function M.diff_with_clipboard()
	local ftype = vim.api.nvim_get_option_value("filetype", {})
	local cmd = string.format(
		[[
    normal! "xy
    vsplit
    enew
    normal! P
    setlocal buftype=nowrite
    set filetype=%s
    diffthis
    normal! \<C-w>\<C-w>
    enew
    set filetype=%s
    normal! "xP
    diffthis
  ]],
		ftype,
		ftype
	)
	vim.api.nvim_exec2(cmd, {})
end

function M.messages_to_quickfix()
	-- Execute :messages command and capture output
	local messages = vim.fn.execute("messages")
	-- Split the output into lines
	local lines = vim.split(messages, "\n")
	-- Create a table of dictionaries for the quickfix list
	local qf_items = {}
	for _, line in ipairs(lines) do
		-- Trim leading and trailing whitespace
		local trimmed_line = line:gsub("^%s*(.-)%s*$", "%1")
		-- Skip if the line is empty
		if trimmed_line ~= "" then
			table.insert(qf_items, { text = trimmed_line })
		end
	end
	-- Set the quickfix list
	vim.fn.setqflist(qf_items, "r")
	vim.cmd.copen()
	vim.cmd("$")
end

---Read file contents
---@param path string
---@return string?
function M.read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content or ""
end

-- TODO: organize that
function M.grepandopen()
	vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
		if pattern ~= nil then
			vim.cmd("silent grep! " .. pattern)
			vim.cmd("copen")
		end
	end)
end

function M.helpgrepnopen()
	vim.ui.input({ prompt = "Enter pattern: " }, function(pattern)
		if pattern ~= nil then
			vim.cmd("silent helpgrep " .. pattern)
			vim.cmd("copen")
		end
	end)
end
vim.keymap.set("n", "<leader>ug", M.helpgrepnopen)

--This code below regarding statuscolumn was borrowed from LazyVim.
--credit to folke/LazyVim https://github.com/LazyVim/LazyVim
-- TODO: use the statuscolumn plugin.
-- Returns a list of regular and extmark signs sorted by priority (low to high)
-- -@return Sign[]
---@param buf number
---@param lnum number
function M.get_signs(buf, lnum)
	-- Get regular signs
	local signs = {}

	if vim.fn.has("nvim-0.10") == 0 then
		-- Only needed for Neovim <0.10
		-- Newer versions include legacy signs in nvim_buf_get_extmarks
		for _, sign in
			ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs)
		do
			local ret = vim.fn.sign_getdefined(sign.name)[1]
			if ret then
				ret.priority = sign.priority
				signs[#signs + 1] = ret
			end
		end
	end

	-- Get extmark signs
	local extmarks = vim.api.nvim_buf_get_extmarks(
		buf,
		-1,
		{ lnum - 1, 0 },
		{ lnum - 1, -1 },
		{ details = true, type = "sign" }
	)
	for _, extmark in pairs(extmarks) do
		signs[#signs + 1] = {
			name = extmark[4].sign_hl_group or "",
			text = extmark[4].sign_text,
			texthl = extmark[4].sign_hl_group,
			priority = extmark[4].priority,
		}
	end

	-- Sort by priority
	table.sort(signs, function(a, b)
		return (a.priority or 0) < (b.priority or 0)
	end)

	return signs
end

function M.get_mark(buf, lnum)
	local marks = vim.fn.getmarklist(buf)
	vim.list_extend(marks, vim.fn.getmarklist())
	for _, mark in ipairs(marks) do
		if
			mark.pos[1] == buf
			and mark.pos[2] == lnum
			and mark.mark:match("[a-zA-Z]")
		then
			return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
		end
	end
end

-- -@param sign? Sign
---@param len? number
function M.icon(sign, len)
	sign = sign or {}
	len = len or 2
	local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
	text = text .. string.rep(" ", len - vim.fn.strchars(text))
	return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

-- TODO: change the icons
function M.foldtext()
	local start_line = vim.api.nvim_buf_get_lines(
		0,
		vim.v.foldstart - 1,
		vim.v.foldstart,
		false
	)[1]
	local end_line =
		vim.api.nvim_buf_get_lines(0, vim.v.foldend - 1, vim.v.foldend, false)[1]

	-- Replace tabs with spaces
	start_line = start_line:gsub("\t", string.rep(" ", vim.bo.tabstop))

	-- Trim whitespace
	end_line = end_line:gsub("^%s*(.-)%s*$", "%1")

	return start_line .. " ... " .. end_line
end

-- function M.foldtext()
-- 	local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
-- 	local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
-- 	if not ret or type(ret) == "string" then
-- 		ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
-- 	end
-- 	table.insert(ret, { " " .. "󰇘" })
--
-- 	if not vim.treesitter.foldtext then
-- 		return table.concat(
-- 			vim.tbl_map(function(line)
-- 				return line[1]
-- 			end, ret),
-- 			" "
-- 		)
-- 	end
-- 	return ret
-- end

function M.statuscolumn()
	local win = vim.g.statusline_winid
	local buf = vim.api.nvim_win_get_buf(win)
	local is_file = vim.bo[buf].buftype == ""
	local show_signs = vim.wo[win].signcolumn ~= "no"

	local components = { "", "", "" } -- left, middle, right

	if show_signs then
		-- -@type Sign?,Sign?,Sign?
		local left, right, fold
		for _, s in ipairs(M.get_signs(buf, vim.v.lnum)) do
			if s.name and s.name:find("GitSign") then
				right = s
			else
				left = s
			end
		end
		if vim.v.virtnum ~= 0 then
			left = nil
		end
		vim.api.nvim_win_call(win, function()
			if vim.fn.foldclosed(vim.v.lnum) >= 0 then
				fold = {
					text = vim.opt.fillchars:get().foldclose or "",
					texthl = "Folded",
				}
			end
		end)
		-- Left: mark or non-git sign
		components[1] = M.icon(M.get_mark(buf, vim.v.lnum) or left)
		-- Right: fold icon or git sign (only if file)
		components[3] = is_file and M.icon(fold or right) or ""
	end

	-- Numbers in Neovim are weird
	-- They show when either number or relativenumber is true
	local is_num = vim.wo[win].number
	local is_relnum = vim.wo[win].relativenumber
	if (is_num or is_relnum) and vim.v.virtnum == 0 then
		if vim.v.relnum == 0 then
			components[2] = is_num and "%l" or "%r" -- the current line
		else
			components[2] = is_relnum and "%r" or "%l" -- other lines
		end
		components[2] = "%=" .. components[2] .. " " -- right align
	end

	return table.concat(components, "")
end

-- Neovim Utils
--- returns current vim mode name
function M.get_mode_name()
	local mode_names = {
		n = "no",
		no = "n?",
		nov = "n?",
		noV = "n?",
		["no\22"] = "n?",
		niI = "ni",
		niR = "nr",
		niV = "nv",
		nt = "nt",
		v = "vi",
		vs = "vs",
		V = "v_",
		Vs = "vs",
		["\22"] = "^V",
		["\22s"] = "^V",
		s = "se",
		S = "s_",
		["\19"] = "^S",
		i = "in",
		ic = "ic",
		ix = "ix",
		R = "re",
		Rc = "rc",
		Rx = "rx",
		Rv = "rv",
		Rvc = "rv",
		Rvx = "rv",
		c = "co",
		cv = "ex",
		r = "..",
		rm = "m.",
		["r?"] = "??",
		["!"] = "!!",
		t = "te",
	}
	return mode_names[vim.api.nvim_get_mode().mode]
end

--- returns current vim mode highlight
function M.get_mode_hl()
	local mode_hls = {
		n = "NormalMode",
		i = "InsertMode",
		v = "VisualMode",
		V = "VisualMode",
		["\22"] = "VisualMode",
		c = "CommandMode",
		s = "SelectMode",
		S = "SelectMode",
		["\19"] = "SelectMode",
		R = "ControlMode",
		r = "ControlMode",
		["!"] = "NormalMode",
		t = "TerminalMode",
	}

	return mode_hls[vim.api.nvim_get_mode().mode]
end

return M
