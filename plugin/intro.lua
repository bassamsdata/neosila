-- Disable default intro message
vim.opt.shortmess:append("I")

local logo = [[
         .▄▄ · ▪  ▄▄▌   ▄▄▄·    󰲓     Z
 󰩖     ▐█ ▀. ██ ██•  ▐█ ▀█      Z    
         ▄▀▀▀█▄▐█·██▪  ▄█▀▀█   z       
         ▐█▄▪▐█▐█▌▐█▌▐▌▐█ ▪▐ z         
          ▀▀▀▀ ▀▀▀.▀▀▀  ▀  ▀           
]]

local copyright = "Copyright (c) 2023 - developers"

local function createLineTable(line)
	local width = vim.fn.strdisplaywidth(line)
	return {
		chunks = {
			{
				text = line,
				hl = "Normal",
				len = #line,
				width = width,
			},
		},
	}
end

local lines = {}
for _, line in ipairs(vim.split(logo, "\n")) do -- split the logo into lines
	table.insert(lines, createLineTable(line))
end
table.insert(lines, createLineTable(copyright))

-- ... rest of the code ...
-- ... rest of the code ...

---Window configuration for the intro message floating window
local win_config = {
	width = 0,
	height = #lines,
	relative = "editor",
	style = "minimal",
	focusable = false,
	noautocmd = true,
	zindex = 1,
}

-- Calculate the width, offset, concatenated text, etc.
local widths = {} -- Store the widths of all lines
for i, line in ipairs(lines) do
	line.text = ""
	line.width = 0
	for _, chunk in ipairs(line.chunks) do
		line.text = line.text .. chunk.text
		line.width = line.width + chunk.width
	end
	widths[i] = line.width -- Store the width of the current line
end

-- Find the maximum width
win_config.width = math.max(unpack(widths)) -- Use math.max and unpack to find the maximum value

for _, line in ipairs(lines) do
	line.offset = math.floor((win_config.width - line.width) / 2)
end

-- Decide the row and col offset of the floating window,
-- return if no enough space
win_config.row = math.floor((vim.go.lines - vim.go.ch - win_config.height) / 2)
win_config.col = math.floor((vim.go.columns - win_config.width) / 2)
if win_config.row < 4 or win_config.col < 8 then
	return
end

-- Create the scratch buffer to display the intro message
-- Set eventignore to avoid triggering plugin lazy-loading handlers
local eventignore = vim.go.eventignore
vim.opt.eventignore:append({
	"BufNew",
	"OptionSet",
	"TextChanged",
	"BufModifiedSet",
})

local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].bufhidden = "wipe"
vim.bo[buf].buftype = "nofile"
vim.bo[buf].swapfile = false

-- Create a StringBuilder
local sb = {}

-- Add lines to the StringBuilder
for _, line in ipairs(lines) do
	table.insert(sb, string.rep(" ", line.offset) .. line.text)
end
-- Convert the StringBuilder to a string
local intro_message = table.concat(sb, "\n")
-- Convert the StringBuilder to a string
local intro_lines = vim.split(intro_message, "\n")

-- Set the lines in the buffer
vim.api.nvim_buf_set_lines(buf, 0, -1, false, intro_lines)

vim.go.eventignore = eventignore

-- Apply highlight groups
local ns = vim.api.nvim_create_namespace("NvimIntro")
for linenr, line in ipairs(lines) do
	local chunk_offset = line.offset
	for _, chunk in ipairs(line.chunks) do
		vim.highlight.range(
			buf,
			ns,
			chunk.hl,
			{ linenr - 1, chunk_offset },
			{ linenr - 1, chunk_offset + chunk.len },
			{}
		)
		chunk_offset = chunk_offset + chunk.len
	end
end

-- Open the window to show the intro message
local win = vim.api.nvim_open_win(buf, true, win_config)
vim.wo[win].winhl = "NormalFloat:Normal"

-- Clear the intro when the user does something
vim.api.nvim_create_autocmd({
	"BufModifiedSet",
	"BufReadPre",
	"StdinReadPre",
	"InsertEnter",
	"TermOpen",
	"TextChanged",
	"VimResized",
	"WinEnter",
}, {
	once = true,
	group = vim.api.nvim_create_augroup("NvimIntro", {}),
	callback = function(info)
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		vim.api.nvim_del_augroup_by_id(info.group)
		return true
	end,
})
