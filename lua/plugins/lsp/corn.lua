return {
	"RaafatTurki/corn.nvim",
	event = "LspAttach",
	config = function()
		-- disable virtual text diags
		vim.diagnostic.config({ virtual_text = false })

		require("corn").setup({
			-- auto_cmds = false,
			sort_method = "column",
			-- scope = 'file',
			icons = {
				error = " ",
				warn = " ",
				hint = "󰠠 ",
				info = " ",
			},
			-- TODO: due Sat 07 Jan 2024 either make a pr for shifting down the win when corn win covers the lines
			-- or make this if statments that if the diagnostics are on lines 1-4, do truncatsion
			-- item_preprocess_func = function(item)
			-- 	return item
			-- end,

			-- on_toggle = function(is_hidden)
			-- toggle virtual_text diags back on when corn is off and vise versa
			-- vim.diagnostic.config({
			-- 	virtual_text = not vim.diagnostic.config().virtual_text,
			-- })
			-- end,
		})
		local function augroup(name)
			return vim.api.nvim_create_augroup("sila_" .. name, { clear = true })
		end
		-- diagnostic_off when in insert or select mode
		vim.api.nvim_create_autocmd("ModeChanged", {
			group = augroup("diagnostic_off"),
			pattern = { "n:i", "v:s", "n:V", "n:" },
			desc = "Disable diagnostics in insert and select mode",
			callback = function(e)
				-- vim.diagnostic.disable(e.buf)
				require("corn").toggle("off")
			end,
		})

		-- diagnostic_on when back in normal mode
		vim.api.nvim_create_autocmd("ModeChanged", {
			group = augroup("diagnostic_on"),
			pattern = { "i:n", "v:n", ":n" },
			desc = "Enable diagnostics when leaving insert mode",
			callback = function(e)
				vim.diagnostic.enable(e.buf)
				require("corn").toggle("on")
			end,
		})
	end,
}
