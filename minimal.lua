vim.api.nvim_create_autocmd('CursorMoved', {
	callback = function()
		vim.opt.winhl:append('Foo:Bar') -- has bug
                -- vim.opt.spell = true -- has bug
                -- vim.opt.shiftwidth = 4 -- no bug
	end
})
