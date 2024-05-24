local M = {}
local opt = vim.opt

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
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smarttab = true

-- o.smartindent = true
-- o.softtabstop = 2
opt.shiftround = true -- Round indent
-- opt.list = true
vim.opt.listchars:append({
  trail = "·",
})

-- tab = " ",
-- tab         = "   ",
-- leadmultispace = "│ ", -- this caused problems
-- multispace  = "│ ",
-- tab = "│ ",
-- space = "⋅",
opt.statuscolumn = [[%!v:lua.require'utils'.statuscolumn()]]

-- Save undo history.
opt.undofile = true
opt.undolevels = 10000
-- Cursor settings
opt.cursorline = true

opt.guicursor = {
  "n-v:block-Cursor/lCursor",
  "i-c-ci-ve:blinkoff500-blinkon1000-block-TermCursor",
}
if not vim.g.neovide then
  -- it has a bug with
  opt.inccommand = "split" -- split window for substitute - nice to have
end
-- view and session options
opt.viewoptions = "cursor,folds"
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"
-- clipoboard
-- opt.clipboard:append("unnamedplus")
opt.showbreak = "↪ "

-- UI characters.
opt.fillchars:append({
  -- foldopen = "",
  -- foldclose = "",
  -- fold = "⸱",
  -- fold = " ",
  -- foldsep = " ",
  diff = "╱",
  eob = " ",
})

-- opt.splitkeep = "screen"
opt.laststatus = 3
opt.pumheight = 10 -- Maximum number of entries in a popup
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
-- opt.foldmethod = "indent"
-- opt.foldtext = "v:lua.require'utils'.foldtext()"
opt.smoothscroll = true
opt.foldtext = 'v:lua.require("utils").simple_fold()'

-- backsapace
-- opt.backspace = "indent,eol,start"

-- format respect list
-- opt.formatoptions:append("n")
opt.formatoptions = "jcroqlnt" -- tcqj
-- this drove me crzy - it controll how vertical movement behave when tab is used

if not vim.g.vscode then
  opt.scrolloff = 4
  opt.showmode = false
end

-- Disable health checks for these providers.
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

if vim.g.neovide then
  -- vim.o.guifont = "Iosevka Comfy:h15:w1" -- text below applies for VimScript
  vim.g.neovide_transparency = 1
  -- vim.g.neovide_window_blurred = true
  vim.g.neovide_input_macos_option_key_is_meta = "both"
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
