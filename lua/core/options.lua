local M = {}
local opt = vim.opt -- for concisenes

-- those for image.nvim to work
package.path = table.concat({
	package.path,
	vim.fs.normalize("~/.luarocks/share/lua/5.0/?/init.lua"),
	vim.fs.normalize("~/.luarocks/share/lua/5.1/?.lua"),
	vim.fs.normalize("~/.luarocks/share/lua/5.1/magick/init.lua"),
}, ";")
-- set leader key to space
vim.g.mapleader = " "
-- Set <\> as the local leader key - it gives me a whole new set of letters.
vim.g.maplocalleader = "\\" -- we need to escabe \ with another \

-- TODO: to seprate these options into 2 modules and then call the more
-- essential one and any additional options will be via pcall.
-- Reason: if I made a small mistake, nvim is totally mess my whole configs.

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- vim.filetype.add({
-- 	extension = {
-- 		psql = "sql",
-- 	},
-- })

-- line numbers
opt.relativenumber = true
opt.number = true

-- Enable mouse mode.
opt.mouse = "a"

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
-- opt.autoindent   = true
opt.shiftround = true -- Round indent
opt.statuscolumn = [[%!v:lua.require'utils'.statuscolumn()]]
-- Save undo history.
opt.undofile = true
opt.undolevels = 10000
-- Cursor settings
opt.cursorline = true

if not vim.g.neovide then
	opt.guicursor = "a:hor25-Cursor/lCursor,v:block,i:ver25-TermCursor"
end
-- view and session options
opt.viewoptions = "cursor,folds"
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"
-- clipoboard
opt.clipboard:append("unnamedplus")
opt.list = true
vim.opt.listchars:append({
	trail = "·",
	-- tab         = "   ",
	-- leadmultispace = "│ ", -- this caused problems
	-- multispace  = "│ ",
	tab = "│ ",
	-- space = "⋅",
})

-- vim.opt.listchars:append("tab:│ ")

-- if vim.fn.has("nvim-0.9") == 1 then
-- 	opt.statuscolumn = [[%!v:lua.require'utils'.statuscolumn()]]
-- end

-- UI characters.
opt.fillchars:append({
	foldopen = "",
	foldclose = "",
	-- fold = "⸱",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
})
-- opt.splitkeep = "screen"
opt.laststatus = 3
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.scrolloff = 8
opt.sidescrolloff = 4
opt.inccommand = "split" -- split window for substitute - nice to have
--spli windows
opt.splitright = true
opt.splitbelow = true
-- search settings
opt.ignorecase = true
opt.smartcase = true
if vim.env.VSCODE then
	vim.g.vscode = true
end
-- Use ripgrep for grepping.
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
-- Confirm to save changes before exiting modified buffer
opt.confirm = true
--line wrapping
opt.wrap = false
-- yank to Capital case register with reserving lines
opt.cpoptions:append(">")
-- completion
vim.opt.wildignore:append({ ".DS_Store" })
opt.conceallevel = 2 -- Hide * markup for bold and italic
opt.foldcolumn = "1"
opt.foldlevel = 99
-- opt.foldtext = "v:lua.require'utils'.foldtext()"
if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
	vim.opt.foldmethod = "expr"
	vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
else
	vim.opt.foldmethod = "indent"
end

-- backsapace
-- opt.backspace = "indent,eol,start"

-- opt.formatoptions = "jcroqlnt" -- tcqj
-- this drove me crzy - it controll how vertical movement behave when tab is used

if not vim.g.vscode then
	opt.showmode = false
end

--
-- Disable health checks for these providers.
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

if vim.g.neovide then
	vim.g.neovide_transparency = 1
	vim.g.neovide_input_macos_alt_is_meta = false
	vim.g.neovide_cursor_animation_length = 0.2
	vim.g.neovide_cursor_trail_size = 0.2
	vim.g.neovide_cursor_antialiasing = false
	vim.g.neovide_cursor_animate_in_insert_mode = true
	vim.opt.linespace = 8
end

--
return M
