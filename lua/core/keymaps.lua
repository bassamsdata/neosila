local map = vim.keymap.set
local M = {}
local U = require("utils")

-- ── love section ──────────────────────────────────────────────────────
-- LOVE: I love these mappings. **They are fun**
map("x", "/", "<Esc>/\\%V") --search within visual selection - this is magic
-- Replace all instances of highlighted words
map(
	"v",
	"<leader>r",
	'"hy:%s/<C-r>h//g<left><left>',
	{ desc = "Replace all instances" }
)
-- open grep directly and then open quickfix with the results
map("n", "<localleader>g", U.grepandopen, { desc = "Grep and open quickfix" })
-- motions -- I really didn't know about such amazing keymaps `:h omap-info`
-- entire buffer (https://vi.stackexchange.com/a/2321)
-- like you can do `daa` to delete entire buffer, `yaa` to yank entire buffer
map("o", "aa", ":<c-u>normal! mzggVG<cr>`z")

map("n", "<C-t>", U.swapBooleanInLine, { desc = "swap boolean" })
map("n", "<up>", "<cmd>lua vim.cmd('norm! 4')<cr>", { desc = "enhance jk" })
map("n", "<down>", "<cmd>lua vim.cmd('norm! 4')<cr>", { desc = "enhance jk" })

map("n", "<C-c>", "<cmd>normal! ciw<cr>a")

map(
	"n",
	"<localleader>m",
	U.messages_to_quickfix,
	{ desc = ":Messages to quickfix" }
)

map("n", "<localleader>d", function()
	return ":e " .. vim.fn.expand("%:p:h") .. "/"
end, { expr = true }) -- NOTE: here ths **expr** is so important

-- ── Misc ──────────────────────────────────────────────────────────────
-- stylua: ignore start
map("n",   "x",     '"_x') -- delete single character without copying into register
map("n",   "§§",    "<cmd>cclose<cr>") -- close quickfix with §§
map("n",   "gt",    "gg") -- Go top of the page
map("n",   "gb",    "G") -- Go bottom of the page
map("i",   "<C-l>", "<C-x><C-l>")-- Complete line -- didn't work
-- map({ "n", "i",     "!", "v" }, "§", "<esc>")
-- stylua: ignore end

-- HACK: this is to insert the fukking hashtag sign in neovim in conjunction
-- with this keymap in wezterm { key = "1", mods = "OPT", action = act.SendKey({ key = "1", mods = "ALT" }) }
map("i", "<A-1>", "#")
map("n", "<A-t>", "<cmd>split | terminal<cr>")

-- ── Clear search with <esc> ───────────────────────────────────────────
map("n", "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" }) -- Open the package manager lazy

-- Keeping the cursor centered when cycling search results
-- map("n", "n", "nzzzv", { desc = "Next result" })
-- map("n", "N", "Nzzzv", { desc = "Previous result" })

-- TODO: Change the the mappings of vim-visual-multi
-- ── page shift ────────────────────────────────────────────────────────
map("n", "<C-Up>", "<C-y>k", { desc = "Shift page up one line" })
map("n", "<C-Down>", "<C-e>j", { desc = "Shift page down one line" })

-- ── better indenting ──────────────────────────────────────────────────
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ── Move to window using the <ctrl> hjkl keys ─────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- ── Resize window using <ctrl> arrow keys ─────────────────────────────
-- stylua: ignore start
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize +2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize -2<cr>", { desc = "Increase window width" })

-- Buffers
map("n", "L",              "<cmd>bn<cr>") -- switch to next buffer
map("n", "H",              "<cmd>bp<cr>") -- switch to previous buffer
-- stylua: ignore end

-- Make U opposite to u.
map("n", "U", "<C-r>", { desc = "Redo" })

-- TODO: check if this is correct before apply
-- Execute macro over a visual region.
-- map('x', '@', function()
--     return ':norm @' .. vim.fn.getcharstr() .. '<cr>'
-- end, { expr = true })

-- Word navigation in non-normal modes.
map({ "i", "c" }, "<C-h>", "<C-Left>", { desc = "Move word(s) backwards" })
map("c", "<C-l>", "<C-Right>", { desc = "Move word(s) forwards" })

-- Move Lines
map("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

map("x", "y", "ygv<ESC>") -- preserve cursor position on visual yank
map("n", "==", "==_") -- move cursor to the start of the line on format
map("x", "=", "=gv_")
map("n", "J", "J_") -- go to end after a join
-- TODO: replace it with treesj plugin
map("n", "S", "T hr<CR>k$") -- split (opposite of J)
-- Add undo break-points
-- map("i", ",", ", <c-g>u") -- caused some problems
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

map(
	"n",
	"<leader>K",
	"<cmd>execute 'help ' . expand('<cword>')<cr>",
	{ desc = "help for under cursor" }
)
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- ┌                                                         ┐
-- │ ── Mini Modules                                         │
-- │ ──────────────────────────────────────────────────────  │
-- └                                                         ┘
-- stylua: ignore start
map("n", "<leader>ff",      "<cmd>Pick frecency<cr>",                 { desc = "Find [F]iles" })
map("n", "<leader><space>", "<cmd>Pick files<cr>",                    { desc = "Find [F]iles" })
map("n", "<leader>fg",      "<cmd>Pick grep_live<cr>",                { desc = "Find [G]rep_live" })
map("n", "<leader>fo",      "<cmd>Pick oldfiles<cr>",                 { desc = "Find [O]ld files" })
map("n", "<leader>fr",      "<cmd>Pick resume<cr>",                   { desc = "Find [R]esume" })
map("n", "<leader>fh",      "<cmd>Pick help<cr>",                     { desc = "Find [H]elp" })
map("n", "<leader>fk",      "<cmd>Pick keymaps<cr>",                  { desc = "Find [K]eymaps" })
map("n", "<leader>b",       "<cmd>Pick buffers<cr>",                  { desc = "Find [B]uffers" })
map("n", "<leader>fk",      "<cmd>Pick keymaps<cr>",                  { desc = "Find [K]eymaps" })
map("n", "<leader>fh",      "<cmd>Pick hl_groups<cr>",                { desc = "Find [H]ighlights" })
map("n", "<leader>fc",      "<cmd>Pick history scope=':'<cr>",        { desc = "Find [C]ommands" })
map("n", "<leader>fs",      "<cmd>Pick history scope='/'<cr>",        { desc = "Find [S]earch" })
map("n", "<leader>gk",      "<cmd>Pick git_hunks<cr>",                { desc = "Git Hun[k]s" })
map("n", "<leader>gs",      "<cmd>Pick git_hunks scope='staged'<cr>", { desc = "Git [S]taged" })
-- stylua: ignore end

-- I got this from reddit - wow, look how simple it is
M.mini_files_key = {
	{
		"<leader>e",
		function()
			-- added this just to open the mini.files at the current file location
			local bufname = vim.api.nvim_buf_get_name(0)
			local _ = require("mini.files").close()
				or require("mini.files").open(bufname, false)
		end,
		{ desc = "File explorer" },
	},
}

-- credit to @MariaSolOs
-- Use dressing (or mini.pick) for spelling suggestions.
map("n", "z=", function()
	vim.ui.select(
		vim.fn.spellsuggest(vim.fn.expand("<cword>")),
		{},
		vim.schedule_wrap(function(selected)
			if selected then
				vim.cmd("normal! ciw" .. selected)
			end
		end)
	)
end, { desc = "Spelling suggestions" })

-- ── clean registers ───────────────────────────────────────────────────
local function clear_registers()
	local registers =
		'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
	for register in registers:gmatch(".") do
		vim.fn.setreg(register, {})
	end
end
map("n", "<leader>rg", clear_registers, { desc = "Clear registers" })

-- ── Abbreviations ─────────────────────────────────────────────────────
vim.keymap.set("!a", "sis", "stylua: ignore start")
vim.keymap.set("!a", "sie", "stylua: ignore end")

return M
