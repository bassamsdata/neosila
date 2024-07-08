-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.tabstop = 2
-- vim.opt.shiftwidth             =  2
-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
-- vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

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
