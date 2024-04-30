local M = {}
local opt = vim.opt -- for concisenes

vim.cmd([[
function! Grep(...)
	return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
	autocmd!
	autocmd QuickFixCmdPost cgetexpr cwindow
	autocmd QuickFixCmdPost lgetexpr lwindow
augroup END
]])

-- set leader key to space
vim.g.mapleader = " "
-- Set <\> as the local leader key - it gives me a whole new set of letters.
vim.g.maplocalleader = "\\" -- we need to escabe \ with another \

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

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
	opt.guicursor = "a:block-Cursor/lCursor,v:block,i:ver25-TermCursor"
	-- it has a bug with neovide currently
	opt.inccommand = "split" -- split window for substitute - nice to have
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
--spli windows
opt.splitright = true
opt.splitbelow = true
-- search settings
opt.ignorecase = true
opt.smartcase = true
if vim.env.VSCODE then
	vim.g.vscode = true
end

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
-- opt.foldlevel = 999
-- opt.foldtext = "v:lua.require'utils'.foldtext()"
if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
	-- vim.opt.foldmethod = "expr"
	vim.opt.foldtext = 'v:lua.require("utils").simple_fold()'
	-- vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"
	-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	-- else
	--vim.opt.foldmethod = "indent"
end
-- set this: vim.opt.foldtext = 'v:lua.require("essentials").simple_fold()'

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
	-- vim.o.guifont = "Iosevka Comfy:h15:w1" -- text below applies for VimScript
	vim.g.neovide_transparency = 1
	vim.g.neovide_input_macos_alt_is_meta = true
	vim.g.neovide_cursor_animation_length = 0.1
	-- vim.g.neovide_scroll_animation_length = 0.15
	vim.g.neovide_cursor_trail_size = 0.2
	vim.g.neovide_cursor_antialiasing = false
	-- vim.g.neovide_cursor_animate_in_insert_mode = true
	vim.opt.linespace = 10 -- 8 was nice for commit font
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_padding_right = 0
	vim.g.neovide_padding_left = 0
end

-- Thanks to Bekaboo for this https://github.com/Bekaboo/nvim
---Lazy-load runtime files
local g = vim.g
---@param runtime string
---@param flag string
---@param event string|string[]
local function _load(runtime, flag, event)
	if not g[flag] then
		g[flag] = 0
		vim.api.nvim_create_autocmd(event, {
			once = true,
			callback = function()
				g[flag] = nil
				vim.cmd.runtime(runtime)
				return true
			end,
		})
	end
end

_load("plugin/rplugin.vim", "loaded_remote_plugins", "FileType")
_load("provider/python3.vim", "loaded_python3_provider", "FileType")
_load("plugin/matchit.vim", "loaded_matchit", "FileType")

return M
