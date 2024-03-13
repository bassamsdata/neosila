-- thanks to Bekaboo for this https://github.com/Bekaboo/nvim
vim.bo.buflisted = false
vim.opt_local.spell = false
vim.opt_local.rnu = false
vim.opt_local.signcolumn = "no"
vim.opt_local.statuscolumn = ""

-- stylua: ignore start
vim.keymap.set('n', '<Tab>', '<CR>zz<C-w>p',  { buffer = true })
vim.keymap.set('n', '<C-j>', 'j<CR>zz<C-w>p', { buffer = true })
vim.keymap.set('n', '<C-k>', 'k<CR>zz<C-w>p', { buffer = true })
vim.keymap.set('n', '<C-n>', 'j<CR>zz<C-w>p', { buffer = true })
vim.keymap.set('n', '<C-p>', 'k<CR>zz<C-w>p', { buffer = true })
-- stylua: ignore end
