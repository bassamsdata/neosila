return {
	{
		"Exafunction/codeium.nvim",
		enabled = function()
			return not vim.b.bigfile
		end,
		event = { "InsertEnter" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- cmd = "Codeium",
		build = ":Codeium Auth",
		opts = {
			enable_chat = true,
			enable_local_search = true,
			enable_index_service = true,
		},
	},
	{
		"sourcegraph/sg.nvim",
		enabled = function()
			return not vim.b.bigfile
		end,
		event = { "LspAttach", "InsertEnter" },
		cmd = "CodyToggle",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = { enable_cody = true },
	},

	{
		"Exafunction/codeium.vim",
		cond = not vim.g.vscode,
		enabled = function()
			return not vim.b.bigfile
		end,
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
