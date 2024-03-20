return {
	{
		"Exafunction/codeium.nvim",
		event = { "InsertEnter" },
		cond = not vim.g.vscode or not vim.b.bigfile,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- cmd = "Codeium",
		build = ":Codeium Auth",
		opts = {},
	},
	{
		"sourcegraph/sg.nvim",
		cond = not vim.g.vscode or not vim.b.bigfile,
		event = { "LspAttach", "InsertEnter" },
		cmd = "CodyToggle",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = { enable_cody = true },
	},

	{
		"Exafunction/codeium.vim",
		cond = not vim.g.vscode or not vim.b.bigfile,
		event = { "BufReadPost", "InsertEnter" },
		config = function()
			vim.g.codeium_enabled = true
      -- stylua: ignore start 
			vim.keymap.set("i", "<C-y>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
			-- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
			-- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
			-- NOTE: here duble 2 C-e will hide cmp and show the suggestions
			vim.keymap.set("i", "<C-e>", function() return vim.fn["codeium#Complete"]() end, { expr = true, silent = true })
			-- stylua: ignore end
			vim.g.codeium_filetypes = {
				text = false, -- for password files like `pass`
			}
		end,
	},
}
